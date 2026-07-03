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
  so a screenshot can't be reused. Signed with the server key but a distinct
  audience, so a pass can't be used as an access token (or vice-versa).
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
- **200:** `{ "valid": true|false, "riderId": "<uuid>|null", "reason": "ok"|"invalid"|"expired" }`

---

## Data

`scan_events(id, rider_id, scanned_by, trip_id, result, method, created_at)` —
`result` ∈ `valid|invalid|expired`, `method` ∈ `qr|photo`. `trip_id` has no FK
yet (trips are #18).

## Security notes

- **Rotating, signed passes** — forgery needs the server key; the short TTL blocks
  screenshot reuse.
- **Audience separation** — a `trotxi-api` access token fails pass verification and
  vice-versa (tested).
- **Full audit** — every scan (including failures) is recorded.

## Deferred (with the money work / product)

- **Eligibility gates** — a valid scan should also require an **active
  subscription** and (later) **debit a token** for the fare. Couples to the
  commission model (on hold), so not built here.
- **Photo-pass fallback** — driver-confirmed boarding when QR fails; needs image
  upload (Cloudflare R2, #24) + product UX for how the driver identifies the rider.

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
