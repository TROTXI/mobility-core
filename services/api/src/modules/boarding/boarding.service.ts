// BoardingService — issue a rider's rotating QR pass, verify a scan, debit the
// ride (#20, E4). Every scan is recorded for audit.
//
// Availability over strictness, like the rate limiter: the KV single-use check
// and the audit write both fail OPEN. A KV or DB blip must never stop a bus
// from boarding.

import { errors } from 'jose';
import type { KvStore } from '../../kv/kv.store';
import type { EntitlementLedgerRepository } from '../entitlements/entitlement-ledger.repository';
import type { DriverRepository } from '../mobility/driver.repository';
import type { TripRepository } from '../mobility/trip.repository';
import type {
  Reservation,
  ReservationDirection,
  ReservationRepository,
} from '../reservations/reservation.repository';
import { verifyPin as checkPin } from '../reservations/pin';
import { signPass, verifyPass, type IssuedPass } from './pass';
import type { ScanEventRepository, ScanMethod } from './scan-event.repository';

/** A driver's request to verify a scanned pass. */
export interface VerifyScanInput {
  /** The token decoded from the scanned QR. */
  pass: string;
  /** The driver performing the scan. */
  scannedBy: string;
  /** The trip being boarded, if known. */
  tripId?: string | null;
}

/** The outcome returned to the driver's app. */
export interface VerifyScanResult {
  valid: boolean;
  /** The rider the pass belongs to (null when invalid/forged). */
  riderId: string | null;
  reason: 'ok' | 'invalid' | 'expired' | 'reused';
  /** True when this scan consumed a ride (a confirmed reservation was boarded). */
  deducted: boolean;
}

/** A driver's request to board a rider via their daily PIN (verification layer 2). */
export interface VerifyPinInput {
  /** The reservation the driver picked off the manifest. */
  reservationId: string;
  /** The boarding code the rider presented, any case. */
  pin: string;
  /** The driver performing the verification. */
  scannedBy: string;
}

/** The outcome of a PIN verification. */
export interface VerifyPinResult {
  valid: boolean;
  riderId: string | null;
  reason: 'ok' | 'invalid' | 'not_found' | 'already_boarded' | 'forbidden';
  deducted: boolean;
}

/** A driver acting on one rider they picked off the manifest (#227). */
export interface ManifestActionInput {
  /** The reservation the driver tapped. */
  reservationId: string;
  /** The driver performing it. */
  actedBy: string;
}

/** The outcome of boarding a rider straight off the manifest. */
export interface BoardRiderResult {
  riderId: string | null;
  reason: 'ok' | 'not_found' | 'already_boarded' | 'not_boardable' | 'forbidden';
  deducted: boolean;
}

/** A driver typing a code with nobody picked first (#241). */
export interface VerifyCodeInput {
  /** The run being boarded. The code is only searched within it. */
  tripId: string;
  /** The code the rider read out, any case. */
  code: string;
  /** The driver performing it. */
  actedBy: string;
}

/** The outcome of boarding by code alone. */
export interface VerifyCodeResult {
  riderId: string | null;
  /**
   * `ambiguous` means two riders on this run hold the same code. Vanishingly
   * unlikely, and refused rather than guessed: picking one would spend the
   * wrong rider's ride.
   */
  reason: 'ok' | 'invalid' | 'already_boarded' | 'ambiguous' | 'forbidden' | 'not_found';
  deducted: boolean;
}

/** The outcome of marking one rider a no-show. */
export interface MarkNoShowResult {
  riderId: string | null;
  reason:
    'ok' | 'not_found' | 'already_boarded' | 'already_no_show' | 'not_boardable' | 'forbidden';
  deducted: boolean;
}

/**
 * The reservation states a driver may act on from the manifest.
 *
 * Both endpoints take a reservation id rather than something the manifest
 * handed back, so neither can assume the row is one the manifest would have
 * shown. Without this, an assigned driver could board a seat that was
 * `declined` or `released` — overfilling a van whose seat had been given up —
 * or debit a ride from a rider who correctly declined to travel.
 *
 * `no_show` is included because boarding one is the documented way to undo a
 * mark; `markNoShow` narrows further to `reserved` on its own.
 */
