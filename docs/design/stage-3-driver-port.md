# Stage 3: existing driver provisioning and credentials

Base: integration merge `8a1a466` (auth PR #298).
Review branch: `codex/stage-3-driver-credentials`.
The payment baseline remains `43cdae0`. No listener, staging deployment, account
creation on staging, mobile screen change or integration/main merge is included.

## Ported surface

Seven already-reviewed operations bring the composed factory from 37 to 44:

| Operation                                       | Existing source / requirement                           |
| ----------------------------------------------- | ------------------------------------------------------- |
| GET/POST /v1/ops/drivers                        | Existing mobility admin driver list/create              |
| PATCH /v1/ops/drivers/{id}                      | Existing mobility admin driver edit; per-resource token |
| POST /v1/ops/drivers/{id}/credentials           | Existing DriverAuthService.issueCredentials; ID-06      |
| POST /v1/ops/drivers/{id}/credentials/reset-pin | Existing resetPin; ID-06/07                             |
| POST /v1/ops/drivers/{id}/credentials/actions   | Existing suspend/activate/unlock; ID-06/07              |
| POST /v1/auth/driver/pin                        | Existing changePin; ID-06/07                            |

The source behavior is in the existing
`services/api/src/modules/auth/driver-auth.service.ts` and mobility admin routes.
This is not a new driver UI or new transport/boarding implementation.
Driver detail GET remains deferred. List rows carry `editToken` for edits.
The target contract's issue-code field is now optional: an omitted code preserves
the existing ops-generated-code flow; explicit codes are normalized and unique.
Six-digit PIN/HMAC/code/weak-PIN primitives come from the previous auth port.

## Preserved behavior and explicit hardening

- Provisioning without a linked user is allowed. Credential issue creates and
  links the driver principal atomically with the credential, receipt and event.
  A linked user must already have the driver role and not be erased. Linking
  does not silently promote a commuter/admin; role administration is separate.
- Reset clears lockout and revokes **all** sessions, but never reactivates a
  suspended credential. Unlock clears lockout without activating it. Activation
  does not revive previously revoked sessions.
- Self PIN change verifies the current PIN, rejects trivial/reused replacements,
  clears `mustChangePin`, and revokes all sessions including the current one,
  matching the existing implementation. Its retry using that revoked session is
  401, not cached authorization. No mandatory PIN setup screen is reintroduced.
- Wrong current-PIN attempts now use the same durable five-attempt/15-minute
  lockout as sign-in. This is additional brute-force protection on the existing
  change operation. Counters commit on rejection, without a successful receipt.
- Archived drivers cannot issue/reset credentials or use sessions. Archive
  rejects scheduled/active assignments; driver row locking coordinates with
  the existing trip guard's shared driver lock. Cancelled/completed history
  remains intact.
- Once credentials or any trip history exists, an established user link cannot
  be transferred/cleared by profile PATCH, enforced by a DB trigger. Initial
  null-to-principal provisioning remains valid. A future explicit reassignment
  workflow must decide consequences; this slice does not invent one.

## Transactions, authorization and retries

Commands discover the target internally, lock all existing principals in UUID
order, authorize from current session/user facts, then lock driver/credential
rows. User locks serialize same-actor retries and credential changes with sign-in.
A concurrent first issue can establish a principal after discovery; the losing
request restarts the entire transaction to lock that principal in the correct
order rather than acquiring user-after-driver. This restart is bounded.

Authorization precedes receipt replay. Scope is actor + operation + normalized
target + key; normalized input is HMAC-digested using the dedicated replay key,
not a public SHA of low-entropy PIN input. Different input conflicts.
Missing drivers return 404 before edit preconditions; fresh edits require
If-Match, but an authorized same-input completed retry replays before stale ETags.
Each successful mutation, completed receipt and attributable event commits
together. Receipt/event failure rolls everything back, including revocation.

Ordinary completed receipts expire after seven days and never re-execute.
Issue/reset return the same encrypted secret for at most five minutes. They
store no plaintext response JSON. AES-256-GCM binds ciphertext to the complete
receipt scope/id; current `pin_version` is also checked. A later PIN change,
archive, expiry or erasure of ciphertext makes old secret replay a 409, never a
fresh implicit reset. Suspension still permits authorized ops reset/replay but
does not permit sign-in.

The composed factory requires a separate 32-byte `credentialReplayKey` and
rejects reuse of signing/cursor/PIN/Apple keys. It has no fallback key. This
slice does not implement key rotation: retain the configured key through receipt
lifetimes; introducing a keyring/versioned digests is deployment work before
rotation. Changing it arbitrarily would invalidate existing replay comparisons.

## Storage and evidence

Append-only migration 008 adds driver contact fields, credential generation,
driver command receipts and driver events: **24 application tables**, none
payment. Migrations 001–007 are unchanged. Audit events contain attributable
operations and ops-authored reason, not PIN/token/hash/body snapshots. Reasons
must not be used to submit secrets.

Runtime cannot update/delete events or rewrite receipts. Its only receipt
UPDATE grant is ciphertext erasure, and the trigger permits only a one-way
change to NULL with all other columns unchanged. Event actor/driver ownership
has a deferred composite FK to its command. This is receipt attribution, not a
claim that arbitrary SQL mutations are guaranteed to emit an event.

The new 15 Postgres scenarios use disposable databases, narrow runtime logins,
real locally signed JWTs, HTTP provisioning and observed lock contention.
DRV-02 proves one first-issued credential under real contention; DRV-05 injects
an event failure and checks PIN/session/key rollback; DRV-13 races sign-in/reset.
DRV-14 uses explicit owner-only trip assignment facts because the real booking
coordinator is still absent; it does not claim assignment/booking delivery.
DRV-15 tests deferred actor attribution at commit. Crypto tests check wrong
scope/key rejection and keyed PIN input digests.

## Still required

`purgeExpiredDriverSecrets(pool, limit)` supplies bounded, skip-locked physical
ciphertext erasure. Logical expiry is already enforced on reads. Scheduling the
worker, choosing its interval, key provisioning/rotation and broader auth
retention remain deployment prerequisites—not delivered by this helper.
No additional unreviewed maintenance endpoint was added.

The factory still refuses a missing reservation coordinator. Membership,
payments, reservations, boarding, GPS and remaining identity/erasure operations
remain separate slices. Existing apps and staging are unchanged.
