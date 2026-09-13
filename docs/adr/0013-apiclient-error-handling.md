# ADR-0013 — Generated Dio client with centralized auth and error handling

**Status:** accepted · **Date:** 2026-06-28 · **Last verified:** 2026-09-13

## Context

Both Flutter applications consume the same Zod-generated OpenAPI contract. They
need consistent bearer injection, token refresh and domain errors without
exposing generated `built_value` models or raw Dio failures to widgets.

## Decision

Use two packages:

- `apps/api_client`: generated from `GET /docs/json`; regenerated whenever the
  API contract changes and not hand-edited.
- `apps/trotxi_client`: a handwritten wrapper that constructs the generated
  client and owns interceptors and shared exception types.

`TrotxiClientFactory` installs interceptors in this order:

1. `AuthInterceptor` injects the bearer token. On a non-sign-in `401`, it runs
   one shared refresh for all concurrent failures, stores the rotated pair and
   retries the original request once.
2. `ErrorInterceptor` translates the final Dio failure into an app-level error.

Refresh and retry failures are separate. Only a `401` from `/auth/refresh`
automatically clears the matching stored session. Refresh timeouts, connectivity
errors, cancellation and server errors preserve it and surface their actual error
category. A failed retry preserves the newly rotated tokens, even if that retry
returns `401`; it does not start another refresh. Explicit sign-out still clears
tokens normally.

The auth interceptor is not queued: an error handler awaiting a retried request
must not block the queue that processes that retry's errors. A shared future
serializes refresh alone. Delayed old-token failures reuse a known rotated token,
not an unrelated new login. The retry marker and idempotent error mapping keep
failures bounded and prevent a server error being remapped to "offline".

| Condition                                  | App error                                      |
| ------------------------------------------ | ---------------------------------------------- |
| Sign-in `401`                              | `InvalidCredentialsException`                  |
| Refresh rejection or retried request `401` | `UnauthorizedException`                        |
| Driver sign-in `403`                       | `AccountSuspendedException`                    |
| Driver credential `423`                    | `CredentialLockedException` with `Retry-After` |
| Any `429`                                  | `RateLimitException` with `Retry-After`        |
| Connection/timeout with no response        | `OfflineException`                             |
| Other HTTP error                           | `ApiException(statusCode, message)`            |

Widgets call app-specific repositories, not Dio or generated APIs directly.
Repositories unwrap the typed error from Dio and translate it into the state a
controller or screen needs.

## Consequences

- API schema drift is caught by client regeneration and compilation.
- Concurrent `401`s cannot race multiple rotating refresh-token calls.
- A rejected sign-in never triggers refresh or clears an existing session.
- Interceptor order is load-bearing and covered by tests.
- Generated one-of request types are re-exported by the wrapper so applications
  do not import generator dependencies directly.

## Current implementation

The wrapper is used by both Flutter apps. The driver app additionally layers
repository classes and ADR-0016 controllers over it. Tests cover error mapping,
single-flight refresh, refresh/retry failure separation, sign-in exceptions and
delayed responses across token rotation. CI runs the shared wrapper's tests in
addition to both app suites.
