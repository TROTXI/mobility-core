# Wallet & Payments (the money system)

**Status:** ✅ live. Reflects the model as of **#66** (subscription vs. top-up
separated). The token-debit-on-boarding side is [#20](https://github.com/TROTXI/mobility-core/issues/20)
(deferred).

The money system has two **separate** flows — keep them straight:

|            | **Subscription**                                     | **Tokens (wallet)**                        |
| ---------- | ---------------------------------------------------- | ------------------------------------------ |
| What       | A recurring **membership fee** to be on the platform | A **prepaid GHS wallet** to pay ride fares |
| Funded by  | `POST /payments/subscribe`                           | `POST /payments/topup`                     |
| On payment | Activates the subscription — **grants no tokens**    | **Grants tokens** — no membership change   |
| Spent by   | (gates boarding)                                     | Boarding debits the fare (#20)             |

**Boarding requires _both_** — an active subscription **and** enough balance.
1 token = 1 GHS. Rationale: [ADR-0011](../adr/0011-token-ledger.md); deep design
in `strategy/system-design.md §4` + `security.md §7`.

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

---

## The wallet (token ledger)

`token_ledger(id, user_id, delta, reason, ref_type, ref_id, idempotency_key
unique, created_at)`.

- `delta` is GHS-denominated (`+50` top-up, `-3` fare).
- `reason` ∈ `topup` | `boarding` | `refund`. `ref_type` ∈ `payment` | `boarding`.
- **Balance** = `SUM(delta)` for the user (0 when empty).

### `GET /me/balance`

The authenticated rider's GHS balance (the home screen, app #35).

- **Auth:** `Bearer`. **Rate limit:** per user.
- **200:** `{ "balanceGhs": 240 }` · **401** no/invalid token.

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

Start a checkout to **load ride tokens** (GHS) into the wallet.

- **Auth:** `Bearer`. **Rate limit:** per user.
- **Body:** `{ "amountGhs": 50 }` (integer ≥ 1)
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

- `SUBSCRIPTION_FEES_GHS` — the membership fee per plan (**placeholders** —
  set real values).

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

# top up 40 GHS
REF=$(curl -s $B/payments/topup -H "authorization: Bearer $AT" \
  -H 'content-type: application/json' -d '{"amountGhs":40}' | jq -r .reference)

# simulate the webhook (sign the exact body with the dev secret)
BODY="{\"event\":\"charge.success\",\"data\":{\"reference\":\"$REF\"}}"
SIG=$(node -e "const c=require('crypto');process.stdout.write(c.createHmac('sha512','fake-paystack-secret').update(process.argv[1]).digest('hex'))" "$BODY")
curl -s $B/webhooks/paystack -H 'content-type: application/json' \
  -H "x-paystack-signature: $SIG" -d "$BODY"

curl -s $B/me/balance -H "authorization: Bearer $AT"   # → { "balanceGhs": 40 }
```

A `subscribe` payment, by contrast, leaves the balance unchanged and activates
the subscription.

## Going live (production)

1. Set `PAYSTACK_SECRET_KEY` (the `sk_live_...`) in the Render dashboard.
2. Register the webhook URL in the Paystack dashboard → `https://…/webhooks/paystack`.
3. Set the real `SUBSCRIPTION_FEES_GHS`.

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
