# Authentication

**Status:** ✅ live (slices 1 + 2). Apple sign-in and OTP fallback are deferred.

How Trotxi proves _who_ is calling and decides _what_ they may do. It has two
layers:

1. **Access tokens + a route guard** — short-lived JWTs verified statelessly on
   every request (slice 1).
2. **Sign-in / refresh / logout** — social sign-in (Google) that issues those
   tokens, plus rotating refresh tokens for long-lived sessions (slice 2,
   orchestrated by `AuthService`).

Design rationale: [ADR-0007](../adr/0007-jwt-auth-guard.md); deep design in
`strategy/security.md §3–4`.

---

## Concepts

- **Access token** — a signed JWT the client sends on every request. Short-lived
  (15 min) and **stateless**: the server verifies the signature, no DB hit.
- **Refresh token** — a long-lived, opaque random token used only to get a new
  access token. Stored **hashed** in `sessions`, **rotated** on each use, and
  **revocable** (logout). The raw token is shown to the client exactly once.
- **Principal** — `request.user = { id, role }`, set by the guard after a valid
  access token.
- **RBAC** — authorization is by the `role` claim (`commuter` | `driver` |
  `admin`). Ownership/relationship checks (e.g. "is this _your_ trip?") are done
  **per-route**, not by the guard.
- **Provider identity** — a `(provider, providerId)` pair (`auth_identity`) links
  a Google account to one Trotxi user. A returning user maps to the same account.

---

## Part 1 — Access tokens & the route guard

### Token format

Signed JWT, **HS256**. Claims:

| Claim         | Meaning                                 |
| ------------- | --------------------------------------- |
| `sub`         | the user id                             |
| `role`        | `commuter` \| `driver` \| `admin`       |
| `iss` / `aud` | `trotxi` / `trotxi-api` (verified)      |
| `iat` / `exp` | issued-at / expiry (default **15 min**) |

The client sends it as `Authorization: Bearer <token>`. Verification also
**validates the decoded payload** (zod) — a structurally valid token with an
unknown role or missing subject is rejected.

### The guard (decorators on the Fastify instance)

| Decorator                   | Effect                                                                                                         |
| --------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `app.authenticate`          | preHandler — **401** if the bearer token is missing/malformed/expired/invalid; on success sets `request.user`. |
| `app.requireRole(...roles)` | preHandler factory — **403** if `request.user.role` isn't in `roles`. Compose **after** `authenticate`.        |
| `app.jwt`                   | the token service (`signAccessToken` / `verifyAccessToken`) — used by the sign-in routes.                      |

### Protecting a route

```ts
// must be logged in
app.get('/account', { preHandler: app.authenticate }, async (req) => getAccount(req.user!.id));

// must be an admin
app.post('/admin/routes', { preHandler: [app.authenticate, app.requireRole('admin')] }, handler);

// per-route ownership (the guard does NOT do this for you)
app.get('/trips/:id', { preHandler: app.authenticate }, async (req, reply) => {
  const trip = await trips.findById(req.params.id);
  if (trip?.driverId !== req.user!.id) return reply.code(403).send();
  return trip;
});
```

`GET /me` is the worked example in `auth.routes.ts`.

### Configuration (Part 1)

| Env var                       | Default                 | Notes                                                                                                     |
| ----------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------- |
| `JWT_SECRET`                  | dev-only fallback       | **Required in production** (min 32 chars); the API refuses to boot without it. `openssl rand -base64 48`. |
| `JWT_ACCESS_TTL`              | `15m`                   | access-token lifetime                                                                                     |
| `JWT_ISSUER` / `JWT_AUDIENCE` | `trotxi` / `trotxi-api` |                                                                                                           |

---

## Part 2 — Sign-in, refresh & logout (`AuthService`)

`AuthService` is the first service-layer service: routes are thin, it owns the
orchestration (verify → find-or-create user → session → tokens).

### Flow

```
client (app)                         API
  │  Google ID token                  │
  ├──POST /auth/google───────────────▶│ verify ID token (Google JWKS, aud)
  │                                    │ find-or-create user + auth_identity
  │                                    │ create session (refresh token, hashed)
  │                                    │ sign access token
  │◀──{ user, accessToken, refreshToken }
  │                                    │
  │  ...15 min later, access expires   │
  ├──POST /auth/refresh───────────────▶│ look up session by hash → rotate
  │◀──{ accessToken, refreshToken }    │   (old refresh token is now dead)
  │                                    │
  ├──POST /auth/logout────────────────▶│ revoke the session
  │◀──204                              │
```

### API

#### `POST /auth/google`

Sign in (or sign up on first use) with a Google ID token.

- **Auth:** none. **Rate limit:** 10/min per IP.
- **Body:** `{ "idToken": "<google ID token>" }`
- **200:** `{ "user": { id, displayName, phone, avatarUrl, role, createdAt }, "accessToken": "...", "refreshToken": "..." }`
- **401** invalid token · **429** rate-limited · **503** sign-in not configured

#### `POST /auth/refresh`

