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
  `make check` (typecheck + lint + unit tests) must pass locally before pushing.
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

## Local setup

```bash
nvm use            # Node 22 (.nvmrc)
make up            # local infra (Docker)
make install       # API deps
make dev           # API on :3000
make install-e2e   # once, then: make e2e
```
