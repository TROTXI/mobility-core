# Deployment

The repo ships a production `Dockerfile` (`services/api/Dockerfile`), a Render
blueprint (`render.yaml`), and a CD pipeline (`.github/workflows/deploy.yml`).

## How CD works

```
push / merge to main
  → CI: all checks must pass (branch protection)
  → Deploy workflow fires on CI success:
      staging  — runs DB migrations, then deploys via the Render API, waits
                 until live, smoke-tests /healthz + /readyz
      production — waits for a manual approval in GitHub (environment
                 "production"), then migrates + deploys + smoke-tests the same way
```

**Migrations run before the deploy** (expand/contract: our migrations are
additive, so the schema must lead the code). They run from CI against the DB's
**external** connection string; a migration failure aborts the deploy before any
new code ships.

- Deploys **queue in order** (no cancellation), so every green commit ships.
- The pipeline is **dormant** until the `DEPLOY_ENABLED` repo variable is
  `true` — flip it after the one-time setup below.
- The production stage is **skipped** until `RENDER_PRODUCTION_SERVICE_ID` is
  set. The production service is now declared in `render.yaml`; see
  "Going live" below for the order things must happen in.

## One-time setup (≈15 minutes)

1. [render.com](https://render.com) → **New** → **Blueprint** → connect
   **`TROTXI/mobility-core`** → **Apply**. Render creates the free Postgres
   (`trotxi-db-staging`) and the `trotxi-api-staging` web service (Frankfurt,
   closest region to Ghana) and runs the first build.
2. Render → **Account Settings → API Keys** → create a key, then:
   ```bash
   gh secret set RENDER_API_KEY -R TROTXI/mobility-core
   ```
3. Copy the staging service id (`srv-…`) and public URL, then:
   ```bash
   gh variable set RENDER_STAGING_SERVICE_ID -R TROTXI/mobility-core --body "srv-..."
   gh variable set STAGING_URL -R TROTXI/mobility-core --body "https://trotxi-api-staging.onrender.com"
   gh variable set DEPLOY_ENABLED -R TROTXI/mobility-core --body "true"
   ```
4. **`JWT_SECRET`** (required — the API refuses to boot in production without
   it). Render dashboard → `trotxi-api-staging` → **Environment** → add
   `JWT_SECRET` = `openssl rand -base64 48`. (Declared `sync: false` in
   `render.yaml`; the value is entered here, never committed.)
5. **`STAGING_DATABASE_URL`** (required for migrate-on-deploy). Render → DB →
   **Connections** → copy the **External Database URL** (hostname ends in
   `…frankfurt-postgres.render.com` — _not_ the Internal one, which only resolves
   inside Render). Paste it interactively so the shell doesn't mangle the
   password:
   ```bash
   gh secret set STAGING_DATABASE_URL -R TROTXI/mobility-core   # then paste at the prompt
   ```
   It must be the **External** URL because migrations run from CI, outside
   Render's network. TLS is handled by the workflow (`DATABASE_SSL=true`), so no
   `sslmode` suffix is needed.
6. Done — the next merge to main migrates + deploys staging automatically. The
   GitHub environments `staging` and `production` already exist; production
   requires approval before its job runs (and its own `PRODUCTION_DATABASE_URL`
   secret + `JWT_SECRET` on the prod service).

## Notes

- **Free tier cold start:** the free web service sleeps after ~15 min idle;
  first request takes ~50 s to wake. Fine for testing.
- **Free Postgres expires** ~30 days after creation — upgrade before relying
  on it.
- The same `Dockerfile` runs anywhere (Fly.io, Railway, ECS, Cloud Run):
  provide `DATABASE_URL` once a datastore lands; the container listens on
  `$PORT` (default 3000).

## Going live

The production service and its database are declared in `render.yaml`. Order
matters — the service cannot resolve `DATABASE_URL` before the database exists.

1. **Apply the blueprint.** Render creates `trotxi-db-production` and
   `trotxi-api`. The service will not be reachable by CI yet.

2. **Set every `sync: false` value** in the Render dashboard:

   | Variable                                                                 | Notes                                                                                                                                             |
   | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
   | `JWT_SECRET`                                                             | **Generate a fresh one** (`openssl rand -base64 48`). Never reuse staging's — a leaked staging secret must not be able to mint production tokens. |
   | `PAYSTACK_SECRET_KEY`                                                    | The **live** key (`sk_live_…`). Staging's test key would accept payments that go nowhere and look like they worked.                               |
   | `FIREBASE_SERVICE_ACCOUNT`                                               | The whole service-account JSON. Unset -> no push, so the daily ask never reaches anyone.                                                          |
   | `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET` | Unset -> avatars are held in memory and lost on restart.                                                                                          |
   | `METRICS_TOKEN`                                                          | Unset in production -> `/metrics` is disabled (404) rather than left open.                                                                        |
   | `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_EXPORTER_OTLP_HEADERS`              | Grafana Cloud. Unset -> no tracing.                                                                                                               |
   | `CORS_ORIGINS`                                                           | Set once the ops console has a production origin.                                                                                                 |

   Everything else (`NODE_ENV`, `GOOGLE_CLIENT_ID`, `OTEL_SERVICE_NAME`,
   `MAP_TILES_URL`) comes from the blueprint and needs no dashboard entry.

3. **Migrate the production database once**, before any traffic:

   ```bash
   DATABASE_URL=<production-connection-string> pnpm --filter @trotxi/api run migrate
   ```

4. **Seed the corridors and set their fares.** Since #103 a route with no fare
   in force cannot be subscribed to — `/payments/subscribe` returns
   `409 not_priced`.

   ```bash
   JWT_SECRET=<production-secret> API_BASE_URL=https://<production-url> \
     pnpm --filter @trotxi/api seed:staging
   ```

   The seed's fare is a **placeholder**. Replace it with the corridor's real
   rate via `PUT /admin/routes/:id/fare`.

5. **Set the GitHub repository variables** `RENDER_PRODUCTION_SERVICE_ID` and
   `PRODUCTION_URL`. Until both exist the production stage is skipped; once
   they do, it still waits for a manual approval in the `production`
   environment.

### Cron jobs are commented out

Render has **no free tier for cron jobs** — they bill per minute with a ~$1/month
minimum each, on `starter` as the smallest instance. Declared at `plan: free`,
an apply fails on all seven and takes the rest of the blueprint with it.

They stay commented until that cost is approved. The daily loop can be driven by
hand in the meantime:

```
POST /admin/ask-dispatch       { travelDate, direction }
POST /admin/resolve-defaults   { travelDate, direction }
POST /admin/resolve-no-shows   { travelDate, direction }
```

To enable: uncomment, change every `plan: free` to `plan: starter`, apply.

### Blueprint changes need an apply

Render syncs blueprint-declared values (those with `value:` rather than
`sync: false`) **only when the blueprint is applied**. Merging a change to
`render.yaml` does not push it to a running service.

This has already bitten once: `MAP_TILES_URL` shipped in #186 and staging
served `mapTiles.url: null` for days, because the blueprint was never
re-applied. If a config change does not appear, apply the blueprint before
looking for a bug.
