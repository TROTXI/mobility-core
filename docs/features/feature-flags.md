# Bootstrap, flags and supported builds

Source audit: 2026-10-03.

Public `GET /flags` supplies client bootstrap configuration: flags,
application/platform minimum builds, map URLs and operations contacts.
Unset contact/map values remain absent/null; clients must not invent a support
number or treat a missing basemap as unavailable boarding.

Ops Platform edits flags and minimum versions using:

- `GET /v1/ops/flags`, `PUT /v1/ops/flags/{key}`.
- `GET /v1/ops/min-versions`,
  `PUT /v1/ops/min-versions/{app}/{platform}`.

Mobile product requests carry client/build/platform metadata. Missing or
unsupported metadata is rejected by the API; unsupported builds receive 426.
The floor cache lasts 30 seconds per process and invalidates locally after
an Ops update. Other replicas can observe the update after that bounded delay.

Flag storage is not proof every feature has an enforced rollout switch, nor
a complete experimentation/cohort platform. Inspect a feature's consumers
before relying on a flag to disable it.

Sources: `services/api-next/src/config/service.ts`, `src/http/app.ts`,
`src/runtime/compose.ts`, `apps/ops/src/screens/Platform.tsx`.
See [performance](../operations/request-performance.md).

## Developer contract

Bootstrap is reachable before sign-in and before a forced upgrade. Read its
configured values instead of hardcoding provider URLs, support numbers or
minimum builds into a screen. On failure, use the client's scoped recovery
behavior and expose unavailable state; do not fabricate configuration.

Ops updates the floor for a specific app/platform. It is not a logout or
permission change. Test both the local invalidation and the bounded delay on
another API instance. If a flag is intended to stop a write, enforce it at
the appropriate server boundary as well as hiding a button.

Code: [configuration](../../services/api-next/src/config/service.ts),
[composition](../../services/api-next/src/runtime/compose.ts).
Tests: [flags](../../services/api-next/tests/flags.test.ts).
