# Commuter phone verification

Source audit: 2026-10-03. Phone verification and the subscription standby
request/offer flow are implemented, not a future endpoint proposal.

Google/configured Apple sign-in and ordinary account access do not require
OTP. Standby enrollment and acceptance require a completed rider name and an
active verified Ghana phone. Phone sign-in establishes that verification, so
the user should not be asked for a second OTP just to join standby.

Social accounts use `POST /v1/me/phone-verification/start`, then
`/v1/me/phone-verification/confirm`; safe state comes from
`GET /v1/me/verification`. Challenges are purpose/owner scoped.
An editable profile number or Paystack phone is not verification.

The server enforces the gate, not merely the app screen. Matching a number
does not merge accounts, transfer subscriptions or establish legal identity.
OTP proves possession, not Ghana Card ownership. Collision/review handling
must not bypass unique ownership.

Standby here means an Ops-reviewed subscription request, not automated
released-seat allocation. See [authentication](../features/authentication.md),
[offers](../features/payments-and-wallet.md),
[mNotify operations](../operations/mnotify-phone-sign-in.md) and the
[private strategy](https://github.com/TROTXI/strategy/blob/main/docs/kyc.md).

Acceptance: phone login → one verification → join; social login with unverified
phone → verify → join; wrong/expired/replayed code → no eligibility; another
account's number → no silent merge; account deletion → no surviving old
verification/session authority.

Sources: `services/api-next/src/auth/phone-otp.ts`,
`membership/standby.ts`, commuter verification and standby screens.
