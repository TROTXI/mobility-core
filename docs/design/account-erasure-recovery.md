# Deletion recovery register and offline replay

The independent deletion register and replay tools prevent restored snapshots
from reopening deleted accounts. Configuration, rehearsal and release checks
belong to the [operations checklist](account-erasure-operations-checklist.md).
Code support does not certify provider retention or recovery readiness.

## Safety model

When activated, the API records an authenticated deletion **intent** in a
separate encrypted R2 register before committing local closure. It contains
stable account IDs and deletion-session audit IDs, not emails, phone numbers,
tokens, avatars or provider payloads. AES-256-GCM authenticates both contents
and the environment namespace. A dedicated encryption key is required.

A missing, corrupt, unavailable or conflicting journal write returns a safe
failure instead of acknowledging deletion. A write that reached R2 but whose
reply was lost can be retried without losing the intent. A later SQL rollback
does not revoke the durable intent: an isolated restore must still honour the
user's authorized deletion. The original API call may have failed; record this
distinction in the case evidence instead of claiming local closure completed.

R2 uses signed S3 requests and conditional PUT (`If-Match`, or `If-None-Match`
for first creation). This prevents two writers overwriting each other's
entries. See [Cloudflare's conditional-write support](https://developers.cloudflare.com/r2/api/s3/api/).
There is no unconditional overwrite, bucket creation, list or delete operation
in this adapter. The register is private and must not have a public/custom
domain or lifecycle rule that silently expires it.

The pilot register is one bounded encrypted object, capped at 10,000 account
entries and 2 MiB on the wire. Each deletion reads and conditionally rewrites
it. This trades throughput for a small, reviewable completeness boundary.
At capacity, new deletion capture fails closed; it never drops old entries.
Concurrent CAS conflicts are retryable failures, not automatic blind writes.
Shard/rotation design must be reviewed before this limit is reached. Do not
delete journal entries until all possible backups/exports and recovery duties
have been accounted for and the retention decision is approved.

## Authority and limits

Migration 039 adds an owner-managed control row. The narrow runtime role may
read it but cannot insert/update it. Interactive deletion takes a shared
transaction advisory lock before phone and user locks. The owner tool takes
the exclusive lock, drains those transactions and fences the remote register.
Afterward new deletion attempts fail, including after process restart.

**This is a deletion fence, not a universal application write freeze.** Stop
all API replicas, worker jobs and operator write paths in the approved
maintenance window before capture/cutover. The gate does not stop a database
owner, old binaries or unrelated running request handlers from writing.
Do not bypass this operational requirement by setting acknowledgement flags.

A restored database must have a different database name from the source and
contain the source control identity/namespace. A backup made before journal
activation is unsupported by this tool and must remain isolated for separate
review. Preparation persists the source writer identity and database name,
creates a new target identity and marks it isolated. Repeated preparation,
replay and promotion reject a target bound to an earlier writer generation;
ordinary backend startup refuses an isolated, ready, fenced or misbound
database. No normal application is started by the offline tool.

The tool reuses the account erasure transaction, including phone-lock order,
session revocation, identity/contact scrubbing, outbox cancellation, membership
triggers and durable avatar/Apple tasks. It neither sends acknowledgements nor
executes external cleanup during replay. Entries absent from the snapshot do
not create users. Already closed users are not closed twice. Interrupted replay
leaves the target isolated and can be rerun.

The target becomes ready only after every captured account present in the
restore is locally closed and the fenced journal has not changed. Promotion
rechecks the content hash and revision, transfers remote writer authority with
CAS, then opens the target's local gate. A lost reply between these steps can
complete only the same handover. The old source stays fenced. There is no
automatic unfence/rollback command. Provider tasks, financial reconciliation
and other post-snapshot privacy decisions still need the wider restore review.

An owner with the encryption key and bucket credentials can subvert this
register. This is not WORM storage or protection against a malicious operator.
Restrict credentials, audit operator access, and protect key recovery. A
deleted/missing initialized register cannot be silently re-created from an
older database. Missing independent evidence blocks recovery.

## Configuration and activation, subject to approval

Use a separate private bucket with bucket-scoped credentials. Confirm the
account's free-tier allowance and approve any cost before provisioning.
Never reuse the avatar bucket or expose these credentials to either app.

Required together for the API and owner tool:

- `ERASURE_JOURNAL_ACCOUNT_ID`
- `ERASURE_JOURNAL_ACCESS_KEY_ID`
- `ERASURE_JOURNAL_SECRET_ACCESS_KEY`
- `ERASURE_JOURNAL_BUCKET`
- `ERASURE_JOURNAL_NAMESPACE`: new UUID unique to this environment.
- `ERASURE_JOURNAL_KEY`: separate 32-byte hex/base64 encryption key, protected
  independently of the database backup and distinct from runtime crypto keys.

With all absent and no initialized database namespace, existing staging
behaviour remains unchanged. Partial configuration fails. Once initialized,
removing configuration does not disable the safeguard: startup/deletion fail.

For the owner CLI only:

- `ERASURE_RECOVERY_DATABASE_URL`: approved source or isolated target owner
  connection, never printed or passed on the command line.
- `ERASURE_RECOVERY_DEVICE_KEY`: the original resolved runtime device key as
  32-byte hex/base64, needed for the same encrypted cleanup task format. Obtain
  it from the approved secret-management environment, not chat or shell output.
- `ERASURE_RECOVERY_APPROVED=1`: explicit acknowledgement of the approved run.
- `ERASURE_RECOVERY_ISOLATED=1`: additionally required for target commands.

The CLI checks the actual connected database against the exact name argument
and verifies the caller owns the app schema. It does not install migrations,
restore backups, provision credentials or configure network isolation.

### First activation

1. Obtain approval and configure the separate storage/keys without publishing
   them. Migrate and refresh runtime grants using the normal reviewed deploy
   procedure. Confirm all binaries that will run include these safeguards.
2. Stop source write traffic and workers. Under the owner environment, run:

   ```sh
   node dist/erasure-recovery-cli.js initialize exact_source_database_name
   ```

   This backfills the live deletion audit and creates the encrypted register.
   Repeating against the same live authority is safe; a missing already
   initialized register or a different authority is refused. No recovery
   guarantee applies to closures already lost before this baseline.

3. Configure the API with the same namespace and journal key, check startup,
   and resume source traffic. Take a new approved recovery baseline after
   activation. Inventory any older backups as unsupported exceptions.
4. Run the authorized hosted R2 round-trip and isolated restore rehearsal
   before claiming this is an operational recovery control.

### Fenced recovery and cutover

Use the [restore release checklist](account-erasure-operations-checklist.md)
and name the approving operator/reviewer. First stop source writes and workers
and isolate the target. Keep that infrastructure fence through cutover.

```sh
# Against the source owner connection, after source write traffic is stopped:
node dist/erasure-recovery-cli.js fence exact_source_database_name

# Change the protected connection to the already isolated restored database:
node dist/erasure-recovery-cli.js prepare exact_restore_database_name
node dist/erasure-recovery-cli.js replay exact_restore_database_name

# Only after evidence review and cutover approval, with traffic still stopped:
node dist/erasure-recovery-cli.js promote exact_restore_database_name
```

The source fence reconciles live audit coverage against the external journal.
Any missing account blocks it. Do not invent a final cutoff from a wall-clock
time. Use the reported fenced revision and recorded replay result. If the
source database is lost, this implementation has no offline force-fence
command: retain the target in isolation and escalate for a reviewed recovery
procedure. Never initialize a replacement journal as a workaround.

Take a new recovery baseline after each successful writer handover. This tool
requires a snapshot carrying the current writer's control identity; a backup
from an earlier writer generation needs separate review and is not accepted
automatically, even if its namespace matches.

Keep the old source stopped after promotion. Route traffic only to the
approved target, run the remaining release checks, then enable approved
workers. A rollback requires replaying deletions accepted by the new writer;
it cannot simply reopen the old source. Running `erasures` later may contact
providers and needs the existing maintenance approval.

## Verification and evidence limits

- Unit tests cover journal authentication/namespace binding, CAS conflicts,
  conditional R2 headers, response limits and configuration completeness.
- Disposable Postgres tests cover write-ahead intent after lost acknowledgement,
  storage refusal, runtime permissions, a fence waiting for an in-flight
  deletion, repeated replay, an interrupted replay, missing snapshot accounts,
  stale watermark refusal and lost-response promotion recovery.
- The automated PostgreSQL restore test reproduces pre-deletion account/control rows in a separate
  disposable database. It is not a Render backup restore or a live R2 test.
- The separate 2026-10-03 hosted rehearsal used an actual Render PITR copy,
  a server-side PostgreSQL snapshot clone and a test R2 register. Its evidence
  does not certify live traffic cutover, provider cleanup or source-loss recovery.
- No migration changes a public API operation; no client regeneration is needed.

Still required under #284: complete backup/export inventory and retention
evidence, review hosted rehearsal scope and remaining cutover checks, obtain
provider responses and legal review, and record maintenance responsibility.
