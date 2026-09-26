# Trotxi Ops console

The desktop operations workspace for dispatch, support, payments and platform
control. It is a React + Vite static site and talks only to the reviewed `/v1`
contract generated into `src/generated/api.ts`.

## Access

An operator signs in with an approved Google account and then completes a
WebAuthn passkey check. Access tokens remain in memory; the rotating refresh
token is scoped to the browser tab. Every `/v1/ops/*` request is still
authorized by current database role and passkey elevation on the API.

The first administrator registers a passkey after their database role is
provisioned. A verified administrator may promote another rider account; that
new administrator must create their own passkey. Lost passkeys are reset only
by another verified administrator—there are no email codes or recovery codes.

## Local development

Use Node 24 and run from the repository root:

```sh
pnpm --filter @trotxi/ops dev
```

Optional public build values:

```text
VITE_API_BASE_URL=https://trotxi-api-staging.onrender.com
VITE_GOOGLE_CLIENT_ID=<Google Web client ID>
VITE_OPS_BUILD=1
```

No secret belongs in a `VITE_*` variable; Vite embeds them into the browser
bundle. Map styles and PMTiles locations come from the API's public `/flags`
bootstrap response.

The local Vite preview is useful for layout and component development, but it
cannot complete the staging sign-in flow by merely using staging's Google client
ID. Google requires the browser's exact origin (scheme, host and port) on that
client's Authorized JavaScript origins list. The API also verifies WebAuthn
against its configured Ops origin and relying-party ID. For a full authenticated
walkthrough, deploy the Ops static site at its approved staging HTTPS origin,
authorize that exact origin in Google Cloud, and configure the API's existing
Ops/CORS origin setting to the same site. Do not bypass the passkey gate or add
arbitrary local preview ports to the staging OAuth client just for visual QA.

## Verification

```sh
pnpm --filter @trotxi/ops typecheck
pnpm --filter @trotxi/ops test:coverage
pnpm --filter @trotxi/ops build
```

The main shell and screens are route-split. MapLibre/PMTiles is isolated in its
own browser chunk and positions refresh from the single Ops overview snapshot
every ten seconds.

## Deployment

`render.yaml` defines `trotxi-ops-staging` as a static site with an SPA rewrite.
The Blueprint sets the API's `OPS_ORIGIN` to this site's exact HTTPS origin;
the backend uses that value for both browser CORS and the passkey RP/origin.
No extra WebAuthn secret is needed.

After CI passes on `main`, `.github/workflows/deploy.yml` deploys the API and
then this static site from the same commit. Render's own auto-deploy stays off
so an unreviewed push cannot bypass the CI gate.
