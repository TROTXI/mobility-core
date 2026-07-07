# Trotxi — mobility-core

The platform monorepo for **Trotxi**, a subscription commuter-transport service
for Accra: riders pay a monthly subscription, receive ride tokens, and redeem
them for reliable daily commutes on managed trotro routes.

> Technology is not the product — **mobility is the product**.

## Architecture in five lines

Two decoupled paths (see [docs/architecture.md](docs/architecture.md) and the
[ADRs](docs/adr/)):

1. **Transactional path** — mobile apps → Node.js + TypeScript API (Fastify) →
   PostgreSQL + PostGIS. Auth, subscriptions, tokens, payments, boarding.
2. **Telemetry path** (post-MVP) — driver GPS → MQTT (EMQX) → Go geo-processor →
   Redis → WebSocket → rider's live map. The paths meet only at Redis.

## Quick start

Requires **Node 22** (see `.nvmrc`) and **pnpm** (the package manager — enable
it with `corepack enable`; the version is pinned in `package.json`).

```bash
corepack enable     # one-time: activates pnpm at the pinned version
pnpm install        # install all workspace deps
pnpm infra:up       # Postgres + Redis + EMQX via Docker
pnpm api            # API in watch mode → http://localhost:3000/healthz (docs at /docs)
pnpm check          # format + typecheck + lint + unit tests
pnpm test:e2e       # Playwright end-to-end suite (real HTTP)
```

This is a **pnpm workspace**: one lockfile (`pnpm-lock.yaml`) and one install
at the root cover every package (`services/api`, `e2e`, tooling). All tasks are
pnpm scripts — run `pnpm run` to list them, or target a package directly with
`pnpm --filter <name> <script>`. Common ones:

| Command                                                    | Does                                   |
| ---------------------------------------------------------- | -------------------------------------- |
| `pnpm infra:up` / `infra:down` / `infra:logs` / `infra:ps` | Local Docker infra                     |
| `pnpm api`                                                 | Run the API in watch mode              |
| `pnpm start`                                               | Run every service's dev server         |
| `pnpm check`                                               | format + typecheck + lint + unit tests |
| `pnpm test` / `pnpm test:e2e`                              | Unit tests / e2e suite                 |
| `pnpm format`                                              | Auto-format the repo (Prettier)        |
| `pnpm codegen`                                             | Generate static types for API Client   |

## Repo layout

```
mobility-core/
├── services/
│   └── api/          # Node.js + TypeScript (Fastify) — transactional API
├── apps/             # Flutter apps (commuter, driver) — see apps/README.md
├── e2e/              # Playwright black-box suite — real HTTP against the API
├── infra/docker/     # Local infra: Postgres+PostGIS, Redis, EMQX
├── docs/             # Architecture + ADRs (decision records)
└── .github/          # CI/CD workflows, PR template
```

## Pipeline

Every push and PR to `main` runs CI (API typecheck/lint/unit tests/build + e2e
journeys). `main` is protected: merging requires all checks green on an
up-to-date branch. Merges to `main` deploy to staging automatically and to
production after a manual approval (see [docs/DEPLOY.md](docs/DEPLOY.md)).

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) — branch naming, conventional commits,
review expectations, and how ADRs work.
