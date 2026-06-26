# ADR-0007 — JWT access tokens & route authorization guard

**Status:** accepted · **Date:** 2026-06-24

## Context

The auth spine ([#16](https://github.com/TROTXI/mobility-core/issues/16)) needs a
way to (a) prove who is calling and (b) decide what they may do, on every
request. The design docs (`docs/security.md`) already chose **social-first
sign-in**, **JWT access tokens + rotated refresh tokens**, and **RBAC plus
per-route ownership checks** (no ReBAC/ABAC engine).

This ADR records the **implementation of the token + guard foundation only**
("slice 1"): the access-token contract and the route guard that the rest of the
team builds on. Sign-in (Google/Apple) and refresh tokens are a follow-up
("slice 2") and will get their own notes; they do not change what is decided
here.

Constraints that shaped this:

- **Stateless verification** — no database round-trip to authenticate a request.
- **Reusable, testable token logic** — slice 2 must verify Google/Apple ID
  tokens, so the token code should not be welded to the web framework.
- **Zero-infra locally** — the API and its tests must run with no secret set.
- **Secure by default in production** — a missing secret must fail loudly, not
  silently fall back to something insecure.

## Decision

**Access tokens are short-lived signed JWTs (HS256), verified statelessly.**

- **Claims:** `sub` = user id, `role` = the user's role, plus `iss` / `aud` /
  `iat` / `exp`. Default lifetime **15 minutes** (`JWT_ACCESS_TTL`).
- **Library: `jose`, not `@fastify/jwt`.** It is framework-agnostic (so the
  token service is a plain, unit-testable module) and ships JWKS verification,
  which slice 2 needs to validate Google/Apple ID tokens. See ADR-0003 for the
  Fastify/TypeScript baseline this sits on.
- **Token service** (`modules/auth/jwt.ts`): `createJwtService(config)` exposes
  `signAccessToken` / `verifyAccessToken`. Verification **validates the decoded
  payload with zod** — a structurally valid token carrying an unknown role or no
  subject is rejected, not trusted.
- **Guard** (`modules/auth/auth.plugin.ts`, registered via `fastify-plugin` so
  decorators live on the root instance):
  - `app.authenticate` — preHandler; **401** if the bearer token is missing,
    malformed, expired, or invalid. On success sets `request.user`.
  - `app.requireRole(...roles)` — preHandler factory for **RBAC**; **403** on a
    role mismatch. Composed _after_ `authenticate`.
  - `request.user` — the authenticated principal `{ id, role }`.
  - `app.jwt` — the token service, for the sign-in routes in slice 2.
- **RBAC via the role embedded in the token** (stateless). **Ownership /
  relationship checks stay per-route**, not in the guard (per `docs/security.md`
  — we deliberately do not run a ReBAC/ABAC engine).
- **Secret is environment-gated** (`config/env.ts`): `JWT_SECRET` is **required
  when `NODE_ENV=production`** (min 32 chars). Outside production a dev-only
  fallback is used and a startup warning is logged.

## How to use it

Protect a route (must be logged in):

```ts
app.get('/account', { preHandler: app.authenticate }, async (req) => {
  return getAccount(req.user!.id); // req.user is { id, role }
});
```

Require a role (RBAC) — note the order, `authenticate` first:

```ts
app.post('/admin/routes', { preHandler: [app.authenticate, app.requireRole('admin')] }, handler);
```

Per-route ownership check (the guard does **not** do this for you):

```ts
app.get('/trips/:id', { preHandler: app.authenticate }, async (req, reply) => {
  const trip = await trips.findById(req.params.id);
  if (trip?.driverId !== req.user!.id) return reply.code(403).send();
  return trip;
});
```

Issue a token (sign-in routes in slice 2, and tests):

```ts
const token = await app.jwt.signAccessToken({ userId, role });
// client then sends:  Authorization: Bearer <token>
```

`GET /me` is the worked example of all of the above in `modules/auth/auth.routes.ts`.

## Consequences

- **Deployed environments must set `JWT_SECRET`.** Staging and production run
  `NODE_ENV=production`, so the API **refuses to boot without it** — intentional
  fail-closed behaviour. It is declared `sync: false` in `render.yaml` and the
  value is set in the Render dashboard (never committed). Local/CI need nothing.
- **Access tokens cannot be revoked before they expire.** This is why the TTL is
  short. Real revocation (logout, "sign out everywhere", reuse detection) is a
  **refresh-token / `sessions`** concern handled in slice 2.
- **Role changes are eventually consistent** — a promotion/demotion takes effect
  on the next token refresh, not instantly. Long-lived or destructive actions
  must re-check authority server-side rather than trusting a possibly-stale role.
- **HS256 (shared secret) is correct while one service both signs and verifies.**
  If we ever split the issuer from verifiers, or expose verification to external
  parties, switch to an asymmetric algorithm (RS256/EdDSA) — that would
  **supersede** this ADR.
- Slices 2 (sign-in + refresh) and 3 (JWKS caching, refresh-reuse detection,
  auth rate limiting — [#23](https://github.com/TROTXI/mobility-core/issues/23))
  build directly on these decorators and the token service.
