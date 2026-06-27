// Redis-backed KvStore (ioredis). Selected when REDIS_URL is set. Covered by
// real-infra/e2e rather than unit tests — see vitest.config.ts excludes.

import { Redis } from 'ioredis';
import type { KvStore } from './kv.store';

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
    const count = await this.redis.incr(key);
    // Set the expiry only on first creation so the window doesn't slide.
    if (count === 1) {
      await this.redis.expire(key, ttlSeconds);
    }
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
