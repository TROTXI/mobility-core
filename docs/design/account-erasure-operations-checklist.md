# Account deletion: evidence packet and restore release gate

Engineering runbook for #284, 2 October 2026. This is not a new retention
policy, legal opinion, provider completion certificate or authorization to
delete data. Use the [data map](account-erasure-data-map.md) and
[pilot retention policy](account-erasure-retention-policy.md) alongside it.

## What has actually been checked

The authenticated staging Ops **Support > Account deletions** page was read
on 2 October Pacific / 3 October UTC. One historical closure showed **three
of three tracked tasks complete**. The page explicitly limited this to local
closure and tracked avatar/sign-in cleanup. No deletion or maintenance job
was run during this inspection. Its linked records before deletion, provider
responses, backup expiry and device cleanup were not independently checked.

This is UI/status evidence only. It is not the complete end-to-end packet.
Do not publish the account ID or a screenshot containing customer data in the
public issue.

## Ownership and evidence handling

Before a run, name a case operator, engineering reviewer, infrastructure
owner and privacy/legal reviewer in the restricted operations record. These
are roles to assign, not evidence that someone has accepted the work.

Use a case ID in public updates. Keep the case-to-account mapping, provider
references and unredacted evidence in approved access-controlled storage,
outside Git. Do not create a second permanent copy of the profile. Record
who can access the packet, its review/expiry date and the deletion authority.
Do not store passwords, session tokens, OTPs, raw message contents or database
connection strings in the packet.

## End-to-end staging packet

Each row needs PASS, FAIL, BLOCKED or NOT APPLICABLE, an evidence location,
UTC observation time and reviewer. A reason is required for NOT APPLICABLE.

1. **Scope and approval.** Identify the exact disposable staging account and
   approved actions. Confirm that the target is not a shared operator or a
   real rider. Record the deployed API/app revisions and environment. Obtain
   separate approval for any new email, SMS, payment or provider mutation.
2. **Before state.** Inventory applicable identity links, sessions/devices,
   avatar object, membership/reservations, outstanding OTP challenges, queued
   messages, payment evidence and holds. Record counts and restricted IDs,
   not sensitive payloads. An absent fixture is a coverage gap, not a pass.
3. **Closure.** Have the account owner complete the app's deletion confirmation.
   Record the response status, request ID and time without tokens or bodies.
   A `204` establishes only that local closure committed.
4. **Access revocation.** On approved test devices, check that an old session
   cannot read the profile or refresh. Check applicable queued deliveries and
   pre-deletion phone challenges are no longer usable. Do not use new sign-in
   as a proof of failure: it can create a different account after the old
   identity link is scrubbed. Do not accidentally recreate the test account.
5. **Local evidence.** Inspect Ops > Support > Account deletions and, if
   authorized, the read-only `app.account_erasure_status` view. Record the
   closure timestamp, revoked counts and done/cancelled/pending/unavailable
   task counts. Distinguish `tracked_complete`, `pending` and `retry_needed`.
6. **Bounded retries.** If work remains, an authorized operator may use the
   existing `erasures` maintenance job in the approved environment. This job
   can mutate shared retention work and contact R2/Apple; approval for a page
   inspection does not authorize running it. Record each start/outcome and
   counts, then inspect the case status again. Respect task availability and
   leases. A zero-work batch is not proof the case is complete, and a `200`
   is not proof every attempted task succeeded. Assign failed work an owner
   and next retry instead of running an unbounded loop.
7. **External checks.** Verify an applicable deleted avatar is unavailable
   without copying a signed URL into public evidence. Record Apple grant
   revocation only where a grant actually existed. Process the external
   provider register below separately.
8. **Retained records.** Confirm applicable financial/audit records remain
   restricted and pseudonymous, not publicly accessible or labelled anonymous.
   Preserve active holds. A record retained for a documented reason is an
   exception, not a silently successful deletion.
9. **Completion statement.** State separately: local closure, tracked cleanup,
   provider exceptions, backup exceptions and device evidence. Record owners
   and due dates for all unresolved items. Keep #284 open until acceptance is
   evidenced or explicit owned follow-ups are approved.

The current worker retries existing `erasure_tasks` and sweeps expired local
payloads/challenges. It does **not** replay account closure from a deletion
register into an older restored database.

## External-provider register

For every row collect: actual product/account and plan; data category and
minimal lookup identifier; applicable hold; configured retention evidence;
provider procedure/support response; requested action and approval; request
ID; response date; proven completion or exception; owner and next review.
Public product defaults do not prove this account's configuration.

| System                        | Required evidence before declaring this part complete                                                                                                                                                              |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Resend                        | Account-specific message/log retention and written handling for exceptional deletion requests. Local outbox scrubbing is not deletion of provider logs or a recipient's delivered email.                           |
| mNotify                       | Written message/delivery-log retention, deletion-request process and backup treatment. Record a support response; do not invent a per-message deletion endpoint.                                                   |
| Firebase                      | Inventory the products actually enabled and identifiers actually available. Separate installations/push from crash, performance and analytics data. Mark an unidentifiable installation as unresolved, not erased. |
| Grafana and hosting logs      | Confirm each configured logs/traces retention window, exported archives and available targeted-deletion procedure. Record whether the account can be linked without collecting new unnecessary identifiers.        |
| Paystack                      | Finance/privacy review of retained transaction, refund and dispute evidence; provider response for any requested non-required data deletion. Local closure is not provider transaction deletion.                   |
| R2 / Apple                    | Applicable durable task outcome and independent object/grant evidence. NOT APPLICABLE requires a recorded reason, not a zero-task assumption.                                                                      |
| Render and downloaded exports | Complete the inventory and isolated restore drill below. Do not infer expiry from the live row or current public pricing.                                                                                          |

