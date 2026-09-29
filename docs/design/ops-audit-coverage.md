# Ops audit coverage (29 September 2026)

`GET /v1/ops/audit-events` is a read over existing evidence, not a second command log. It returns actor ID, action, target, reason when retained, and UTC time. It never returns request bodies, provider payloads, keys, PINs, or receipt response snapshots. Access requires an authenticated Ops session. The UI pages 50 rows at a time and can filter by area, exact actor/action/target, and inclusive UTC dates. A cursor is bound to every filter.

| Ops mutations                                                      | Durable evidence shown in Audit                                   |
| ------------------------------------------------------------------ | ----------------------------------------------------------------- |
| Routes, stops, patterns and publication                            | `catalog_events`                                                  |
| Service schedules                                                  | `schedule_events`                                                 |
| Trips, assignments, reschedules, cancellations and generated trips | `trip_events`                                                     |
| Vehicles, incidents and driver requests/decisions                  | `fleet_events`                                                    |
| Driver records and credential issuance, reset and state changes    | `driver_events`                                                   |
| Commute slots/requests and rider restrictions                      | `membership_events`                                               |
| No-show decisions that change a reservation                        | `boarding_events`                                                 |
| Fare publication and plan pricing                                  | `pricing_events`                                                  |
| Feature flags, minimum app versions and administrator role changes | `config_events`                                                   |
| Operator passkey reset                                             | `admin_passkey_events`                                            |
| Manual payment-review decisions                                    | `payment_review_commands` (decision and reason only)              |
| TEST refund initiation                                             | `refund_initiations` (intent and reason, not provider settlement) |
| GPS evidence-hold creation and release                             | `gps_events`                                                      |

The read does not imply that every event is an administrator action: driver and rider operations also appear in some of these tables. “Actor” means the user whose ID the durable source recorded. The current user row supplies a display name for convenience; it is not a historical role assertion.

## Still missing before #167 can close

- **Maintenance run evidence:** per-item domain changes often have receipts or events, but there is no one durable start/outcome record for every manual and scheduled batch. In particular, no-op batches, failed batches, personal-pause resumes, email/push delivery, erasure, driver-secret, and admission sweeps are not uniformly reconstructable in Ops Audit. Metrics and GitHub/Render logs are not substitutes for an append-only run record.
- **Execution identity:** scheduled work currently uses a real administrator user/session. Existing domain events do not preserve whether the operator clicked a control or a worker used that account. A run record needs an explicit `manual`/`worker` origin, not an inference from the current user role or a mutable client header alone.
- **Outcome linkage:** an audit row for a command does not imply the provider accepted a refund, delivered an email, or that every batch item succeeded. Those are separate provider/delivery and maintenance outcomes.
- **Historical attribution:** the current display name can change or be erased. Actor ID is durable; a historical label would need a bounded, privacy-reviewed snapshot policy.

The next slice should write append-only maintenance start/outcome rows, including zero-work and failure paths, from both HTTP and worker entry points. It should test that a committed maintenance action is not reported as unaudited success if the outcome write fails, while never persisting sensitive result bodies.
