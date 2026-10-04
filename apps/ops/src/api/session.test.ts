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
const readOptions = {
  params: { header: { 'X-Trotxi-Client': 'ops' as const, 'X-Trotxi-Build': 1 } },
};

describe('OpsSession', () => {
  it('does not restore a session from a refresh that completes after logout', async () => {
    let finish!: (response: Response) => void;
    const fetcher = vi
      .fn()
      .mockResolvedValueOnce(Response.json(tokens('access', 'refresh')))
      .mockResolvedValueOnce(new Response(null, { status: 401 }))
      .mockImplementationOnce(
        () =>
          new Promise<Response>((resolve) => {
            finish = resolve;
          }),
      )
      .mockResolvedValue(new Response(null, { status: 204 }));
    const session = new OpsSession('https://api.example.test', fetcher, new MemoryStorage());
    await session.signInGoogle('token');
    const pending = session.client.GET('/v1/ops/vehicles', readOptions);
    const rejected = expect(pending).rejects.toMatchObject({ code: 'session_changed' });
    await vi.waitFor(() => expect(fetcher).toHaveBeenCalledTimes(3));
    await session.logout();
    finish(Response.json(tokens('late-access', 'late-refresh')));
    await rejected;
    expect(session.signedIn).toBe(false);
  });
  it('shares matching GETs, not completed responses or different queries', async () => {
    let finish!: (response: Response) => void;
    const fetcher = vi
      .fn()
      .mockResolvedValueOnce(Response.json(tokens('access', 'refresh')))
      .mockImplementation(
        () =>
          new Promise<Response>((resolve) => {
            finish = resolve;
          }),
      );
    const session = new OpsSession('https://api.example.test', fetcher, new MemoryStorage());
    await session.signInGoogle('token');
    const first = session.client.GET('/v1/ops/vehicles', readOptions);
    const second = session.client.GET('/v1/ops/vehicles', readOptions);
    await Promise.resolve();
    await Promise.resolve();
    expect(fetcher).toHaveBeenCalledTimes(2);
    finish(Response.json({ data: [], page: { nextCursor: null } }));
    const responses = await Promise.all([first, second]);
    expect(responses.map((r) => r.data?.data)).toEqual([[], []]);
    const fresh = session.client.GET('/v1/ops/vehicles', readOptions);
    await Promise.resolve();
    await Promise.resolve();
    expect(fetcher).toHaveBeenCalledTimes(3);
    finish(Response.json({ data: [], page: { nextCursor: null } }));
    await fresh;
  });

  it('blocks other screens during Retry-After without retrying mutations', async () => {
    vi.useFakeTimers();
    try {
      const fetcher = vi
        .fn()
        .mockResolvedValueOnce(Response.json(tokens('access', 'refresh')))
        .mockResolvedValueOnce(
          Response.json(
            { error: { code: 'rate_limited', message: 'Wait.' } },
            { status: 429, headers: { 'Retry-After': '60' } },
          ),
        )
        .mockResolvedValue(Response.json({ data: [], page: { nextCursor: null } }));
      const session = new OpsSession('https://api.example.test', fetcher, new MemoryStorage());
      await session.signInGoogle('token');
      await session.client.GET('/v1/ops/vehicles', readOptions);
      await expect(session.client.GET('/v1/ops/drivers', readOptions)).rejects.toMatchObject({
        status: 429,
      });
      expect(fetcher).toHaveBeenCalledTimes(2);
      vi.advanceTimersByTime(60_000);
      await session.client.GET('/v1/ops/drivers', readOptions);
      expect(fetcher).toHaveBeenCalledTimes(3);
    } finally {
      vi.useRealTimers();
    }
  });

  it('one cancelled consumer does not cancel another shared reader', async () => {
    let finish!: (response: Response) => void;
    const fetcher = vi
      .fn()
      .mockResolvedValueOnce(Response.json(tokens('access', 'refresh')))
      .mockImplementation(
        () =>
          new Promise<Response>((resolve) => {
            finish = resolve;
          }),
      );
    const session = new OpsSession('https://api.example.test', fetcher, new MemoryStorage());
    await session.signInGoogle('token');
    const controller = new AbortController();
    const first = session.client.GET('/v1/ops/vehicles', {
      ...readOptions,
      signal: controller.signal,
    });
    const second = session.client.GET('/v1/ops/vehicles', readOptions);
    const cancelled = expect(first).rejects.toMatchObject({ name: 'AbortError' });
    await Promise.resolve();
    await Promise.resolve();
    controller.abort();
    finish(Response.json({ data: [], page: { nextCursor: null } }));
    await cancelled;
    expect((await second).data?.data).toEqual([]);
  });
  it('calls browser fetch with Window as its receiver by default', async () => {
    const browserFetch = vi.fn(function (this: typeof globalThis) {
      if (this !== globalThis) throw new TypeError('Illegal invocation');
      return Promise.resolve(Response.json(tokens('access', 'refresh')));
    });
    vi.stubGlobal('fetch', browserFetch);
    try {
      const session = new OpsSession('https://api.example.test', undefined, new MemoryStorage());
      await session.signInGoogle('google-id-token');
      expect(session.signedIn).toBe(true);
      expect(browserFetch).toHaveBeenCalledOnce();
    } finally {
      vi.unstubAllGlobals();
    }
  });

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
      if (request.url.endsWith('/v1/auth/ops/google'))
        return Response.json(tokens('old', 'refresh-1'));
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
      if (request.url.endsWith('/v1/auth/ops/google'))
        return Response.json(tokens('old', 'refresh-1'));
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
      if (request.url.endsWith('/v1/auth/ops/google'))
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
