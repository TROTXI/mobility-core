# Authentication and sessions

**Owner:** Godfred Awuku · **Last verified:** 2026-09-13

**Status:** Social auth, rotating sessions and driver credentials are live.
Google is configured on staging. Apple verification, code exchange and account
revocation are implemented; production use still needs the Apple Developer IDs
and signing key. SMS/OTP remains deferred.

## Model

- Access tokens are HS256 JWTs with `sub`, `role`, `iss`, `aud`, `iat` and
  `exp`; the default lifetime is 15 minutes.
- Refresh tokens are opaque random values. Only SHA-256 hashes are stored in
  `sessions`; every refresh rotates the token.
- Reusing a refresh token that was consumed by rotation revokes all sessions
  for the user. Reusing a token revoked by logout simply returns `401`.
- Roles are `commuter`, `driver` and `admin`. Role checks do not replace
  relationship checks such as “is this the assigned driver?”
- Social identities are `(provider, providerId)` links. Driver credentials are
  first-party credentials in their own table, not `auth_identity` rows.

## Social and session API

| Endpoint                  | Auth              | Current behaviour                                                                               |
| ------------------------- | ----------------- | ----------------------------------------------------------------------------------------------- |
| `POST /auth/google`       | public, 10/min/IP | Verify Google ID token; find or create the user; return user and token pair                     |
| `POST /auth/apple`        | public, 10/min/IP | Same flow for Apple; accepts first-use `fullName`, raw `nonce` and optional `authorizationCode` |
| `POST /auth/refresh`      | public, 10/min/IP | Rotate a valid refresh token and return a new pair                                              |
| `POST /auth/logout`       | public, 10/min/IP | Revoke the supplied refresh token; idempotent `204`                                             |
| `GET /me`                 | bearer            | Return the current user with a signed avatar URL                                                |
| `GET /me/sessions`        | bearer            | List active session IDs and timestamps, never token hashes                                      |
| `DELETE /me/sessions/:id` | bearer            | Revoke one session owned by the caller; idempotent `204`                                        |
| `POST /me/devices`        | bearer            | Register or transfer the caller's FCM device token                                              |

Apple-specific rules:

- Apple returns a person's name only on the first authorization. The client must
  send `fullName` then; it is ignored for an existing account.
- If the ID token contains a nonce claim, the request must provide the raw nonce
  that produced it.
- `authorizationCode` is exchanged best-effort for a provider refresh token so
  `DELETE /me` can revoke Apple access during account erasure.
- `APPLE_CLIENT_ID` accepts a comma-separated native bundle ID and Services ID.

## Driver credential API

Drivers do not self-register. Operations issues a readable driver code and a
six-digit PIN; only an HMAC-SHA256 value is stored.

| Endpoint                                        | Role              | Current behaviour                                       |
| ----------------------------------------------- | ----------------- | ------------------------------------------------------- |
| `POST /auth/driver`                             | public, 10/min/IP | Sign in with code/PIN; return driver and token pair     |
| `POST /auth/driver/pin`                         | driver            | Change PIN and revoke every other session               |
| `POST /admin/drivers/:id/credentials`           | admin             | Create/link driver user and return one-time credentials |
| `POST /admin/drivers/:id/credentials/reset-pin` | admin             | Return a new one-time PIN and revoke sessions           |
| `PATCH /admin/drivers/:id/credentials`          | admin             | Suspend, reinstate or unlock the credential             |

A wrong code and wrong PIN deliberately produce the same `401`. Five failed
attempts create a durable 15-minute lock (`423` with `Retry-After`). Suspension
returns `403` and revokes live sessions. `rememberDevice=false` uses the
shift-length refresh lifetime; `true` uses the normal refresh lifetime.

### Driver-app sign-in and recovery

The app follows sign-in → account confirmation → Today. It does not force a
self-service PIN change after sign-in. Recovery stays under **Can't sign in?**:
check the driver code, ask the operator for a replacement PIN, or contact
operations for a locked or incorrectly linked account. This is the product
decision confirmed on 2026-09-13 against the Authentication / Recovery design.

The API's `mustChangePin` response field and `POST /auth/driver/pin` remain for
compatibility, but the current app does not use the flag as an entry gate or
expose the self-service change screen. Operator-issued PINs remain usable until
reset; an operations reset still revokes sessions. PIN verification, lockout,
suspension and session protections are unchanged. The design's four-digit copy
is not the current API contract: existing driver PINs remain six digits.

## Configuration

| Variable                                             | Purpose                                         |
| ---------------------------------------------------- | ----------------------------------------------- |
| `JWT_SECRET`                                         | Required in production, minimum 32 characters   |
| `JWT_ACCESS_TTL`                                     | Access-token lifetime, default `15m`            |
| `JWT_REFRESH_TTL_DAYS`                               | Normal refresh lifetime, default 30 days        |
| `DRIVER_SHIFT_TTL_HOURS`                             | Non-remembered driver session, default 12 hours |
| `GOOGLE_CLIENT_ID`                                   | Google Web OAuth audience                       |
| `APPLE_CLIENT_ID`                                    | Accepted Apple audiences                        |
| `APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY` | Apple code exchange and revocation              |

When a social provider ID is absent in production its route returns `503`; in
development the corresponding fake verifier keeps the system zero-infrastructure.

## Security invariants

- Authentication fails closed in production when the signing secret is absent.
- Driver lockouts live in PostgreSQL, not the fail-open cache.
- Both mobile apps keep the access/refresh pair in Keychain/Keystore-backed
  secure storage; the access token remains short-lived.
- Destructive or trip-specific operations perform server-side relationship
  checks even after JWT role validation.

## Code

- `services/api/src/modules/auth/`
- `apps/trotxi_client/lib/trotxi_client.dart`
- migrations `022`, `026`, `034` and `035`
- [ADR-0007](../adr/0007-jwt-auth-guard.md)
