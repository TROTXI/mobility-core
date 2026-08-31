# Feature documentation

**Owner:** Godfred Awuku · **Last updated:** 2026-06-28

Living, per-feature documentation for `mobility-core` — what each feature does,
its API contract, how it works, how to configure it, and its security/edge-case
notes. Aimed at backend engineers building on a feature and frontend engineers
consuming it.

These docs describe **behaviour and contracts**; the **why** behind a decision
lives in an [ADR](../adr/), and the deep design lives in the private `strategy`
repo (`system-design.md`, `security.md`). Each doc links to both.

> A feature doc is the source of truth for _how to use_ a feature. When code and
> a doc disagree, the code wins — fix the doc in the same PR.

## Index

| Feature                                                                  | Doc                                              | Status                                 |
| ------------------------------------------------------------------------ | ------------------------------------------------ | -------------------------------------- |
| Authentication — access tokens, route guard, sign-in/refresh/logout      | [authentication.md](authentication.md)           | ✅ live                                |
| Profile & avatars — `PATCH /me`, avatar upload → R2 (photo pass) (#24)   | [profile-avatars.md](profile-avatars.md)         | ✅ live                                |
| Payments — Paystack subscribe + webhook, credit-netted (#128)            | [payments-and-wallet.md](payments-and-wallet.md) | ✅ live (fare-derived pricing, #103)   |
| Ride entitlements & credits — allocation, month-end conversion, netting  | [entitlements.md](entitlements.md)               | ✅ E1 + E5 (conversion #162, net #128) |
| Daily ride confirmation — confirm/decline, ask-dispatch, capacity (#161) | [reservations.md](reservations.md)               | ✅ E3 live (crons unfunded, #126)      |
| Mobility — routes, stops, trips, ETAs, derived geometry                  | [mobility.md](mobility.md)                       | ✅ live                                |
| Rate limiting (#23)                                                      | [rate-limiting.md](rate-limiting.md)             | ✅ live                                |
| Boarding — QR scan + manifest + PIN, all deduct (#20, E4)                | [boarding.md](boarding.md)                       | 🟢 3-layer verification live           |
| Observability & performance (#28)                                        | [design](../design/observability.md)             | ✅ backend live (metrics/traces/logs)  |
| Feature flags + force-update — `GET /flags` + admin ops (#27)            | [feature-flags.md](feature-flags.md)             | ✅ live (home-grown, PostHog later)    |
| Basemap: self-hosted tiles, styles, glyphs, served via `/flags` (#178)   | [basemap.md](basemap.md)                         | ✅ live (clients: #180, #170)          |

## Conventions for a feature doc

One doc per feature (roughly one `services/api/src/modules/*` area). Each should
cover, in this order:

1. **Overview** — what it is, in two or three sentences, and its status.
2. **Concepts / model** — the key ideas a reader must hold.
3. **API** — every endpoint: method, path, auth, request, responses + status codes.
4. **How it works** — the flow (a diagram when it helps).
5. **Configuration** — env vars and their effect.
6. **Security** — what protects it and what to watch for.
7. **Local development & testing** — how to run/exercise it with zero infra.
8. **Where the code lives** — the files.
9. **Related** — ADRs and design-doc sections.
