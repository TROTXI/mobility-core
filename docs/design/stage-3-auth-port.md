# Stage 3: port existing sign-in and session logic

Base: integration merge `8f74dbd` (PR #297), not deploying `main`.
Review branch: `codex/stage-3-auth-port`. The payment baseline stays `43cdae0`.
No listener, staging deployment, account creation on staging, data reset or
consumer cutover is included. Stage 3 remains in progress.

## What is reused and what changes

The existing service already implemented Google/Apple verification, driver PINs,
refresh, logout and self-scoped sessions. This is a persistence/contract port,
not eight newly invented product features. Helpers under `src/auth` retain the
existing provider issuer/audience rules, Apple nonce/string-boolean handling,
PIN HMAC domain, six-digit policy, code normalization and random refresh format.
The HTTP surface uses the reviewed `/v1` named responses and expiry fields.

The replacement removes three concrete transaction/authorization gaps:

- Provider lookup, user creation, identity linkage and initial session commit
  together. Concurrent first sign-ins cannot leave an orphan user behind.
- Refresh consumption, next hash, session expiry and token signing are one
  transaction. A failed insert/sign/commit does not consume the old credential.
- Access JWTs include a stable `sid`. Protected transport and account operations
  check that session, the current user and driver eligibility in their own SQL
  transaction. Logout/revocation takes effect without waiting for JWT expiry.

The user lock is first: auth mutations take it exclusively; authorized transport
commands hold it shared through commit. Session and credential locks follow.
Known invalid-credential outcomes that must persist a lockout/revocation are
returned from the transaction, committed, then surfaced as HTTP errors. They
are not thrown inside the transaction and accidentally rolled back.

## Explicit behavior, not a silent policy rewrite

**Refresh reuse:** the old `AuthService.refresh` calls `revokeAllForUser`, despite
the old test describing “family” revocation. This port preserves all-user-session
revocation for an unexpired consumed credential. AUTH-03 checks both the winning
rotation and an unrelated device session become unusable. Losing a successful
refresh response and retrying that credential still rejects and revokes; no
secret response cache or grace period is invented. This remains a known baseline
limitation, distinct from a failed transaction whose original token still works.

**Device lifetime:** remembered/social sessions retain the rolling configured
refresh lifetime. Shared driver devices retain their fixed shift expiry across
rotation. The old issuer lost the shared-device TTL on refresh; preserving that
choice throughout the session fulfills ID-08. Each consumed generation retains
its own expiry; an already-expired old credential cannot revoke newer sessions.

**Driver lockout:** unknown code and wrong PIN return the same initial 401.
Five failures lock for 15 minutes, including concurrent attempts; 423 includes
the remaining `Retry-After`. A valid PIN after the lock expires clears counters.
Suspended/archived/unlinked drivers cannot use existing sessions. Future ops
suspension/reset commands must additionally revoke sessions in their mutation
transaction, matching the existing ops behavior. `mustChangePin` is metadata;
no mandatory PIN setup screen or new mobile navigation rule is introduced.

**Provider failures:** invalid signatures/audiences/expiry/nonce are 401; key-fetch
network failures or an unconfigured provider are 503. Google email claims now
require explicit `email_verified: true` when an email is present, matching the
existing Apple protection. JWT algorithms and expiry claims are explicit.
No known development signing-key fallback or JSON-token fake is ported.

**Apple:** keep the verified provider subject, first-login name, relay email and
existing best-effort optional authorization-code exchange. Captured provider
refresh tokens use AES-256-GCM with subject-bound AAD and a separate configured
key; they never enter generic command receipts or API output. Exchange/revoke
HTTP calls have a ten-second timeout. Apple token capture can still fail or be
lost if the external exchange succeeds but the DB transaction fails. This port
does not claim reliable erasure/revocation delivery; that workflow, provider key
rotation and its retry evidence remain required before launch.

## Scope and requirements

| Operations                       | Existing requirement                     | Proof                                                               |
| -------------------------------- | ---------------------------------------- | ------------------------------------------------------------------- |
| Google/Apple sign-in             | ID-01, ID-02, existing provider behavior | AUTH-01/02/10/13; real local-JWKS signature tests                   |
| Driver sign-in                   | ID-06, ID-07, ID-08                      | AUTH-07/08; normalization/HMAC/weak-PIN vectors                     |
| Refresh                          | ID-03, ID-07, ID-08                      | AUTH-03/04/08/14/15; observed contention and rollback               |
| Logout                           | ID-04                                    | AUTH-05/16; independent devices and in-flight authorization         |
| Account/session reads and revoke | ID-05; current session facts             | AUTH-06/09/12/15/17; pagination, self-scope, replay, runtime grants |

These are eight previously approved operations, not new target operations.
Revocation receipts contain no secrets and a fixed 204 outcome. They are scoped
to caller + target + key, expire after seven days, and authorize before replay.
Revoking a missing/foreign session is an indistinguishable no-op. Self-revocation
succeeds once; a retry with the now-revoked credential is 401, not cached access.

Migration `007` adds five tables (22 application tables total, **none payment**).
`001`–`006` are byte-identical. New relationships restrict deletion; no cascade
can erase transport/accounting history. Runtime roles remain independent of the
installer and cannot mutate completed receipt history, delete tables' rows or
install DDL. The installer must reapply grants after migrations.

## Evidence and remaining work

The new gate runs 17 Postgres scenarios and six pure/crypto tests. PG scenarios
use a fresh disposable database and narrow runtime login each, full migrations,
real JWT verification with local signed provider tokens, explicit blocking
connections and checked lock waiters. Missing DB configuration fails, never
skips. Provider network/sandbox behavior is **not** established by local JWKS.
Metadata records this boundary, migration hashes and cleanup targets; the full
suite records actual source hashes and JUnit results. Existing transport/catalog
gates run unchanged. No two-database payment comparison is claimed here.

Still separate: ops driver provisioning/issue/reset/status, self PIN change,
profile/avatar mutations, erasure/outbox cleanup, push registration, provider
secret configuration, auth retention/physical cleanup, distributed rate limiting
and trusted-proxy configuration. Avatar reads only sign an existing object key
through an explicit local signer; there is no fabricated public URL fallback.
Driver PG fixtures are owner-created test records, not an ops provisioning API.

The composed app still refuses a missing reservation coordinator. No permissive
default or test adapter is used to claim a deployable complete backend. The next
review slice can port credential/profile/erasure operations; subsequent business
slices still need membership, payments, reservations, boarding and GPS.
