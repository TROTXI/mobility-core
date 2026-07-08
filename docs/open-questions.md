# Hybrid Model — what's proven, and the open questions

**Owner:** Godfred Awuku · **Date:** 2026-07-08

Context: the whole hybrid-model loop now runs **end to end** — see
[`services/api/scripts/e2e-demo.sh`](../services/api/scripts/e2e-demo.sh) (in this
PR). Running it for real surfaced the gaps below. **None are broken code** — they
are **product/schema decisions** that block the remaining epics. This is the
agenda for the product/pricing meeting.

---

## ✅ Proven (the demo asserts this every run)

```
admin → create route/stop/vehicle/trip
      → promote a user to driver (#116) → assign to trip
rider → sign in → subscribe → (signed) webhook → 44 rides (E1)
      → confirm tomorrow's trip → daily PIN (E3/E4)
driver→ open manifest (name + photo pass) → board by PIN → ride debits 44 → 43 (E4)
```

Idempotency holds (re-board = `already_boarded`, no second debit) and a wrong PIN
is rejected. Auth, subscribe→allocate, reservations+PIN, manifest, and boarding
deduction all work together.

---

## 🔴 The one structural gap: rider ↔ route/trip

The demo has to **hand the rider the `tripId`** to confirm. In production the app
must answer _"which trip is mine tomorrow?"_ on its own — and **nothing links a
rider to a route/corridor**.

- **Blocks:** E3 **ask-dispatch** (can't send "travelling tomorrow?" if we don't
  know who rides what) → the daily confirmation can't be automated.
- **Decision needed:** are pilot riders **pinned to one corridor** (a
  `rider_route` record set at subscribe/onboarding)? Chosen per-confirmation from
  a browse? This is the **next decision to make** — it unblocks the whole
  confirmation loop.

## 🟡 Numbers not decided (block E5 / E6)

- **Allocation isn't period-guarded.** Each paid webhook allocates 44, keyed by
  payment reference — so subscribing twice yields **88**, not 44. The
  "**one allocation per subscription period** + renewal netting" logic is **E5**,
  and needs the **per-ride credit value** decided (plan price ÷ entitlement? a
  table?).
- **Pricing set.** Tiers (standard/premium/corporate/student), plan prices,
  **standby fare**, and **KYC scope** are all placeholders (44 rides, GHS 20).
  Blocks **E5** (credit conversion) and **E6** (standby pool).

## 🟢 Deferred polish (known, not blocking the loop)

- **Manifest authz** — a manifest isn't yet restricted to the trip's **assigned
  driver** (any driver token can view any trip's manifest). Pairs with #25's
  driver↔user lookup.
- **QR direction resolution** — a QR scan boards the rider's _earliest open leg
  today_; the PIN + manifest target an exact reservation. Converges once trips
  carry a direction.
- **FCM send** — the backend needs the **Firebase service account** (from
  adomfosugit) to actually send the daily push. Device-token registration
  already exists.
- **Housekeeping** — duplicate migration number `016` (`016_reservation_pin` +
  `016_trip_positions`); renumber one on the next migration.

---

## Decisions, in priority order

| #   | Decision                                              | Owner         | Unblocks        |
| --- | ----------------------------------------------------- | ------------- | --------------- |
| 1   | **rider ↔ route** association model                   | Product + CTO | E3 ask-dispatch |
| 2   | **Per-ride credit value** + one-allocation-per-period | Product       | E5              |
| 3   | **Tier differentiation + prices**                     | Product       | E1b, E5         |
| 4   | **Standby fare + KYC scope**                          | Product       | E6              |
| 5   | Provide **Firebase service account**                  | adomfosugit   | E3 push send    |

Survey data (current one-way spend, willingness-to-pay) feeds #2–#4 — results not
yet collected.
