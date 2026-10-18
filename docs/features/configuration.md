# Bootstrap and supported builds

Source audit: 2026-10-17.

Public `GET /bootstrap` provides the configuration clients need before sign-in:

- minimum supported builds for each app and platform;
- operations support availability and contact details;
- map tile and style configuration;
- the API server time.

Unset contact or map values remain absent or null. Clients must not invent a
support number or treat a missing basemap as unavailable boarding.

Ops Platform manages minimum versions through `GET /v1/ops/min-versions` and
`PUT /v1/ops/min-versions/{app}/{platform}`. There are no runtime feature flags
or rollout controls.

Mobile product requests carry client, build and platform metadata. Missing or
unsupported metadata is rejected by the API; unsupported builds receive 426.
The floor cache lasts 30 seconds per process and invalidates locally after an
Ops update. Other replicas can observe the update after that bounded delay.

## Developer contract

Bootstrap is reachable before sign-in and before a forced upgrade. Read its
configured values instead of hardcoding provider URLs, support numbers or
minimum builds into a screen. On failure, use the client's scoped recovery
behavior and expose unavailable state; do not fabricate configuration.

Ops updates the floor for one app and platform. It is not a logout or permission
change. Test both local invalidation and the bounded delay on another API
instance.

Code: [configuration](../../services/api-next/src/config/service.ts),
[composition](../../services/api-next/src/runtime/compose.ts).
Tests: [configuration](../../services/api-next/tests/config.test.ts),
[Postgres configuration](../../services/api-next/tests/config.pg.test.ts).
See [API integration](../api/README.md) and
[performance](../operations/request-performance.md).
