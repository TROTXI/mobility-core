# Staging deletion recovery rehearsal, 2026-10-03

Issue #284. An isolated rehearsal was approved with a maximum incremental
cost of USD 1. This record contains no credentials or account contact details.

## Activation baseline

- A separate private R2 bucket, `trotxi-erasure-staging`, holds the encrypted
  deletion register. Its storage credentials are bucket-scoped. Public access
  and object-expiry rules are not enabled.
- Staging initialization captured one existing local account closure at
  journal revision 0. No new live account was deleted for activation.
- Staging API commit `1647700f12b138bbd1deb71518f4d1aa0e5b09ad` was deployed with
  the register configuration. Health and readiness returned HTTP 200, the
  version matched, and the register/runtime writer check passed.
- The temporarily paused deploy, payment/email maintenance and staging seed
  workflows were restored to active. None was manually dispatched.

## Isolation and recovery method

Render restored the staging database to a new PostgreSQL 18 instance named
`trotxi-erasure-restore-drill`, resource `dpg-db0ijgou01pc73ahpjm0-a`, in
Frankfurt. The selected PITR point was 2026-10-03 09:00 PDT (16:00 UTC), after
register activation. Render reported the copy available, and SQL confirmed
that it contained the initialized control and one historical closure.

The temporary plan was 0.1 CPU / 256 MB at USD 6/month plus 15 GB storage at
USD 4.50/month, prorated. No autoscaling, HA, replica, connection pool,
application, worker or scheduled service was added.

A resource-specific operator IP rule was saved. The existing workspace rule
still allows password-protected external database connections from all IPs.
This rehearsal therefore does **not** establish network-level isolation.
Isolation here means a non-serving copy with no application/worker attached,
exact-host restrictions in the harness and no provider side-effect adapters.
The shared workspace rule was not changed.

Only the disposable copy's control identity was rebound to an independent
test namespace and newly generated test encryption/device keys. The live
register was never fenced, replayed, promoted or overwritten. No live database
writes were performed during the rehearsal.

For the post-snapshot deletion scenarios, PostgreSQL created
`erasure_drill_target` from `trotxi_mks9` using `CREATE DATABASE ... TEMPLATE`
on that same temporary instance while the source had no client sessions.
Synthetic accounts existed before this copy and were deleted afterward in
the disposable source. A third synthetic account was created and deleted
after the copy. No local database export was written.

This is an actual Render PITR recovery followed by a hosted PostgreSQL
snapshot-copy/replay exercise. It is **not** a second provider PITR recovery
across the synthetic deletions, a logical-export restore, a live traffic
cutover or a production disaster-recovery sign-off.

## Observed checks

The harness called the repository's `AccountService`, `AuthService`,
`ErasureRecovery`, `ErasureJournal` and signed R2 adapter directly. It did not
start the HTTP server or worker. Real R2 reads and conditional writes used
only independent test objects.

- The test register captured all three synthetic deletions plus the historical
  closure. Fencing reported revision 4 and four captured entries.
- Preparation before source fencing was refused. Promotion before successful
  replay was refused. Normal runtime access to the restored target was refused.
- A deliberate trigger failure interrupted replay. The target stayed isolated
  and could not be promoted. Removing the test trigger allowed replay to resume.
- Repeated replay examined four entries without duplicate fixture closures.
- Restored profile name, email, phone and avatar pointer were cleared.
- Old fixture sessions and refresh credentials were rejected by `AuthService`.
- Identity subjects and push device tokens were scrubbed.
- The fixture phone challenge became failed with its code hash and encrypted
  phone removed. This was a database-state check, not a live SMS/OTP request.
- The queued fixture email became cancelled with its payload removed.
- The post-snapshot account remained absent rather than being recreated.
- Purchase count was unchanged. This is not evidence for every financial hold
  or post-snapshot accounting case.
- Avatar cleanup remained a pending task. No provider deletion, email, SMS,
  push or payment request was executed.

## Handover and disposal

Final verification passed: changing the fenced test-register revision blocked
promotion, replay established the new watermark, and promotion transferred the
test writer authority. The target passed its runtime gate and the old source
remained blocked. No live traffic was redirected.

Permanent disposal was explicitly approved. By 2026-10-03 16:39 UTC, Render showed that resource
`dpg-db0ijgou01pc73ahpjm0-a` no longer exists. Cloudflare confirmed both test
objects below were successfully deleted; only the live register remained in
the folder. These test copies cannot be recovered through the provider UI.
The temporary local harness was stopped and removed, and transient credentials
were cleared. No database export was saved locally.

The instance existed for approximately 25 minutes. At the displayed prorated
USD 10.50/month combined compute/storage rate, estimated incremental cost is
under USD 0.02, not a verified invoice amount. There is no remaining test
database to accrue charges.

Deleted temporary R2 test objects, not the live register:

- `erasure-register/394c6107-a256-4d18-9d4d-7a1240ddd989.bin` (initial attempt).
- `erasure-register/06718061-5b2c-4f8f-af0a-d3ac572d5fec.bin` (rehearsal).

The first attempt stopped at a conservative session-count check before making
the snapshot. The repeated attempt confirmed no source client sessions and
let PostgreSQL enforce its own snapshot-copy checks. All attempt data was
confined to the now-deleted disposable instance and these test objects.

## Remaining acceptance work

The roles below identify required responsibility, not accepted assignments.
Named owners, evidence locations and review dates belong in the restricted
operations record. This rehearsal does not complete these items.

| Item                                                      | Required owner role                               | Completion evidence / gate                                                                                                                                                                                                                 |
| --------------------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Provider retention and deletion procedures                | Privacy lead with provider account administrators | Account-specific written procedures, responses and exceptions for Resend, mNotify, Firebase, Grafana and Paystack before provider cleanup is certified.                                                                                    |
| Backup and export inventory                               | Infrastructure owner                              | Actual staging/production windows, exports, replicas, downloaded or developer-held copies, disposal records and review dates before backup coverage is accepted.                                                                           |
| Financial holds and other post-snapshot privacy decisions | Finance/privacy lead with engineering reviewer    | Applicable hold and redaction reconciliation, beyond an unchanged purchase count, before any real recovery release.                                                                                                                        |
| Hosted cutoff concurrency and traffic cutover             | Infrastructure owner with engineering reviewer    | Drain an in-flight deletion, refuse post-fence deletion, freeze all other writers, reconcile the final watermark and record release approval before serving a restored database. Existing local concurrency tests are not hosted evidence. |
| Full staging deletion evidence packet                     | Case operator with engineering reviewer           | Seeded applicable linked records, app/API closure, old-device access checks, bounded cleanup outcomes and provider/backup exceptions. Direct service calls in this drill are not the app/HTTP E2E packet.                                  |
| Retention maintenance responsibility                      | Operations owner                                  | Approve a schedule or name a manual operator with cadence, run records and overdue-work escalation before relying on time-based expiry. No schedule was added by this rehearsal.                                                           |
| Production retention policy                               | Ghana legal reviewer with privacy/finance leads   | Written approval or amendments before production retention periods or customer commitments are published.                                                                                                                                  |

Source-loss recovery remains unsupported by the current offline tool. A missing
source requires a separately reviewed recovery procedure, not a replacement
register or forced promotion.

Issue #284 remains open until these acceptance items are evidenced or moved
to explicitly accepted, owned follow-ups. External-provider cleanup is not
certified by this rehearsal.
