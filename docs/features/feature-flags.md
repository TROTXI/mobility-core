# Feature flags & force-update (#27)

**Status:** ✅ live — home-grown for the pilot (PostHog later).

## Overview

The "deploy ≠ release" keystone. The apps fetch a single public endpoint,
`GET /flags`, on launch/session to:

- **gate features** behind flags (a kill-switch + a rollout percentage), and
- run their **force-update** check against the minimum supported app version.

Flags and minimum versions are stored in Postgres and flipped by operations
through the admin API — no code change or deploy required to turn a feature off
or force an update.

## Concepts / model

Two small config tables (migration `018_feature_flags.sql`):

- **`feature_flags`** — one row per flag: `key`, `enabled` (the kill-switch),
  `rollout_percentage` (0–100), an ops-only `description`, and `updated_at`.
  `rollout_percentage` is returned as-is; per-user bucketing / cohorts are a
  later concern (they land with PostHog). "Enabled + rollout" is the shape apps
  read today.
- **`app_min_versions`** — one row per platform (`ios` | `android`) holding the
  lowest app build the API still supports. The version string is opaque to the
  API; the app compares it against its own build.

## API

### `GET /flags` — public

No auth. Fetched by the apps on launch/session. Returns a **slim** shape (no ops
metadata) and never fails the launch: if the stores are unwired it returns an
empty payload.

```json
{
  "flags": [{ "key": "live_positions", "enabled": true, "rolloutPercentage": 50 }],
  "minSupportedVersion": { "ios": "1.2.0", "android": "1.1.0" }
}
```

A platform with no configured minimum is `null` (no force-update in effect yet).

### Admin (all `requireRole('admin')`; 401 → 403 → 503 when unwired)

| Method & path                       | Body                                             | Purpose                                         |
| ----------------------------------- | ------------------------------------------------ | ----------------------------------------------- |
| `GET /admin/flags`                  | —                                                | List every flag (full rows).                    |
| `PUT /admin/flags/:key`             | `{ enabled?, rolloutPercentage?, description? }` | Create or update a flag (upsert / kill-switch). |
| `GET /admin/min-versions`           | —                                                | List the min version per platform.              |
| `PUT /admin/min-versions/:platform` | `{ version }`                                    | Set the force-update floor (`ios`/`android`).   |

`PUT /admin/flags/:key` is a partial upsert: on create, omitted fields default
(`enabled=false`, `rolloutPercentage=100`, `description=null`); on update, the
patch merges over the existing row (omitted = unchanged, explicit `null` clears
`description`).

## How it works

1. Ops set a flag or bump a min version via `/admin/*`.
2. On the app's next launch/session it calls `GET /flags`.
3. The app hides/shows features per `enabled` (+ `rolloutPercentage` when it
   buckets locally) and force-updates itself if its build is below
   `minSupportedVersion` for its platform.

Repository pattern (ADR-0009): `InMemory*` repos for zero-infra dev/tests,
`Pg*` selected in `server.ts` when `DATABASE_URL` is set.

## Configuration

No env vars. Flags and minimum versions are **data**, managed at runtime via the
admin API (or seeded directly in SQL). Bootstrapping the first admin follows the
same path as the rest of `/admin/*` (see `admin.routes.ts`).

## Security

- `GET /flags` is intentionally public (like `GET /routes`) — it must answer
  before sign-in — and returns only `key`/`enabled`/`rolloutPercentage`; the
  ops-only `description` is never exposed.
- All writes are admin-role guarded, rate-limited before the role check (house
  convention), and 503 when the repositories are unwired.

## Local development & testing

Zero infra — the in-memory repositories back the endpoint by default:

```bash
pnpm api          # then: curl localhost:3000/flags
pnpm test         # flags.routes.test.ts, feature-flag.repository.test.ts, min-version.repository.test.ts
```

## Where the code lives

- `services/api/src/modules/flags/` — repositories (`feature-flag.*`,
  `min-version.*`), `flags.schema.ts`, public `flags.routes.ts`.
- Admin ops live in `services/api/src/modules/admin/` (schema + routes).
- `services/api/src/db/migrations/018_feature_flags.sql`.

## Related

- ADR-0008 (zod ↔ OpenAPI contract), ADR-0009 (repository pattern).
- Wave 2, issue #27 (depends on the data-layer foundation, PR #15).
