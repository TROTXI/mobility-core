# Background jobs and scheduling

Status: prepared, disabled by default. This change does not provision hosting,
enable a scheduler, change GitHub variables or retire an existing live job.

## Hosting and cost

The optional scheduler runs inside the existing API process. It adds no separate
worker service, external scheduler credential or public maintenance endpoint.
It uses the backend's existing restricted database role and configured providers.
It needs an **always-on API**. The checked-in staging Render blueprint uses
`plan: free`; do not enable this scheduler on a service that sleeps. The actual
dashboard plan must be checked at cutover. Any hosting upgrade needs approval.

Cloudflare Workers Free can host a lightweight trigger, but not the whole Node
backend. At the time of this review its limits include 100,000 requests/day and
10 ms CPU per scheduled invocation. Waiting for network I/O does not count as
CPU. The database, backend, SMS and payment-provider usage still have their own
costs. This implementation does not deploy a Cloudflare Worker or promise an
end-to-end free production service. See the
[official limits](https://developers.cloudflare.com/workers/platform/limits/).

## Proposed schedule

All times are UTC, also Accra time. These are eligibility windows, not exact
delivery guarantees. The next tick starts 60 to 70 seconds after the previous
cycle finishes. Slow providers and large backlogs can delay later work.

| Job                        | When eligible                    | Why it exists                                                                                                            |
| -------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Push                       | Each minute                      | Deliver queued phone notifications; creating an inbox item alone does not alert a phone.                                 |
| Messages (`emails`)        | Each minute                      | Prepare due email reminders, drain encrypted email and SMS queues, and handle delivery retries.                          |
| Payments                   | Every 15 minutes                 | Process provider events, reconcile uncertain payments, and close ended periods.                                          |
| Auto-renewals              | Every 15 minutes                 | Prepare renewal reminders and process eligible, opted-in saved-card renewals. Not automatic mobile-money charging.       |
| GPS retention              | Every 5 minutes                  | Delete expired location evidence while preserving holds.                                                                 |
| Admission cleanup          | Every 5 minutes                  | Remove expired rate-budget windows without resetting current limits.                                                     |
| Driver secrets             | Every 5 minutes                  | Clear expired replayable driver credential material.                                                                     |
| Erasures                   | Every 5 minutes                  | Retry outstanding erasure work and clear expired account receipts, OTP challenges and email-access material.             |
| Trip generation            | Hourly                           | Create missing departures for today and the next seven days from published schedules. Does not generate past departures. |
| Resume pauses              | Hourly                           | End personal pauses whose resume time has passed.                                                                        |
| Ask riders                 | From 21:00                       | Create tomorrow's ride-confirmation requests in both directions. Push delivery is separate.                              |
| Reservation defaults       | From 00:00                       | Resolve today's unanswered requests using the existing reservation rules.                                                |
| No-shows                   | From 23:30 and next-day catch-up | Settle eligible unboarded reservations and consume their rides. Preserves the existing late-evening policy.              |
| Route learning             | From 01:30                       | Update travel-time estimates from eligible trip evidence.                                                                |
| Incident retention         | From 01:30                       | Redact expired resolved-incident material while respecting holds.                                                        |
| Payment evidence retention | From 01:30                       | Redact expired raw payment evidence without deleting the financial ledger.                                               |

Payment inbox, reconciliation and period close are parts of the combined
payments job, not three extra schedules. Their Ops buttons remain available
for targeted recovery. All manual controls remain manual; their presence does
not prove that automatic scheduling is active.

The existing 21:00 ask and midnight default policy is deliberately unchanged.
This scheduler does not implement a new per-rider reminder-time policy. Late
services after 23:30 require a separate review of the no-show business cutoff.

## Execution and recovery

- One checked-out PostgreSQL connection holds a session advisory lock for a
  cycle. Other API replicas skip the cycle. Use a direct or session-pooled
  database connection, never a transaction-pooling proxy for this lock.
- The scheduler requires at least four pool connections, push and at least one
  messaging provider, and an admin service identity with no contact details,
  driver record, sign-in identities or interactive-session history. Startup
  validation does not create or elevate an account.
- Jobs reuse the existing worker entry point, maintenance-session authorization,
  domain transactions and audits. No additional HTTP bypass is introduced.
- Each batch is limited to 100. A job can take at most ten passes, checking a
  45-second budget between passes. This does not cancel an in-flight provider
  call or transaction. Stalled full batches and remaining backlogs are failures,
  not reported as successful empty runs. Blocked records may still require Ops
  intervention; the scheduler cannot repair their underlying domain state.
- UTC slots are recorded in the existing maintenance audit. Completed slots
  survive process restarts. Failed or interrupted daily slots retry after five
  minutes. Periodic work is eligible again in its next interval.
- A failure does not skip unrelated jobs. Failures and group outcomes emit
  bounded JSON logs without provider payloads or user identifiers. These are
  logs, not a newly configured alert destination. Configure failure and missing-
  execution alerts before production activation.
- Delivery is at least once, not exactly once. A crash between work and its
  completion record can replay a job. Existing domain/provider deduplication
  remains necessary. Losing the lock connection stops subsequent work but
  cannot undo an already-started transaction or provider request.
- Shutdown stops new work and waits for in-flight work within the API's existing
  15-second exit deadline. A forced exit leaves an incomplete audit for recovery.
- Daily recovery covers today, plus yesterday's no-shows. A multi-day outage
  needs an explicit Ops review for older service dates. Do not bulk backfill
  old reservations or charges blindly.

## Controlled staging cutover

1. Review the timetable, provider configuration and service identity on an
   always-on staging API. Check the live hosting plan and approve any new cost.
   Keep `REPLACEMENT_SCHEDULER_ENABLED=false` or unset while deploying the code.
2. Set the **repository-level** GitHub variable `STAGING_JOB_SCHEDULER=api`.
   Both legacy maintenance workflows will skip, including manual dispatches.
   Wait for any already-running maintenance workflows to finish. This guard
   does not stop a workflow that was already running.
3. Confirm no separate Render/Cloudflare/other cron invokes the same jobs.
   Those external invocations do not participate in the new scheduler lock.
4. Set `REPLACEMENT_SCHEDULER_ENABLED=true` and a dedicated
   `REPLACEMENT_MAINTENANCE_USER_ID` on the API, then perform an approved deploy.
   Do not copy root secrets into a new cron environment. No extra secret is
   required by the scheduler.
5. Verify startup says `scheduler: enabled`, group logs and maintenance audit
   outcomes appear, and test-mode delivery/payment recovery works. Observe a
   complete service-day cycle and configure failure/missing-run alerts before
   treating this as production-ready.

Rollback: disable the API scheduler and wait for its work to stop **before**
removing the GitHub repository variable or setting it to `github`. Check the
audit for incomplete work and recover only the affected service dates. Legacy
GitHub workflows do not cover all the jobs listed above, so rollback restores
the old coverage gaps rather than silently claiming equivalent automation.

No live cutover, provider send, payment charge or hosting purchase is authorized
by this document.
