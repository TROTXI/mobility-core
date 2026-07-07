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
import type { ReservationRepository } from '../reservations/reservation.repository';
import { signPass, verifyPass, type IssuedPass } from './pass';
import type { ScanEventRepository } from './scan-event.repository';

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

    // A valid scan consumes the rider's confirmed reservation for today: mark it
    // boarded and debit one ride (ADR-0014, E4). Idempotent by reservation, and
    // findBoardable skips already-boarded seats, so re-scanning a rider (with a
    // freshly rotated QR) can't double-charge. Fails OPEN — a hiccup here must
    // not stop the bus; reconciliation catches any gap.
    let deducted = false;
    if (reason === 'ok' && riderId && this.deps.reservations && this.deps.entitlements) {
      try {
        const boardable = await this.deps.reservations.findBoardable(riderId, todayISO());
        if (boardable) {
          await this.deps.reservations.markBoarded(boardable.id);
          await this.deps.entitlements.record({
            userId: riderId,
            deltaRides: -1,
            reason: 'boarding',
            refType: 'reservation',
            refId: boardable.id,
            idempotencyKey: `board:${boardable.id}`,
          });
          deducted = true;
        }
      } catch (err) {
        console.error('boarding: ride deduction failed (allowed to board anyway)', err);
      }
    }

    // Audit is best-effort here: verification already answered the driver, and a
    // DB blip (or a rider deleted mid-window tripping the FK) must not 500 the
    // scan. Failures are logged loudly instead.
    try {
      await this.deps.scanEvents.record({
        riderId,
        scannedBy: input.scannedBy,
        tripId: input.tripId ?? null,
        result: reason === 'ok' ? 'valid' : reason,
        method: 'qr',
      });
    } catch (err) {
      console.error('boarding: failed to record scan event (audit gap)', err);
    }

    return { valid: reason === 'ok', riderId, reason, deducted };
  }
}
