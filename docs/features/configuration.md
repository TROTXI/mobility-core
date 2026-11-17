# Bootstrap and supported builds

Source audit: 2026-10-17.

Public `GET /bootstrap` provides the configuration clients need before sign-in:

- minimum supported builds for each app and platform;
- optional rollout entries for features shipped in a reviewed mobile build;
- operations support availability and contact details;
- map tile and style configuration;
- the API server time.

Unset contact or map values remain absent or null. Clients must not invent a
support number or treat a missing basemap as unavailable boarding.

Ops Platform manages minimum versions through `GET /v1/ops/min-versions` and
`PUT /v1/ops/min-versions/{app}/{platform}`.

Mobile product requests carry client, build and platform metadata. Missing or
unsupported metadata is rejected by the API; unsupported builds receive 426.
The floor cache lasts 30 seconds per process and invalidates locally after an
Ops update. Other replicas can observe the update after that bounded delay.

## Roll out a reviewed mobile feature

1. Implement the feature in the app and use a fixed key at its entry points.
   Commuter code can call `CommuterApi.isFeatureEnabled(key)`. Driver widgets
   can watch `ConfigController` and call `isFeatureEnabled(key)`. Keep the
   feature's usual API permissions and business rules in the backend.
2. Submit a store build with the feature and document it in the review notes.
   Give reviewers access on the backend they use. A rule with the submitted
   build as its minimum makes the feature available for review while users on
   earlier builds stay ineligible. Record the first approved build for each
   app and platform that includes the feature.
3. Add one entry per target to the API service's `MOBILE_FEATURE_ROLLOUTS`
   environment variable and deploy the backend configuration. For example, the
   following enables a feature for eligible commuter iOS and driver Android
   builds.

   ```json
   [
     { "app": "commuter", "platform": "ios", "key": "example_feature", "minimumBuild": 42 },
     { "app": "driver", "platform": "android", "key": "example_feature", "minimumBuild": 37 }
   ]
   ```

4. Relaunch each target app and verify the feature on an eligible build and its
   absence on a build below the rollout minimum. To withdraw a rollout, remove
   its entry and redeploy the backend configuration. Installed apps pick up the
   change on their next successful configuration load, normally at launch.

The setting defaults to an empty array. It allows up to 64 entries and each
app, platform, and key combination must be unique. The bootstrap response is
public, so use keys that can be disclosed. A missing rollout keeps the feature
off. The driver app requires a fresh bootstrap response to enable any rollout.
The rollout minimum applies to this feature alone.

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
