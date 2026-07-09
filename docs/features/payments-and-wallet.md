# Payments (the money system)

**Owner:** Godfred Awuku · **Last updated:** 2026-07-05

**Status:** 🔄 **MODEL PIVOTED** (2026-07-04). Product adopted the **Hybrid
Subscription Model** ([ADR-0014](../adr/0014-hybrid-subscription-model.md);
engineering plan in `strategy/docs/hybrid-subscription-model.md`): a subscription
buys a **ride entitlement**, unused rides become **Ride Credits** against the
next renewal, and there is **no prepaid wallet**.

The old wallet/top-up flow has been **removed from the code** (clean-slate
sweep): `POST /payments/topup`, `GET /me/balance`, and the entire ledger module
are deleted. What remains — and what epic **E1** builds on — is
`POST /payments/subscribe` + the Paystack webhook that activates a membership.
The `token_ledger` table stays in migration history and is **dropped by
migration `021`** (E7, #106); the **append-only-ledger pattern** it established
returns in E1 as the entitlement and credit ledgers.

---

## What exists today

`POST /payments/subscribe` starts a Paystack checkout for the platform
membership fee; the signature-verified webhook activates the subscription on
`charge.success`. Amounts are stored and transported in **pesewas** (1 GHS = 100
pesewas), matching Paystack. Deep design: `strategy/system-design.md §4` +
`security.md §7`.

**Deferred (with the money epics, not before):** nightly Paystack
reconciliation, circuit-breaker around the aggregator, refunds. **Production
posture:** without `PAYSTACK_SECRET_KEY`, payment routes return **503** and
staging stays up; go-live steps wait for E1.

---

## Concepts

- **Payment = state machine** `pending → paid|failed`, **never mutated once
  `paid`**. `reference` is unique (ours and Paystack's) and dedupes webhooks.
- **Server-authoritative amounts** — the membership fee comes from the server,
  never from the client.
- **Money unit: pesewas (minor units).** Every amount is an integer in pesewas —
  `1 GHS = 100 pesewas`. Never floats. The app converts to/from GHS at the
  display edge.

---

## Payments (Paystack)

`payments(id, user_id, reference unique, purpose, plan, amount, currency, status,
created_at, updated_at)`. `purpose` is `subscription` (the `topup` value remains
in the DB CHECK for legacy staging rows, which the webhook ignores); `plan`
(`monthly` | `annual`) is set for subscriptions.

### Flow

```
client (app)                          API                         Paystack
  ├─POST /payments/subscribe──────────▶│ create pending payment
  │                                     ├──initialize transaction──▶│
  │◀──{ authorizationUrl, reference }───┤◀──authorization_url────────┤
  │                                     │
  │  (user pays in Paystack checkout)   │                            │
  │                                     │◀───POST /webhooks/paystack─┤ charge.success
  │                                     │  verify HMAC-SHA512 sig
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

#### `POST /webhooks/paystack`

Paystack's payment confirmation. **Public**, but signature-verified.

- **Header:** `x-paystack-signature` — HMAC-SHA512 of the **raw** body, keyed by
  the secret key. **Mandatory**.
- **200:** `{ "received": true }` (also for ignored/duplicate events — idempotent)
- **401** bad/missing signature · **503** not configured
- On `charge.success` for a subscription payment: activates the subscription.

### Idempotency & fail-safe

Per `system-design §4.2` ("idempotent webhooks"), the webhook is **not** one big
transaction — each step is independently idempotent, so a retried/partial webhook
converges: subscription activation is guarded by the one-active-per-user index
(no double activate), and `markPaid` only does `pending → paid`. Paystack retries
delivery; a **nightly reconciliation** (future) backstops the rest. We never
mutate a `paid` payment.

### Configuration

| Env var               | Default | Notes                                                                                                                                                                                            |
| --------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `PAYSTACK_SECRET_KEY` | unset   | the `sk_...` **secret** key — for API calls **and** webhook signature verification. A real secret → Render dashboard only, never committed. Unset → dev fake client (non-prod) / **503** (prod). |

Server-side, `SUBSCRIPTION_FEES_PESEWAS` (in `payments.service.ts`) holds the
membership fee per plan in pesewas — **placeholders**, replaced by the `plans`
table in epic E1.

> The `sk_...` secret key is the **backend's**. The mobile app uses the
> **`pk_...` public** key in the Paystack SDK.

---

## Security notes

- **Verify the webhook signature** — non-negotiable. We compute HMAC-SHA512 over
  the **raw** request bytes (via `fastify-raw-body`); a re-serialized JSON would
  not match. Without it, anyone could POST a fake "payment succeeded".
- **No lost payment** — state machine + idempotent webhook + (future)
  reconciliation; a `paid` row is immutable.
- **Server-authoritative amounts** — never trust a client-reported price.
- **Degrade safe** — if Paystack is down, only new subscriptions block.

## Local development & testing

No keys needed — a **fake Paystack client** is wired when `PAYSTACK_SECRET_KEY`
is unset (non-production). It returns a stub checkout URL and signs/verifies
webhooks with a known dev secret (`fake-paystack-secret`):

```bash
B=http://localhost:3000
AT=...   # an access token (see authentication.md)

# start a subscription checkout
REF=$(curl -s $B/payments/subscribe -H "authorization: Bearer $AT" \
  -H 'content-type: application/json' -d '{"plan":"monthly"}' | jq -r .reference)

# simulate the webhook (sign the exact body with the dev secret)
BODY="{\"event\":\"charge.success\",\"data\":{\"reference\":\"$REF\"}}"
SIG=$(node -e "const c=require('crypto');process.stdout.write(c.createHmac('sha512','fake-paystack-secret').update(process.argv[1]).digest('hex'))" "$BODY")
curl -s $B/webhooks/paystack -H 'content-type: application/json' \
  -H "x-paystack-signature: $SIG" -d "$BODY"   # → { "received": true }, subscription now active
```

## Going live (production)

1. Set `PAYSTACK_SECRET_KEY` (the `sk_live_...`) in the Render dashboard.
2. Register the webhook URL in the Paystack dashboard → `https://…/webhooks/paystack`.
3. Set the real membership fees (superseded by the `plans` table in E1).

## Where the code lives

```
services/api/src/modules/payments/
  payment.repository.ts(.pg)    # payment state machine (purpose, pending→paid)
  paystack.client.ts           # PaystackClient interface + signature helper + Fake
  paystack.client.live.ts      # real HTTP client (excluded from unit coverage)
  payments.service.ts          # initializeSubscription / handleWebhook
  payments.routes.ts           # /payments/subscribe, /webhooks/paystack
  payments.schema.ts
services/api/src/db/migrations/
  007_payments.sql · 008_payment_purpose.sql
  # 006_token_ledger.sql retained (history); table dropped by 021_drop_token_ledger.sql (E7)
```

## Related

- [ADR-0014 — Hybrid Subscription Model](../adr/0014-hybrid-subscription-model.md) (supersedes the wallet model)
- [ADR-0011 — append-only token ledger](../adr/0011-token-ledger.md) (the pattern, reused in E1)
- [ADR-0009 — repository pattern](../adr/0009-repository-pattern.md)
- `strategy/docs/hybrid-subscription-model.md` (epics E1–E7) · `system-design.md §4` · `security.md §7`
