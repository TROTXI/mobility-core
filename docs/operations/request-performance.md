# Request-path performance

## Changes

- Minimum supported mobile builds are cached for 30 seconds per API process,
  separately for each app and platform. Concurrent misses share a read. A
  successful Ops update invalidates the local cache after commit, including
  in-flight reads. Other replicas observe the update within 30 seconds. An
  expired cache does not bypass a failed database read.
- The common transaction setup sends `BEGIN` and its three `SET LOCAL` commands
  in one database round trip. Time zone, lock timeout, statement timeout and
  repeatable-read isolation are unchanged. Specialized workers keep their own
  existing limits and batch only their setup statements.
- Transport reuses the role and driver ID returned by authentication inside the
  same transaction. Authentication still checks current database state and holds
  user, session and credential locks in the established order. No token claims
  or cross-request authorization cache replace those checks.
- GPS ingestion reads the server clock with the locked trip, avoiding a separate
  clock query. The materialized locked row precedes clock evaluation.
- The driver's map uses the already-running native GPS stream. It no longer
  polls the API for the device's own position. The label says **Device GPS**:
  this is not confirmation that the server received the fix. Existing upload
  health indicators and durable offline queues remain authoritative for delivery.
- Stop ETAs still use the server's route-based calculation and foreground-only
  live refresh. No straight-line estimate replaces a road-based ETA. Trip detail
  caching already existed and remains unchanged.
- Concurrent live reads share a result, including an empty position. Late
  responses cannot refill another session's cache. Route shapes and live fix
  caches retain at most 32 and 16 entries respectively.

On a warm-cache driver position upload, the code removes up to seven database
round trips: three setup calls, two repeated identity lookups, one clock read,
and one build-floor lookup. This is a request-count reduction, not a measured
production latency claim. Database execution, network latency and cold starts
still need real-environment measurement.

## Ops asset caching

`render.yaml` declares `Cache-Control: public, max-age=31536000, immutable` only
for `/assets/*`, where Vite emits content-hashed bundles. HTML, legal pages and
unhashed public files are deliberately excluded. Keep manually copied public
files out of that path unless their names are content-versioned.

A commit deployment does not apply Render header settings. After merge, apply
the reviewed header rule to the Ops static site through its Blueprint or Render
Headers settings. Verify an actual asset referenced by the deployed HTML has
the immutable header, and that `/` and `/privacy` do not. Do not enable other
Blueprint services as part of this change.

## Verification and limits

- Run all API PostgreSQL suites serially, unit tests, type checking and contract
  tests. Cache tests cover concurrent requests, expiry, failure, write
  invalidation and late reads. Transaction tests cover commit, rollback, errors,
  isolation and pooled-connection setting cleanup.
- Run driver analysis and tests. Check local marker changes, trip completion,
  account changes, offline delivery and foreground/background transitions.
- Compare warm authenticated request latency and database query counts under the
  same load before and after deployment. Keep cold-start timings separate.
- Hosting plans, per-user admission writes, session locks and provider settings
  are unchanged. No paid cache service or hosting upgrade is introduced.

References: [PostgreSQL client timeouts](https://www.postgresql.org/docs/18/runtime-config-client.html),
[Render static-site headers](https://render.com/docs/static-site-headers).
