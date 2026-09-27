# ADR-0018: Ops-reviewed commute changes and paid-time pauses

- Status: implemented on this branch; deployment pending
- Date: 2026-09-13
- Related: ADR-0014, ADR-0017, issue #240

## Context

Moving home must not force a rider off the platform. A requested corridor may
not have recurring capacity, and editing a paid subscription directly could
overbook trips, strand old reservations or change the valuation of unused rides.
The commuter team owns rider interaction and the API; the ops team owns its UI.

## Decision

Persist intent separately in `commute_requests`. Operations pulls the queue and
records an audited decision through role-protected endpoints. Waitlisting alone
does not change the subscription. One rider can have one open request, and each
approval claims one explicitly verified recurring transfer slot atomically.

Pause requires rider consent and an ops action. Store it separately from payment
dispute suspension: resolving a dispute must not undo a commute pause. While
paused, booking/dispatch, period close and new checkout are refused or excluded.
On resume, extend the same period by elapsed pause time. Retain the original
deadline and extension in the pause history; financial rate/price/route snapshots
and the entitlement balance remain unchanged.

The shared per-user transaction lock serializes payment and commute changes.
Applying an approved transfer requires its date to have arrived, unchanged
current-period identity, no unsettled trip, valid ordered stops, a held slot and
the same fare. Cancel future old-route reservations, replace the operational
assignment, and resume an authorized pause in one transaction. Different fares
require a later explicit pricing policy; do not guess a pro-rata amount.

Expiry/refund/cancellation or a replacement period invalidates stale approvals,
releases transfer capacity, and ends obsolete pauses. Keep request/event history.
No extra ride allocation or automatic charge is part of a transfer.

## Consequences

- The rider app can ship independently of an ops UI, but ops must arrange queue
  review before requests are enabled for riders.
- Approval is a held slot, not automatic application on a future date. Ops applies
  it explicitly. No new scheduler is enabled.
- Integration requires Postgres; an unconfigured API returns 503 rather than
  pretending to persist requests in memory.
- This does not implement a platform-wide recurring capacity allocator, fare
  adjustments, push notifications or the ops console.
- Migration/API must precede the commuter app deployment.

See [the feature/API handoff](../features/commute-change-requests.md) for exact
routes, request bodies, state transitions and verification scope.
