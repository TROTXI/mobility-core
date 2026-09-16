import { createHmac, randomUUID } from 'node:crypto';
import { SignJWT, jwtVerify } from 'jose';
import { fail } from '../transport/errors.js';

const audience = 'trotxi-boarding-pass';
const issuer = 'trotxi-replacement';
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
export interface PassBinding {
  userId: string;
  reservationId: string;
  tripId: string;
}
export class BoardingProofs {
  constructor(private readonly key: Buffer) {
    if (!Buffer.isBuffer(key) || key.length !== 32)
      throw new Error('Dedicated 32-byte boarding proof key required');
  }
  digest(value: string) {
    return createHmac('sha256', this.key).update(value).digest('hex');
  }
  code(reservationId: string, tripId: string) {
    // A stable, scoped fallback, not a new code on every rotating QR. The key
    // never leaves the server; neither codes nor their low-entropy input hashes
    // are stored in command receipts. A collision is refused, never guessed.
    const bytes = createHmac('sha256', this.key).update(`code:${tripId}:${reservationId}`).digest();
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    return Array.from(bytes.subarray(0, 4), (b) => alphabet[b & 31]).join('');
  }
  async issue(binding: PassBinding, now: Date) {
    const issued = Math.floor(now.getTime() / 1000),
      expires = issued + 60;
    const qrToken = await new SignJWT({
      reservationId: binding.reservationId,
      tripId: binding.tripId,
    })
      .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
      .setSubject(binding.userId)
      .setAudience(audience)
      .setIssuer(issuer)
      .setJti(randomUUID())
      .setIssuedAt(issued)
      .setExpirationTime(expires)
      .sign(this.key);
    return {
      reservationId: binding.reservationId,
      tripId: binding.tripId,
      qrToken,
      expiresAt: new Date(expires * 1000).toISOString(),
      boardingCode: this.code(binding.reservationId, binding.tripId),
    };
  }
  async verify(token: string, now: Date) {
    try {
      const { payload } = await jwtVerify(token, this.key, {
        algorithms: ['HS256'],
        audience,
        issuer,
        currentDate: now,
        clockTolerance: 5,
        requiredClaims: ['sub', 'jti', 'iat', 'exp', 'reservationId', 'tripId'],
      });
      const values = [payload.sub, payload.jti, payload.reservationId, payload.tripId];
      if (
        values.some((v) => typeof v !== 'string' || !uuid.test(v)) ||
        typeof payload.iat !== 'number' ||
        typeof payload.exp !== 'number' ||
        payload.exp - payload.iat !== 60 ||
        payload.iat > Math.floor(now.getTime() / 1000) + 5
      )
        throw new Error('claims');
      return {
        userId: payload.sub!,
        jti: payload.jti!,
        reservationId: payload.reservationId as string,
        tripId: payload.tripId as string,
      };
    } catch {
      fail(
        409,
        'invalid_boarding_proof',
        'Refresh the boarding pass or use another verification method.',
      );
    }
  }
}
