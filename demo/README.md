# Trotxi live demo

An animated investor walkthrough of the Hybrid Subscription Model loop —
**subscribe → confirm → board → no-show → month-end credit** — for a real fleet
of **40 members** on the Circle ⇄ Madina corridor. It's a **two-sided** view:
Ama's phone journey on one side, and a live **operator console** on the other
(members, monthly revenue, seats confirmed, boarded, occupancy, credit liability).
Every number — the ride entitlement, the daily PIN, each deduction, the operator
economics, the converted credit — is returned **live by the real Trotxi API**,
not scripted.

## Run it

```bash
pnpm --filter @trotxi/api demo
# → Trotxi live demo → http://localhost:4319
```

Open <http://localhost:4319> and press **Play** (or step with Next / ← →).

## How it works

`services/api/scripts/demo-server.ts` boots the real API in-process (in-memory,
zero infra) and serves this page plus a few `POST /demo/*` endpoints. Each beat of
the walkthrough calls one endpoint, which drives that step of the loop through the
actual API and returns the real result:

| Beat      | Real call behind it                                                      |
| --------- | ------------------------------------------------------------------------ |
| Subscribe | `/payments/subscribe` + the signed Paystack webhook → 44 rides allocated |
| Confirm   | `POST /me/reservations` → the daily boarding PIN                         |
| Board     | `POST /boarding/verify-pin` → one ride deducted (44 → 43)                |
| No-show   | `POST /admin/resolve-no-shows` → a held-but-unused seat deducted         |
| Month-end | `POST /admin/convert-credits` → unused rides → Ride Credits              |

It runs entirely locally so a pitch never waits on a cold start. Pricing figures
are illustrative placeholders (see `payments.service.ts` / `credit.service.ts`)
until the pilot pricing is locked; the mechanics are real.

> Note: browser pages can call a deployed API only because CORS is enabled on the
> API (`@fastify/cors`). The demo runner serves this page same-origin, so it needs
> no configuration.