No provider request was sent and no provider retention window was verified
as part of this documentation change. Production accounting periods and
customer-facing commitments still require the review named in the policy.

## Backup inventory

The infrastructure owner records the following separately for staging and
production. Use NOT PROVISIONED for an environment that does not exist.

- Exact database resource and workspace plan, with observation date.
- Recovery/PITR window actually available in the dashboard and its oldest
  recovery point. Record the provider's documented semantics, not just a
  guessed expiry date.
- Logical exports: creation time, provider expiry, download destinations,
  access owner and disposal/review date. Inventory developer laptops, CI
  artifacts and object storage rather than assuming there are no copies.
- Replicas and restore copies, including temporary validation databases.
- Protected location of deletion facts newer than the chosen restore point,
  integrity checks, coverage/watermark, access controls and expiry policy.
- Verified expiration evidence, provider exception, or an owner and deadline
  where evidence cannot yet be obtained.

These deployment-specific values are **not verified** by this runbook.

## Restore release gate

This is a required procedure to implement and rehearse, not an existing
automated recovery capability. Restoring or exporting personal data and
provisioning any paid resource require explicit approval.

1. **Isolate first.** Restore only into an approved non-serving environment.
   Prevent public/mobile/Ops access and disable outbound email, SMS, push,
   payment and provider-cleanup side effects. Do not attach normal workers or
   production credentials to the restored copy.
2. **Fence the source, then capture the final deletion set.** For the pilot,
   use an approved maintenance window that stops source writes across all API
   replicas, workers and operator paths. Drain in-flight transactions to a
   known commit/rollback outcome before establishing the final cutoff. Keep
   this fence in place through replay, verification and traffic cutover;
   isolating only the restored target is insufficient. A deletion arriving
   while fenced must not be acknowledged as completed on the old source.
   Record the fence acknowledgement, drained writers and final committed
   capture watermark. A wall-clock timestamp or a largest allocated sequence
   alone does not prove that all earlier transactions have committed.

   Obtain all closures newer than the restore point through that verified
   watermark from a separately protected source. The audit table inside the
   old snapshot cannot contain later deletions. An initial capture made while
   the source was live is only provisional: capture and replay its final delta
   after fencing. Reconcile provenance, contiguous coverage and the replayed
   watermark. If the source is unavailable, require independent evidence of
   every acknowledged closure and a fence preventing it from rejoining as a
   writer; otherwise stop. An incomplete register is not safe recovery.

   Online redirection is an alternative only after a reviewed coordinator can
   durably record every acknowledged deletion, replay through a cutover
   barrier and hand off to one authoritative writer without a gap. That
   mechanism does not currently exist here. Do not substitute a last-minute
   query followed by a traffic switch while the source can still accept writes.

3. **Apply schema and reviewed replay.** Use a purpose-built, reviewed recovery
   path that reapplies account closure by stable account ID, preserving the
   transaction's phone-lock ordering, session/device revocation, identity and
   message scrubbing, membership triggers and durable cleanup tasks. Do not
   set only `users.deleted_at`, copy audit rows as a substitute for cleanup,
   disable constraints, forge a rider token or call a nonexistent replay API.
   No such restore-specific replay tool was found in the current replacement
   backend. Until it exists and is tested, this step is BLOCKED.
4. **Prevent resurrection outside identity.** Reconcile restored OTPs,
   outboxes, pending jobs, provider-grant tasks, avatar references and holds
   before enabling workers. Reapply applicable post-snapshot restrictions and
   retention/redaction decisions; account deletion replay alone is not a
   complete recovery of all privacy decisions.
5. **Prove the result.** Use a fixture created before a snapshot and deleted
   after it. Restore the older snapshot, apply replay, then prove old sessions
   and challenges fail, profile/contact/avatar pointers are scrubbed, pending
   sends cannot execute and financial holds remain intact. Replay twice and
   simulate interruption; no account reopening, duplicate sends or duplicate
   financial effects are acceptable. Test closures whose user row does not
   exist in the snapshot, and record their disposition rather than creating it.
   Also start a deletion before the fence and attempt another after the
   provisional cutoff: the first must be drained and included if committed;
   the second must either be captured before the final barrier or refused
   without a success acknowledgement. Test a missing final delta, an in-flight
   transaction at cutoff and a stale source attempting to resume writes.
   Each unresolved case must block release.
6. **Sign off before release.** Engineering and the privacy/infrastructure
   owners reconcile the deletion register against restored state, record all
   exceptions and confirm that the replayed watermark equals the fenced
   source's final committed watermark with no outstanding capture/replay work.
   Keep the old source fenced while routing traffic and granting write
   authority to the restored target; only then re-enable approved workers.
   Verify stale clients cannot write to the old source. If the fence is lost
   or the source accepts another deletion, invalidate sign-off and repeat
   final capture/replay/verification before release. A rollback after target
   writes also requires reconciling those new deletions, not simply reopening
   the stale source. Until these checks pass, keep the restore isolated.
   Dispose of the approved test copy under its recorded lifecycle, with
   separate approval for irreversible deletion.

## Open engineering work, not completed controls

- Select and implement independent durable capture of deletion facts, with
  a source write fence, final committed watermark, verified final delta and
  a way to detect missing facts before release. No online cutover is implied.
- Implement a reviewed, idempotent restore-only replay path and recovery
  tests. The ordinary `DELETE /v1/me` endpoint requires the account's session;
  it is not an administrator bulk replay mechanism.
- Run the authorized isolated restore drill and record evidence.
- Verify actual backup/export windows and obtain provider responses.

Source checks: `account/service.ts` (`erase`, `retryErasures`), migrations
017/032/034, `runtime/maintenance.ts` and `runtime/job-outcome.ts`. The data
map remains the source for per-store tests and downstream erasure triggers.
