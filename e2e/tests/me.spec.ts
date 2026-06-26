import { expect, test } from '@playwright/test';
import { SignJWT } from 'jose';
import { E2E_JWT_SECRET, JWT_AUDIENCE, JWT_ISSUER, SEED_USER } from '../fixtures';

const hasDb = !!process.env.DATABASE_URL;

async function accessToken(sub: string, role: string): Promise<string> {
  return new SignJWT({ role })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(sub)
    .setIssuedAt()
    .setIssuer(JWT_ISSUER)
    .setAudience(JWT_AUDIENCE)
    .setExpirationTime('5m')
    .sign(new TextEncoder().encode(E2E_JWT_SECRET));
}

test.describe('GET /me', () => {
  test('rejects an unauthenticated request', async ({ request }) => {
    const res = await request.get('/me');
    expect(res.status()).toBe(401);
  });

  test.describe('against Postgres', () => {
    // Exercises the real DB path end-to-end: token -> guard -> Pg repo -> row.
    test.skip(!hasDb, 'requires DATABASE_URL (real Postgres)');

    test('returns the seeded user for a valid token', async ({ request }) => {
      const token = await accessToken(SEED_USER.id, SEED_USER.role);
      const res = await request.get('/me', { headers: { authorization: `Bearer ${token}` } });
      expect(res.status()).toBe(200);
      expect(await res.json()).toMatchObject({
        id: SEED_USER.id,
        displayName: SEED_USER.displayName,
        role: SEED_USER.role,
      });
    });

    test('returns 404 for a valid token whose user does not exist', async ({ request }) => {
      const token = await accessToken('00000000-0000-0000-0000-0000000000ff', 'commuter');
      const res = await request.get('/me', { headers: { authorization: `Bearer ${token}` } });
      expect(res.status()).toBe(404);
    });
  });
});