const MANIFEST_ACTIONABLE = ['reserved', 'boarded', 'no_show'] as const;

/**
 * Wrong codes tolerated per reservation per window before the rest are refused
 * unread. A driver retyping a smudged code at the kerb needs several goes; a
 * four-character alphabet does not survive thousands.
 */
const MAX_PIN_ATTEMPTS = 10;

/** How long that attempt budget lasts, in seconds. */
const PIN_ATTEMPT_WINDOW_SECONDS = 15 * 60;

/**
 * The same budget for the code-only path, where one attempt is checked against
 * every open seat on the run rather than one.
 *
 * Higher, because a driver boarding fifteen riders in a row will legitimately
 * mistype more than ten times across a whole run, and the ceiling is not what
 * makes this safe. What makes it safe is that the caller is already the run's
 * assigned driver — and an assigned driver can board any rider on their
 * manifest with no code at all (see boardRider). The code proves the RIDER is
 * who they say; it was never what stood between a driver and the manifest.
 */
const MAX_TRIP_CODE_ATTEMPTS = 30;

/** Collaborators for {@link BoardingService}, injected at app wiring. */
export interface BoardingServiceDeps {
  /** Append-only scan audit trail. */
  scanEvents: ScanEventRepository;
  /** Marks passes consumed (single-use); Redis in prod, in-memory in dev/tests. */
  kv: KvStore;
  /** Reservations — a valid scan boards the rider's confirmed seat. Optional:
   * when unwired, verification stays integrity-only (no deduction). */
  reservations?: ReservationRepository;
  /** Ride entitlement ledger — a boarded seat debits one ride. Optional (see above). */
  entitlements?: EntitlementLedgerRepository;
  /**
   * Trips + drivers, to check the scanner is the driver this run is assigned to
   * (#25's rule, applied to PIN boarding). Both must be wired for the check to
   * run; unwired leaves verification as it was.
   */
  trips?: TripRepository;
  drivers?: DriverRepository;
  /** Server signing key for passes (the JWT secret). */
  secret: string;
  /** Pass lifetime in seconds (short → the QR rotates). */
  passTtlSeconds: number;
}

// Today's date as `YYYY-MM-DD` (UTC), the day a scan boards against.
function todayISO(): string {
  return new Date().toISOString().slice(0, 10);
}

/** Boarding-pass issuance + scan verification (see the file header). */
export class BoardingService {
  /** @param deps - the scan-event repo, KV store, signing secret, and pass TTL. */
  constructor(private readonly deps: BoardingServiceDeps) {}

  /**
   * Issue a short-lived boarding pass for a rider.
   *
   * @param userId - the authenticated rider.
   * @returns the signed pass and its lifetime.
   */
  async issuePass(userId: string): Promise<IssuedPass> {
    return signPass(userId, this.deps.secret, this.deps.passTtlSeconds);
  }

  /**
   * Verify a scanned pass (integrity + single-use) and record the scan. A pass
   * already consumed by a previous valid scan returns `reason: 'reused'` — a
   * shared screenshot dies on the second scan, not just at the TTL.
   *
   * @param input - the scanned pass, the driver, and the trip.
   * @returns whether the pass is valid, the rider id, and the reason.
   */
  async verifyScan(input: VerifyScanInput): Promise<VerifyScanResult> {
    let riderId: string | null = null;
    let jti: string | null = null;
    let reason: VerifyScanResult['reason'] = 'invalid';
    try {
      ({ userId: riderId, jti } = await verifyPass(input.pass, this.deps.secret));
      reason = 'ok';
    } catch (err) {
      reason = err instanceof errors.JWTExpired ? 'expired' : 'invalid';
    }

    // Single-use: atomically count uses of this jti; >1 means the pass was
    // already consumed. Fails open — a KV outage must not block boarding (the
    // audit trail still records the duplicates for reconciliation).
    if (reason === 'ok' && jti) {
      try {
        // Key TTL slightly outlives the pass (TTL + clock tolerance).
        const uses = await this.deps.kv.increment(
          `pass:used:${jti}`,
          this.deps.passTtlSeconds + 10,
        );
        if (uses > 1) reason = 'reused';
      } catch (err) {
        console.warn('boarding: single-use check failed (KV unavailable); allowing scan', err);
      }
    }

    // A valid scan consumes the rider's confirmed reservation for today. Fails
    // OPEN — a hiccup here must not stop the bus; reconciliation catches any gap.
    let deducted = false;
    if (reason === 'ok' && riderId && this.deps.reservations && this.deps.entitlements) {
      try {
        const boardable = await this.deps.reservations.findBoardable(riderId, todayISO());
        if (boardable) deducted = await this.boardAndDebit(boardable);
      } catch (err) {
        console.error('boarding: ride deduction failed (allowed to board anyway)', err);
      }
    }

    await this.recordScan(riderId, input.scannedBy, input.tripId ?? null, reason, 'qr');
    return { valid: reason === 'ok', riderId, reason, deducted };
  }

