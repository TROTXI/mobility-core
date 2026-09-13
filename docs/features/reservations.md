# Daily ride confirmation and seat capacity

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Confirmation, push dispatch, default-yes, pickup/drop-off snapshots
and vehicle-capacity handling are live. The standby offer cascade is not built.

## Model

There is one reservation per rider, travel day and direction (`morning` or
`evening`). It carries the trip and the pickup/drop-off stops copied from the
subscription at dispatch time.

```text
pending → reserved → boarded
        ↘ declined
        ↘ unseated
reserved → no_show | operator_cancelled | released
```

`source` is `confirmation`, `default` or `standby`. The schema reserves the
standby value, but no allocation service currently creates standby reservations.

## Rider API

| Endpoint                               | Behaviour                                                                                           |
| -------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `POST /me/reservations`                | Confirm or decline one day/direction; returns the four-character boarding code only on confirmation |
| `GET /me/reservations?from=YYYY-MM-DD` | List the caller's reservations, newest day first                                                    |

Confirming is the paywall. It returns `402` for no active subscription, no rides
remaining or a trip outside the subscribed corridor. It returns `409` when the
vehicle is full. Declining remains allowed after entitlement lapses because it
releases intent and consumes nothing.

## Scheduled operations

| Endpoint                       | Behaviour                                                                                        |
| ------------------------------ | ------------------------------------------------------------------------------------------------ |
| `POST /admin/ask-dispatch`     | For a date/window, create pending reservations for active route subscribers and send FCM prompts |
| `POST /admin/resolve-defaults` | At cutoff, default unanswered riders to reserved until capacity is full; mark overflow unseated  |

Dispatch is idempotent. Direction is currently inferred from scheduled UTC time
(before noon = morning), a pilot convention that should eventually become an
explicit trip field.

The intended windows remain morning ask at 18:00 and cutoff at 21:00, evening
ask at 12:00 and cutoff at 14:00 Ghana time. Render cron definitions exist but
are commented out because each job requires a paid plan; operations can invoke
the admin endpoints manually.

## Capacity and deductions

- Capacity comes from the trip's assigned vehicle. An unassigned vehicle means
  there is no enforceable ceiling.
- `unseated` is terminal and distinct from a rider-declined or released seat.
- Boarding and confirmed no-show handling are owned by `BoardingService` and use
  the same `board:<reservation-id>` idempotency key.
- Operator cancellation never consumes a ride.

## Deferred

- Releasing declined seats into a KYC'd standby pool.
- Offer ordering, expiry and instant single-journey payment.
- An explicit direction field on trips.

## Code

- `services/api/src/modules/reservations/`
- `services/api/src/modules/notifications/ask-dispatch.*`
- migrations `013`, `016_reservation_pin`, `019`, `031` and `033`
