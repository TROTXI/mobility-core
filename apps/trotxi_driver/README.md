# Trotxi driver app

Flutter driver app using `trotxi_client`, generated `api_client` and
`trotxi_map`. See [build setup](../README.md).

Ops creates drivers and issues a code plus temporary six-digit PIN through
SMS/email or private handoff. The app requires a private PIN before normal work.
Recovery is Ops-managed; it is not commuter phone-OTP sign-in.

Implemented: assigned trips, readiness/location checks, start/arrival/complete,
QR/code/photo boarding, manifests, summaries, incidents, work requests,
profile photo/PIN controls and privacy/support guidance.

One active-trip GPS publisher continues in supported background/locked states.
It uses a bounded secure-storage queue with original fix IDs/timestamps and
matching server receipts. It does not promise collection after force-quit.
The map shows local device GPS separately from server-confirmed delivery.
Failed completion flushes surface unsent data rather than silently discarding it.

See [driver operations](../../docs/features/driver-operations.md),
[reliability](../../docs/driver-reliability.md) and
[onboarding](../../docs/driver-onboarding.md).
Physical-device GPS/push and store-signing checks remain release gates.
