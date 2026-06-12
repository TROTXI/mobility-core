# ADR-0001 — Record architecture decisions

**Status:** accepted · **Date:** 2026-06-12

## Context

Technical decisions made in meetings evaporate. New teammates re-litigate them;
old teammates forget the constraints that shaped them.

## Decision

We record significant architecture decisions as short, numbered, immutable
documents in `docs/adr/`. Format: Context → Decision → Consequences. A decision
is "significant" if reversing it later would cost more than a sprint.

Accepted ADRs are never edited — they are **superseded** by a new ADR that
links back.

## Consequences

- PRs that make architectural choices must include an ADR (enforced in review).
- The ADR log doubles as onboarding material: read them in order and you know
  why the system looks the way it does.
