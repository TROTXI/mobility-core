# ADR-0005 — PostgreSQL + PostGIS as the system of record

**Status:** accepted · **Date:** 2026-06-12

## Context

Money is involved: subscriptions, token balances, payments, boardings. The
domain is also inherently geospatial (routes, stops, vehicle positions).

## Decision

PostgreSQL 16 with PostGIS as the single system of record for the
transactional path.

Technical grounds:

- **ACID where money lives** — token redemption and boarding are transactional;
  balance math must never be eventually consistent.
- **PostGIS** — routes, stops, and geo-queries (nearest stop, point-along-route)
  are first-class, no second datastore needed.
- **Boring on purpose** — backup/restore, migrations, hosting, and hiring are
  all solved problems.
- **Growth path without migration**: TimescaleDB (GPS time-series) is a
  Postgres extension; read replicas before sharding.

## Consequences

- Schema changes go through versioned, idempotent SQL migrations in the repo.
- Redis is a cache/bridge only — never a source of truth.
- Analytics workloads (ClickHouse) and event streaming (Kafka) are explicitly
  post-MVP; we do not build them speculatively.
