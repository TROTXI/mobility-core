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
}

/** Collaborators for {@link BoardingService}, injected at app wiring. */
export interface BoardingServiceDeps {
  /** Append-only scan audit trail. */
  scanEvents: ScanEventRepository;
  /** Marks passes consumed (single-use); Redis in prod, in-memory in dev/tests. */
  kv: KvStore;
  /** Server signing key for passes (the JWT secret). */
  secret: string;
  /** Pass lifetime in seconds (short → the QR rotates). */
  passTtlSeconds: number;
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

    return { valid: reason === 'ok', riderId, reason };
  }
}
