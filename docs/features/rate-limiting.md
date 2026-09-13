# Rate limiting

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Live.

The Fastify `app.rateLimit()` pre-handler implements fixed-window counters over
the KV abstraction. Development/tests use memory; production uses Redis when
`REDIS_URL` is configured.

## Buckets

- Pre-auth credential routes use IP buckets, normally 10 requests/minute.
- Authenticated routes use user-ID buckets and the configurable default.
- Public database-backed routes use IP buckets.
- The Paystack webhook is not rate-limited by source IP. Paystack retries and
  bursts share a small provider address set, so an IP bucket could discard valid
  money events; signature verification and the durable inbox are its controls.

Every response includes limit/remaining headers. Exceeding the budget returns
`429` with `Retry-After`.

## Proxy requirement

On Render, `request.ip` is meaningful only when `TRUST_PROXY` trusts the private
load-balancer ranges. The production value is
`loopback, linklocal, uniquelocal`. Numeric hop counts are rejected at startup
because Fastify 5.12 treats them as fail-closed and would collapse users onto the
load balancer's address.

## Failure posture

The generic rate limiter and boarding attempt budgets fail open if KV is down;
an outage must be visible in telemetry but must not take the API or vehicle door
down. Driver credential lockout is different: it lives durably in PostgreSQL and
fails closed.

Rate limiting is never authorization. Protected routes still authenticate,
enforce roles and perform ownership/assignment checks.

## Configuration

| Variable                    | Default                         | Purpose                                          |
| --------------------------- | ------------------------------- | ------------------------------------------------ |
| `RATE_LIMIT_MAX`            | `100`                           | General requests per window                      |
| `RATE_LIMIT_WINDOW_SECONDS` | `60`                            | Window length                                    |
| `TRUST_PROXY`               | private/loopback list on Render | Trusted proxy addresses                          |
| `REDIS_URL`                 | unset                           | Select Redis instead of the in-memory KV adapter |

## Code

- `services/api/src/modules/ratelimit/ratelimit.plugin.ts`
- `services/api/src/kv/`
- [ADR-0010](../adr/0010-kv-redis.md)
