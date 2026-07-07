# Contributing

## Workflow

1. Pick a work item (GitHub issue). Discuss scope there before coding.
2. Branch from `main`: `feat/<short-name>`, `fix/<short-name>`, `docs/…`, `chore/…`.
3. Open a PR using the template. Keep PRs small — one work item, one PR.
4. All CI checks must pass and conversations must be resolved before merge.
   `main` is protected; there is no pushing around the pipeline.
5. Squash-merge with a conventional-commit title (see below).

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org):

```
feat(api): add subscription redemption endpoint
fix(commuter): refresh balance after boarding
docs(adr): record payment-provider decision
chore(ci): cache flutter dependencies
test(e2e): cover declined mobile-money charge
```

## Code expectations

- **TypeScript**: strict mode, no `any` without a comment explaining why.
  `pnpm check` (format + typecheck + lint + unit tests) must pass locally before pushing.
- **Package manager**: this is a **pnpm workspace** — `corepack enable` once,
  then `pnpm install` at the root installs every package. Don't use `npm`.
- **Pre-commit hook (Husky)**: activate it once with `pnpm install` at the repo
  root. On every commit it:
  1. installs workspace dependencies if they're missing or stale,
  2. auto-formats staged files with Prettier (lint-staged),
  3. lints + typechecks `services/api` _when API source is staged_.

  It's fast feedback, not the gate — bypass with `git commit --no-verify` if you
  must. **CI is the real enforcement**: it runs `format:check`, lint, typecheck,
  tests and build on a clean install, so nothing unformatted or broken can merge.
  `pnpm check` runs the same gates locally.

- **Tests are part of the feature**: services get unit tests (vitest); every
  user-visible flow gets an e2e journey (`e2e/tests/`). The unit-coverage gate
  applies to the logic layer.
- **Architecture pattern**: routes → services → repositories, with dependencies
  injected through `buildApp(deps)`. Repositories come in pairs (in-memory for
  tests/zero-infra dev, Postgres for real runs).
- **Flutter**: `flutter analyze` clean; widget tests for new screens.

## Decisions (ADRs)

Significant technical decisions are recorded in `docs/adr/` — short, numbered,
immutable once accepted (supersede instead of editing). If your PR makes or
changes an architectural decision, it includes an ADR. See
[docs/adr/0001-record-architecture-decisions.md](docs/adr/0001-record-architecture-decisions.md).

## Codespaces / dev container

A `.devcontainer/devcontainer.json` is provided for contributors who prefer
not to install Flutter locally, or who work in GitHub Codespaces.

The container is based on `ghcr.io/cirruslabs/flutter:stable` and runs
`flutter doctor` on creation. Workspace dependencies are **not** installed
automatically — follow the local setup steps below once the container is ready.

**To use it in Codespaces:**
Open the repo on GitHub → **Code → Codespaces → Create codespace on main**.
The container builds automatically on first open and on any change to
`.devcontainer/`.

## Types generation

API types for the Flutter apps are generated from the live OpenAPI contract
published by the staging API at `/docs/json`.

```bash
pnpm codegen    # generates Dart models + Dio client into apps/api_client
```

**To use it in VS Code locally:**
Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers),
then **Reopen in Container** from the command palette.

## Local setup

```bash
nvm use            # Node 22 (.nvmrc)
corepack enable    # activates pnpm at the pinned version
pnpm install       # all workspace deps (also activates the Husky hook)
pnpm infra:up      # local infra (Docker)
pnpm api           # API on :3000
pnpm test:e2e      # run the e2e suite
```
