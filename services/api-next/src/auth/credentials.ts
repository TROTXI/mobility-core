import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
import { jwtVerify, SignJWT } from 'jose';
import type { Actor } from '../transport/service.js';

// Same SHA-256/random-32-byte format as services/api/modules/auth/tokens.ts.
export const hashToken = (token: string) => createHash('sha256').update(token).digest('hex');
export const newRefresh = () => randomBytes(32).toString('base64url');
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
export interface AccessConfig {
  secret: Uint8Array;
  issuer: string;
  audience: string;
  ttlSeconds: number;
}
export function accessTokens(config: AccessConfig) {
  if (
    config.secret.length < 32 ||
    !config.issuer ||
    !config.audience ||
    !Number.isInteger(config.ttlSeconds) ||
    config.ttlSeconds < 1 ||
    config.ttlSeconds > 3600
  )
    throw new Error('Explicit access signing key, issuer, audience and bounded TTL required');
  return {
    async sign(actor: Actor, role: string, now: Date, expires: Date) {
      return new SignJWT({ sid: actor.sessionId, role })
        .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
        .setSubject(actor.userId)
        .setIssuer(config.issuer)
        .setAudience(config.audience)
        .setIssuedAt(Math.floor(now.getTime() / 1000))
        .setExpirationTime(Math.floor(expires.getTime() / 1000))
        .sign(config.secret);
    },
    async verify(authorization: string): Promise<Actor | null> {
      if (!/^Bearer [^\s]{1,8192}$/.test(authorization)) return null;
      try {
        const { payload } = await jwtVerify(authorization.slice(7), config.secret, {
          issuer: config.issuer,
          audience: config.audience,
          algorithms: ['HS256'],
          requiredClaims: ['sub', 'sid', 'iat', 'exp'],
        });
        if (
          typeof payload.sub !== 'string' ||
          !uuid.test(payload.sub) ||
          typeof payload.sid !== 'string' ||
          !uuid.test(payload.sid)
        )
          return null;
        // Roles in the JWT are informational; authorization reads the database.
        return { userId: payload.sub.toLowerCase(), sessionId: payload.sid.toLowerCase() };
      } catch {
        return null;
      }
    },
  };
}

// Recoverable Apple revocation credentials must not be stored as plaintext.
// AAD binds a ciphertext to the provider subject; no cross-account substitution.
export function providerTokenBox(key: Buffer) {
  if (key.length !== 32) throw new Error('Separate 32-byte provider encryption key required');
  return {
    seal(token: string, subject: string) {
      const iv = randomBytes(12),
        cipher = createCipheriv('aes-256-gcm', key, iv);
      cipher.setAAD(Buffer.from(`apple:${subject}`));
      return Buffer.concat([
        iv,
        cipher.update(token, 'utf8'),
        cipher.final(),
        cipher.getAuthTag(),
      ]).toString('base64url');
    },
    open(value: string, subject: string) {
      const bytes = Buffer.from(value, 'base64url');
      if (bytes.length < 29) throw new Error('Invalid encrypted provider credential');
      const cipher = createDecipheriv('aes-256-gcm', key, bytes.subarray(0, 12));
      cipher.setAAD(Buffer.from(`apple:${subject}`));
      cipher.setAuthTag(bytes.subarray(-16));
      return Buffer.concat([cipher.update(bytes.subarray(12, -16)), cipher.final()]).toString(
        'utf8',
      );
    },
  };
}
