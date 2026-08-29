// Redis-backed KvStore (ioredis). Selected when REDIS_URL is set. Covered by
// real-infra/e2e rather than unit tests — see vitest.config.ts excludes.

import { Redis } from 'ioredis';
import type { KvStore } from './kv.store';

// INCR plus a conditional EXPIRE, evaluated server-side so the pair cannot be
// torn apart by a dropped connection. Returns the post-increment count.
const INCREMENT_WITH_TTL = `
  local count = redis.call('INCR', KEYS[1])
  if count == 1 then
    redis.call('EXPIRE', KEYS[1], ARGV[1])
  end
  return count
`;

export class RedisKvStore implements KvStore {
  private readonly redis: Redis;

  constructor(url: string) {
    this.redis = new Redis(url, {
      // Surface connection problems instead of queueing forever.
      maxRetriesPerRequest: 3,
    });
  }

  async get(key: string): Promise<string | null> {
    return this.redis.get(key);
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    if (ttlSeconds === undefined) {
      await this.redis.set(key, value);
    } else {
      await this.redis.set(key, value, 'EX', ttlSeconds);
    }
  }

  async del(key: string): Promise<void> {
    await this.redis.del(key);
  }

  async increment(key: string, ttlSeconds: number): Promise<number> {
    // One atomic operation, not INCR-then-EXPIRE (#154). Split across two round
    // trips, a connection drop between them leaves the key with NO TTL: the
    // counter climbs forever, `count === 1` never recurs so the expiry is never
    // set again, and that subject is permanently 429'd until someone deletes the
    // key by hand. Low probability, but the failure mode is a locked-out rider
    // with no alert and nothing in the logs to explain it.
    //
    // Fixed-window semantics are unchanged: the TTL is still set only when the
    // counter is new, so the window does not slide on each request.
    const count = (await this.redis.eval(INCREMENT_WITH_TTL, 1, key, String(ttlSeconds))) as number;
    return count;
  }

  async ping(): Promise<boolean> {
    try {
      return (await this.redis.ping()) === 'PONG';
    } catch {
      return false;
    }
  }

  async close(): Promise<void> {
    await this.redis.quit();
  }
}
