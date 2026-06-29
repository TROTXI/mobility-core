// Key-value store abstraction with two implementations — InMemory (tests +
// zero-infra dev) and Redis (real runs, see kv.store.redis.ts). The server picks
// one by REDIS_URL, mirroring the repository pattern. Consumers (rate limiting,
// idempotency keys, caching) depend on this interface, not on Redis directly.

/** A small key-value store; backed by Redis in prod, in-memory in dev/tests. */
export interface KvStore {
  /**
   * Read a value.
   *
   * @param key - the key to read.
   * @returns the stored string, or null if absent/expired.
   */
  get(key: string): Promise<string | null>;
  /**
   * Set a value, optionally expiring after `ttlSeconds`.
   *
   * @param key - the key to write.
   * @param value - the value to store.
   * @param ttlSeconds - optional time-to-live; omit for no expiry.
   */
  set(key: string, value: string, ttlSeconds?: number): Promise<void>;
  /**
   * Delete a key (no-op if absent).
   *
   * @param key - the key to remove.
   */
  del(key: string): Promise<void>;
  /**
   * Atomically increment a counter, returning the new value. The TTL is set
   * only when the counter is first created, so the window does not slide on each
   * hit — the building block for fixed-window rate limiting.
   *
   * @param key - the counter key.
   * @param ttlSeconds - lifetime of the window, applied on first creation only.
   * @returns the counter's new value.
   */
  increment(key: string, ttlSeconds: number): Promise<number>;
  /**
   * Liveness check for the readiness probe.
   *
   * @returns true if the store is reachable.
   */
  ping(): Promise<boolean>;
  /** Release resources (connections, timers). */
  close(): Promise<void>;
}

interface Entry {
  value: string;
  /** Epoch ms when this entry expires, or null for no expiry. */
  expiresAt: number | null;
}

/** In-memory {@link KvStore} for dev and unit tests (no Redis). */
export class InMemoryKvStore implements KvStore {
  private readonly store = new Map<string, Entry>();

  /**
   * Return a live entry, lazily evicting it if it has expired.
   *
   * @param key - the key to read.
   * @returns the entry, or undefined if absent/expired.
   */
  private read(key: string): Entry | undefined {
    const entry = this.store.get(key);
    if (!entry) return undefined;
    if (entry.expiresAt !== null && entry.expiresAt <= Date.now()) {
      this.store.delete(key);
      return undefined;
    }
    return entry;
  }

  async get(key: string): Promise<string | null> {
    return this.read(key)?.value ?? null;
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    const expiresAt = ttlSeconds === undefined ? null : Date.now() + ttlSeconds * 1000;
    this.store.set(key, { value, expiresAt });
  }

  async del(key: string): Promise<void> {
    this.store.delete(key);
  }

  async increment(key: string, ttlSeconds: number): Promise<number> {
    const existing = this.read(key);
    const count = existing ? Number(existing.value) + 1 : 1;
    // Keep the original expiry across increments (fixed window).
    const expiresAt = existing ? existing.expiresAt : Date.now() + ttlSeconds * 1000;
    this.store.set(key, { value: String(count), expiresAt });
    return count;
  }

  async ping(): Promise<boolean> {
    return true;
  }

  async close(): Promise<void> {
    this.store.clear();
  }
}
