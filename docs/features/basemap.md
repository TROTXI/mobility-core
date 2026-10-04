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
