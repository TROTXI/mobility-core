# Basemap

Source audit: 2026-10-03.

Both Flutter apps and Ops integrate MapLibre. Public Ghana PMTiles, generated
light/dark styles and glyphs are separate from private avatar storage.
Bootstrap `GET /flags` provides map configuration; clients retain visible
OpenStreetMap/OpenMapTiles attribution.

Ops registers the PMTiles protocol and bundles its MapLibre worker for the
site's CSP. The shared Flutter package is `apps/trotxi_map`. Basemap failure
must leave route, position/status and trip actions usable where data exists.

Tiles are reference geography, not Trotxi routing or live vehicle data.
Route geometry is a versioned API resource. There is no built-in commercial
geocoding, turn-by-turn navigation or guaranteed offline map download feature.

Tile hosting must support byte ranges and appropriate CORS; Ops CSP must
permit the configured tile origin. A source-code deployment alone does not
apply Render response headers. See [Ops CSP](../operations/ops-csp.md).

Sources: `maps/`, `apps/trotxi_map/`,
`apps/ops/src/components/LiveMap.tsx`, `render.yaml`.

## Diagnose the right layer

| Symptom                                    | Inspect                                                           |
| ------------------------------------------ | ----------------------------------------------------------------- |
| No background tiles                        | Bootstrap URLs, byte ranges, CORS, style/glyph assets and Ops CSP |
| Map renders but vehicle is absent          | Authorized live response, freshness and trip state                |
| Driver dot moves but Ops is stale          | Durable upload queue and matching server receipts                 |
| Route is a straight line                   | Configured version geometry, not the tile provider                |
| Map works in a test but not a native build | Platform MapLibre setup and the actual build/device               |

Do not make trip/boarding actions depend on tile availability. Keep attribution
visible and distinguish a missing basemap from missing vehicle data.

Code: [Ops map](../../apps/ops/src/components/LiveMap.tsx),
[shared mobile map](../../apps/trotxi_map/).
Test: [Ops map regression](../../apps/ops/src/components/LiveMap.test.tsx).
