import { SignJWT } from 'jose';
import { describe, expect, it } from 'vitest';
import { createJwtService, type AuthConfig } from '../src/modules/auth/jwt';

const config: AuthConfig = {
  secret: 'test-secret-at-least-32-characters-long-0000',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};

const key = new TextEncoder().encode(config.secret);

// Craft a token directly (bypassing the service) to exercise the verify paths.
function craft(opts: {
  sub?: string;
  role?: string;
  issuer?: string;
  audience?: string;
  exp?: number | string;
}): Promise<string> {
  const payload = opts.role !== undefined ? { role: opts.role } : {};
  const jwt = new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setSubject(opts.sub ?? 'user-1')
    .setIssuer(opts.issuer ?? config.issuer)
    .setAudience(opts.audience ?? config.audience)
    .setExpirationTime(opts.exp ?? '15m');
  return jwt.sign(key);
}

describe('createJwtService', () => {
  const jwt = createJwtService(config);

  it('signs and verifies an access token round-trip', async () => {
    const token = await jwt.signAccessToken({ userId: 'user-1', role: 'driver' });
    expect(await jwt.verifyAccessToken(token)).toEqual({ userId: 'user-1', role: 'driver' });
  });

  it('rejects a malformed token', async () => {
    await expect(jwt.verifyAccessToken('not-a-jwt')).rejects.toThrow();
  });

  it('rejects a token signed with a different secret', async () => {
    const other = createJwtService({
      ...config,
      secret: 'a-totally-different-secret-32-chars-min',
    });
    const token = await other.signAccessToken({ userId: 'user-1', role: 'commuter' });
    await expect(jwt.verifyAccessToken(token)).rejects.toThrow();
  });

  it('rejects an expired token', async () => {
    const token = await craft({ role: 'commuter', exp: Math.floor(Date.now() / 1000) - 60 });
    await expect(jwt.verifyAccessToken(token)).rejects.toThrow();
  });

  it('rejects a token with the wrong issuer', async () => {
    const token = await craft({ role: 'commuter', issuer: 'someone-else' });
    await expect(jwt.verifyAccessToken(token)).rejects.toThrow();
  });

  it('rejects a token carrying an unknown role', async () => {
    const token = await craft({ role: 'superuser' });
    await expect(jwt.verifyAccessToken(token)).rejects.toThrow();
  });
});
