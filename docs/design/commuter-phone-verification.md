# Pilot phone verification for standby

**Status:** product boundary, 2026-09-30. Follows the approved
[KYC strategy](https://github.com/TROTXI/strategy/blob/main/docs/kyc.md).

## Recommended pilot rule

Google sign-in and ordinary commuter account access do not require a phone OTP.
Require a verified Ghana mobile number when a commuter **joins the new-rider
standby flow**. An authenticated account, basic profile and explicit payment on
offer acceptance remain separate requirements in the strategy. Successful OTP
verification proves control of a number, **not** the subscriber's legal identity
or Ghana Card ownership. Do not label this Ghana Card KYC.

The existing membership `waitlisted` state represents a route-change request
for an already subscribed rider. It is **not** the new-rider standby flow and
must not be used as the enforcement point for this policy. The current API and
app do not yet have a dedicated standby application endpoint or screen, so no
universal sign-in, booking or payment gate should be added in anticipation.

## Current implementation and safe extension

- Phone sign-in already sends a six-digit mNotify OTP, creates or signs in a
  phone-identity commuter, and bounds expiry, guesses and sends. It is distinct
  from verifying the phone of an existing Google-identity commuter.
- A non-null `users.phone` or payment contact number is not proof of OTP
  possession. Google users must be offered an authenticated, account-bound
  verification challenge before standby eligibility can use their number.
- Store verified-number status separately, with an immutable challenge purpose
  and owner. Reuse the existing provider, expiry and rate limits, with a
  per-account budget. Keep verification valid across logins; erase it with the
  account. Never merge accounts or transfer subscriptions based on a matching
  number or OTP alone.
- The standby API must enforce verified-phone eligibility server-side when it
  is added. The commuter UI should ask for OTP only at standby application,
  show an actionable pending/verified state, and keep sign-in, help and erasure
  reachable.

## Delivery sequence

1. Define the standby application and offer-acceptance contract against the
   strategy; do not confuse it with membership route-change waitlisting.
2. Add account-bound phone verification, unique live ownership, erasure and
   concurrency tests, without changing Google sign-in eligibility.
3. Add the standby API guard and its commuter UI; regenerate the canonical
   client from the published contract.
4. Rehearse Google account → standby application → OTP → eligible standby,
   plus wrong, expired and replayed codes, number collision and erasure on
   staging. Do not log OTPs, full phone numbers or provider keys.

Full Ghana Card verification remains deferred until there is an approved use
case, NIA-authorized verification and privacy review, as the strategy states.
