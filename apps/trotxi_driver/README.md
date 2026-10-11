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

## Visual system

The driver app keeps its original blue-black and muted off-blue palette in
light and dark themes. It shares the commuter app's bundled Inter typeface
and improved component patterns, not its green brand colours. Driver-specific controls
keep large tap targets and explicit start, boarding and completion steps.
Entering a complete PIN only enables Sign in; it never submits automatically.
Today opens the trip workflow instead of starting or completing a trip directly.

The design research used [Uber's driver app guide](https://www.uber.com/us/en/drive/driver-app/)
for current-work hierarchy and quick access to support,
[Lyft's trip-detail guidance](https://help.lyft.com/hc/en-us/driver/articles/8668928544-Upfront-pay)
for readable information before an action, and
[Component Gallery](https://component.gallery/components/) for consistent component patterns.
These inform presentation only. Trotxi does not expose ride-hailing earnings,
ratings or unimplemented dispatch features.

`test/approved_design_test.dart` exercises 14 screen states in both themes at
320px width with enlarged text, plus the active-trip navigation safeguard.
For review PNGs of the real Flutter widgets using fixture data:

```sh
flutter test test/approved_design_test.dart --update-goldens \
  --dart-define=DESIGN_OUTPUT=/absolute/path/to/driver-previews
```

Preview fixtures deliberately do not provide a live map or GPS position.
Native camera, background location and push still require device acceptance.
