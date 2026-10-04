# Ops audit coverage (29 September 2026)

`GET /v1/ops/audit-events` is a read over existing evidence, not a second command log. It returns actor ID, action, target, reason when retained, and UTC time. It never returns request bodies, provider payloads, keys, PINs, or receipt response snapshots. Access requires an authenticated Ops session. The UI pages 50 rows at a time and can filter by area, exact actor/action/target, and inclusive UTC dates. A cursor is bound to every filter.

| Ops mutations                                                               | Durable evidence shown in Audit                                   |
| --------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| Routes, stops, patterns and publication                                     | `catalog_events`                                                  |
| Service schedules                                                           | `schedule_events`                                                 |
| Trips, assignments, reschedules, cancellations and generated trips          | `trip_events`                                                     |
| Vehicles, incidents and driver requests/decisions                           | `fleet_events`                                                    |
| Incident-detail redaction                                                   | `incident_redactions` and `maintenance_run_*`                     |
| Driver records and credential issuance, reset and state changes             | `driver_events`                                                   |
| Commute slots/requests and rider restrictions                               | `membership_events`                                               |
| New-rider standby offers and rider transitions                              | `standby_events`                                                  |
| No-show decisions that change a reservation                                 | `boarding_events`                                                 |
| Fare publication and plan pricing                                           | `pricing_events`                                                  |
| Feature flags, minimum app versions and administrator role changes          | `config_events`                                                   |
| Operator passkey reset                                                      | `admin_passkey_events`                                            |
| Operator invitations, activation, access changes and first-superadmin setup | `ops_team_events`                                                 |
| Manual payment-review decisions                                             | `payment_review_commands` (decision and reason only)              |
| TEST refund initiation                                                      | `refund_initiations` (intent and reason, not provider settlement) |
| GPS evidence-hold creation and release                                      | `gps_events`                                                      |
| Manual and scheduled maintenance, including no-work and failures            | `maintenance_run_starts` and `maintenance_run_outcomes`           |

The read does not imply that every event is an administrator action: driver and rider operations also appear in some of these tables. “Actor” means the user whose ID the durable source recorded. The current user row supplies a display name for convenience; it is not a historical role assertion.

`services/api-next/tests/ops-audit-coverage.test.ts` pins every published Ops mutation to one of these sources and pins the full scheduled-job list to the worker run recorder. Adding a privileged operation or scheduled job without reviewing its evidence makes CI fail. The sampled read tests cover role grants, payment decisions, trip assignments, configuration changes and manual maintenance. Audit reads require an authenticated Ops session; commuter and driver routes expose none of these rows. The two maintenance tables are append-only and have no automatic deletion job. They contain only IDs, a bounded operation name, origin, status, counts and timestamps, so they remain available for the lifetime of this staging database unless a separate retention policy is approved. Database backups may retain older copies under the hosting provider's policy.

## Explicit limits

- **Historical migration boundary:** maintenance attempts before migration 032 have no run records. The new rows record only future attempts. An unmatched start indicates that execution was interrupted before an outcome could be written.
- **Outcome linkage:** an audit row for a command does not imply the provider accepted a refund, delivered an email, or that every batch item succeeded. Those are separate provider/delivery and maintenance outcomes.
- **Historical attribution:** the current display name can change or be erased. Actor ID is durable; a historical label would need a bounded, privacy-reviewed snapshot policy.

Maintenance starts and outcomes retain only actor, operation, origin, timestamps, status and bounded counts. They do not imply a provider accepted a payment or delivered a message; those facts remain in their respective evidence tables.
