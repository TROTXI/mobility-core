# Boarding verification

Source audit: 2026-10-03.

The assigned driver boards a reservation using a QR proof, boarding code or
photo-manifest selection. All methods converge on one transactional settlement.

## API

- Rider: `POST /v1/me/reservations/{id}/pass`.
- Driver manifest: `GET /v1/driver/trips/{id}/manifest`.
- Boarding: `POST /v1/driver/trips/{id}/boardings`.
- No-show: `POST /v1/driver/trips/{id}/reservations/{reservationId}/no-show`.
- Ops manifest: `GET /v1/ops/trips/{id}/manifest`.

Passes are reservation-bound and short-lived. The server validates proofs,
ownership, current assignment, trip and funded-reservation state. Code attempts
have a durable budget. A photo URL is resolved from private account storage,
never trusted from a QR payload.

A boarding/no-show charge is unique to the reservation. The reservation,
charge, ledger effects, receipt and required events commit together or roll
back. A retry does not deduct another ride. Optional telemetry after commit
may fail without undoing settlement; required accounting does not fail open.

A boarding code is an alternative to the camera, not offline authorization.
The driver still needs an API confirmation. No local offline boarding queue is
implemented. Declined, cancelled or otherwise ineligible seats cannot be boarded
simply because an old QR or screenshot exists.

Sources: `services/api-next/src/boarding/{service,proofs}.ts`,
`tests/boarding.pg.test.ts`, driver Scan/Manifest screens.
