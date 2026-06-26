// Framework-agnostic access-token service. Kept free of Fastify so it can be
// unit-tested directly and reused (Slice 2 adds refresh tokens + social
// sign-in, which verify Google/Apple ID tokens via jose's JWKS support).

import { SignJWT, jwtVerify } from 'jose';
import { z } from 'zod';
import { USER_ROLES, type UserRole } from '../users/user.repository';

const ALG = 'HS256';

/** Auth configuration. The secret is required in production (see config/env.ts). */
export interface AuthConfig {
  secret: string;
  /** Access-token lifetime, e.g. '15m' (jose duration syntax). */
  accessTtl: string;
  issuer: string;
  audience: string;
}

/** Claims we put in (and read back out of) an access token. */
export interface AccessTokenClaims {
  userId: string;
  role: UserRole;
}

// Validate the decoded payload before trusting it: a structurally valid but
// semantically wrong token (unknown role, missing subject) is treated as invalid.
const accessPayloadSchema = z.object({
  sub: z.string().min(1),
  role: z.enum(USER_ROLES),
});

export interface JwtService {
  signAccessToken(claims: AccessTokenClaims): Promise<string>;
  /** Resolves with the claims, or rejects if the token is invalid/expired. */
  verifyAccessToken(token: string): Promise<AccessTokenClaims>;
}

/**
 * Dev-only fallback so the API and tests run with zero config. Production must
 * supply a real JWT_SECRET — env validation enforces this (config/env.ts).
 */
export const DEV_AUTH_CONFIG: AuthConfig = {
  secret: 'dev-only-insecure-secret-change-me-0123456789abcdef',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};

export function createJwtService(config: AuthConfig): JwtService {
  const key = new TextEncoder().encode(config.secret);
  const verifyOptions = { issuer: config.issuer, audience: config.audience };

  return {
    async signAccessToken({ userId, role }) {
      return new SignJWT({ role })
        .setProtectedHeader({ alg: ALG })
        .setSubject(userId)
        .setIssuedAt()
        .setIssuer(config.issuer)
        .setAudience(config.audience)
        .setExpirationTime(config.accessTtl)
        .sign(key);
    },

    async verifyAccessToken(token) {
      const { payload } = await jwtVerify(token, key, verifyOptions);
      const { sub, role } = accessPayloadSchema.parse(payload);
      return { userId: sub, role };
    },
  };
}
