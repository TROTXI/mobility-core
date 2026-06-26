# ADR-0010 — Key-value store (Redis) with in-memory fallback

**Status:** accepted · **Date:** 2026-06-26

## Context

We need a fast key-value layer for **rate-limit counters**, **idempotency keys**,
and short-lived **caching** (#22). We want the same "zero-infra locally, real in
production" ergonomics as the datastore (ADR-0009), and we don't want callers
binding directly to a Redis client.

## Decision

A **`KvStore` interface** (`get` / `set` with TTL / `del` / `increment` / `ping`
/ `close`) with two implementations, selected by **`REDIS_URL`** — mirroring the
repository pattern (ADR-0009):

- **`InMemoryKvStore`** — default (no `REDIS_URL`); zero infra for dev/tests/CI.
- **`RedisKvStore`** — `ioredis` (the rate-limiter ecosystem standard); used when
  `REDIS_URL` is set. Excluded from unit coverage like `*.pg.ts`.

Scope and guarantees:

- **Ephemeral data only** — counters, idempotency keys, cache. **Sessions and
  refresh tokens live in Postgres** (ADR-0007), _not_ Redis. So a wiped Redis
  loses nothing critical, and the **free, no-persistence Redis tier is safe** for
  the pilot (Render Key Value / Upstash).
- `increment(key, ttl)` is **fixed-window** (TTL set once, on first write) — the
  building block for rate limiting (#23).
- `/readyz` pings the KV when one is configured; it's closed on shutdown.

## Consequences

- Rate limiting (#23) and future idempotency keys build on this seam; **no Redis
  account is needed** for dev/tests/CI.
- Consumers treat the KV as best-effort — the rate limiter **fails open** if the
  store is unavailable, so a Redis outage degrades rather than downs the API.
- The pub/sub seam for the telemetry path (ADR-0002) can extend this client
  later rather than introducing a separate dependency.
