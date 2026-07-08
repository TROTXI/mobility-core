# Daily ride confirmation (reservations)

**Owner:** Godfred Awuku · **Last updated:** 2026-07-05 · **Issue:** #101 (epic E3)

The **daily confirmation loop** of the Hybrid Subscription Model (ADR-0014). Each
travel day the rider is asked "travelling tomorrow morning?" / "this evening?";
they confirm or decline, and a **no-response defaults to travelling** at the
cutoff. A reservation is what boarding (E4) verifies against and what the standby
pool (E6) fills when declined.

> **Scope shipped (E3-core):** the reservation lifecycle + the rider's
> confirm/decline API + the default-yes operation. **Deferred to when trips (#18)
> land:** the scheduled _ask-dispatch_ (which seeds `pending` rows for tomorrow's
> trips and sends the FCM push) and seat **capacity / release** to standby. So
> `trip_id` carries **no FK yet** (same as `scan_events`).

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

---

## Data

`reservations(id, user_id, trip_id, travel_date, direction, status, source,
confirmed_at, created_at, updated_at)`, unique `(user_id, travel_date,
direction)`. `trip_id` has no FK yet (trips are #18).

## Deferred (with #18)

- **Ask-dispatch cron** — for each subscribed rider on tomorrow's trips, seed a
  `pending` row (`createPending`) and send the FCM prompt; run
  `markDefaultTravelling` at each cutoff. Needs trips + capacity.
- **FCM push** — the notification sender (Firebase Admin) — needs the Firebase
  service account (adomfosugit, #88–90).
- **Deduction** — a confirmed no-show / a boarding consumes a ride (E4).

## Where the code lives

```
services/api/src/modules/reservations/
  reservation.repository.ts(.pg)   # lifecycle: respond, createPending,
                                   # markDefaultTravelling, listForUser, find
  reservations.routes.ts           # POST /me/reservations, GET /me/reservations
  reservations.schema.ts
services/api/src/db/migrations/013_reservations.sql
```

## Related

- [ADR-0014 — Hybrid Subscription Model](../adr/0014-hybrid-subscription-model.md)
- `strategy/docs/hybrid-subscription-model.md` (epics E1–E7)
- [entitlements.md](entitlements.md) (E1) · [boarding.md](boarding.md) (E4 deducts against a reservation)
