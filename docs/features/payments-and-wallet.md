# Wallet & Payments (the money system)

**Owner:** Godfred Awuku · **Last updated:** 2026-07-04

**Status:** 🔄 **MODEL PIVOTED** (2026-07-04). The hold is lifted — product
adopted the **Hybrid Subscription Model**
([ADR-0014](../adr/0014-hybrid-subscription-model.md); engineering plan in
`strategy/docs/hybrid-subscription-model.md`): subscriptions carry a **ride
entitlement**, unused rides become **Ride Credits** against the next renewal,
and there is **no prepaid wallet**. The wallet/top-up flows documented below are
**live on staging but LEGACY** — kept accurate for what's deployed, retired once
the entitlement flow lands (epic E7).

> 🔄 **Build to the new model, not this doc's wallet semantics.** Still valid
> and carried forward: the Paystack integration (checkout + signed webhook),
> pesewas storage, the append-only-ledger pattern, and all the idempotency/
> security controls below. Superseded: `POST /payments/topup` and the wallet
> meaning of `GET /me/balance`.

The money system has two **separate** flows — keep them straight:

|            | **Subscription**                                     | **Tokens (wallet)**                        |
| ---------- | ---------------------------------------------------- | ------------------------------------------ |
| What       | A recurring **membership fee** to be on the platform | A **prepaid GHS wallet** to pay ride fares |
| Funded by  | `POST /payments/subscribe`                           | `POST /payments/topup`                     |
| On payment | Activates the subscription — **grants no tokens**    | **Grants tokens** — no membership change   |
| Spent by   | (gates boarding)                                     | Boarding debits the fare (#20)             |

**Boarding requires _both_** — an active subscription **and** enough balance.
1 token = 1 GHS; amounts are stored and exposed in **pesewas** (1 GHS = 100
pesewas). Rationale: [ADR-0011](../adr/0011-token-ledger.md); deep design in
`strategy/system-design.md §4` + `security.md §7`.

---

## Status & roadmap (ON HOLD)

**Paused 2026-06-28**, pending the product team's commission-charging model.

### ✅ Built & working (rider-side)

- **Subscription** = platform membership fee → `POST /payments/subscribe`;
  Paystack `charge.success` activates the subscription (grants no tokens).
- **Token wallet** = prepaid balance → `POST /payments/topup` grants tokens;
  `GET /me/balance` returns it. Append-only `token_ledger`, balance = `SUM(delta)`.
- **Paystack integration** — checkout init + **signature-verified webhook**
  (HMAC-SHA512 over the raw body), branching on payment `purpose`.
- **Money safety** — exactly-once via `idempotency_key`, never mutate a `paid`
  payment, server-authoritative amounts, fail-safe (idempotent) webhook steps.
- **Pesewas units** end-to-end (minor units; #68).

### ⏸️ Blocked on the commission decision

The system today handles **rider-side money only**. It does **not** model the
platform's revenue or the driver's side — both depend on how commissions work:

- **Commissions** — how / where Trotxi takes its cut (undefined).
- **Driver payouts** — paying drivers their fares, net of commission (unmodeled).
- **Fare model & revenue split** — and whether the ledger needs driver
  sub-accounts / commission + payout entries.

**Open questions for product (to unblock):**

1. **Basis** — % of fare, flat per ride, a cut of top-ups, or subscription-only?
2. **Who bears it** — rider surcharge, driver deduction, or a split?
3. **Timing** — charged at boarding, at payout, or at top-up?
4. **Payouts** — how / when do drivers get paid, and how does commission net out?
5. **Model fit** — does commission ride on the existing wallet/ledger, or need a
   separate driver ledger + payout flow?

### ⏳ Deferred (later, not all commission-blocked)

- **Boarding debit** (#20) — spending tokens to board (QR/scan). Overlaps the
  commission decision, so it should wait for it.
- **Refunds** (`reason: refund` exists in the ledger; no flow yet).
- **Nightly reconciliation** against Paystack settlement.
- **SMS receipts** (mNotify; planning-phase, skipped).

### Production posture while paused

- Payments **fail safe**: with no `PAYSTACK_SECRET_KEY`, `/payments/*` return
  **503** and staging stays up. No real funds are processed.
- **Go-live is intentionally NOT done** — the live webhook URL and real
  `SUBSCRIPTION_FEES_PESEWAS` are unset. Resume at [Going live](#going-live-production)
  once the commission model lands.

---

## Concepts

- **Append-only ledger, not a balance column.** The wallet is `token_ledger` —
  every credit (+) and debit (−) is one immutable row. **Balance = `SUM(delta)`**
  (derived; cache later, but never the source of truth). A mutable balance column
  loses money under concurrency/crashes and has no audit trail.
- **Exactly-once writes** via a unique `idempotency_key` — a retried grant/debit
  is a no-op, never a double-write.
- **Payment = state machine** `pending → paid|failed`, **never mutated once
  `paid`**. `reference` is unique (ours and Paystack's) and dedupes webhooks.
- **Server-authoritative amounts** — the fare and the membership fee come from
  the server, never from the client.
- **Money unit: pesewas (minor units).** Every amount (`delta`, `amount`,
  balances, API fields) is an integer in pesewas — `1 GHS = 100 pesewas`, matching
  Paystack. Never floats. The app converts to/from GHS at the display edge.

---

## The wallet (token ledger)

`token_ledger(id, user_id, delta, reason, ref_type, ref_id, idempotency_key
unique, created_at)`.

- `delta` is in **pesewas** (`+5000` = GHS 50 top-up, `-300` = GHS 3 fare).
- `reason` ∈ `topup` | `boarding` | `refund`. `ref_type` ∈ `payment` | `boarding`.
- **Balance** = `SUM(delta)` for the user (0 when empty).

### `GET /me/balance`

The authenticated rider's wallet balance in pesewas (the home screen, app #35;
the app formats GHS).

- **Auth:** `Bearer`. **Rate limit:** per user.
- **200:** `{ "balancePesewas": 24000 }` (= GHS 240) · **401** no/invalid token.

---

## Payments (Paystack)

`payments(id, user_id, reference unique, purpose, plan, amount, currency, status,
created_at, updated_at)`. `purpose` ∈ `subscription` | `topup`; `plan`
(`monthly` | `annual`) is set **only** for subscriptions.

### Flow

```
client (app)                          API                         Paystack
  ├─POST /payments/{subscribe|topup}──▶│ create pending payment
  │                                     ├──initialize transaction──▶│
  │◀──{ authorizationUrl, reference }───┤◀──authorization_url────────┤
  │                                     │
  │  (user pays in Paystack checkout)   │                            │
  │                                     │◀───POST /webhooks/paystack─┤ charge.success
  │                                     │  verify HMAC-SHA512 sig
  │                                     │  purpose=topup → grant tokens
  │                                     │  purpose=subscription → activate
  │                                     │  mark payment paid
  │                                     ├──200 { received: true }────▶│
```

### API

#### `POST /payments/subscribe`

Start a checkout for the platform **membership fee**.

- **Auth:** `Bearer`. **Rate limit:** per user.
- **Body:** `{ "plan": "monthly" | "annual" }`
- **200:** `{ "authorizationUrl": "https://checkout.paystack.com/...", "reference": "trotxi_..." }`
- **401** · **429** · **503** payments not configured

#### `POST /payments/topup`

Start a checkout to **load ride tokens** (pesewas) into the wallet.

- **Auth:** `Bearer`. **Rate limit:** per user.
- **Body:** `{ "amountPesewas": 5000 }` (integer ≥ 100, i.e. GHS 1; = GHS 50 here)
- **200:** `{ "authorizationUrl": "...", "reference": "..." }` · **401** · **429** · **503**

#### `POST /webhooks/paystack`

Paystack's payment confirmation. **Public**, but signature-verified.

- **Header:** `x-paystack-signature` — HMAC-SHA512 of the **raw** body, keyed by
  the secret key. **Mandatory** — without it anyone could mint tokens.
- **200:** `{ "received": true }` (also for ignored/duplicate events — idempotent)
- **401** bad/missing signature · **503** not configured
- On `charge.success`: **top-up** → grants `amount` tokens (`reason: topup`);
  **subscription** → activates the subscription. Neither does the other.

### Idempotency & fail-safe

Per `system-design §4.2` ("idempotent webhooks"), the webhook is **not** one big
transaction — each step is independently idempotent, so a retried/partial webhook
converges:

- the ledger grant is keyed `topup:<reference>` → no double grant;
- subscription activation is guarded by the one-active-per-user index → no double
  activate;
- `markPaid` only does `pending → paid`.

Paystack retries delivery; a **nightly reconciliation** against Paystack's
settlement (future) backstops anything it gives up on. We never mutate a `paid`
payment.

### Configuration

| Env var               | Default | Notes                                                                                                                                                                                            |
| --------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `PAYSTACK_SECRET_KEY` | unset   | the `sk_...` **secret** key — for API calls **and** webhook signature verification. A real secret → Render dashboard only, never committed. Unset → dev fake client (non-prod) / **503** (prod). |

Other server-side config (in `payments.service.ts`):

- `SUBSCRIPTION_FEES_PESEWAS` — the membership fee per plan, in pesewas
  (**placeholders** — set real values).

> The `sk_...` secret key is the **backend's**. The mobile app uses the
> **`pk_...` public** key in the Paystack SDK.

---

## Security notes

- **Verify the webhook signature** — non-negotiable. We compute HMAC-SHA512 over
  the **raw** request bytes (via `fastify-raw-body`); a re-serialized JSON would
  not match.
- **No double-spend / double-grant** — the unique `idempotency_key` on every
  ledger write.
- **No lost payment** — state machine + idempotent webhooks + (future)
  reconciliation; a `paid` row is immutable.
- **Server-authoritative amounts** — never trust a client-reported fare/price/
  balance.
- **Degrade safe** — if Paystack is down, riding with _existing_ tokens still
  works; only new top-ups/subscriptions block.

## Local development & testing

No keys needed — a **fake Paystack client** is wired when `PAYSTACK_SECRET_KEY`
is unset (non-production). It returns a stub checkout URL and signs/verifies
webhooks with a known dev secret (`fake-paystack-secret`):

```bash
B=http://localhost:3000
AT=...   # an access token (see authentication.md)

# top up GHS 40 (4000 pesewas)
REF=$(curl -s $B/payments/topup -H "authorization: Bearer $AT" \
  -H 'content-type: application/json' -d '{"amountPesewas":4000}' | jq -r .reference)

# simulate the webhook (sign the exact body with the dev secret)
BODY="{\"event\":\"charge.success\",\"data\":{\"reference\":\"$REF\"}}"
SIG=$(node -e "const c=require('crypto');process.stdout.write(c.createHmac('sha512','fake-paystack-secret').update(process.argv[1]).digest('hex'))" "$BODY")
curl -s $B/webhooks/paystack -H 'content-type: application/json' \
  -H "x-paystack-signature: $SIG" -d "$BODY"

curl -s $B/me/balance -H "authorization: Bearer $AT"   # → { "balancePesewas": 4000 }
```

A `subscribe` payment, by contrast, leaves the balance unchanged and activates
the subscription.

## Going live (production)

1. Set `PAYSTACK_SECRET_KEY` (the `sk_live_...`) in the Render dashboard.
2. Register the webhook URL in the Paystack dashboard → `https://…/webhooks/paystack`.
3. Set the real `SUBSCRIPTION_FEES_PESEWAS`.

## Where the code lives

```
services/api/src/modules/ledger/
  ledger.repository.ts(.pg)     # append-only ledger: append (idempotent) + balanceOf
  ledger.routes.ts             # GET /me/balance
services/api/src/modules/payments/
  payment.repository.ts(.pg)    # payment state machine (purpose, pending→paid)
  paystack.client.ts           # PaystackClient interface + signature helper + Fake
  paystack.client.live.ts      # real HTTP client (excluded from unit coverage)
  payments.service.ts          # initializeSubscription / initializeTopup / handleWebhook
  payments.routes.ts           # /payments/subscribe, /payments/topup, /webhooks/paystack
  payments.schema.ts
services/api/src/db/migrations/
  006_token_ledger.sql · 007_payments.sql · 008_payment_purpose.sql
```

## Related

- [ADR-0011 — append-only token ledger](../adr/0011-token-ledger.md)
- [ADR-0009 — repository pattern](../adr/0009-repository-pattern.md)
- `strategy/system-design.md §4 (data model)` · `security.md §7 (money controls)`
