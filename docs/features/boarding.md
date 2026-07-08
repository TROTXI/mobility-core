# Boarding — QR passes & scan verification

**Owner:** Godfred Awuku · **Last updated:** 2026-07-08

**Status:** 🟢 All three verification layers live (#20, E4): **QR scan**,
**driver manifest** (photo pass), and **daily PIN** — any one boards the rider's
confirmed reservation and **debits one ride** (ADR-0014). The **confirmed-yes
no-show** deduction (cutoff cron) and the **assigned-driver-only manifest**
(#129) are now built too — see below.

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
- **Integrity → boarding** — verifying a pass proves it's a **real pass for
  rider X**; a valid scan then **boards the rider's confirmed reservation for
  today** and debits **1 ride** from their entitlement (E1 ledger). The debit is
  **idempotent per reservation** (`board:<reservationId>`), and `findBoardable`
  skips already-boarded seats — so re-scanning a rider (even with a freshly
  rotated QR) never double-charges. A valid pass with **no confirmed reservation**
  boards nothing (`deducted: false`) — walk-up/standby is E6.
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
- **200:** `{ "valid": true|false, "riderId": "<uuid>|null", "reason": "ok"|"invalid"|"expired"|"reused", "deducted": true|false }`
  (`reused` = the pass was already consumed; `deducted` = a confirmed reservation
  was boarded and a ride debited. `riderId` is still returned so the driver sees
  who presented it.)

#### `GET /boarding/manifest?tripId=<uuid>`

The trip's confirmed riders (driver only) — the photo pass.

- **Auth:** `Bearer` + **role `driver`**. **Rate limit:** per user.
- **200:** `{ "tripId", "riders": [ { reservationId, userId, name, avatarUrl, direction, boarded } ] }`
  — `avatarUrl` is a short-lived signed URL (null when no photo); only
  `reserved`/`boarded` seats appear. **400** bad tripId · **403** · **503**

#### `POST /boarding/verify-pin`

Board a rider by their daily 4-digit PIN (driver only) — verification layer 2.

- **Auth:** `Bearer` + **role `driver`**. **Rate limit:** per user.
- **Body:** `{ "reservationId": "<uuid>", "pin": "1234" }`
- **200:** `{ "valid", "riderId", "reason": "ok"|"invalid"|"not_found"|"already_boarded", "deducted" }`
  — `ok` boards + debits; `already_boarded` is the idempotent no-op. **400** bad PIN · **403**

---

## Data

`scan_events(id, rider_id, scanned_by, trip_id, result, method, created_at)` —
`result` ∈ `valid|invalid|expired|reused`, `method` ∈ `qr|photo|pin`. `trip_id`
has no FK yet (trips are #18). The daily PIN is stored on `reservations`
(`daily_pin_hash`, a keyed HMAC — never plaintext).

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
([ADR-0014](../adr/0014-hybrid-subscription-model.md)): boarding is **three
verification layers**, and any one consumes **1 ride from the subscription
entitlement**. **Done (this + prior slices):** QR scan + deduction, the driver
**manifest** (photo pass, assigned-driver-gated), the **daily PIN**, and the
**no-show** cutoff deduction. Still to come:

- ✅ **QR scan** — `POST /boarding/scan` (deducts).
- ✅ **Driver manifest** — `GET /boarding/manifest?tripId=` (name + signed photo).
- ✅ **Daily PIN** — `POST /boarding/verify-pin` (boards + deducts, idempotent).
- ✅ **Confirmed-yes no-show** — `POST /admin/resolve-no-shows` (admin cutoff
  cron): every still-`reserved` seat that wasn't boarded is deducted and marked
  `no_show`. Deducts on the **same idempotency key as boarding**
  (`board:<reservationId>`) so a late board and the no-show sweep can't both
  charge; operator cancellation never deducts.
- ✅ **Manifest → assigned driver only** (#129) — a trip's manifest is restricted
  to its assigned driver (`drivers.findByUserId` + `trip.assignedDriverId`).
- **Per-rider pickup point** on the manifest — needs a rider↔stop link.
- Direction/trip resolution: a QR scan still boards the rider's **earliest open
  leg for the day** (morning before evening); the PIN + manifest target a
  specific reservation. When trips carry the run's direction, the scan converges.

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
