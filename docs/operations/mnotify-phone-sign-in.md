# Commuter phone sign-in — Ghana pilot

Phone OTP is an additional commuter sign-up/sign-in option. Driver code/PIN,
driver email onboarding and Ops Google + passkey authentication remain available.
Phone identities never adopt a Google account merely because its editable
profile contains the same number. Phone-account linking is out of this slice.

## Enable delivery

Use mNotify's API v2 key in the API service's `MNOTIFY_API_KEY` environment
setting. Keep the key out of source control, screenshots and chat. The optional
`MNOTIFY_SENDER` setting defaults to `TROTXI`; the sender must be approved in
mNotify and contain at most 11 characters. Fund the SMS account before enabling
the app flow. No new encryption secret, cron job or deployment service is needed.

With no key, requests fail safely with `503 phone_signin_unavailable` and make
no provider call. Adding a key permits charged SMS requests; mock tests do not
establish real provider delivery. mNotify does not offer a Paystack-style TEST
checkout here: use only an explicitly approved test recipient for a live check.

## API sequence

Both endpoints require commuter client/platform/build headers. Other clients
are refused with 403. They do not require an existing bearer token.

1. `POST /v1/auth/phone/request` with `{"phone":"0241234567"}`.
   Local, `233…` and `+233…` forms normalize to the same Ghana phone identity.
   The response is `{data:{challengeId,expiresAt,resendAfterSeconds:60}}`.
2. `POST /v1/auth/phone/verify` with `{challengeId,code}` (six digits).
   Success returns the existing `TokensResponse` envelope. The canonical Dart
   client supplies `PublicApi.requestPhoneSignIn` and `verifyPhoneSignIn`.
3. The first successful verification creates a commuter. Later verification
   reopens that same phone account. Existing session rotation/revocation applies.

## Security and limits

- Codes expire after five minutes, allow at most five guesses, and are single-use.
  Incorrect guesses commit; concurrent successful verification consumes once.
- Resending invalidates the previous challenge. Sending is limited to one per
  minute, five per hour and ten per rolling day per number; the pilot has a
  fixed 200-message rolling daily cap, in addition to shared IP admission.
- The database stores keyed hashes, encrypted phone numbers and no plaintext
  OTP. Success, supersession, five failed guesses and unconfirmed sending scrub
  the encrypted payload and code hash. Lifetime and attempts cannot be rewritten
  by the runtime. Expired rows are physically removed in bounded request-time
  batches after 24 hours, preserving the rate-limit window; without subsequent
  requests those encrypted rows can remain longer. Never claim a periodic purge.
- mNotify's API puts its key in the URL. The adapter hides provider errors and
  HTTP instrumentation excludes that destination. Neither phone nor code is an
  observability label or persisted mobile value.
- A timeout or ambiguous response invalidates the challenge and returns 503.
  It is not automatically retried: mNotify's documented quick-SMS endpoint has
  no idempotency key. The user explicitly requests a fresh code after cooldown.
- SMS OTP is not phishing-resistant. Ops must retain its passkey requirement.
  Phone-number recycling/SIM-swap risk remains; verified account linking and
  stronger phone-account recovery require a separate policy before production.

## Driver SMS boundary

Ops defaults to SMS when a driver has a Ghana mobile number; email remains an
alternative. Issue/reset requests use `smsInstructions: true` or
`emailInstructions: true`, never both. Neither is mandatory: Ops may show the
temporary credentials once and give them to the driver privately.

SMS includes the driver code and a newly issued temporary PIN (72-hour expiry),
not a driver's private PIN. First sign-in requires choosing a private PIN.
Migration 031 stores the pending payload encrypted in `driver_sms_outbox`, bound
to the driver, phone and credential version. Reset, private PIN change, phone
change, suspension, archive and erasure cancel obsolete queued payloads.

Sending starts immediately after commit. Provider acceptance is not proof of
handset delivery. An uncertain send is marked `unknown` and scrubbed: it is
never automatically resent because mNotify has no documented idempotency key.
Ops must reset the PIN to issue fresh instructions after checking the number.
An interrupted sending claim is also scrubbed as unknown after one minute.

Pending messages never attempted can be processed by the existing `emails`
maintenance command (`node dist/worker.js emails`, with the normal backend
environment). Its counts include SMS and uncertain outcomes fail the job signal.
The lightweight GitHub email-retry script remains email-only; it does not retry
SMS. No additional scheduled job or secret has been introduced.
Without a worker run, pending encrypted SMS payloads can remain after their PIN
expires; expiry still prevents sending them. Running the worker scrubs them.

The same optional `MNOTIFY_API_KEY` and `MNOTIFY_SENDER` serve OTP and driver SMS.
Do not configure live sending or test SMS until the sender ID is approved.
Adom has submitted it; approval and an explicitly authorised handset test remain.

Provider format: [mNotify API documentation](https://readthedocs.mnotify.com/).
