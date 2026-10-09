import createClient, { type Client } from 'openapi-fetch';
import type { components, paths } from '../generated/api';

const refreshKey = 'trotxi.ops.refresh';
// Invitation secrets stay out of URLs, logs and persistent storage. Reopen the
// email if this page is reloaded before sign-in completes.
let invitationToken: string | null = null;
if (typeof window !== 'undefined') {
  const candidate = new URLSearchParams(window.location.hash.slice(1)).get('invite');
  if (candidate && /^[A-Za-z0-9_-]{43}$/.test(candidate)) {
    invitationToken = candidate;
    window.history.replaceState(null, '', window.location.pathname + window.location.search);
  }
}
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
  private epoch = 0;
  private retryUntil = 0;
  private reads = new Map<
    string,
    { promise: Promise<Response>; controller: AbortController; users: number }
  >();
  readonly client: Client<paths>;

  constructor(
    readonly baseUrl: string,
    // Browser fetch needs Window as its receiver (not this OpsSession).
    private readonly transport: typeof fetch = (input, init) => globalThis.fetch(input, init),
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
    if (invitationToken) return;
    if (!this.storage.getItem(refreshKey)) return;
    const epoch = this.epoch;
    try {
      await this.refresh();
    } catch {
      if (epoch === this.epoch) this.clear();
    }
  }

  async signInGoogle(idToken: string) {
    const epoch = this.epoch;
    const response = await this.publicRequest('/v1/auth/ops/google', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken, ...(invitationToken ? { invitationToken } : {}) }),
    });
    const tokens = await response.json().then(unwrap<Tokens>);
    if (epoch !== this.epoch) throw new ApiError(401, 'session_changed', 'Sign in again.');
    this.save(tokens);
    invitationToken = null;
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
    this.checkCooldown();
    if (request.method !== 'GET') return this.sendAuthorized(request);
    const key = JSON.stringify([this.epoch, request.url, [...request.headers]]);
    let flight = this.reads.get(key);
    if (!flight) {
      const controller = new AbortController();
      const shared = new Request(request, {
        signal: AbortSignal.any([controller.signal, AbortSignal.timeout(30_000)]),
      });
      const promise = this.sendAuthorized(shared).finally(() => {
        if (this.reads.get(key)?.promise === promise) this.reads.delete(key);
      });
      flight = { promise, controller, users: 0 };
      this.reads.set(key, flight);
    }
    flight.users++;
    const sharedFlight = flight;
    try {
      return await new Promise<Response>((resolve, reject) => {
        const cancel = () => reject(new DOMException('Request cancelled', 'AbortError'));
        if (request.signal.aborted) {
          cancel();
          return;
        }
        request.signal.addEventListener('abort', cancel, { once: true });
        sharedFlight.promise
          .then((response) => {
            if (!request.signal.aborted) resolve(response.clone());
          }, reject)
          .finally(() => request.signal.removeEventListener('abort', cancel));
      });
    } finally {
      if (--sharedFlight.users === 0 && this.reads.get(key) === sharedFlight) {
        this.reads.delete(key);
        sharedFlight.controller.abort();
      }
    }
  }

  private checkCooldown() {
    const seconds = Math.ceil((this.retryUntil - Date.now()) / 1000);
    if (seconds > 0)
      throw new ApiError(
        429,
        'rate_limited',
        `Please wait ${seconds} seconds before trying again.`,
        String(seconds),
      );
  }

  private async sendAuthorized(request: Request) {
    if (!this.accessToken) throw new ApiError(401, 'not_authenticated', 'Sign in again.');
    const epoch = this.epoch;
    const check = () => {
      if (epoch !== this.epoch) throw new ApiError(401, 'session_changed', 'Sign in again.');
    };
    // Constructing the first authenticated Request consumes a POST/PATCH body.
    // Keep a pristine copy for a retry after rotating the access token.
    const retry = request.clone();
    const first = await this.transport(this.withAuth(request));
    check();
    if (first.status !== 401) return this.detectElevationExpiry(first);
    try {
      await this.refresh();
      check();
    } catch (error) {
      if (
        epoch === this.epoch &&
        error instanceof ApiError &&
        (error.status === 401 || error.status === 403)
      )
        this.clear();
      throw error;
    }
    const response = await this.transport(this.withAuth(retry));
    check();
    return this.detectElevationExpiry(response);
  }

  private async detectElevationExpiry(response: Response) {
    if (response.status === 429) {
      const header = response.headers.get('Retry-After');
      const numeric = header === null ? NaN : Number(header);
      const delay =
        Number.isFinite(numeric) && numeric >= 0
          ? numeric * 1000
          : Date.parse(header ?? '') - Date.now();
      this.retryUntil = Math.max(
        this.retryUntil,
        Date.now() + (Number.isFinite(delay) && delay >= 0 ? delay : 5000),
      );
    }
    if (response.status === 403 && (await errorFrom(response)).code === 'passkey_required')
      this.dispatchEvent(new Event('elevation-required'));
    return response;
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
      const epoch = this.epoch;
      const refreshToken = this.storage.getItem(refreshKey);
      if (!refreshToken) throw new ApiError(401, 'not_authenticated', 'Sign in again.');
      const response = await this.publicRequest('/v1/auth/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });
      const tokens = await response.json().then(unwrap<Tokens>);
      if (epoch !== this.epoch) throw new ApiError(401, 'session_changed', 'Sign in again.');
      this.save(tokens);
    })();
    try {
      await this.refreshing;
    } finally {
      this.refreshing = null;
    }
  }

  private async publicRequest(path: string, init: RequestInit) {
    const epoch = this.epoch;
    if (path !== '/v1/auth/logout') this.checkCooldown();
    const headers = new Headers(init.headers);
    for (const [key, value] of Object.entries(opsHeaders)) headers.set(key, String(value));
    const response = await this.transport(`${this.baseUrl}${path}`, {
      ...init,
      headers,
      signal: init.signal ?? AbortSignal.timeout(30_000),
    });
    if (epoch === this.epoch) await this.detectElevationExpiry(response);
    if (!response.ok) throw await errorFrom(response);
    return response;
  }

  private save(tokens: Tokens) {
    if (tokens.account.id !== this.accountValue?.id) this.resetReads();
    this.accessToken = tokens.accessToken;
    this.accountValue = tokens.account;
    this.storage.setItem(refreshKey, tokens.refreshToken);
    this.dispatchEvent(new Event('change'));
  }

  private clear() {
    this.resetReads();
    this.accessToken = null;
    this.accountValue = null;
    this.storage.removeItem(refreshKey);
    this.dispatchEvent(new Event('change'));
  }

  private resetReads() {
    this.epoch++;
    this.retryUntil = 0;
    for (const flight of this.reads.values()) flight.controller.abort();
    this.reads.clear();
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

// Required at build time (vite.config.ts refuses to build without it), so a
// production bundle can never quietly talk to staging.
export const apiBaseUrl = String(import.meta.env.VITE_API_BASE_URL ?? '').replace(/\/$/, '');
