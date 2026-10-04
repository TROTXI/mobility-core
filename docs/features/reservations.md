# Ride confirmation and capacity

Source audit: 2026-10-03.

A reservation belongs to a rider, service date, direction, trip and paid period.
Direction is explicitly `outbound` or `return`; it is not inferred from
morning/evening or the hour. Pickup/drop-off are version-owned stop occurrences.

## Operations

- `POST /v1/me/reservation-decisions`: confirm or decline.
- `GET /v1/me/reservations` and `/{id}`: own reservation state.
- `POST /v1/ops/maintenance/ask-dispatch`: create eligible prompts.
- `POST /v1/ops/maintenance/reservation-defaults`: settle unanswered requests.
- `POST /v1/ops/maintenance/no-shows`: settle eligible unboarded seats.

Confirmation checks paid coverage for the departure, commute selection,
restrictions/pauses, offered weekdays/allowance and assigned-vehicle capacity.
A purchased package alone is not a reserved seat. Declining releases intent
without consuming a ride. Defaults can reserve or mark overflow unseated;
operator cancellation does not charge.

A prepaid renewal can fund tomorrow's departure before its coverage starts.
The ride is attributed to the renewal, not the currently active period.
Generation/ask-dispatch must run in the right order; a preferred notification
hour alone does not schedule these jobs.

Boarding/no-show consumption is atomic and idempotent. There is no offline
boarding promise or automatic released-seat offer cascade.
See [boarding](boarding.md), [notifications](../api/notifications.md) and
[manual operations](../runbooks/rider-services-staging.md).

Sources: `services/api-next/src/membership/service.ts`,
`services/api-next/src/boarding/service.ts`, migrations 013 and 042.
