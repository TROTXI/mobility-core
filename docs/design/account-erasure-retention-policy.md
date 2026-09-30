# Account deletion and retained evidence: pilot decision

Status: engineering policy for disposable staging, 30 September 2026. This is
not a legal opinion or a promise that external processors erase data when
`DELETE /v1/me` returns. Ghana tax/privacy counsel must approve the production
financial-record period and any wording published to customers.

## Retention decision

| Data                                                                         | Rule                                                                                                                                                                                                                                                                                                                                                                            | What remains after the rule runs                                                                                                                                                                                                    |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Account identity, sessions, active devices, pending messages, private avatar | Close/revoke/scrub in the existing account transaction; retry tracked R2/Apple work until independently confirmed                                                                                                                                                                                                                                                               | Local deletion audit and restricted command identities; no usable sign-in or profile                                                                                                                                                |
| Payment accounting facts                                                     | Provisionally restrict to finance/Ops audit for six years; **do not implement a six-year purge until a Ghana adviser confirms the applicable tax/accounting rule and start date**                                                                                                                                                                                               | Purchase, collection, refund, dispute, amount, currency, timestamps, Paystack reference, decision and actor links remain pseudonymous, not anonymous                                                                                |
| Encrypted raw Paystack event bodies                                          | Redact a processed event 180 days after processing, provided its immutable purchase association is known and no unresolved attempt, open review, pending refund or refund intent, or unresolved dispute exists for that purchase. This is a pilot minimisation choice, **not** a statutory period. The bounded `payment-evidence-retention` worker performs the one-way change. | Event ID, environment, source, payload hash, outcome, purchase association and structured ledger entries remain. Ready/quarantined and legacy events without a provable purchase association are excluded and require human review. |
| GPS and resolved incident details                                            | Existing 30-day trace and 90/365-day incident rules, subject to active holds                                                                                                                                                                                                                                                                                                    | Existing restricted hold and redaction evidence                                                                                                                                                                                     |
| Managed backup copies                                                        | Expire under the actual Render plan; never claim a live-row update rewrites a backup. Reapply post-backup deletion facts before serving a restored database.                                                                                                                                                                                                                    | Restore copies may exist during the provider window. Downloaded/self-managed exports need a separate inventory and expiry rule.                                                                                                     |

Ghana's [Data Protection Act, section 24](https://dataprotection.org.gh/wp-content/uploads/2025/05/Data-Protection-Act-2012-Act-843.pdf)
requires purpose-limited retention and deletion or de-identification at the end
of the applicable period. The [GRA e-VAT guidance](https://gra.gov.gh/wp-content/uploads/2024/07/E-VAT-GUIDELINES_20240222.pdf)
sets a six-year minimum for the VAT records of registered persons; it does not
say that every Trotxi webhook body should be kept that long. Paystack describes
[its own five/six-year obligations](https://dr.paystack.com/gh/terms), which
must not be presented as Trotxi's automatic obligation. Paystack's
[dispute guidance](https://paystack.com/docs/payments/manage-disputes/) expects
the merchant to supply transaction and fulfilment evidence; the structured
ledger and ride/attendance facts must be validated as sufficient before the
first production redaction of a historical event.

## External-provider handling

The Ops account-deletion tab is deliberately named **local deletion status**.
Its `tracked_complete` state covers only tracked avatar and revocable sign-in
tasks. An operator must record provider request IDs, responses and actual
expiry/deletion evidence separately; no successful local API response is a
cross-provider erasure certificate.

- **Paystack:** preserve transaction/refund/dispute records required for
  reconciliation and claims. Review any request involving a deleted rider
  against open financial work before seeking deletion of non-required fields.
  Do not call an imagined transaction-deletion endpoint.
- **Resend:** sent messages cannot be recalled. Its [security statement](https://resend.com/security)
  says email and log data are retained for 30 days on Free, Pro and Scale.
  Confirm the actual account configuration and request support action only if
  a message contains exceptional sensitive data; record the response.
- **mNotify:** its [terms](https://www.mnotify.com/terms) confirm it processes
  customer-supplied message data but do not establish a per-message deletion
  API or a usable retention period. Ask mNotify support for written retention,
  deletion and backup-expiry procedures before making a customer promise.
- **Firebase:** removing a push token locally stops Trotxi sends, but does not
  prove the installation or Analytics records are deleted. Firebase documents
  an [installation-ID deletion path](https://firebase.google.com/docs/projects/manage-installations)
  and explicitly notes that it does **not** delete Analytics data. An app-side
  identifier/consent design is needed before treating this as an automated task.
- **Grafana:** current request logs intentionally omit bodies, query strings
  and auth headers. If a sensitive value nevertheless reaches Logs, Grafana
  documents a [targeted deletion API](https://grafana.com/docs/grafana-cloud/send-data/logs/delete-log-lines/);
  [trace deletion](https://grafana.com/docs/grafana-cloud/send-data/traces/remove-trace-info/)
  requires support. Verify this stack's actual retention rather than assuming
  the product default; inspect any exported archives separately.
- **Render:** [paid Postgres recovery](https://render.com/docs/postgresql-backups)
  is three days on Hobby or seven days on Pro+, and on-demand logical exports
  are retained by Render for seven days. Verify the workspace plan and any
  downloaded exports. A restore must replay account deletion before apps use it.

## Manual staging cadence (no new paid cron jobs)

The designated staging operator records UTC start/end, job name, counts,
failures and follow-up in the operations log. Use the already configured
maintenance identity and deployed worker; never copy database or provider
secrets into an issue or terminal transcript.

| When                                                     | Worker                                | Required check                                                                                                                                                                                                                                                                                     |
| -------------------------------------------------------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| After each deletion request and each staging working day | `erasures`                            | Re-run bounded batches until the account's local status is `tracked_complete` or an unavailable task has an owner and next retry. A `204` alone is insufficient.                                                                                                                                   |
| Each staging working day                                 | `gps-retention`, `incident-retention` | Inspect job exit and remaining eligible/overdue counts; investigate holds and failures.                                                                                                                                                                                                            |
| Weekly                                                   | `payment-evidence-retention`          | Record redacted count and check `backlogRemaining=false`; a remaining backlog makes the job fail for monitoring and must be drained in another bounded run. Separately review ready/quarantined or unassociated legacy events and open financial holds. Never force a held row through the worker. |

This manual cadence is a **staging concession**, not an unattended production
control. Before real users or a production deletion promise, schedule and
monitor these jobs, test restore-and-replay of deletion, confirm provider and
backup windows, and approve the accounting period with counsel. A missed run
or provider uncertainty remains open work under issue #284.
