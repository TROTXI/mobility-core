import createClient, { type Client } from 'openapi-fetch';
import type { components, paths } from '../generated/api';

const refreshKey = 'trotxi.ops.refresh';
export const opsHeaders = {
  'X-Trotxi-Client': 'ops',
  'X-Trotxi-Build': Number(import.meta.env.VITE_OPS_BUILD ?? '1'),
} as const;

type Tokens = components['schemas']['Tokens'];
export type Account = components['schemas']['Account'];

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
    readonly retryAfter?: string | null,
  ) {
    super(message);
  }
}

export class OpsSession extends EventTarget {
  private accessToken: string | null = null;
  private accountValue: Account | null = null;
  private refreshing: Promise<void> | null = null;
  readonly client: Client<paths>;

  constructor(
    readonly baseUrl: string,
    private readonly transport: typeof fetch = fetch,
    private readonly storage: Storage = sessionStorage,
  ) {
    super();
    this.client = createClient<paths>({
      baseUrl,
      fetch: (request) => this.authorized(request as Request),
    });
  }

  get account() {
    return this.accountValue;
  }

  get signedIn() {
    return Boolean(this.accessToken && this.accountValue);
  }

  async restore() {
    if (!this.storage.getItem(refreshKey)) return;
    try {
      await this.refresh();
    } catch {
      this.clear();
    }
  }

  async signInGoogle(idToken: string) {
    const response = await this.publicRequest('/v1/auth/google', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken }),
    });
    this.save(await response.json().then(unwrap<Tokens>));
  }

  async logout() {
    const refreshToken = this.storage.getItem(refreshKey);
    if (refreshToken) {
      try {
        await this.publicRequest('/v1/auth/logout', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ refreshToken }),
        });
      } catch {
        // Local sign-out still completes when the network is unavailable.
      }
    }
    this.clear();
  }

  private async authorized(request: Request) {
    if (!this.accessToken) throw new ApiError(401, 'not_authenticated', 'Sign in again.');
    const first = await this.transport(this.withAuth(request));
    if (first.status !== 401) return first;
    await this.refresh();
    return this.transport(this.withAuth(request));
  }

  private withAuth(request: Request) {
    const headers = new Headers(request.headers);
    headers.set('Authorization', `Bearer ${this.accessToken}`);
    for (const [key, value] of Object.entries(opsHeaders)) headers.set(key, String(value));
    return new Request(request, { headers });
  }

  private async refresh() {
    if (this.refreshing) return this.refreshing;
    this.refreshing = (async () => {
      const refreshToken = this.storage.getItem(refreshKey);
      if (!refreshToken) throw new ApiError(401, 'not_authenticated', 'Sign in again.');
      const response = await this.publicRequest('/v1/auth/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });
      this.save(await response.json().then(unwrap<Tokens>));
    })();
    try {
      await this.refreshing;
    } finally {
      this.refreshing = null;
    }
  }

  private async publicRequest(path: string, init: RequestInit) {
    const headers = new Headers(init.headers);
    for (const [key, value] of Object.entries(opsHeaders)) headers.set(key, String(value));
    const response = await this.transport(`${this.baseUrl}${path}`, {
      ...init,
      headers,
      signal: init.signal ?? AbortSignal.timeout(30_000),
    });
    if (!response.ok) throw await errorFrom(response);
    return response;
  }

  private save(tokens: Tokens) {
    this.accessToken = tokens.accessToken;
    this.accountValue = tokens.account;
    this.storage.setItem(refreshKey, tokens.refreshToken);
    this.dispatchEvent(new Event('change'));
  }

  private clear() {
    this.accessToken = null;
    this.accountValue = null;
    this.storage.removeItem(refreshKey);
    this.dispatchEvent(new Event('change'));
  }
}

function unwrap<T>(value: unknown): T {
  if (!value || typeof value !== 'object' || !('data' in value))
    throw new ApiError(502, 'invalid_response', 'The server returned an invalid response.');
  return (value as { data: T }).data;
}

export async function errorFrom(response: Response) {
  const body = await response
    .clone()
    .json()
    .catch(() => null);
  const error = body?.error;
  return new ApiError(
    response.status,
    typeof error?.code === 'string' ? error.code : 'request_failed',
    typeof error?.message === 'string' ? error.message : 'The request could not be completed.',
    response.headers.get('Retry-After'),
  );
}

export const apiBaseUrl = String(
  import.meta.env.VITE_API_BASE_URL ?? 'https://trotxi-api-staging.onrender.com',
).replace(/\/$/, '');
