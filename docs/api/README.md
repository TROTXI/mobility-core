# Commuter API integration

Source audit: 2026-10-03. Use the current replacement API, not retired
unversioned subscription endpoints.

## Source of truth

- [Executable source](../design/contracts/target-contract.mjs).
- [Implemented OpenAPI](../design/contracts/replacement.openapi.json).
- `services/api-next/src/http/contract.json` is the runtime copy.
- `apps/trotxi_client` wraps generated `apps/api_client`.

`staging-examples.json` is retained as a dated captured fixture for contract
tests. Its old direct-purchase flow, 44 rides and example amount are not
current commercial defaults or a supported new-purchase walkthrough.

## Request rules

Use the documented client/build/platform headers and bearer token where
required. Supply `Idempotency-Key` for commands that require it; reuse it only
for the same logical action and payload. Send resource ETags/edit tokens in
`If-Match` where required. Lists use their declared cursor/limit/filter fields.

Money uses integer pesewas: `{amountMinor: 1000, currency: 'GHS'}` is GHS 10.
Do not send a client-calculated price when accepting an offer. Service dates
are Ghana calendar dates; timestamps are instants. Weekdays use ISO 1 through 7.

## Screen-to-endpoint map

| Task                             | Endpoint                                                                |
| -------------------------------- | ----------------------------------------------------------------------- |
| Bootstrap                        | `GET /flags`                                                            |
| Social sign-in                   | `POST /v1/auth/google` or configured Apple route                        |
| Phone sign-in                    | `POST /v1/auth/phone/request`, then `verify`                            |
| Account                          | `GET /v1/me`                                                            |
| Verify existing account's phone  | `/v1/me/phone-verification/start`, `confirm`; `GET /v1/me/verification` |
| Choose route/schedule            | `GET /v1/routes`, `/v1/routes/{id}/schedules`                           |
| Choose version-owned stops       | `GET /v1/route-patterns/{id}/versions/{versionId}`                      |
| Request/list subscription offers | `POST/GET /v1/me/standby`                                               |
| Accept offer                     | `POST /v1/me/standby/{id}/accept`                                       |
| Recover payment/history          | `GET /v1/me/purchases` and `/{id}`                                      |
| Current/upcoming coverage        | `GET /v1/me/membership`                                                 |
| Confirm/decline                  | `POST /v1/me/reservation-decisions`                                     |
| Reservations/pass                | `GET /v1/me/reservations`; `POST /v1/me/reservations/{id}/pass`         |
| Live trip                        | `GET /v1/trips/{id}/live`                                               |
| Inbox/preferences                | `/v1/me/notifications`, `/v1/me/notification-preferences`               |
| Commute changes                  | `/v1/me/commute-requests`                                               |

## Request and pay

1. Sign in. Read account and membership separately; authentication does not buy
   coverage. Keep refresh handling in the shared client.
2. Choose one outbound and one return leg. Each leg names its exact schedule,
   pattern version and ordered pickup/drop-off occurrence IDs, not physical stop
   IDs. Preserve the monthly/annual selection and requested travel weekdays.
3. Complete the profile/phone requirements and submit standby. An application
   is not a payment or a seat.
4. Ops sends immutable dates, price, allowances and credit terms. Show all of
   them and the payment deadline before acceptance. Use the response terms,
   never a hardcoded price or ride count.
5. Accept, then open the returned Paystack checkout. Follow purchase state until
   authoritative fulfilment or an actionable failure/review outcome. Recover the
   existing purchase after network loss; do not create another charge.
6. Display future coverage as upcoming. Book using the period covering the
   trip's departure, even when confirmation happens the preceding evening.

Direct `POST /v1/me/purchases` and the old nonbinding price-preview route do
not provide a bypass around offered terms. See
[payments](../features/payments-and-wallet.md) for credit, expiry and renewal.

## Errors

Use `error.code` for behavior and preserve `requestId` for support.
401 is not the same as a network timeout; 409 is a domain conflict; 412/428
require a fresh edit token; 426 requires an updated app; 429 requires honoring
Retry-After. Do not automatically replay mutations through session refresh.

Payment return URLs, provider acceptance and notification receipt are not
proof of settled membership. Unavailable live tracking must not expose another
rider's trip. Current authorization is checked on each scoped read.

## Generation and build

From the repo root, regenerate both contract artifacts, Ops types and Dart
client after schema changes. Follow with build_runner in `apps/api_client`.
See [API README](../../services/api-next/README.md) and
[mobile build instructions](../../apps/README.md).

No server key belongs in a mobile build. Staging payment tests use TEST mode.
