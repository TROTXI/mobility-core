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
  set (uncomment the production block in `render.yaml` when going live).

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
   **Connections** → copy the **External** connection string, append
   `?sslmode=no-verify`, then:
   ```bash
   gh secret set STAGING_DATABASE_URL -R TROTXI/mobility-core \
     --body "postgres://USER:PASS@HOST.frankfurt-postgres.render.com/DB?sslmode=no-verify"
   ```
   (External + SSL because migrations run from CI, outside Render's network.
   `no-verify` keeps the connection encrypted without needing Render's CA cert.)
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
