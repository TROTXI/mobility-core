# Rate limiting

**Owner:** Godfred Awuku · **Last updated:** 2026-06-28

**Status:** ✅ live (#23).

A reusable guard that caps how often a client can hit a route — protecting
credential and abuse-prone endpoints from brute force, scraping, and basic DoS.
Fixed-window counting, backed by the KV store. Deep design: `strategy/security.md
§8`; storage: [ADR-0010](../adr/0010-kv-redis.md).

---

## Concepts

- **Fixed window.** A counter per `(route, subject)` with a TTL set **once**, on
  the first hit — the window doesn't slide. Built on `KvStore.increment`.
- **Subject = IP or user.** `by: 'ip'` (default) buckets per client IP — used for
  pre-auth endpoints. `by: 'user'` buckets per authenticated user — used for
  logged-in abuse. `by: 'user'` falls back to IP if there's no principal, so the
  limit is never silently skipped.
- **Fails open.** If the KV store is unavailable the request is **allowed** (a
  cache outage must not take the API down) — logged as a warning.
- **Backing store.** In-memory in dev/tests, Redis in prod ([ADR-0010](../adr/0010-kv-redis.md)).

---

## Usage

`app.rateLimit(options)` is a preHandler factory (decorator on the Fastify
instance):

```ts
// per IP (e.g. a public or pre-auth endpoint)
app.post('/auth/google', { preHandler: [app.rateLimit({ max: 10, windowSeconds: 60 })] }, h);

// per user (compose AFTER authenticate)
app.get(
  '/me',
  { preHandler: [app.authenticate, app.rateLimit({ max: 100, windowSeconds: 60, by: 'user' })] },
  h,
);
```

| Option          | Default | Meaning                        |
| --------------- | ------- | ------------------------------ |
| `max`           | —       | requests allowed per window    |
| `windowSeconds` | —       | window length                  |
| `by`            | `'ip'`  | bucket key: `'ip'` or `'user'` |

## Response

- Under the limit → the route runs, with headers:
  - `X-RateLimit-Limit` — the cap
  - `X-RateLimit-Remaining` — remaining in the window
- Over the limit → **429** with `Retry-After: <windowSeconds>` and body
  `{ "error": "rate_limited", "message": "Too many requests. Try again later." }`.

Clients should honour `Retry-After` and back off.

## Where it's applied today

| Endpoint(s)                                      | Limit                                            |
| ------------------------------------------------ | ------------------------------------------------ |
| `POST /auth/google`, `POST /auth/refresh`        | **10/min per IP** (strict, credential endpoints) |
| `GET /me`, `GET /me/balance`, `POST /payments/*` | default, **per user**                            |
| `POST /webhooks/paystack`                        | 60/min per IP                                    |

Public browse endpoints (mobility) should also opt in per IP as they land.

## Configuration

| Env var                     | Default | Notes                                                              |
| --------------------------- | ------- | ------------------------------------------------------------------ |
| `RATE_LIMIT_MAX`            | `100`   | default per-window cap (the value passed to per-user route limits) |
| `RATE_LIMIT_WINDOW_SECONDS` | `60`    | default window                                                     |

Auth/webhook endpoints use their own stricter inline limits (above); the env
defaults drive the general per-user limits.

## Security notes

- **Per-IP for pre-auth** (login/refresh) is the brute-force guard; **per-user**
  protects authenticated abuse.
- **Fail-open is a deliberate trade-off** — availability over strictness. A
  determined attacker who can take down Redis could bypass limits; acceptable for
  the pilot, revisit if it becomes a vector.
- It is **not** a substitute for auth or ownership checks — it only throttles.

## Local development & testing

Works with zero infra (in-memory KV). To see it trigger, hit a tightly-limited
route repeatedly:

```bash
# /auth/refresh is 10/min per IP — the 11th call in a minute returns 429
for i in $(seq 1 11); do
  curl -s -o /dev/null -w "%{http_code}\n" -XPOST localhost:3000/auth/refresh \
    -H 'content-type: application/json' -d '{"refreshToken":"x"}'
done
# → 401 ×10 (bad token, but allowed), then 429
```

## Where the code lives

```
services/api/src/modules/ratelimit/ratelimit.plugin.ts   # app.rateLimit(...)
```

## Related

- [ADR-0010 — KV/Redis](../adr/0010-kv-redis.md) (the backing store)
- `strategy/security.md §8 (rate limiting & abuse)`
- Issue #23