  /**
   * Verification layer 2 — board a rider via the daily PIN the driver typed
   * against the manifest (offline-friendly when the QR can't be scanned). The
   * PIN only matches a `reserved` seat, and boarding is idempotent per
   * reservation, so a repeat returns `already_boarded` without a second debit.
   *
   * @param input - the reservation, the presented PIN, and the driver.
   * @returns whether the PIN boarded the seat, the rider id, and the reason.
   */
  async verifyPin(input: VerifyPinInput): Promise<VerifyPinResult> {
    if (!this.deps.reservations) {
      return { valid: false, riderId: null, reason: 'not_found', deducted: false };
    }
    const reservation = await this.deps.reservations.findById(input.reservationId);
    if (!reservation) {
      return { valid: false, riderId: null, reason: 'not_found', deducted: false };
    }
    // The manifest and GPS reporting both require the caller to be the driver
    // this run is assigned to; boarding by code did not, which left a four
    // character code as the only thing standing between any driver account and
    // any rider's seat on any trip in the fleet.
    if (!(await this.isAssignedDriver(input.scannedBy, reservation.tripId))) {
      return { valid: false, riderId: null, reason: 'forbidden', deducted: false };
    }
    // Budget the wrong guesses. Without it the only ceiling on brute-forcing a
    // 4-character code is the route's generic per-user rate limit, which is
    // thousands of attempts an hour against a code that lives all day.
    if (!(await this.withinPinAttemptBudget(reservation.id))) {
      return { valid: false, riderId: reservation.userId, reason: 'invalid', deducted: false };
    }
    if (!checkPin(input.pin, reservation.pinHash, this.deps.secret)) {
      await this.recordScan(
        reservation.userId,
        input.scannedBy,
        reservation.tripId,
        'invalid',
        'pin',
      );
      return { valid: false, riderId: reservation.userId, reason: 'invalid', deducted: false };
    }
    // Correct PIN. A `reserved` seat boards + debits; an already-`boarded` one is
    // a no-op (idempotent — no second charge).
    if (reservation.status !== 'reserved') {
      await this.recordScan(
        reservation.userId,
        input.scannedBy,
        reservation.tripId,
        'reused',
        'pin',
      );
      return {
        valid: true,
        riderId: reservation.userId,
        reason: 'already_boarded',
        deducted: false,
      };
    }
    let deducted = false;
    try {
      deducted = await this.boardAndDebit(reservation);
    } catch (err) {
      console.error('boarding: PIN ride deduction failed (allowed to board anyway)', err);
    }
    await this.recordScan(reservation.userId, input.scannedBy, reservation.tripId, 'ok', 'pin');
    return { valid: true, riderId: reservation.userId, reason: 'ok', deducted };
  }

