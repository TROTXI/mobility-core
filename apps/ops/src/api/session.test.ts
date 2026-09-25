import { describe, expect, it, vi } from 'vitest';
import { OpsSession } from './session';

const account = {
  id: '00000000-0000-4000-8000-000000000001',
  displayName: 'Operator',
  email: 'ops@example.test',
  phone: null,
  avatarUrl: null,
  role: 'admin' as const,
  createdAt: '2026-01-01T00:00:00.000Z',
};
const tokens = (accessToken: string, refreshToken: string) => ({
  data: {
    accessToken,
    refreshToken,
    accessExpiresAt: '2026-01-01T00:15:00.000Z',
    refreshExpiresAt: '2026-02-01T00:00:00.000Z',
    account,
  },
});

describe('OpsSession', () => {
  it('keeps access in memory, refresh in session storage, and sends fixed Ops metadata', async () => {
    const storage = new MemoryStorage();
    const fetcher = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const request = input instanceof Request ? input : new Request(input, init);
      expect(request.headers.get('X-Trotxi-Client')).toBe('ops');
      return Response.json(tokens('access-1', 'refresh-1'));
    });
    const session = new OpsSession('https://api.example.test', fetcher as typeof fetch, storage);
    await session.signInGoogle('google-id-token');
    expect(session.account).toEqual(account);
    expect(storage.getItem('trotxi.ops.refresh')).toBe('refresh-1');
    expect(JSON.stringify(storage)).not.toContain('access-1');
  });

  it('rotates a stored refresh token when restoring a tab', async () => {
    const storage = new MemoryStorage();
    storage.setItem('trotxi.ops.refresh', 'old-refresh');
    const fetcher = vi.fn(async () => Response.json(tokens('new-access', 'new-refresh')));
    const session = new OpsSession('https://api.example.test', fetcher as typeof fetch, storage);
    await session.restore();
    expect(session.signedIn).toBe(true);
    expect(storage.getItem('trotxi.ops.refresh')).toBe('new-refresh');
  });

  it('clears local credentials even when logout cannot reach the server', async () => {
    const storage = new MemoryStorage();
    const fetcher = vi
      .fn()
      .mockResolvedValueOnce(Response.json(tokens('access', 'refresh')))
      .mockRejectedValueOnce(new Error('offline'));
    const session = new OpsSession('https://api.example.test', fetcher as typeof fetch, storage);
    await session.signInGoogle('token');
    await session.logout();
    expect(session.signedIn).toBe(false);
    expect(storage.length).toBe(0);
  });

  it('retries a POST with its original body and rotated bearer after access expiry', async () => {
    const seen: { body: string; bearer: string | null }[] = [];
    const fetcher = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const request = input instanceof Request ? input : new Request(input, init);
      if (request.url.endsWith('/v1/auth/google')) return Response.json(tokens('old', 'refresh-1'));
      if (request.url.endsWith('/v1/auth/refresh'))
        return Response.json(tokens('new', 'refresh-2'));
      seen.push({ body: await request.text(), bearer: request.headers.get('Authorization') });
      return seen.length === 1
        ? Response.json({ error: { code: 'token_expired' } }, { status: 401 })
        : Response.json({ data: { ok: true } });
    });
    const session = new OpsSession(
      'https://api.example.test',
      fetcher as typeof fetch,
      new MemoryStorage(),
    );
    await session.signInGoogle('google-id-token');
    const response = await session['authorized'](
      new Request('https://api.example.test/v1/ops/command', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason: 'reassign' }),
      }),
    );
    expect(response.status).toBe(200);
    expect(seen).toEqual([
      { body: '{"reason":"reassign"}', bearer: 'Bearer old' },
      { body: '{"reason":"reassign"}', bearer: 'Bearer new' },
    ]);
  });

  it('signs out when a revoked refresh token is refused', async () => {
    const storage = new MemoryStorage();
    const fetcher = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const request = input instanceof Request ? input : new Request(input, init);
      if (request.url.endsWith('/v1/auth/google')) return Response.json(tokens('old', 'refresh-1'));
      if (request.url.endsWith('/v1/auth/refresh'))
        return Response.json({ error: { code: 'session_revoked' } }, { status: 401 });
      return Response.json({ error: { code: 'token_expired' } }, { status: 401 });
    });
    const session = new OpsSession('https://api.example.test', fetcher as typeof fetch, storage);
    await session.signInGoogle('google-id-token');
    const changed = vi.fn();
    session.addEventListener('change', changed);
    await expect(
      session['authorized'](new Request('https://api.example.test/v1/ops/route')),
    ).rejects.toMatchObject({ status: 401 });
    expect(session.signedIn).toBe(false);
    expect(storage.length).toBe(0);
    expect(changed).toHaveBeenCalledOnce();
  });

  it('notifies the passkey gate when elevation expires without consuming the error response', async () => {
    const fetcher = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const request = input instanceof Request ? input : new Request(input, init);
      if (request.url.endsWith('/v1/auth/google'))
        return Response.json(tokens('access', 'refresh'));
      return Response.json({ error: { code: 'passkey_required' } }, { status: 403 });
    });
    const session = new OpsSession(
      'https://api.example.test',
      fetcher as typeof fetch,
      new MemoryStorage(),
    );
    await session.signInGoogle('google-id-token');
    const required = vi.fn();
    session.addEventListener('elevation-required', required);
    const response = await session['authorized'](
      new Request('https://api.example.test/v1/ops/route'),
    );
    expect(required).toHaveBeenCalledOnce();
    expect((await response.json()).error.code).toBe('passkey_required');
  });
});

class MemoryStorage implements Storage {
  private values = new Map<string, string>();
  get length() {
    return this.values.size;
  }
  clear() {
    this.values.clear();
  }
  getItem(key: string) {
    return this.values.get(key) ?? null;
  }
  key(index: number) {
    return [...this.values.keys()][index] ?? null;
  }
  removeItem(key: string) {
    this.values.delete(key);
  }
  setItem(key: string, value: string) {
    this.values.set(key, value);
  }
}
