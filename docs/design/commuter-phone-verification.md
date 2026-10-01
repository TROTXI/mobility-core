# Commuter phone verification — implementation boundary

**Status:** implementation plan, 2026-09-30. This updates the product scope of
[strategy/docs/kyc.md](https://github.com/TROTXI/strategy/blob/main/docs/kyc.md):
every commuter, including one who signed in with Google, must verify a Ghana
mobile number before using commuter booking and payment features. The strategy's
standby-only scope is superseded by this decision. Its distinction between
phone control and legal identity remains: **SMS OTP is not Ghana Card KYC**.

## Current state

- `POST /v1/auth/phone/request` and `/verify` already send a six-digit code
  through mNotify and sign in or create a phone-identity commuter. The code is
  single-use, expires after five minutes, and has bounded guesses and sends.
- Google sign-in creates an independent commuter identity. `users.phone` may be
  present from other sources and is **not** proof of OTP verification.
- Phone challenges currently have no account owner or purpose. Their `verify`
  method can create a new user, so it must **not** be used as an authenticated
  account-upgrade endpoint without changing its semantics.
- An approved mNotify sender ID and staging key permit a charged delivery test;
  a successful handset delivery has not yet been recorded in the runbook.

## Pilot rule

Verification is a one-time account upgrade, not an OTP on every login. A
verified phone survives logout and Google reauthentication. Replacing the
number clears verification until the replacement OTP succeeds. Erasure removes
verification and outstanding challenges. A material account-risk event may
require re-verification later, with an explicit policy and audit trail.

Successful phone-OTP sign-in counts as verified number control for that phone
identity. Migration must derive its initial verification record from the
successful phone identity, **not** from a non-null `users.phone` or a payment
record. No Google account is marked verified merely because a profile or
Paystack response contains a matching number.

## Authenticated upgrade

1. A signed-in commuter starts verification with a Ghana mobile number. Issue
   a challenge bound to **that user and that purpose**; retain the existing
   phone/IP budget and add a per-account budget. Return the same safe response
   for numbers that are already registered.
2. The same signed-in account confirms the challenge. Atomically consume the
   code, enforce uniqueness across live accounts, attach a verified-number
   record, and write an audit event. Never disclose another account's identity.
3. A safe read endpoint returns `unverified | pending | verified | review`, a
   masked number, verification timestamp and actionable missing requirements;
   it never returns OTP, provider data or another user's account information.
4. The commuter app routes an unverified Google user to the phone-verification
   screen after sign-in. Public/help/legal pages, verification, logout and
   account erasure remain reachable. The API must also gate paid/booking
   mutations; a UI-only gate is not enforcement.

Use a separate verification record with a unique normalized-number digest and
`verified_at`, rather than interpreting `users.phone` as verified. Extend the
existing challenge table with owner and purpose while preserving the existing
phone-sign-in path. Reuse its mNotify adapter and expiry/attempt behavior.

## Collision and recovery policy

An OTP proves possession but is not permission to transfer another account's
rides, subscriptions or social identity. If the number already belongs to a
different live commuter, **do not merge or reassign automatically**. Keep both
accounts unchanged and return a generic review-required outcome after code
confirmation. Operations needs a separately audited recovery/transfer flow;
it must define what happens to purchases before implementation. A Google user
who verifies an unused number does not automatically gain phone sign-in until
an explicit account-linking policy is approved.

## Delivery order and acceptance

1. Database record/challenge purpose, erasure, uniqueness and concurrency tests.
2. Authenticated start/confirm/status API and OpenAPI/client regeneration.
3. App gate and verification screens; backend gate on booking/payment mutations.
4. Staging tests with one authorized handset: Google → OTP → verified → reopen
   app; wrong/expired/replayed code; number replacement; number collision;
   erasure. Never log phone, OTP or API key.

Do not describe this as Ghana Card verification. A future Ghana Card identity
check needs its own approved use case, NIA-authorized verification and privacy
review, as set out in the strategy document.
