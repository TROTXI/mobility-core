# Feature documentation

Source audit: 2026-10-03. These documents describe the implementation on main.
They replace the retired ADR collection. Product intent is maintained separately
in [strategy](https://github.com/TROTXI/strategy).

| Area                                         | Guide                                         |
| -------------------------------------------- | --------------------------------------------- |
| Social, phone, driver and Ops access         | [Authentication](authentication.md)           |
| Subscription requests and priced offers      | [Payments and wallet](payments-and-wallet.md) |
| Period-scoped rides and renewal discounts    | [Entitlements](entitlements.md)               |
| Daily confirmation and capacity              | [Reservations](reservations.md)               |
| QR, code, photo and no-show settlement       | [Boarding](boarding.md)                       |
| Routes, versions, schedules, fleet and trips | [Mobility](mobility.md)                       |
| Driver lifecycle, GPS and requests           | [Driver operations](driver-operations.md)     |
| Reviewed commute transfers                   | [Commute changes](commute-change-requests.md) |
| GPS, ETA and retention                       | [Live positions](live-positions.md)           |
| Shared map rendering                         | [Basemap](basemap.md)                         |
| Profiles, avatars and erasure                | [Account lifecycle](profile-avatars.md)       |
| Bootstrap, flags and supported builds        | [Configuration](feature-flags.md)             |
| Admission and caches                         | [Rate limiting](rate-limiting.md)             |
| Inbox and preferences                        | [Notifications](../api/notifications.md)      |
| Ops workflows                                | [Ops guide](ops-console.md)                   |
| Logs, metrics and traces                     | [Observability](../design/observability.md)   |

## Integration conventions

Use the implemented [OpenAPI](../design/contracts/replacement.openapi.json),
not old unversioned endpoint examples. Most product routes start with `/v1`;
bootstrap, health and the Paystack webhook have explicit exceptions.

Clients send the required app/build/platform metadata. Commands use the
operation's idempotency and edit-token requirements. Most lists use opaque
cursors; do not invent offset pagination. Amounts use integer pesewas, rendered
as GHS only at the UI boundary.

See [status](../STATUS.md) for deferred work, [API integration](../api/README.md)
for the request sequence and [deployment](../DEPLOY.md) for actual scheduling
boundaries. For code locations and checks, use the
[developer guide](../development.md).
