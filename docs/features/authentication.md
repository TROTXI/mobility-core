# Authentication and sessions

Source audit: 2026-10-03.

## Sign-in methods

- Commuters: `POST /v1/auth/google`, optional configured Apple, or
  `/v1/auth/phone/request` then `/v1/auth/phone/verify`.
- Drivers: `POST /v1/auth/driver` with driver code and six-digit PIN.
  Ops creates drivers and issues/resets temporary credentials. Temporary PINs
  expire and require a private PIN change before normal driver work.
- Ops: invited Google account plus WebAuthn passkey registration/authentication.
  Current database role and session elevation are enforced on Ops requests.
  Invitations require both their secret link and the matching verified Google
  identity. They never replace the passkey check.

HS256 access tokens are verified for signature, issuer, audience and expiry.
Current session, role and account state are checked in the database.
Refresh tokens rotate; consumed-token reuse revokes sessions. Mobile credentials
use OS secure storage; Ops access tokens are in memory and refresh state is
tab-scoped. There is no fake-provider fallback in the deployed composition.

## Phone verification and account boundaries

mNotify delivers six-digit codes. A successful phone sign-in records verified
phone possession for that phone account. Google/Apple users can sign in without
a phone; the authenticated `/v1/me/phone-verification/start` and `confirm`
flow verifies their number before standby enrollment/acceptance.

A basic rider name and an active verified phone record are required for standby.
A profile phone field, payment phone or social login is not verification.
Matching numbers never silently merge accounts or transfer subscriptions.
Collision/review states do not authorize taking another account's number.

OTP has bounded lifetime, attempts, resend and shared spend limits. Uncertain
delivery invalidates the challenge instead of pretending a usable code was sent.
See [mNotify operations](../operations/mnotify-phone-sign-in.md).

## Driver and administrator controls

Ops can issue/reset, suspend, reinstate and unlock driver credentials. Resets
revoke sessions. Delivery can be SMS or email, or a private one-time handoff;
do not log credentials. [Onboarding](../driver-onboarding.md) covers recovery.

Passkey reset requires another elevated superadmin. Phone OTP is not an Ops
second factor. The dedicated maintenance identity is non-human and separate
from interactive operators.

Sources: `services/api-next/src/auth/`, `runtime/config.ts`,
`apps/ops/src/auth/`, `apps/trotxi_driver/lib/core/state/session_controller.dart`.
Configuration support does not prove Apple or production provider setup.

## Flow and ownership

```mermaid
flowchart TD
  entry["Choose sign-in"] --> method{"Phone or social"}
  method -->|"Phone"| loginCode["Request and verify OTP"]
  method -->|"Social"| social["Verify provider identity"]
  loginCode --> session["Authenticated account"]
  social --> session
  session --> eligible{"Name and phone verified"}
  eligible -->|"Yes"| request["Request subscription"]
  eligible -->|"No"| profile["Complete name and account-bound OTP"]
  profile --> request
```

The commuter initiates login and stores tokens through the shared client.
The API verifies credentials and owns sessions/phone verification. mNotify
delivers the challenge but cannot itself grant access. Ops has a separate
Google-plus-passkey flow; driver access uses code/PIN, not commuter OTP.

| Situation                          | Client behavior                                                 | Server boundary                                                          |
| ---------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------ |
| Google sign-in, phone unverified   | Allow ordinary account access; verify before requesting service | Standby rejects missing verification                                     |
| Phone OTP already succeeded        | Do not ask for another OTP just to join                         | Verified record still belongs to that account                            |
| Expired/wrong/replayed code        | Show failure; request a fresh challenge when eligible           | No session/verification granted                                          |
| Send refused or unconfirmed        | Show delivery failure and retry guidance                        | Do not treat challenge as verified                                       |
| 429                                | Honor Retry-After; preserve user input                          | Shared and purpose-specific budgets apply                                |
| Account number collision           | Show the explicit review/conflict state                         | No silent account/subscription merge                                     |
| Refresh request loses its response | Use shared-session recovery behavior                            | Refresh tokens are single-use; unsafe parallel reuse can revoke sessions |

Temporary driver PINs must complete private-PIN setup before trip work.
Never implement a generic “retry every 401” wrapper around mutations.

Developer entry points:
[OTP](../../services/api-next/src/auth/phone-otp.ts),
[auth service](../../services/api-next/src/auth/service.ts),
[session client](../../apps/trotxi_client/lib/commuter_session_client.dart).
Tests: [auth](../../services/api-next/tests/auth.pg.test.ts) and
[account](../../services/api-next/tests/account.pg.test.ts).
Requests: [worked auth examples](../api/worked-examples.md#2-establish-commuter-eligibility).

## Invite only Ops access

The Ops login uses `POST /v1/auth/ops/google`, not the commuter registration
endpoint. An uninvited Google identity receives `ops_access_required` without
creating an account. Existing administrators continue to sign in normally.
`isSuperadmin` is an additional capability on an admin, checked in the database
on each access-management request; it is not trusted from a token or UI flag.

Only an elevated superadmin can list the team, issue/resend/cancel invitations,
change administrator access or reset another operator's passkeys. Ordinary
admins retain dispatch and support work. The old role endpoint cannot grant
admin access and now also requires superadmin authorization.

An invitation lasts 48 hours. Email delivery uses the encrypted transactional
outbox, immediate delivery attempt and existing retry worker. Provider acceptance
does not prove inbox delivery. Resending rotates the secret and makes the old
link unusable. The database stores only its hash; the encrypted email contains
the link. The UI removes the URL fragment before sign-in and keeps the secret
only in memory. Reloading before sign-in may require reopening the email.

Google verification must return the invited email. Matching a profile email
alone never grants access or merges identities. Claiming gives that account
only passkey-setup access. Completing a verified passkey ceremony before expiry
activates Ops access and consumes the invitation. Cancellation during setup
revokes sessions and removes the pending admin role. Expired setup cannot activate.

Invitations that were never claimed can be resent, including after expiry.
Cancel an expired claimed invitation before issuing a replacement. Expired
invitations remain in Team & access until a superadmin resolves them. Acceptance
and cancellation scrub the duplicate invite name/email and secret. Account
erasure also scrubs matching invitations; audit IDs remain, without link secrets.

Access changes and passkey resets appear in Audit log. Revocation through Team
removes the admin role and revokes sessions, but does not delete the person's
commuter account or subscription. Self access changes are refused. The database
also refuses removing or erasing the last superadmin.

Source: [team service](../../services/api-next/src/auth/ops-team.ts).
First-owner setup: [deployment](../DEPLOY.md#first-superadmin-setup).
