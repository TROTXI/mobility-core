# Rate limiting and caching — replacement system

Code audit: 26 September 2026. Limits below are defaults, not a claim that live
Render environment overrides were inspected.

## Admission controls shared by Ops and mobile clients

- Authenticated accounts: 120 requests/minute by default, shared across API
  instances using a PostgreSQL atomic counter. Different sessions/apps do not
  get separate budgets for the same account. Exhaustion returns 429 and a
  `Retry-After` header. Fixed clock-aligned windows permit a boundary burst.
- IP admission: 600 requests/minute by default, bounded process-local Fastify
  storage. This is not a shared global IP budget across instances. Trusted proxy
  configuration determines whether callers are counted correctly.
- Sign-in, PIN changes and passkey routes: tighter 10/minute IP route limits.
  Driver PIN failures additionally lock the credential after five failures for
  15 minutes. Boarding-code attempts have their own driver/trip budget.
- No Redis deployment is required. PostgreSQL admission costs one round trip
  per authenticated request; revisit if load testing identifies it as a bottleneck.

## Caching

- Reviewed API routes set `Cache-Control: no-store`. ETags/edit tokens enforce
  concurrent edits; their presence does not imply an HTTP response cache.
- Ops holds screen query results in React state, not a shared persistent data
  cache. Overview/live trip polls run every ten seconds; manifests every minute.
- Driver configuration has a backend/session-realm-scoped persistent fallback.
  Published geometry is reused by pattern version, live reads have a five-second
  cache, and assignment/session checks must precede sensitive reuse.
- Commuter tracking reauthorizes each live read. It reuses geometry and stop
  occurrences for the selected version but does not reuse a cached position as
  evidence of current entitlement. Its tracking loop backs off on rate limits.
- Offline GPS storage is a durable delivery queue, not a cache of authoritative
  live positions. A matching receipt, not successful local storage, establishes
  delivery. GPS upload now respects `Retry-After` without discarding queued IDs.

## Gaps worth addressing before greater scale

1. Ops polling does not consistently pause for hidden tabs or respect server
   cooldowns. Generated-client call sites often flatten typed errors to messages.
2. Driver non-GPS polling uses fixed intervals; it needs coordinated cooldowns
   across the account's requests rather than independent repeated 429s.
3. Ops queries are per-screen, without shared request deduplication. Abort helps,
   but rapidly changing filters can waste work; late-success handling should be
   guarded explicitly as well as cancelling transport.
4. IP limits can affect many phones sharing depot/bus Wi-Fi, and process-local
   limits grow with instance count. Measure before changing defaults.
5. No general server response cache reduces repeated catalogue/database reads.
   If added, cache only immutable/public data with explicit version keys; do not
   cache entitlement, mutable manifests, balances or authorization decisions.

Current controls are suitable as a conservative pilot starting point, not proof
of capacity or complete abuse protection. Avoid introducing a broad private-data
cache or Redis solely for appearance; measure actual latency and request volume.
