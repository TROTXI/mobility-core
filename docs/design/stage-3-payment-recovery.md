# Stage 3: payment recovery — migration 012

Implementation branch: `codex/stage-3-payment-recovery`, based on integration
`8da4f53f1341fd5dddcbdf94a9268769c932be50` after #305. Target:
`codex/backend-replacement`, not main. Nothing in this slice deploys or schedules
anything. Applied migrations 001–011 remain byte-identical.

## Scope and ownership

Codex owns 012: provider evidence, recovery, refunds, disputes and ops review.
Claude can continue the remaining driver operations on the existing 010 tables.
013 remains Codex's commute/pause/reservation integration; 014 is reserved for
Claude's GPS/ETA slice; 015 is boarding/settlement. Do not reuse those numbers.
No changes to `transport_commands`' allowed operations or Claude's incident and
request contracts are required here.

| Source                    | Existing requirement served                                                                  |
| ------------------------- | -------------------------------------------------------------------------------------------- |
| `payment_events`          | Authenticated durable evidence; retry after a worker crash                                   |
| `payment_collections`     | Cash success is a fact even when a failed purchase must not be fulfilled                     |
| `payment_refunds`         | Stable provider refund identity, partial totals and monotonic progress                       |
| `payment_disputes`        | Independent disputes and final verdicts, not a single payment flag                           |
| `payment_access_blocks`   | Dispute blocks belong to the purchased period; releasing one source must not release another |
| `payment_reversals`       | Immutable calculation/source for compensating ledger entries                                 |
| `payment_reviews`         | Ops visibility of unresolved provider progress and consumed/unrecoverable value              |
| `payment_review_commands` | Attributable, replay-safe local review decisions                                             |

These eight sources extend the ten-table financial foundation. They are not
eight new payment products. Purchase fulfilment state, observed cash and access
restrictions intentionally have different owners.

## Processing and accounting rules

1. Verify the HMAC over the exact request bytes. Encrypt and commit the evidence
   before acknowledging the webhook. An unsupported, incomplete, foreign-mode or
   unknown-reference payload cannot be guessed into a purchase.
2. A worker locks one ready inbox row, then its rider, attempt/purchase and period.
   Financial changes and the processed acknowledgement share that transaction.
   A failed write leaves neither an acknowledgement nor partial value. Retry
   metadata is updated separately after rollback, conditionally on still being
   ready; it cannot overwrite another worker's committed result.
3. Work is bounded to 1–100 records. `SKIP LOCKED` excludes another worker's claim;
   backoff is bounded and ten failed attempts quarantine rather than spin.
   Quarantine is terminal for this worker. It needs an explicit operational
   investigation, not automatic reassignment of retired sandbox references.
4. Verify is an external read **outside** the database transaction. Only complete,
   exact-reference, same-environment facts are admitted. A timeout, 404, malformed
   response or unresolved status does **not** free held credit. Explicit verified
   failure can release a still-held amount. This conservative 404 policy is an
   intentional replacement behavior, not a claim of unchanged baseline behavior.
5. Late success after local failure records cash and creates a review. It does
   not allocate another period, overwrite a new pending purchase, or make the old
   failed purchase occupy the unique unresolved-purchase slot. A later refund
   of that collection is recorded without inventing rides or captured credit.
6. A full cash refund appends compensating entries. The original captured hold
   and purchase debit remain intact. Refund sources validate actual processed
   cash, the frozen purchase, the period's ride balance and its closure; matching
   effects and reversed period state are required at commit.
7. Consumption means boarding/no-show debits net of returned rides. Month-end
   conversion is not consumption. Converted credit is recovered only from
   available balance **before** restoring captured credit, excluding other holds.
   Any shortfall plus the exact rounded consumed-value estimate becomes the
   manual-review amount. No debt is automatically charged.
8. Partial refunds do not proportionally remove rides or restore captured credit.
   Accepted disputes remain blocked until processed refunds cover the aggregate
   accepted amount for that purchase. A declined verdict releases only its own
   block. Another pending dispute still blocks that period. A historical-period
   dispute does not suspend a later paid period or the rider's whole account.
