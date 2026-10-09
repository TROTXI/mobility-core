# Authentication and sessions

Email and full-name flow updated: 2026-10-08.

## Sign-in methods

- Commuters: `POST /v1/auth/google`, optional configured Apple, or
  `/v1/auth/phone/request` then `/v1/auth/phone/verify`, or verified
  email/password through `/v1/auth/email/login`.
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

A full rider name and an active verified phone record are required for standby.

Phone OTP sign-in initially creates a `New commuter` profile. The app asks for
`firstName` and `lastName`, plus optional `otherNames`, before opening Home.
Google users without these fields complete the same screen. `PATCH /v1/me`
stores the components and constructs `displayName` as first, other, last,
separated by spaces. First/last names allow 60 characters each and other names 80,
with a combined display name limited to 200 characters. Unicode names are supported;
controls are rejected. The account response
returns all three components. Existing names are not split by guessing.
Name entry does not itself verify legal identity.
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

## Email signup, recovery and linking

The commuter app offers **Continue with email**, **Create an account**, and
**Forgot password**. Any syntactically valid email domain is supported.

1. Signup collects full-name fields and email, then calls
   `POST /v1/auth/email/signup`. No password or usable session exists yet.
2. A verification email opens `/account-access#token=...` on the configured
   Ops web origin. This is a public commuter page, outside the Ops sign-in gate.
   It clears the fragment from browser history and keeps the secret only in
   memory. Opening the email does not consume the link.
3. The user chooses and confirms a password, then the page calls
   `POST /v1/auth/email/complete`. The 30-minute, single-use link proves email
   ownership and enables email login. Return to the app to sign in.
4. Login returns ordinary commuter access/refresh tokens. It does not verify
   phone possession or make the commuter eligible for standby without OTP.

Forgot password calls `POST /v1/auth/email/reset`. Responses are generic for
unknown addresses and addresses without email credentials. Provider send time
is not awaited in that response. Completing reset invalidates all older email
links and sessions, including other devices. It does not automatically log in.
The user receives a password-change notice. Reset requests alone do not change
the password or lock the user out.

**Profile > Security & sign-in > Email & password** supports adding an email
to an account first created with Google or phone. This requires a sign-in from
the last 15 minutes when requesting the code, and proof of the new email. The
code keeps its full 30-minute lifetime in that same live session; completion
does not repeat the session-age check. The emailed code is entered in
the initiating app session with a new password. Another account or session
cannot redeem it, and the public signup completion cannot redeem a linking
code. Linking retains the same rider ID, subscriptions and existing sign-in
method. Matching a contact address never merges two accounts. An address
already used by another account is refused. Adding Google to an email-created
account is not implemented; use email sign-in for that account.

The same security screen changes an enabled password using the current
password and recent sign-in. It signs out all sessions. Google-only users
manage their Google password with Google until they explicitly add email
sign-in here. Driver PIN recovery and Ops invitations/passkeys are unchanged.

Passwords allow 15 to 128 characters without composition rules, with a small
local common-password rejection list. They are hashed with Argon2id (19 MiB,
two passes, one lane) and random salts. At most two hashes run concurrently per
API process; excess work returns a retryable busy error. Login is bounded by
shared IP and email/IP budgets. Verification/resets send at most once per
minute and five times per account per hour. This is not a compromised-password
database check or multi-factor authentication.

Only token hashes are stored in challenges. Email links are encrypted in the
existing outbox, checked again before delivery, and retried by the existing
email worker. Account erasure scrubs credentials, names and outstanding links.
The existing `erasures` job also clears expired token hashes and releases
unverified email claims after one day; never-activated signup profiles with no
sessions or other identities are scrubbed. Run that job regularly. No new
paid provider or scheduled service is required by this implementation.

### Release and acceptance

- Apply migration 047 and deploy the API and Ops public recovery page before
  distributing the new commuter build. `RESEND_API_KEY` and the existing
  configured Ops origin must be correct. The web origin must match API CORS.
- Use a non-Google email address to register, verify and sign in. Confirm the
  full name appears in Profile and the email does not count as phone proof.
- Phone sign-in: OTP, full name, then standby without a second login OTP.
  Google/email sign-in: full name and account-bound phone OTP before standby.
- Reset from a second device. The old password and both old sessions must fail;
  the new password must work. Expired and already-used links must be refused.
- Link email from Google/phone. Verify the rider ID and subscriptions stay the
  same, and a different signed-in device cannot redeem the linking code.
- Test browser mail links on Android and iOS. Browser completion and returning
  to app sign-in are supported; native universal-link opening is not required.
- Real-provider delivery and physical-device acceptance are separate from
  local automated tests. Never paste passwords or link tokens into tickets.

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
change administrator access or reset another operator's passkeys. Every change
(invite, resend, cancel, delete, promote, demote, passkey reset) also needs a
passkey check from the last five minutes, not just the eight-hour session
elevation; otherwise the request returns `passkey_required` and the console asks
for the passkey before the change is repeated. A session taken over within the
elevation window therefore cannot invite an address its holder controls. Ordinary
admins retain dispatch and support work. The old role endpoint cannot grant
admin access or downgrade an administrator to a commuter or driver. It requires
superadmin authorization for the remaining commuter/driver role changes.

An invitation lasts 48 hours. Email delivery uses the encrypted transactional
outbox, immediate delivery attempt and existing retry worker. Provider acceptance
does not prove inbox delivery. Resending rotates the secret and makes the old
link unusable. The database stores only its hash; the encrypted email contains
the link. The UI removes the URL fragment before sign-in and keeps the secret
only in memory. Reloading before sign-in may require reopening the email.

Google verification must return the invited email. Matching a profile email
alone never grants access or merges identities. Operators use a Google account
and address that are not already a Trotxi account: an invitation to an address
that belongs to any account is refused, and a Google identity that already has a
rider or driver account cannot claim one (`operator_account_conflict`). Claiming
creates a new account with only passkey-setup access. Completing a verified passkey
ceremony before expiry
activates Ops access and consumes the invitation. Cancelling unclaimed invitations
invalidates the link. Cancelling claimed setup deletes the account created for that
invitation, after an explicit warning; it never holds a rider profile. Expired setup
cannot activate.

Invitations that were never claimed can be resent, including after expiry.
Cancel an expired claimed invitation before issuing a replacement. Expired
invitations remain in Team & access until a superadmin resolves them. Acceptance
and cancellation scrub the duplicate invite name/email and secret. Account
erasure also scrubs matching invitations; audit IDs remain, without link secrets.

Access changes and passkey resets appear in Audit log. **Delete account** in Team
closes the entire account through the existing erasure flow, rather than changing
its role to commuter. It revokes sessions and passkeys, scrubs personal details
and identity links, and closes membership state under the existing erasure policy.
Required financial and audit records remain; external cleanup uses the durable
erasure queue. The recovery fence and independent deletion journal apply when
configured. The team command receipt, local erasure and attributed event commit
together, so retrying the same command does not delete twice.

**Make administrator** only removes superadmin capability and keeps ordinary Ops
access. Self access changes are refused. The last superadmin cannot be erased;
that refusal happens before writing a durable deletion intent.

Source: [team service](../../services/api-next/src/auth/ops-team.ts).
First-owner setup: [deployment](../DEPLOY.md#first-superadmin-setup).
