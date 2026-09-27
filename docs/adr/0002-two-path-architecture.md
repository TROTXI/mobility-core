# ADR-0002 — Two decoupled paths: transactional vs telemetry

**Status:** accepted · **Date:** 2026-06-12

## Context

The platform has two workloads with opposite needs. Business logic (auth,
subscriptions, payments, boarding) changes weekly and needs strong consistency.
Live vehicle tracking is latency-critical (<100 ms target), high-frequency, and
tolerates eventual consistency.

## Decision

Separate them end to end. The transactional path (apps → Fastify API →
Postgres) and the telemetry path (GPS → MQTT/EMQX → Go processor → Redis →
WebSocket) share no services and meet only at Redis, where the API reads live
positions.

For the MVP/pilot, the telemetry path's _implementation_ is deferred: the API
serves positions over HTTP polling behind the same client-facing contract.

## Consequences

- Product iteration can never degrade live-map latency, and vice versa.
- Two runtimes to operate eventually (Node + Go) — accepted; deferral keeps
  pilot operations to one.
- The client contract for positions must be designed now so the engine swap is
  invisible later.

## Current implementation — 2026-09-12

The transactional side is a single Fastify modular monolith backed by
PostgreSQL/PostGIS. The pilot position contract is live over driver HTTP writes
and rider HTTP polling, with Redis/KV caching and durable GPS history. Completed
runs already feed batch geometry and segment-speed learning inside the API. The
dedicated EMQX/Go/WebSocket telemetry runtime remains deferred.
