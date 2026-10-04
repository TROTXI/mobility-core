# Rate limiting and caches

Source audit: 2026-10-03.

The current API does not depend on Redis or fail-open KV counters.
PostgreSQL coordinates authenticated-account admission and anonymous/sign-in
IP budgets; a bounded local limiter rejects excess before expensive work.
Failures of shared admission refuse requests rather than silently bypassing it.

Default account admission is 120 requests/minute and general IP admission is
600/minute, with tighter credential-route limits. OTP spend, driver lockout
and boarding-code attempts have additional controls. Paystack webhooks also
pass shared anonymous admission before their signed body is buffered.

429 responses include Retry-After. Ops/mobile cooldown coordination does not
automatically replay a mutation. Caches are account/backend scoped and cleared
on session changes; no cached response establishes current access rights.

See [the detailed limits/cache guide](../rate-limiting-and-caching.md) and
[request performance](../operations/request-performance.md) for cache bounds,
cleanup and minimum-build caching. Those defaults are not a claim that live
environment overrides were inspected.

Sources: `services/api-next/src/runtime/admission.ts`, `src/http/app.ts`,
`apps/ops/src/api/`, `apps/trotxi_client/lib/`.
