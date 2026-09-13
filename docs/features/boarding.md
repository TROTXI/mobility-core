# Boarding verification

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** QR, trip-wide code entry, reservation-targeted PIN, photo-manifest
boarding, driver-marked no-shows and cutoff no-shows are live.

## Verification paths

Any of the three rider proofs can complete boarding:

1. QR pass: a signed HS256 JWT for audience `trotxi-pass`, approximately 60
   seconds old and single-use by `jti`.
2. Daily code: a four-character code stored only as keyed HMAC. The driver can
   enter it directly for the run or against a selected reservation.
3. Photo manifest: the assigned driver identifies the rider from name and a
   short-lived signed avatar URL, then boards the reservation directly.

All successful paths converge on the same operation: mark the reservation
boarded and append `-1` ride with `idempotency_key = board:<reservation-id>`.

## API

| Endpoint                         | Role            | Purpose                                                               |
| -------------------------------- | --------------- | --------------------------------------------------------------------- |
| `GET /me/pass`                   | rider           | Issue a rotating QR pass                                              |
| `POST /boarding/scan`            | driver          | Verify QR integrity/single-use and board the rider's open reservation |
| `POST /boarding/verify-code`     | assigned driver | Find the one actionable seat on a run with this code and board it     |
| `POST /boarding/verify-pin`      | assigned driver | Verify a code against a known reservation and board it                |
| `GET /boarding/manifest?tripId=` | assigned driver | Confirmed riders with status, source, name and signed photo           |
| `POST /boarding/board`           | assigned driver | Board a rider identified from the photo manifest                      |
| `POST /boarding/no-show`         | assigned driver | Mark one confirmed rider absent and consume the ride                  |
| `POST /admin/resolve-no-shows`   | admin           | Convert all still-reserved seats at cutoff to no-shows                |

The trip-wide code path refuses ambiguous matches instead of charging the first
rider found. Old numeric four-digit codes remain accepted; newly generated
codes use an ambiguity-resistant alphanumeric alphabet.

The QR endpoint is still role-gated rather than assignment-gated and resolves
the rider's earliest boardable reservation for the current UTC day. Code, PIN
and photo paths target a specific trip/reservation and enforce assignment. This
is the current contract, not the desired end state.

## Authorization and attempt limits

PIN/code/photo actions require the caller to be the trip's assigned driver, not
merely to hold the driver role. Wrong attempts are budgeted in KV: per
reservation for targeted PIN entry and per trip/driver for the door flow.

## Failure posture

Boarding prioritizes getting a verified rider onto the vehicle:

- KV failure allows the attempt and logs the missing single-use/guess budget.
- Scan-audit failure is logged without reversing boarding.
- A QR-path deduction failure does not reject the rider; reconciliation must
  identify the audit gap.

This availability posture is deliberately narrower than authentication or
payment processing, which fail closed.

## Idempotency and corrections

- QR, code, photo and no-show use the same `board:<reservation-id>` key.
- Repeated boarding returns `already_boarded` without another deduction.
- A driver can board a rider after marking them no-show; the shared key prevents
  a second charge.
- Declined, released, unseated and operator-cancelled rows are not boardable.

## Code

- `services/api/src/modules/boarding/`
- `services/api/src/modules/reservations/pin.ts`
- migrations `010`, `016_reservation_pin` and `017`
- [ADR-0014](../adr/0014-hybrid-subscription-model.md)
