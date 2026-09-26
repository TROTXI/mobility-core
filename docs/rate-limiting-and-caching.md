# Rate limiting and caching — replacement system

Code audit: 26 September 2026. Limits below are defaults, not a claim that live
Render environment overrides were inspected.

## Admission controls shared by Ops and mobile clients

- Authenticated accounts: 120 requests/minute by default, shared across API
  instances using a PostgreSQL atomic counter. Different sessions/apps do not
  get separate budgets for the same account. Exhaustion returns 429 and a
  `Retry-After` header. Fixed clock-aligned windows permit a boundary burst.
- IP admission: 600 requests/minute by default. A bounded process-local limiter
  refuses obvious excess before parsing/authentication; a PostgreSQL second line
  shares the budget across instances for anonymous/sign-in routes only. Session
  routes (including GPS, boarding and Ops polling) use the shared account budget
  without an extra IP database write. IP digests use a purpose-separated HKDF
  key derived from the cursor root, not the cursor key directly; no raw addresses
  are stored. Trusted proxy configuration determines correct counting. Health
  checks do not depend on shared admission.
- Paystack webhooks share the anonymous `all` IP bucket too. Admission runs
  after the local limiter but before buffering the signed body; admitted
  requests retain the exact bytes used for signature verification.
- Sign-in, PIN changes and passkey routes: tighter 10/minute IP route limits.
  Driver PIN failures additionally lock the credential after five failures for
  15 minutes. Boarding-code attempts have their own driver/trip budget.
- No Redis deployment or new secret is required. Anonymous shared IP admission
  adds one PostgreSQL round trip; public authentication routes add another scoped
  check. Signed-in requests retain only their existing account check. Failure refuses requests with
  503 instead of bypassing admission. Revisit the storage if load tests identify
  it as a bottleneck.
- Expired counter cleanup is the existing `node dist/worker.js admission` job.
  Add it to the scheduling checklist (suggested every five minutes). Until jobs
  are enabled, run it manually and drain bounded batches; nothing in this PR
  schedules a paid service. Upserts reuse a subject's row, but distinct subjects
  accumulate without cleanup.

## Caching

- Reviewed API routes set `Cache-Control: no-store`. ETags/edit tokens enforce
  concurrent edits; their presence does not imply an HTTP response cache.
- Ops holds screen query results in React state, not a shared persistent data
  cache. Overview/live trip polls run every ten seconds; manifests every minute.
  Hidden tabs do not start reads, returning to the tab refreshes, and polling
  does not cancel/restart an unfinished read. Matching in-flight GETs share one
  transport with independent cancellation; completed responses are not cached.
  Filter changes discard old rows, and aborted/old-session replies cannot
  populate a new screen or restore credentials after logout.
- Driver configuration has a backend/session-realm-scoped persistent fallback.
  Published geometry is reused by pattern version, live reads have a five-second
  cache, and assignment/session checks must precede sensitive reuse.
- Commuter tracking reauthorizes each live read. It reuses geometry and stop
  occurrences for the selected version but does not reuse a cached position as
  evidence of current entitlement. Its tracking loop backs off on rate limits.
  The shared data client holds at most 64 immutable geometries by ID, shares
  in-flight geometry reads, retries failures, and clears them on account changes.
- Both mobile apps and Ops coordinate `Retry-After` cooldowns across screens,
  rather than sending repeated requests from independent polling loops. Delta
  seconds and HTTP dates are supported; absent/invalid headers use five seconds.
  New login/logout clears the cooldown. Driver GETs share matching pending reads,
  not completed private responses. Mutations are never replayed by this mechanism.
  Account-wide cooldown is deliberate: retrying a different endpoint cannot
  bypass the shared account budget. This can also conservatively pause unrelated
  calls after an endpoint/IP refusal; finer cooldowns require a server-declared
  scope, not guessing from the URL.
- Offline GPS storage is a durable delivery queue, not a cache of authoritative
  live positions. A matching receipt, not successful local storage, establishes
  delivery. GPS upload now respects `Retry-After` without discarding queued IDs.

## Gaps worth addressing before greater scale

1. IP limits can affect many phones sharing depot/bus Wi-Fi. Measure before
   changing defaults; neither the shared counter nor client cooldown replaces
   upstream DDoS protection.
2. No general server response cache reduces repeated catalogue/database reads.
   If added, cache only immutable/public data with explicit version keys; do not
   cache entitlement, mutable manifests, balances or authorization decisions.

Current controls are suitable as a conservative pilot starting point, not proof
of capacity or complete abuse protection. Avoid introducing a broad private-data
cache or Redis solely for appearance; measure actual latency and request volume.
