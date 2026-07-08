# Daily ride confirmation (reservations)

**Owner:** Godfred Awuku · **Last updated:** 2026-07-08 · **Issue:** #101 (epic E3)

The **daily confirmation loop** of the Hybrid Subscription Model (ADR-0014). Each
travel day the rider is asked "travelling tomorrow morning?" / "this evening?";
they confirm or decline, and a **no-response defaults to travelling** at the
cutoff. A reservation is what boarding (E4) verifies against and what the standby
pool (E6) fills when declined.

> **Scope shipped (E3):** the reservation lifecycle + the rider's confirm/decline
> API + the default-yes operation (E3-core), **plus the scheduled _ask-dispatch_**
> — now that trips (#18) have landed, the loop seeds `pending` rows for tomorrow's
> route trips and pushes the "travelling?" prompt over **FCM**, and a cutoff
> trigger runs the default-yes. **Still deferred:** seat **capacity / release** to
> standby (E6) and the **cron schedule** itself (Render infra hits the admin
> triggers below). So `trip_id` still carries **no FK yet** (same as `scan_events`).

**Rider ↔ route (the pilot model).** A rider is linked to a corridor by their
**subscription**: at checkout the chosen `route_id` is threaded through the
payment and **pins the subscription** on activation (`subscriptions.route_id`).
Ask-dispatch targets a trip's riders via `findActiveByRoute(trip.routeId)`.

---

## Model

One reservation per **rider × travel day × direction** (`morning` | `evening`).

- **status:** `pending` (asked, awaiting reply) → `reserved` (travelling) |
  `declined`; then `boarded` | `no_show` (E4), `released` (E6),
  `operator_cancelled`.
- **source:** `confirmation` (rider answered), `default` (no reply → defaulted),
  `standby` (E6).

**Confirmation windows** (from the master doc; drive the future cron):
morning ask 18:00–20:45, **cutoff 21:00**; evening ask 12:00–13:45,
**cutoff 14:00**. At each cutoff, `markDefaultTravelling(date, direction)` flips
the still-`pending` rows to `reserved`/`default`.

---

## API

#### `POST /me/reservations`

Confirm or decline (an upsert per day+direction).

- **Auth:** `Bearer`. **Rate limit:** per user.
- **Body:** `{ "tripId?": "<uuid>", "travelDate": "YYYY-MM-DD", "direction": "morning"|"evening", "travelling": true|false }`
- **200:** the reservation `{ id, tripId, travelDate, direction, status, source, pin? }`
  (`reserved` when travelling, else `declined`). On a **confirm**, `pin` is the
  rider's daily **4-digit boarding PIN** — returned **once** here; only its keyed
  hash (`daily_pin_hash`) is stored. The driver types it against the manifest to
  board (E4, `POST /boarding/verify-pin`). · **400** bad date · **401** · **429** · **503**

#### `GET /me/reservations?from=YYYY-MM-DD`

The rider's reservations, newest travel day first.

- **200:** `{ "reservations": [ … ] }`

#### `POST /admin/ask-dispatch` · `POST /admin/resolve-defaults`

The scheduled loop's two triggers — a Render cron hits these with an **admin**
token: `ask-dispatch` in the ask window, `resolve-defaults` at the cutoff.

- **Auth:** `Bearer` **admin**. **Rate limit:** per user.
- **Body:** `{ "travelDate": "YYYY-MM-DD", "direction": "morning"|"evening" }`
- **ask-dispatch → 200:** `{ "trips": <n>, "asked": <n> }` — for each scheduled
  trip of that day+direction, seed a `pending` reservation for every active
  subscriber of the trip's route and push the "travelling?" prompt. Idempotent
  (re-running leaves existing rows untouched). A trip's direction comes from its
  scheduled time (before noon UTC → morning) — a pilot heuristic, same as the
  boarding scan.
- **resolve-defaults → 200:** `{ "defaulted": <n> }` — `markDefaultTravelling`.
- **401** · **403** (non-admin) · **503** (unwired) · **429**

---

## Data

`reservations(id, user_id, trip_id, travel_date, direction, status, source,
confirmed_at, created_at, updated_at)`, unique `(user_id, travel_date,
direction)`. `trip_id` has no FK yet (trips are #18). Rider↔route lives on
`subscriptions.route_id` / `payments.route_id` (migration `019`).

**FCM push** is wired: `FcmNotificationSender` (`notification.sender.live.ts`)
sends via `firebase-admin` to a rider's registered device tokens (#84), used when
`FIREBASE_SERVICE_ACCOUNT` is set (else the recording fake). The service-account
key is a **secret → Render env only**.

## Deferred

- **Cron schedule** — the Render cron that hits `POST /admin/ask-dispatch` at the
  ask windows and `POST /admin/resolve-defaults` at each cutoff (infra config).
- **Capacity / release** — seat caps + releasing a declined seat to standby (E6).

## Where the code lives

```
services/api/src/modules/reservations/
  reservation.repository.ts(.pg)   # lifecycle: respond, createPending,
                                   # markDefaultTravelling, listForUser, find
  reservations.routes.ts           # POST /me/reservations, GET /me/reservations
  reservations.schema.ts
services/api/src/modules/notifications/
  ask-dispatch.service.ts          # dispatchAsks + resolveDefaults (the loop)
  ask-dispatch.routes.ts           # POST /admin/ask-dispatch, /resolve-defaults
  notification.sender.ts           # NotificationSender + FakeNotificationSender
services/api/src/db/migrations/013_reservations.sql
services/api/src/db/migrations/019_subscription_route.sql   # rider↔route pin
```

## Related

- [ADR-0014 — Hybrid Subscription Model](../adr/0014-hybrid-subscription-model.md)
- `strategy/docs/hybrid-subscription-model.md` (epics E1–E7)
- [entitlements.md](entitlements.md) (E1) · [boarding.md](boarding.md) (E4 deducts against a reservation)
