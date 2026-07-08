// BoardingService — issue a rider's rotating QR pass, and verify a scanned pass
// (#20). Verification is integrity-only: it proves the pass is a genuine,
// unexpired, not-already-used pass for a rider, and records every scan for
// audit. The eligibility gates (active membership, token debit on board) are
// deferred with the money work (#19/#21) — a valid scan here means "real pass",
// not "cleared to ride".
//
// Availability over strictness (same posture as the rate limiter): the KV
// single-use check and the audit write both fail OPEN — a KV/DB blip must never
// stop a bus from boarding. The audit trail is best-effort in this phase; when
// the money work lands, the token debit becomes the transactional anchor and
// the scan record should ride with it.

import { errors } from 'jose';
import type { KvStore } from '../../kv/kv.store';
import type { EntitlementLedgerRepository } from '../entitlements/entitlement-ledger.repository';
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
  /** The 4-digit PIN the rider presented. */
  pin: string;
  /** The driver performing the verification. */
  scannedBy: string;
}

/** The outcome of a PIN verification. */
export interface VerifyPinResult {
  valid: boolean;
  riderId: string | null;
  reason: 'ok' | 'invalid' | 'not_found' | 'already_boarded';
  deducted: boolean;
}

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
    });
    return true;
  }

  /**
   * Cutoff no-show resolution (E4): every still-`reserved` seat for the
   * day+direction that was never boarded is a no-show — deduct one ride and mark
   * it `no_show`. The mirror of boarding: both consume the confirmed seat's ride.
   *
   * Deducts on the **same idempotency key as boarding** (`board:<reservationId>`)
   * so a seat is charged **at most once**: a late board after a no-show sweep (or
   * a re-run) collides on the key and is a no-op. Combined with only selecting
   * `reserved` rows, a re-run neither double-deducts nor re-marks. Deducts BEFORE
   * marking (like the credit conversion) so a partial run converges without
   * losing the deduction. No-op when the ledgers aren't wired.
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
