# Driver incident privacy and retention

Pilot policy approved 29 September 2026. The periods below are product choices,
not time limits prescribed by Ghana's Data Protection Act. They run from the
`resolved` decision time (`handled_at`), not the driver's report time. An open
or acknowledged incident remains available to Operations until it is resolved.
The [Data Protection Act, 2012 (Act 843), section 24](https://nita.gov.gh/theevooc/2017/12/Data-Protection-Act-2012-Act-843.pdf)
requires retention tied to necessity and deletion or de-identification when
that basis ends; it does not supply these category windows.

| Category                            | Identifiable report details after resolution |
| ----------------------------------- | -------------------------------------------: |
| `vehicle`, `route_blocked`, `other` |                                      90 days |
| `collision`, `passenger_safety`     |                                     365 days |

An active, explicitly recorded trace hold blocks incident redaction. The hold
has its own reason, owner and review date. Releasing it makes the incident
eligible at the next sweep if its category window has passed. Operations must
review active holds; a review date does **not** silently release one. An
unresolved incident and a hold are not a licence to retain indefinitely: the
owner must resolve/review them, and overdue cases need operational attention.

## Collected and retained

The driver supplies an optional note, optional location and one of five
categories. Trip provenance is checked against the assigned driver. The API
rejects obvious payment-card numbers and sign-in secrets in incident notes and
resolution text; this filter is not a substitute for human review. Staff should
not copy passenger names, phone numbers, payment details or credentials into
free text. The app should request a location only when needed for the report.

At expiry, a batch transaction removes note, precise coordinates, resolution,
driver, trip, vehicle and handler links from the incident row. It records
`redacted_at`, increments the edit version, and writes an append-only
`incident_redactions` fact naming the maintenance operator, incident and
category. The incident row retains category, status and timestamps for
aggregate service statistics. Its ID still joins restricted command/event
audit records, so this is minimization and link removal, **not anonymization**.
Ops reads return null for redacted fields;
the driver's own list no longer includes the unlinked row. The database refuses
restoring a redacted row or creating a new trace hold for it.

Incident fleet-event snapshots and trace-hold event snapshots are minimized at
write time; migration 033 also removes sensitive fields from historical copies.
When an incident is redacted, released holds lose their incident link and free
text, and related command response snapshots are cleared in the same
transaction, even if a hold was just released inside its seven-day replay
window. Command identity/hash/actor and event actor remain as restricted,
attributable audit facts; they are **not anonymous** and are not exposed in
the incident list. Account deletion already anonymizes the driver profile and
closes sessions but does not bypass an open incident or active evidence hold.
Broader cross-system erasure and provider/back-up retention remain tracked
separately under issue #284. Database backups may preserve pre-redaction copies
until the hosting provider's backup retention expires.

## Execution and evidence

`node dist/worker.js incident-retention` runs one bounded batch of at most 100
incidents, using the configured maintenance operator. It returns counts for
redacted, held and still-eligible rows; a still-eligible backlog makes the
worker exit nonzero, rather than claiming retention succeeded. The worker run
start/outcome records are durable. Repeating a run is safe: already-redacted
rows are never selected again. The job is prepared but **not scheduled** in
`render.yaml`; do not claim automated enforcement until an approved scheduler
is enabled and the first result is checked. The worker requires a configured
`REPLACEMENT_MAINTENANCE_USER_ID` and the usual database connection; the active
staging web-service block does not declare that operator ID. During staging,
run it manually only once that existing maintenance identity is configured,
and review the outcome without logging report text or coordinates.
