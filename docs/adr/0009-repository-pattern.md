# ADR-0009 — Repository pattern with environment-selected datastore

**Status:** accepted · **Date:** 2026-06-26

## Context

We want two things that usually conflict: **zero-infra local dev and tests** (no
database needed to run or unit-test the API) **and** real Postgres in CI and
production — without branching the domain logic on which one is active. This was
established in the database foundation (#15) and every domain module now copies
it (`users`, `subscriptions`).

## Decision

Each domain exposes a **repository interface** with two implementations:

- **InMemory** (`*.repository.ts`) — `Map`-backed, the reference implementation.
  Used by unit tests and zero-infra local dev.
- **Postgres** (`*.repository.pg.ts`) — the real adapter.

`server.ts` selects the implementation **at startup by `DATABASE_URL`** (set →
Postgres, unset → in-memory). Conventions:

- A `toX(row)` helper maps snake_case rows → camelCase domain objects.
- **Parameterized queries only** (`$1, $2`) — never string-concatenate values
  (the SQL-injection guard).
- `*.pg.ts` adapters are **excluded from unit coverage** (`vitest.config.ts`) —
  they run only against real infrastructure (CI migrations job / e2e).
- Routes and services depend on the **interface**, never on a concrete adapter.

## Consequences

- Domain/route logic is datastore-agnostic; tests run with no DB; CI/e2e exercise
  the Postgres path.
- **In-memory repos may not enforce every DB constraint** (e.g. partial unique
  indexes). The database is the source of truth; the in-memory adapter is a
  convenience for tests/dev, not a second enforcement point.
- As business rules grow, logic belongs in a **service layer above the
  repositories** (routes → services → repositories), not in the adapters.
- The KV/cache layer mirrors this same shape — see ADR-0010.