  /**
   * Board whoever holds this code on this run (#241) — no rider picked first.
   *
   * The original design made the driver select a seat off the manifest and
   * only then type the code, so four characters were never a key to the whole
   * run. That reasoning stopped holding when boardRider landed in #227: the
   * assigned driver can already board any rider on their manifest with no code
   * whatsoever, so searching the code across the run gives away nothing that
   * was not already given.
   *
   * What it buys is the door. A driver with a queue should be able to take a
   * code and act on it, not hunt for a name first, and "find the person, then
   * type the thing they just said" is two steps where the design has one.
   *
   * @param input - the run, the presented code, and the driver.
   * @returns who boarded, or why nobody did.
   */
  async verifyCodeOnTrip(input: VerifyCodeInput): Promise<VerifyCodeResult> {
    if (!this.deps.reservations) {
      return { riderId: null, reason: 'not_found', deducted: false };
    }
    if (!(await this.isAssignedDriver(input.actedBy, input.tripId))) {
      return { riderId: null, reason: 'forbidden', deducted: false };
    }
    if (!(await this.withinTripCodeBudget(input.tripId, input.actedBy))) {
      return { riderId: null, reason: 'invalid', deducted: false };
    }

    const reservations = await this.deps.reservations.listForTrip(input.tripId);
    // The seats a code can name. A declined or unseated row is not a seat, and
    // must not be reachable by typing four characters any more than by tapping.
    const candidates = reservations.filter((r) =>
      MANIFEST_ACTIONABLE.includes(r.status as (typeof MANIFEST_ACTIONABLE)[number]),
    );
    const matches = candidates.filter((r) => checkPin(input.code, r.pinHash, this.deps.secret));

    if (matches.length === 0) {
      await this.recordScan(null, input.actedBy, input.tripId, 'invalid', 'pin');
      return { riderId: null, reason: 'invalid', deducted: false };
    }
    if (matches.length > 1) {
      // Two seats, one code. Refused rather than resolved by picking the first:
      // the wrong rider would be charged and the right one would still be stood
      // at the door.
      await this.recordScan(null, input.actedBy, input.tripId, 'invalid', 'pin');
      return { riderId: null, reason: 'ambiguous', deducted: false };
    }

    const reservation = matches[0]!;
    if (reservation.status === 'boarded') {
      await this.recordScan(reservation.userId, input.actedBy, input.tripId, 'reused', 'pin');
      return { riderId: reservation.userId, reason: 'already_boarded', deducted: false };
    }

    let deducted = false;
    try {
      deducted = await this.boardAndDebit(reservation);
    } catch (err) {
      console.error('boarding: code ride deduction failed (allowed to board anyway)', err);
    }
    await this.recordScan(reservation.userId, input.actedBy, input.tripId, 'ok', 'pin');
    return { riderId: reservation.userId, reason: 'ok', deducted };
  }

  /**
   * Count this attempt against the run's budget of wrong codes.
   *
   * Fails OPEN like the rest of this file: a KV outage must not strand a bus.
   *
   * @param tripId - the run being boarded.
   * @param userId - the driver doing the boarding.
   * @returns whether the attempt is still within budget.
   */
  private async withinTripCodeBudget(tripId: string, userId: string): Promise<boolean> {
    try {
      const attempts = await this.deps.kv.increment(
        `code:attempts:${tripId}:${userId}`,
        PIN_ATTEMPT_WINDOW_SECONDS,
      );
      return attempts <= MAX_TRIP_CODE_ATTEMPTS;
    } catch (err) {
      console.warn('boarding: trip code budget unavailable; allowing attempt', err);
      return true;
    }
  }

  /**
   * Board a rider the driver has already identified by face and photo (#227).
   *
   * No code is asked for, on purpose. The photo pass exists precisely for the
   * case where a code will not scan or the rider cannot produce one, and
   * demanding a code here would defeat the fallback it is. The assigned-driver
   * check is what stands in its place, and it is the same one `verifyPin` gained
   * in #221.
   *
   * A `no_show` seat can be boarded: a rider who ran up at the next stop should
   * not be stuck because a driver marked them a minute early. The shared
   * `board:<id>` key means the ride is charged once either way.
   *
   * @param input - the reservation and the driver.
   * @returns whether the rider boarded, and whether a ride was consumed.
   */
  async boardRider(input: ManifestActionInput): Promise<BoardRiderResult> {
    if (!this.deps.reservations) {
      return { riderId: null, reason: 'not_found', deducted: false };
    }
    const reservation = await this.deps.reservations.findById(input.reservationId);
    if (!reservation) return { riderId: null, reason: 'not_found', deducted: false };
    if (!(await this.isAssignedDriver(input.actedBy, reservation.tripId))) {
      return { riderId: null, reason: 'forbidden', deducted: false };
    }
    if (reservation.status === 'boarded') {
      await this.recordScan(
        reservation.userId,
        input.actedBy,
        reservation.tripId,
        'reused',
        'photo',
      );
      return { riderId: reservation.userId, reason: 'already_boarded', deducted: false };
    }
    // A seat that was declined, released or never confirmed is not a seat. The
    // manifest never offers one, but this endpoint takes an id, and boarding it
    // would both charge someone who said they were not travelling and put a
    // rider in a place the capacity check had already given away.
    if (!MANIFEST_ACTIONABLE.includes(reservation.status as (typeof MANIFEST_ACTIONABLE)[number])) {
      return { riderId: reservation.userId, reason: 'not_boardable', deducted: false };
    }

    let deducted = false;
    try {
      deducted = await this.boardAndDebit(reservation);
    } catch (err) {
      console.error('boarding: manifest ride deduction failed (allowed to board anyway)', err);
    }
    await this.recordScan(reservation.userId, input.actedBy, reservation.tripId, 'ok', 'photo');
    return { riderId: reservation.userId, reason: 'ok', deducted };
  }

