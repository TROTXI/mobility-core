# Trotxi ops console

The dispatcher's web app (#170): assign buses and drivers to runs, watch the
ones in progress, settle the ones that finished. Replaces Swagger and curl for
daily operations.

**Design:** `docs/ops-console.md` in the private `TROTXI/strategy` repo —
stack, access model, screens, data flow, and what the API still owes this
console. Read it before scaffolding.

## What is already set up (the seam, #174)

- **Workspace entry** — `pnpm-workspace.yaml` lists `apps/ops`; `pnpm install`
  resolves `@trotxi/ops` from the repo root.
- **CI** — the workspace-wide gates (#172) run `typecheck`, `lint`,
  `test:coverage`, and `build` in every package that defines them. This package
  defines none yet, so CI skips it; the moment your scaffold adds those
  scripts, they become merge gates automatically. No workflow edit needed.
- **`theme.ts`** — the Fluent UI v9 `BrandVariants` ramp generated from the
  brand primary `#013215`, plus light and dark themes. Move it into your `src/`
  tree; regenerate rather than hand-tweak.
- **Deploy target** — a commented `runtime: static` block in `render.yaml`
  (same precedent as the production block). It gets uncommented when your
  first deployable build lands; `CORS_ORIGINS` on the API is set at the same
  time.

## What is deliberately yours

Everything else: Vite config, tsconfig, ESLint setup, routing, components,
`src/`. The design doc records the agreed stack (React + Vite + TypeScript,
Fluent UI v9, `openapi-typescript` + `openapi-fetch`, React Router, MapLibre +
PMTiles); the choices inside it are the build owner's.

Two repo conventions that apply here:

- Use the pinned pnpm via `corepack enable`, and install with
  `pnpm install --frozen-lockfile` unless you are deliberately adding a
  dependency — the lockfile guard in CI rejects lockfile churn that arrives
  without a manifest change.
- `pnpm run format:check` (Prettier, repo root) covers this directory already.
