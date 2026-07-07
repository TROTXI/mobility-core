# Boarding — QR passes & scan verification

**Owner:** Godfred Awuku · **Last updated:** 2026-07-02

**Status:** 🟡 integrity slice live (#20). The **eligibility gates** (active
membership + token debit on board) and the **photo-pass** fallback are deferred —
see below.

Lets a driver confirm a rider is boarding with a **genuine, unforged, unexpired
pass**, and logs every scan for audit. Rationale: #20.

---

## Concepts

- **Pass** — a **short-lived signed token** (JWT, HS256, audience `trotxi-pass`,
  ~60s) the rider's app renders as a **QR**. The short TTL means the QR **rotates**,
  and each pass carries a unique `jti` making it **single-use**: the first valid
  scan consumes it (KV `increment`), so a shared screenshot dies on the second
  scan, not just at the TTL. Signed with the server key but a distinct audience,
  so a pass can't be used as an access token (or vice-versa). Verification allows
  5s clock tolerance (drift across instances).
- **Integrity vs eligibility** — verifying a pass proves it's a **real pass for
  rider X**. It does **not** (yet) check membership or debit tokens — those are the
  money-gated part (#19/#21), deliberately deferred.
- **Scan event** — every verification is one **append-only** audit row
  (`scan_events`): rider, driver, trip, result, method. `rider_id` is null for an
  invalid/forged pass (unattributable).

---

## API

#### `GET /me/pass`

Issue the caller's rotating boarding pass.

- **Auth:** `Bearer`. **Rate limit:** per user.
- **200:** `{ "pass": "<token>", "expiresInSeconds": 60 }` — render `pass` as a QR; refresh before it lapses.

#### `POST /boarding/scan`

Verify a scanned pass (drivers only) and record the scan.

- **Auth:** `Bearer` + **role `driver`** (else **403**). **Rate limit:** per user.
- **Body:** `{ "pass": "<scanned token>", "tripId?": "<uuid>" }`
- **200:** `{ "valid": true|false, "riderId": "<uuid>|null", "reason": "ok"|"invalid"|"expired"|"reused" }`
  (`reused` = the pass was already consumed by an earlier scan; `riderId` is still
  returned so the driver sees who presented it)

---

## Data

`scan_events(id, rider_id, scanned_by, trip_id, result, method, created_at)` —
`result` ∈ `valid|invalid|expired|reused`, `method` ∈ `qr|photo`. `trip_id` has
no FK yet (trips are #18).

## Security notes

- **Rotating, signed, single-use passes** — forgery needs the server key; the
  short TTL rotates the QR; the `jti` consume-on-scan kills screenshot sharing
  within the window.
- **Audience separation** — a `trotxi-api` access token fails pass verification and
  vice-versa (tested).
- **Full audit** — every scan (including failures and reuses) is recorded.
- **Availability over strictness** — the KV single-use check and the audit write
  both **fail open** (log loudly, never block boarding). Same posture as the rate
  limiter; when the money work lands, the token debit becomes the transactional
  anchor and this decision is revisited.
- **Input hygiene** — the scanned pass is capped at 512 chars before it reaches
  `jwtVerify`; the scan route throttles **before** the role check so non-driver
  tokens can't hammer unthrottled 403s.

## Next (Hybrid Subscription Model — ADR-0014, boarding v2 / epic E4)

The commercial model is decided
([ADR-0014](../adr/0014-hybrid-subscription-model.md)): this QR core becomes
**one of three verification layers**, and boarding consumes **1 ride from the
subscription entitlement** (not a fare debit from a wallet). Coming in E4:

- **Driver manifest layer** — name + **photo** (server-side, R2 #24) + pickup
  point for the day's reservations. The photo pass is now required product.
- **Daily 4-digit PIN layer** — offline-friendly fallback; any layer completes
  verification.
- **Ride deduction on verify** (idempotency key = reservation id) + the
  confirmed-yes **no-show** deduction job; operator cancellation never deducts.
- Eligibility: active subscription + a **confirmed reservation** for the trip
  (from the daily-confirmation flow), replacing the old wallet-balance gate.

## Where the code lives

```
services/api/src/modules/boarding/
  pass.ts                    # sign/verify the short-lived pass (jose)
  scan-event.repository.ts(.pg) # append-only scan audit
  boarding.service.ts        # issuePass + verifyScan (records the scan)
  boarding.routes.ts         # GET /me/pass, POST /boarding/scan
  boarding.schema.ts
services/api/src/db/migrations/010_scan_events.sql
```

## Related

- [authentication.md](authentication.md) (the same JWT/HS256 machinery, different audience)
- `strategy/system-design.md §4.3` (boarding requires membership + balance)
