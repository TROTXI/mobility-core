# ADR-0006 — MQTT (EMQX) + Go for the telemetry path

**Status:** accepted, implementation deferred post-MVP · **Date:** 2026-06-12

## Context

Vehicle GPS is high-frequency, small-payload, and must survive Accra's network
dead-zones. The delivery side fans positions out to many watching riders with
a <100 ms end-to-end target (ADR-0002).

## Decision

When pilot scale demands it: drivers publish over **MQTT** to **EMQX**; a **Go**
geo-processor consumes, snaps/filters, and writes to **Redis**; a Go WebSocket
gateway fans out to riders.

Technical grounds:

- **MQTT over HTTP for GPS**: 2-byte headers vs ~100s of bytes; QoS 1 gives
  store-and-forward through dead-zones — fixes data loss at the protocol level.
- **Go for the hot path**: goroutines make 10k concurrent socket connections
  cheap; predictable sub-ms processing without GC pauses that matter at this
  latency budget.
- **Raw WebSockets over Socket.io**: less framing overhead, no fallback
  machinery we don't need in 2026.

## Consequences

- Not built until the HTTP-polling fallback measurably hurts (pilot telemetry
  will tell us). The client contract is engine-agnostic from day one.
- EMQX runs in local docker-compose from the start so the path can be
  prototyped any time.
