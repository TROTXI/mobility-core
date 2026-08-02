# Endpoint test console

A live, visual walkthrough of the whole API for team demos: **62 test cases in
9 suites**, each sending a real request to the real `buildApp` instance and
asserting the documented contract — platform probes, sign-in + RBAC, fleet
setup, payments + entitlement (signed/forged/replayed webhooks), the E3
confirmation loop, E4 boarding (QR, PIN, manifest, idempotent debits), no-show +
credit conversion, live positions + ETA, and guardrails (validation + the rate
limiter tripping at ~100 calls).

## Run it

```bash
pnpm --filter @trotxi/api demo:endpoints
# → console    http://localhost:4400
# → Swagger UI http://localhost:3001/docs   (same live in-memory state)
```

Press **Run all suites**. Suites are stateful and sequential (sign-in → fleet →
subscribe → reserve → board → settle); **Reset state** starts a fresh world.
Expand any row to see the exact request, the expected contract, and the actual
response. The **Tokens** panel exposes the dev-signed bearer tokens so anyone
can replay a call in Swagger or curl against `localhost:3001`.

Everything is in-memory and dev-signed (fake Paystack, dev JWT secret) — the
HTTP surface, validation, RBAC, and idempotency logic are the real production
code paths.