  /**
   * Mark one rider as not having turned up (#227).
   *
   * The driver at the stop knows this; the admin sweep hours later is guessing
   * from the same data with less of it. So the mark is final for the seat, and
   * the ride is debited now rather than at the cutoff.
   *
   * Final is not irreversible: boarding the rider afterwards still works, and
   * because both paths share `board:<reservationId>` the ledger charges once
   * whichever order they arrive in. The cutoff sweep only looks at still
   * `reserved` seats, so it never sees this one again either.
   *
   * @param input - the reservation and the driver.
   * @returns whether the mark landed, and whether a ride was consumed.
   */
  async markNoShow(input: ManifestActionInput): Promise<MarkNoShowResult> {
    if (!this.deps.reservations) {
      return { riderId: null, reason: 'not_found', deducted: false };
    }
    const reservation = await this.deps.reservations.findById(input.reservationId);
    if (!reservation) return { riderId: null, reason: 'not_found', deducted: false };
    if (!(await this.isAssignedDriver(input.actedBy, reservation.tripId))) {
      return { riderId: null, reason: 'forbidden', deducted: false };
    }
    // Refused rather than silently reversed. A rider verified onto the vehicle
    // is on it, and letting a later tap undo that would make the manifest
    // disagree with the bus.
    if (reservation.status === 'boarded') {
      return { riderId: reservation.userId, reason: 'already_boarded', deducted: false };
    }
    if (reservation.status === 'no_show') {
      return { riderId: reservation.userId, reason: 'already_no_show', deducted: false };
    }
    // Only a confirmed seat can fail to turn up. Marking anything else would
    // deduct a ride from a rider who declined, was never seated, or had the run
    // cancelled under them — the one group who must never be charged.
    if (reservation.status !== 'reserved') {
      return { riderId: reservation.userId, reason: 'not_boardable', deducted: false };
    }

    // Debit BEFORE marking, the same order the cutoff sweep uses: a run that
    // fails between the two converges on a retry rather than losing the charge.
    let deducted = false;
    if (this.deps.entitlements) {
      await this.deps.entitlements.record({
        userId: reservation.userId,
        deltaRides: -1,
        reason: 'no_show',
        refType: 'reservation',
        refId: reservation.id,
        idempotencyKey: `board:${reservation.id}`,
        subscriptionPeriodId: reservation.subscriptionPeriodId ?? null,
      });
      deducted = true;
    }
    await this.deps.reservations.markNoShow(reservation.id);
    return { riderId: reservation.userId, reason: 'ok', deducted };
  }

  /**
   * Whether this user is the driver the reservation's run is assigned to.
   *
   * Permissive in exactly two cases, both of which mean there is no assignment
   * to check rather than a check that failed: the trip/driver stores are not
   * wired, or the reservation is not attached to a trip at all.
   *
   * @param userId - the signed-in driver doing the boarding.
   * @param tripId - the reservation's trip, when it has one.
   * @returns whether boarding may proceed.
   */
  private async isAssignedDriver(userId: string, tripId: string | null): Promise<boolean> {
    if (!this.deps.trips || !this.deps.drivers || !tripId) return true;
    const trip = await this.deps.trips.findById(tripId);
    if (!trip) return true;
    const driver = await this.deps.drivers.findByUserId(userId);
    return driver !== null && trip.assignedDriverId === driver.id;
  }