Exchange a refresh token for a new pair (**rotates** — the old refresh token is invalidated).

- **Auth:** none (the refresh token is the credential). **Rate limit:** 10/min per IP.
- **Body:** `{ "refreshToken": "..." }`
- **200:** `{ "accessToken": "...", "refreshToken": "..." }`
- **401** invalid/expired/revoked · **503** not configured

#### `POST /auth/logout`

Revoke a refresh token. Idempotent.

- **Body:** `{ "refreshToken": "..." }` → **204** (always, even for an unknown token).

#### `GET /me`

The authenticated user.

- **Auth:** `Bearer` access token. **Rate limit:** per user.
- **200:** the user · **401** no/invalid token · **404** user not found.

### Refresh tokens & sessions

- A refresh token is `randomBytes(32)`; only its **SHA-256 hash** is stored
  (`sessions.refresh_token_hash`) — a DB leak exposes no usable tokens.
- **Rotation:** `/auth/refresh` revokes the presented session and issues a new
  one (`rotated_from` links them). Reusing a rotated token → 401.
- **Revocation:** logout sets `revoked_at`. (Refresh-reuse _detection_ — revoking
  the whole family on replay — is slice-3 hardening, not yet implemented.)

### The verifier (how Google is wired)

`AuthService` depends on an `IdTokenVerifier` interface, selected at startup:

| Condition              | Verifier                                                                  | `/auth/google`                  |
| ---------------------- | ------------------------------------------------------------------------- | ------------------------------- |
| `GOOGLE_CLIENT_ID` set | **GoogleIdTokenVerifier** (jose JWKS; checks signature, issuer, audience) | real sign-in                    |
| unset, non-production  | **FakeIdTokenVerifier**                                                   | dev/test (see below)            |
| unset, production      | none                                                                      | **503** (keeps staging booting) |

### Configuration (Part 2)

| Env var                | Default | Notes                                                                                                                                         |
| ---------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `GOOGLE_CLIENT_ID`     | unset   | the Google **"Web"** OAuth client ID = the token audience. **Public, not a secret.** No client _secret_ needed (we only verify the ID token). |
| `JWT_REFRESH_TTL_DAYS` | `30`    | refresh-token lifetime                                                                                                                        |

> The mobile apps additionally need **Android + iOS** OAuth client IDs in the
> same Google project; the backend only needs the Web client ID.

---

## Rate limiting

`/auth/google` and `/auth/refresh` are capped at **10 requests/min per IP** (the
credential-endpoint brute-force guard). `/me` is limited per user. Over the
limit → **429** with a `Retry-After` header. Backed by the KV store (in-memory
in dev, Redis in prod); it **fails open** if the store is down.

## Security notes

- **Access tokens can't be revoked before they expire** — hence the short TTL.
  Real "sign out" is the refresh/session layer (logout).
- **Role changes are eventually consistent** — a promotion/demotion takes effect
  on the next refresh, not instantly. Destructive actions should re-check
  server-side.
- **HS256** (shared secret) is correct while one service both signs and verifies.
  Splitting issuer/verifier later → move to RS256/EdDSA (would supersede ADR-0007).
- **Client storage:** keep the refresh token in secure storage (Keychain /
  Keystore), not plain prefs.

## Local development & testing

No Google setup needed in dev — the **fake verifier** is wired when
`GOOGLE_CLIENT_ID` is unset (non-production). The `idToken` is just a JSON blob
of claims:

```bash
# sign in
curl -s localhost:3000/auth/google -H 'content-type: application/json' \
  -d '{ "idToken": "{\"sub\":\"g-1\",\"name\":\"Ama\"}" }'
# → { user, accessToken, refreshToken }

# call a protected route with the accessToken (NOT the idToken)
curl localhost:3000/me -H "authorization: Bearer <accessToken>"
```

In Swagger (`/docs`): call `POST /auth/google`, copy the `accessToken` from the
response, click **Authorize**, paste just that token.

## Where the code lives

```
services/api/src/modules/auth/
  jwt.ts                     # token sign/verify service (HS256)
  auth.plugin.ts             # app.authenticate / app.requireRole / request.user
  id-token-verifier.ts       # IdTokenVerifier interface + FakeIdTokenVerifier
  id-token-verifier.google.ts# GoogleIdTokenVerifier (JWKS; excluded from unit coverage)
  session.repository.ts(.pg) # refresh-token sessions (hashed, rotate, revoke)
  auth-identity.repository.*  # provider identity → user link
  auth.service.ts            # AuthService: signIn / refresh / logout
  auth.routes.ts             # /me, /auth/google, /auth/refresh, /auth/logout
  auth.schema.ts             # request/response zod schemas
  tokens.ts                  # refresh-token generation + hashing
```

## Related

- [ADR-0007 — JWT access tokens & guard](../adr/0007-jwt-auth-guard.md)
- [ADR-0008 — zod + OpenAPI contract](../adr/0008-zod-openapi-contract.md)
- [ADR-0009 — repository pattern](../adr/0009-repository-pattern.md)
- `strategy/security.md §3 (authentication), §4 (authorization)`
