// BoardingService — issue a rider's rotating QR pass, and verify a scanned pass
// (#20). Verification is integrity-only: it proves the pass is a genuine,
// unexpired pass for a rider, and records every scan for audit. The eligibility
// gates (active membership, token debit on board) are deferred with the money
// work (#19/#21) — a valid scan here means "real pass", not "cleared to ride".

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
  reason: 'ok' | 'invalid' | 'expired';
}

/** Collaborators for {@link BoardingService}, injected at app wiring. */
export interface BoardingServiceDeps {
  /** Append-only scan audit trail. */
  scanEvents: ScanEventRepository;
  /** Server signing key for passes (the JWT secret). */
  secret: string;
  /** Pass lifetime in seconds (short → the QR rotates). */
  passTtlSeconds: number;
}

/**
 * True when a jose verify error is a JWT-expired failure.
 *
 * @param err - the caught verify error.
 * @returns whether it indicates an expired pass.
 */
function isExpired(err: unknown): boolean {
  return (err as { code?: string }).code === 'ERR_JWT_EXPIRED';
}

/** Boarding-pass issuance + scan verification (see the file header). */
export class BoardingService {
  /** @param deps - the scan-event repo, signing secret, and pass TTL. */
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
   * Verify a scanned pass (integrity) and record the scan.
   *
   * @param input - the scanned pass, the driver, and the trip.
   * @returns whether the pass is valid, the rider id, and the reason.
   */
  async verifyScan(input: VerifyScanInput): Promise<VerifyScanResult> {
    let riderId: string | null = null;
    let reason: VerifyScanResult['reason'] = 'invalid';
    try {
      ({ userId: riderId } = await verifyPass(input.pass, this.deps.secret));
      reason = 'ok';
    } catch (err) {
      reason = isExpired(err) ? 'expired' : 'invalid';
    }

    await this.deps.scanEvents.record({
      riderId,
      scannedBy: input.scannedBy,
      tripId: input.tripId ?? null,
      result: reason === 'ok' ? 'valid' : reason,
      method: 'qr',
    });

    return { valid: reason === 'ok', riderId, reason };
  }
}
