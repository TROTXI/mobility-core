# ADR-0003 — TypeScript + Fastify for the transactional API

**Status:** accepted · **Date:** 2026-06-12

## Context

The transactional API is where product iteration happens: subscriptions,
tokens, payments, boarding rules. It needs end-to-end type safety, a fast
inner loop, and first-class validation — not raw compute (that lives in the
telemetry path, ADR-0002).

## Decision

Node.js 22 + TypeScript (strict) on Fastify 5, with zod for runtime validation
at the boundaries.

Technical grounds:

- **One type system across the wire**: shared request/response types between
  validation (zod infers TS types) and handlers eliminates a whole defect class.
- **Fastify over Express**: schema-first validation, measured ~2× throughput,
  structured logging (pino) built in, first-class plugin encapsulation.
- **I/O-bound fit**: the API orchestrates Postgres and payment providers; the
  event loop handles that shape well. CPU-heavy geo work is explicitly out of
  scope here.
- **Ecosystem**: mature SDKs for every integration we need (payment
  aggregators, SMS, push).

## Consequences

- Strict mode + ESLint are non-negotiable gates in CI.
- CPU-bound features do not get added to this service; they go to the Go side
  (ADR-0002) or a worker.
