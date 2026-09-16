# Stage 5 verification and Stage 6 staging cutover

Owner: Codex only. Starting integration commit: `67c8147` (merged #323).
This is an execution record and release checklist, **not a completed cutover**.
New frontend features excluded in `stage-4-completion.md` stay out of scope.

## Observed deployment, 2026-09-16

- Existing API: `trotxi-api-staging`, `srv-d8suhkn7f7vs73bigd40`, Frankfurt,
  Docker Free. Render reports legacy commit `1a46ad06c613479e883db191c410f2069fbe2579`.
- Existing database: `trotxi-db-staging`, `dpg-d8sugvv7f7vs73bifff0-a`,
  PostgreSQL 18, Basic-256mb, **1 GB storage**, 9.38% used at inspection.
- Paystack's existing staging key was inspected: **TEST**. No value is recorded
  here. The subsequent unpaid provider probe is recorded below separately.
- No replacement Render service exists in the observed workspace. The existing
  deployment workflow still runs the legacy installer. Do not point it at a
  replacement database or merge to `main` and assume this selects api-next.

The full 12,960,000-fix load gate must not run on the existing 1 GB volume.
Select/approve an isolated target and sufficient capacity first; compute and
storage are separate decisions. No upgrade, reset or new paid service has been
approved or performed by this rehearsal. Measure actual row/index/WAL usage
before selecting headroom; a smaller local test is not the full-size gate.
Godfred confirmed this is the team's disposable staging environment and that
production will use a larger database. Functional rehearsal does not require
a staging upgrade. Full-scale capacity evidence remains a pre-production gate,
not a completed check or a reason to allocate a larger staging plan now.

Rehearsal branch checks: **285 Postgres, 37 unit and 24 contract checks pass**,
none skipped; replacement typecheck and formatting pass. The first Docker build
timed out fetching the official Node image. A separate pull and full rebuild
subsequently succeeded. The local image (not deployed) is
`sha256:6e4509a9b8e93736ad5a628ad8818305060c6720857bdc81a79cb8148fe835ac`,
tagged `trotxi-replacement-rehearsal:stage5-working`. This is build evidence,
not a successful provider-configured server startup. A network-disabled,
read-only container ran the compiled installer inventory: all **21 migration
hashes match the reviewed source**, byte for byte.

## Real provider probe results, 2026-09-16

The user downloaded the Render environment export. It was moved to the agreed
temporary path and restricted to owner read/write (`0600`). Preflight confirmed
TEST Paystack credentials and the required R2 settings without database access.

- Paystack: **6/6 checks passed**. The real provider accepted initialization and
  returned an HTTPS checkout on `checkout.paystack.com`. Verify returned a TEST
  non-success for the unpaid reference `probe-121fbcbe1a14cd699eec53ad`.
  That unpaid TEST checkout remains at Paystack; no cash was taken. The other
  checks include the explicitly local signature/tamper/unsigned checks and
  must not be counted as observed automatic delivery.
- R2: **4/4 checks passed**. One random probe object was uploaded; its signed
  read returned the identical 71-byte image, the expired signature returned
  **403**, and the fresh signed read after deletion returned **404**. Only that
  probe object was deleted. This validates the real object-store adapter, not
  the account-erasure worker's end-to-end behavior.
- Neither probe connected to a database, changed Paystack settings or changed
  the deployed API. Credentials and signed URLs are not included in this record.

Automatic webhook delivery, hosted payment completion, reconciliation and
native app walkthrough remain separate pending gates. A provider initialization
success is not a paid or fulfilled purchase.

## Isolated local native rehearsal

`scripts/local-rehearsal.ts` accepts only a loopback PostgreSQL admin connection
to the `postgres` database and explicit `HARNESS_ALLOW_CREATE_DATABASES=1`.
It creates a uniquely named local database, installs the 21 reviewed migrations,
and grants a separate narrow runtime role. The downloaded staging database URL
is not used. Provider credentials are read as data from the private environment
export; TEST-only guards remain mandatory. Generated purpose keys, runtime
configuration and disposable driver credentials stay in owner-only temporary
files outside Git. Failed runs retain their explicitly named database for
diagnosis rather than automatically deleting possible provider evidence.

The successful run on 2026-09-16 started the real composition on loopback port
3002 with Google, TEST Paystack and R2 adapters. HTTP seed commands created a
test driver, vehicle, two-stop corridor, outbound/return patterns, schedules,
assigned trips and a fare. The bootstrap operator session was revoked after
seeding. Health, readiness, version and flags returned 200 over HTTP. This is
local source-runtime evidence, not a Render deployment or Docker startup gate.

Android driver and iOS commuter debug builds were installed with that local
base URL and a fresh session realm. Native sign-in is not yet marked passed.
On iOS 18.4 / Xcode 16.3 the Google authentication sheet failed at
`accounts.google.com` with NSURLErrorDomain -1005 and QUIC failures, while the
local API remained healthy. This resembles the
[Apple-confirmed simulator HTTP/3 defect](https://developer.apple.com/forums/thread/777999);
the cause is not proven until a different runtime succeeds. The user approved
installing an alternative runtime without erasing the existing simulator.
Apple's downloader refused 18.3 but installed **iOS 18.2 (22C150)**. A separate
`Trotxi Commuter Stable Test` iPhone 16 Pro simulator now runs the same installed
commuter binary and displays its sign-in screen. No OAuth settings or app code
were changed for this comparison. The user then completed Google sign-in;
a read-only check of the isolated database confirmed one Google commuter and
one active session. That establishes a successful native/provider/backend
exchange on 18.2, not exhaustive network stability or the rest of the walkthrough.

The subsequent Android commuter "No Connection" screen was on the old build
(installed September 13), not the rebuilt driver app. A credential-free health
request from inside the emulator to `10.0.2.2:3002` returned 200. The commuter
rehearsal build adds a **debug-only** network security config permitting HTTP
only to `10.0.2.2`, `127.0.0.1` and `localhost`; other hosts retain HTTPS-only
policy and release manifests do not reference that debug resource.
The rebuilt Android commuter APK installed successfully without clearing app
data. The user reported it working, and a fresh UI inspection showed the
replacement sign-in screen rather than the old connection error. Android
Google sign-in subsequently succeeded: the user reported completion, the native
home and Wallet screens loaded, and the local database contained one Google
commuter with two active sessions (up from one after iOS). Wallet showed zero
rides/credit, no current coverage and no purchases, matching the fresh account.
Purchase setup opened successfully. Paid checkout, boarding and other post-login
journeys remain separate gates.

## Provider rehearsal: no database access

Export staging's environment privately from Render, never into Git or chat.
The launcher reads data with Node's dotenv parser; it does not execute the file.
It refuses symlinks, non-owner files and group/world-readable files. It passes
only the selected provider's settings to its child, never DATABASE_URL, JWT,
Render account keys or the rest of the parent's environment.

From `services/api-next`, with Node 24 and dependencies installed:

```sh
chmod 600 /private/tmp/trotxi-staging-rehearsal.env
node --import tsx scripts/provider-rehearsal.ts --env-file /private/tmp/trotxi-staging-rehearsal.env --check preflight
node --import tsx scripts/provider-rehearsal.ts --env-file /private/tmp/trotxi-staging-rehearsal.env --check paystack
node --import tsx scripts/provider-rehearsal.ts --env-file /private/tmp/trotxi-staging-rehearsal.env --check r2
```

`preflight` validates presence/mode, making no network request. `paystack` opens
one unpaid TEST checkout and verifies it. Its local HMAC self-check is **not**
automatic webhook evidence. `r2` creates one randomly named probe object, checks
signed reads/expiry, then deletes that object only. Failed cleanup is reported;
the script cannot claim a timed-out upload never reached the provider.

Staging runtime configuration defaults to
`REPLACEMENT_DEPLOYMENT_ENVIRONMENT=staging`. Live Paystack keys are refused even
with `REPLACEMENT_ALLOW_LIVE_PAYMENTS=yes`. `NODE_ENV=production` does not change
this. A future production deployment would require both an explicit production
environment and the separate live opt-in; it is not authorized here.

## Stage 5 evidence still required

| Gate                        | Required evidence                                                                                                                                              | Current status                                              |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| Exact deploy artifact       | Docker build, migration hashes, config preflight, narrow-role readiness                                                                                        | In progress                                                 |
| Android and iOS             | Both apps against assembled replacement: native sign-in, restored secure session, minimum-version refusal, boarding, driver-only GPS receipt and map rendering | Not run this rehearsal                                      |
| Paystack initialization     | Real TEST initialize/verify via replacement adapter                                                                                                            | Passed: unpaid TEST probe; local checks separately labelled |
| Automatic Paystack delivery | Hosted paid TEST checkout; reference-correlated provider-origin inbox receipt and exactly one fulfilment; no signed replay used as proof                       | Not run                                                     |
| Reconciliation              | Separate unresolved TEST purchase recovered through Verify; no fabricated success                                                                              | Not run                                                     |
| R2 and erasure              | Probe reads/expiry/delete, then account erasure worker removes that account's object with durable completion                                                   | R2 probe passed 4/4; erasure flow pending                   |
| Capacity                    | 12.96M fixes on approved intended tier; latency, drain rate, backlog recovery, locks, WAL/storage/vacuum                                                       | Pre-production gate; no staging upgrade requested           |
| Recovery                    | Rehearsal before external writes and a distinct after-external-writes scenario                                                                                 | Not run                                                     |

Keep raw provider payloads, tokens, signed object URLs and GPS out of committed
evidence. Record commit, image digest, migration hashes, test counts, sanitized
references and outcome summaries. A successful local regression suite is not a
substitute for any unrun gate above.

## Stage 6 order and stop conditions

1. Reconfirm no real riders, live payments or retained non-disposable data.
   If any exist, stop clean-replacement cutover and revise the approved plan.
2. Record exact source/target service and database IDs, backup/recovery status,
   target region/tier and costs. Obtain exact fixture-reset approval if any
   existing database is to be cleared. A paid database is not reset approval.
3. Install the reviewed migrations with the dedicated owner connection. Create
   and grant the narrow runtime role; never pass owner credentials to the API.
   Recheck checksums, privileges, supported PostGIS version and verified TLS.
4. Provision the maintenance principal and independently generated purpose keys;
   configure Google, private R2, maps and TEST Paystack. Confirm trusted proxy
   facts instead of guessing a hop count. Start replacement privately/isolated
   and finish Stage 5 before switching clients or changing the webhook target.
5. Replace the legacy migration/deploy selection explicitly and pin the tested
   commit/image. Stop legacy writers/maintenance before the coordinated switch.
   Release both migrated clients with the matching API base and a new session
   realm. Old installed clients are not assumed upgraded by a minimum gate.
6. Set the Paystack **TEST** webhook to the approved replacement endpoint; record
   the prior TEST setting for abort. Observe automatic delivery, quarantine late
   unmatched old test references, reconcile, and verify no double fulfilment.
7. Enable required maintenance only after the on-demand jobs pass, then observe
   scheduled execution and failure reporting. Verify health/readiness/version,
   sign-in, purchase, reservations, boarding, live position, expiry and erasure.

Before new external writes, abort may stop the isolated candidate and restore
the recorded old service/webhook/client configuration. Preserve the candidate
for diagnosis rather than deleting it opportunistically.

After external writes, **do not restore old binaries against new records or
rewrite ledgers**. Stop new admissions/writes as needed, retain the replacement
database and callback evidence, reconcile Paystack facts, and roll forward or
use a separately reviewed recovery plan. Database restoration cannot undo a
provider payment, refund or webhook history. No rollout is marked complete
until the corresponding observed evidence is recorded.