  /**
   * Count this attempt against the reservation's budget of wrong codes.
   *
   * Fails OPEN like the rest of this file: a KV outage must not strand a bus,
   * and the cost of that choice is a brute-force window that only opens while
   * Redis is down.
   *
   * @param reservationId - the seat being boarded.
   * @returns whether the attempt is still within budget.
   */
  private async withinPinAttemptBudget(reservationId: string): Promise<boolean> {
    try {
      const attempts = await this.deps.kv.increment(
        `pin:attempts:${reservationId}`,
        PIN_ATTEMPT_WINDOW_SECONDS,
      );
      return attempts <= MAX_PIN_ATTEMPTS;
    } catch (err) {
      console.warn('boarding: PIN attempt budget unavailable; allowing attempt', err);
      return true;
    }
  }

  /**
   * Board a reservation and debit one ride — the shared consume step for both
   * the QR scan and the PIN. Idempotent per reservation (`board:<id>`).
   *
   * @param reservation - the confirmed reservation being boarded.
   * @returns whether a ride was debited (true when the ledger is wired).
   */
  private async boardAndDebit(reservation: Reservation): Promise<boolean> {
    if (!this.deps.reservations || !this.deps.entitlements) return false;
    await this.deps.reservations.markBoarded(reservation.id);
    await this.deps.entitlements.record({
      userId: reservation.userId,
      deltaRides: -1,
      reason: 'boarding',
      refType: 'reservation',
      refId: reservation.id,
      idempotencyKey: `board:${reservation.id}`,
      subscriptionPeriodId: reservation.subscriptionPeriodId ?? null,
    });
    return true;
  }

  /**
   * Cutoff no-show resolution (E4): every still-`reserved` seat for the
   * day+direction that was never boarded is a no-show — deduct one ride and mark
   * it `no_show`. The mirror of boarding: both consume the confirmed seat's ride.
   *
   * Shares boarding's idempotency key (`board:<reservationId>`), so a seat is
   * charged at most once — a late board after the sweep collides and no-ops.
   * Deducts BEFORE marking, so a partial run converges without losing it.
   *
   * @param travelDate - the travel day (`YYYY-MM-DD`).
   * @param direction - morning or evening.
   * @returns how many reservations were resolved as no-shows.
   */
  async resolveNoShows(
    travelDate: string,
    direction: ReservationDirection,
  ): Promise<{ noShows: number }> {
    if (!this.deps.reservations || !this.deps.entitlements) return { noShows: 0 };
    const reserved = await this.deps.reservations.listReserved(travelDate, direction);
    for (const r of reserved) {
      await this.deps.entitlements.record({
        userId: r.userId,
        deltaRides: -1,
        reason: 'no_show',
        refType: 'reservation',
        refId: r.id,
        idempotencyKey: `board:${r.id}`,
        subscriptionPeriodId: r.subscriptionPeriodId ?? null,
      });
      await this.deps.reservations.markNoShow(r.id);
    }
    return { noShows: reserved.length };
  }

  /**
   * Append a best-effort scan-audit row. A DB blip (or an FK race on a deleted
   * rider) must not fail the boarding, so errors are logged, never thrown.
   *
   * @param riderId - the rider (null when unattributable).
   * @param scannedBy - the driver.
   * @param tripId - the trip, if known.
   * @param result - the verification outcome to record.
   * @param method - how the rider was verified (`qr` | `pin`).
   */
  private async recordScan(
    riderId: string | null,
    scannedBy: string,
    tripId: string | null,
    result: VerifyScanResult['reason'],
    method: ScanMethod,
  ): Promise<void> {
    try {
      await this.deps.scanEvents.record({
        riderId,
        scannedBy,
        tripId,
        result: result === 'ok' ? 'valid' : result,
        method,
      });
    } catch (err) {
      console.error('boarding: failed to record scan event (audit gap)', err);
    }
  }
}