9. Batch close isolates failure per period; checkout's own close still throws.
   The disputed-period close guard exists in both the service and the database.

Provider refunds use a stable `refund_reference`. Missing identity/required
facts are quarantined, not deduplicated by amount or event hash. Provider progress
uses shared rank definitions in SQL and TypeScript; contradictory final dispute
verdicts do not rewrite history.

## HTTP boundary implemented

Seven operations are added to the executable subset, taking it from 47 to 54:

- `POST /webhooks/paystack` — provider signature, exact raw-body parser scoped to
  this route, 1 MiB maximum; no rider token or app build metadata.
- `GET /v1/ops/payments/reviews` — current-session/current-admin authorization,
  signed actor-bound pagination, open items only.
- `POST /v1/ops/payments/reviews/{id}/decisions` — If-Match, idempotency and actor
  plus reason. This resolves/waives a **local ticket**; it cannot refund Paystack,
  clear a dispute, waive an externally enforced debt, or alter ledger history.
- `POST /v1/ops/maintenance/payment-inbox`
- `POST /v1/ops/maintenance/payment-reconciliation`
- `POST /v1/ops/maintenance/period-close`
- `POST /v1/ops/maintenance/payments` — inbox, reconciliation, then period close.

Versioned responses use the reviewed `{data}` / `{data,page}` envelopes. The one
contract addition is `PaymentReview.editToken`: a deferred detail endpoint cannot
supply the per-row If-Match needed to decide an item obtained from the list.
`Money.amountMinor` always means integer pesewas; manual reviews expose their
estimated amount at risk, not the original gross price.

Maintenance currently admits verified admins. The contract's alternative scoped
worker identity is **not implemented or claimed** by this slice; ordinary bearer
tokens or client headers cannot elevate to it. No cron has been enabled.

## Evidence and deliberate limits

`payment-recovery.pg.test.ts` runs against the real runtime login and contiguous
PostGIS migration chain. Required database configuration is enforced; these tests
never skip. `payment-provider.test.ts` tests protocol validation and arithmetic.
Both are in the financial CI gate; the PG file is also in `test:postgres`.

Named cases cover encrypted durable acknowledgement, two observed lock-wait
races, crash rollback/retry, missed-webhook verification, retained holds on
uncertain verification, late collections, full/partial refunds, closed-period
conversion, held-credit shortfall, independent disputes, cross-period isolation,
coordinator rollback, batch isolation, review authorization/replay, HTTP schemas
and direct-SQL reversal integrity. The 011 suite retains its 16 scenario assertions;
its fixture was extracted for reuse, not replaced with a new interpretation.
The 010→011 upgrade assertion still installs exactly 011 before applying later SQL.

This is **not the completed 16-scenario baseline/candidate comparison**. No baseline
negative control or checkpoint expectation was changed. Duplicate allocation is
still detected in the pinned baseline control and separately rejected structurally
by the replacement; these are different evidence claims.

013 must supply real pause/reservation/assignment callbacks and have membership
access evaluate **all** active period blocks. The callback tests here are explicitly
domain-isolated, not production reservation evidence. 015 must test consumed
boarding/no-show/return effects through real typed sources; 012 does not weaken
the existing ride-entry constraints to manufacture those fixtures. The arithmetic
is tested independently, while zero-consumption conversion/refund is real SQL.

Before deployment: compose the services with real cross-domain adapters, configure
independent evidence encryption and cursor keys, define evidence retention and key
rotation/re-encryption, add monitored worker scheduling/scoped worker auth, and run
Paystack TEST contract/delivery checks. None of the injected provider responses is
claimed as a live sandbox observation. No network request to Paystack, real charge,
staging mutation, or main deployment was made during these tests.

Protocol references: [Paystack webhooks](https://paystack.com/docs/payments/webhooks/),
[Verify](https://paystack.com/docs/payments/verify-payments/),
[refunds](https://paystack.com/docs/payments/refunds/), and
[disputes](https://paystack.com/docs/payments/manage-disputes/).

The zero-real-users/no-real-payments/no-retained-non-disposable-data tripwire remains
in force. This branch does not implement an automated onboarding block.
