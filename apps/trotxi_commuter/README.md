# Trotxi commuter app

Flutter commuter app over `trotxi_client` and the canonical generated
`api_client`. Build requirements are in [the apps guide](../README.md).

## Implemented flow

Google/configured Apple or phone OTP sign-in → complete rider profile and
verify phone for standby → choose route, outbound/return journeys and weekdays
→ request an Ops offer → review dates, price, ride allowances and credit values
→ explicitly pay through Paystack → observe verified fulfilment.

Home, Trips, Wallet and Profile expose reservations/passes, scoped live tracking,
current/upcoming membership, payment recovery/history, ride/credit history,
pauses, commute-change requests, avatar/account controls and support.
The bell opens the durable inbox; preferences use the server ETag.

There is no fixed 44-ride subscription, direct public purchase bypass, cash
top-up wallet, automatic card renewal or single-seat standby cascade.
Phone OTP already verifies phone-login accounts; social accounts verify at
standby when needed. OTP is not Ghana Card identity verification.

See [API integration](../../docs/api/README.md),
[offers](../../docs/features/payments-and-wallet.md) and
[notifications](../../docs/api/notifications.md).

Preferred ask time is stored, not an enabled scheduler. Push/store/Apple and
production configuration require separate acceptance; source support is not
proof a device received a notification.
