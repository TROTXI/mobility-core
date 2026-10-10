# Trotxi commuter app

Flutter commuter app over `trotxi_client` and the canonical generated
`api_client`. Build requirements are in [the apps guide](../README.md).

## Implemented flow

Phone and password signup collects full name and contact email, verifies the
phone by SMS, then signs in with the password. Contact email verification is
separate and enables recovery. Riders choose a route, outbound/return journeys
and weekdays, request an Ops offer, review dates, price, ride allowances and
credit values, pay through Paystack, then observe verified fulfilment.

Home, Trips, Wallet and Profile expose reservations/passes, a public route and
stop preview, scoped live bus tracking,
current/upcoming membership, payment recovery/history, ride/credit history,
pauses, commute-change requests, avatar/account controls and support.
Wallet also exposes opt-in card auto-renewal, turn-off and saved-card removal.
The bell opens the durable inbox; preferences use the server ETag. When the
rider enables phone alerts, the app registers its Firebase device token and
opens the server inbox from a push tap. Push content is not authorization.

There is no fixed 44-ride subscription, direct public purchase bypass, cash
top-up wallet or single-seat standby cascade. Card auto-renewal requires a
reusable card and explicit consent; mobile money is not charged automatically.
The signup OTP verifies the phone. It is not Ghana Card identity verification.

See [API integration](../../docs/api/README.md),
[offers](../../docs/features/payments-and-wallet.md) and
[notifications](../../docs/api/notifications.md).

Push, map tiles, store builds and production configuration require separate
device and deployment acceptance; source support is not proof a handset
received a notification or rendered a basemap.
