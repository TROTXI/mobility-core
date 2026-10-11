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
For iOS push, the Runner target includes the Push Notifications entitlement and
background modes. The Apple app identifier and signing profile must allow push,
and the APNs authentication key must be uploaded to the matching Firebase app.
Verify registration and delivery on a physical device; Xcode selects the APNs
environment from the signing profile.

## Interface

The commuter theme bundles Inter locally and shares warm neutral surfaces,
green actions, form fields, cards, dialogs and sheets across light and dark modes.
Home, Trips, Wallet and Profile stay in the bottom navigation; search is in the
header. Signup keeps details, password and SMS verification on separate steps,
with live password requirements and a fixed action above the keyboard.

Waitlist requests show a journey summary before submission and require
confirmation before withdrawal. Payment history uses compact transaction cards;
the receipt holds coverage, journey allowances and the full price breakdown.
Support references are behind an expandable section rather than shown as IDs.
Wallet keeps ride allowance separate from available and held money credit.

Profile groups everyday settings and account access. Password and recovery email
have separate screens. A verified phone opens on its current status, with an
explicit action to change it. Support uses configured contact channels, falling
back to the approved `info@trotxi.com` mailbox when no support email is supplied.

Boarding passes use the real server proof and remain high contrast in both
themes. Expired or backgrounded proofs are hidden. Reservation dates, times and
stops come from the API, never from the design preview's sample journeys.

Run `flutter test test/approved_design_test.dart test/remaining_design_test.dart`
for narrow-screen, enlarged-text, contrast and screen-state checks. Optional
review renders can be generated with
`flutter test test/approved_design_test.dart test/remaining_design_test.dart --update-goldens --dart-define=DESIGN_OUTPUT=/absolute/output/path`.
These renders are not cross-platform pixel baselines and are not part of normal CI.
