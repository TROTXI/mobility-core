# Launch configuration, feature flags and force-update

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Live with the pilot's home-grown flag store.

`GET /flags` is the public launch/session payload shared by all clients. It
contains feature gates, minimum versions, basemap configuration and operations
contact details. This keeps operational values out of shipped app binaries.

## Public response

```json
{
  "flags": [{ "key": "live_positions", "enabled": true, "rolloutPercentage": 100 }],
  "minSupportedVersion": { "ios": null, "android": null },
  "mapTiles": {
    "url": null,
    "styleUrl": null,
    "darkStyleUrl": null,
    "attribution": "© OpenStreetMap contributors · © OpenMapTiles"
  },
  "operations": {
    "phone": null,
    "whatsapp": null,
    "email": null,
    "hours": null
  }
}
```

The endpoint is public because sign-in recovery, force-update and map startup
need it before authentication. It omits flag descriptions and timestamps.

`enabled` is the kill switch. `rolloutPercentage` is data only; cohort bucketing
is performed by clients until a product-analytics platform replaces the pilot
implementation.

## Admin API

| Endpoint                            | Purpose                                            |
| ----------------------------------- | -------------------------------------------------- |
| `GET /admin/flags`                  | Full flag rows                                     |
| `PUT /admin/flags/:key`             | Partial upsert of enabled, rollout and description |
| `GET /admin/min-versions`           | Current iOS and Android floors                     |
| `PUT /admin/min-versions/:platform` | Set a force-update floor                           |

Map and operations-contact values are environment configuration, not database
rows. Unset values serialize as `null`, which tells clients to hide or degrade
that surface safely. A placeholder emergency number must never be shipped.

## Code

- `services/api/src/modules/flags/`
- admin flag routes in `services/api/src/modules/admin/`
- migration `018_feature_flags.sql`
