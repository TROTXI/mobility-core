# Trotxi documentation

Start with [implemented features](features/README.md). Each guide explains the
user flow, business rules, API boundary and code responsible for it.

## Follow a product flow

- [Sign in and verify a phone](features/authentication.md)
- [Create routes, stops and schedules](features/mobility.md)
- [Request a subscription, send an offer and pay](features/payments-and-wallet.md)
- [Confirm a ride](features/reservations.md) and [board](features/boarding.md)
- [Run a driver trip](features/driver-operations.md) and [track it](features/live-positions.md)
- [Manage changes](features/commute-change-requests.md), [ride credit](features/entitlements.md)
  and [account deletion](features/profile-avatars.md)
- [Work in Ops](features/ops-console.md)

## Build or change a feature

Use the [developer guide](development.md) for code locations and checks, then
the [API integration guide](api/README.md) and [response examples](api/response-examples.md).
The [implemented OpenAPI](design/contracts/replacement.openapi.json) defines
request/response shapes. The [architecture](architecture.md) explains state ownership.

## Run the system

[Deployment](DEPLOY.md), [rider-service jobs](runbooks/rider-services-staging.md),
[staging security](operations/staging-security.md) and
[account recovery](design/account-erasure-recovery.md) are operating references,
not additional product designs. [Status](STATUS.md) separates implementation
from release prerequisites.

Historical implementation reports, redesign proposals and ADRs are not part
of the current documentation. Git retains them. Contract sources, generated
inventories and build scripts remain because generation and CI use them.
