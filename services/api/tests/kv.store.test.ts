import { afterEach, describe, expect, it, vi } from 'vitest';
import { InMemoryKvStore } from '../src/kv/kv.store';

describe('InMemoryKvStore', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it('stores and retrieves a value', async () => {
    const kv = new InMemoryKvStore();
    await kv.set('k', 'v');
    expect(await kv.get('k')).toBe('v');
  });

  it('returns null for a missing key', async () => {
    const kv = new InMemoryKvStore();
    expect(await kv.get('nope')).toBeNull();
  });

  it('deletes a key', async () => {
    const kv = new InMemoryKvStore();
    await kv.set('k', 'v');
    await kv.del('k');
    expect(await kv.get('k')).toBeNull();
  });

  it('expires a value after its TTL', async () => {
    vi.useFakeTimers();
    const kv = new InMemoryKvStore();
    await kv.set('k', 'v', 10);

    vi.advanceTimersByTime(9_000);
    expect(await kv.get('k')).toBe('v');

    vi.advanceTimersByTime(2_000);
    expect(await kv.get('k')).toBeNull();
  });

  it('increments a counter from zero', async () => {
    const kv = new InMemoryKvStore();
    expect(await kv.increment('c', 60)).toBe(1);
    expect(await kv.increment('c', 60)).toBe(2);
    expect(await kv.get('c')).toBe('2');
  });

  it('keeps the original TTL across increments (fixed window)', async () => {
    vi.useFakeTimers();
    const kv = new InMemoryKvStore();

    await kv.increment('c', 10); // window opens, expires at t+10s
    vi.advanceTimersByTime(6_000);
    expect(await kv.increment('c', 10)).toBe(2); // does NOT extend the window

    vi.advanceTimersByTime(5_000); // now past the original 10s
    expect(await kv.get('c')).toBeNull();
    // A fresh increment starts a new window at 1.
    expect(await kv.increment('c', 10)).toBe(1);
  });

  it('reports ready and clears on close', async () => {
    const kv = new InMemoryKvStore();
    expect(await kv.ping()).toBe(true);
    await kv.set('k', 'v');
    await kv.close();
    expect(await kv.get('k')).toBeNull();
  });
});
