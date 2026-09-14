import { afterEach, describe, expect, it, vi } from 'vitest';
import { Pool } from 'pg';
import { buildApp } from '../src/app';
import { createJwtService } from '../src/modules/auth/jwt';
import { CommuteConflict, PgCommuteService } from '../src/modules/commute/commute.service.pg';
import { commuteSubmit } from '../src/modules/commute/commute.schema';
const auth = {
  secret: 'commute-test-secret-at-least-32-characters',
  accessTtl: '15m',
  issuer: 'trotxi',
  audience: 'trotxi-api',
};
const id = '11111111-1111-4111-8111-111111111111';
const input = {
  routeId: id,
  pickupStopId: id,
  dropoffStopId: '22222222-2222-4222-8222-222222222222',
  morningDeparture: '06:30',
  eveningReturn: '17:30',
  requestedDate: '2099-01-01',
};
afterEach(() => vi.restoreAllMocks());
describe('commute API contract', () => {
  it('validates times, dates, notes and defaults pause consent off', () => {
    expect(commuteSubmit.parse(input).pauseIfWaitlisted).toBe(false);
    for (const patch of [
      { morningDeparture: '17:00' },
      { eveningReturn: '08:00' },
      { requestedDate: '2026-02-30' },
      { note: 'x'.repeat(1001) },
    ])
      expect(commuteSubmit.safeParse({ ...input, ...patch }).success).toBe(false);
  });
  it('fails closed when persistence is not configured', async () => {
    const app = await buildApp({ auth });
    try {
      const token = await createJwtService(auth).signAccessToken({ userId: id, role: 'commuter' });
      const response = await app.inject({
        url: '/me/commute-requests',
        headers: { authorization: `Bearer ${token}` },
      });
      expect(response.statusCode).toBe(503);
    } finally {
      await app.close();
    }
  });
  it.each([
    [new CommuteConflict('slot_unavailable', 'Already held'), 409, 'slot_unavailable'],
    [Object.assign(new Error('foreign key'), { code: '23503' }), 409, 'reference_changed'],
    [Object.assign(new Error('unique'), { code: '23505' }), 409, 'conflict'],
    [new Error('database failed'), 500, 'Internal Server Error'],
  ])('serializes a safe error for %s', async (error, status, code) => {
    const pool = new Pool({ connectionString: 'postgres://unused.invalid/test' });
    const service = new PgCommuteService(pool);
    vi.spyOn(service, 'submit').mockRejectedValue(error);
    const app = await buildApp({ auth, commuteService: service });
    try {
      const token = await createJwtService(auth).signAccessToken({ userId: id, role: 'commuter' });
      const response = await app.inject({
        method: 'POST',
        url: '/me/commute-requests',
        headers: { authorization: `Bearer ${token}` },
        payload: input,
      });
      expect(response.statusCode).toBe(status);
      expect(response.json().error).toBe(code);
    } finally {
      await app.close();
      await pool.end();
    }
  });
});
