# Self-hosted basemap

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Ghana PMTiles, light/dark styles, glyphs, CDN hosting and API config
are live. The shared Flutter map package and driver integration are live.
Commuter and ops integration remain incomplete.

## Architecture

```text
Geofabrik Ghana OSM extract
  → Planetiler → ghana.pmtiles
  → generated light/dark MapLibre styles + Noto Sans glyphs
  → Cloudflare R2/CDN at tiles.trotxi.com
  → URLs from GET /flags
  → commuter, driver and ops overlays
```

PMTiles is one range-requested archive, so the platform runs no tile server and
pays no per-map-view vendor fee. The basemap contains only public map features;
rider, route and vehicle overlays come from the transactional API.

## Client contract

`GET /flags` returns:

```json
{
  "mapTiles": {
    "url": "https://tiles.trotxi.com/ghana.pmtiles",
    "styleUrl": "https://tiles.trotxi.com/style.light.json",
    "darkStyleUrl": "https://tiles.trotxi.com/style.dark.json",
    "attribution": "© OpenStreetMap contributors · © OpenMapTiles"
  }
}
```

Clients load the style URL, not the archive directly, and must keep attribution
visible. Any URL may be `null`; the application must continue with ETA and
boarding information even when the basemap is unavailable.

The shared `apps/trotxi_map` package owns the Flutter MapLibre surface. Web
clients must register the `pmtiles://` protocol before constructing the map.
Changing theme reloads the style, so clients must re-add route, vehicle and stop
overlays after the style finishes loading.

## Assets

- `ghana.pmtiles`: PMTiles v3, OpenMapTiles 3.16 schema, zoom 0–14.
- `style.light.json` and `style.dark.json`: generated from one layer definition.
- Noto Sans Regular/Medium glyph ranges covering Latin and Latin Extended.

The tile host must preserve HTTP range semantics (`206`, `Accept-Ranges`,
`Content-Range`) and expose those headers through CORS.

## Build and configuration

```bash
pnpm --filter @trotxi/maps build
pnpm --filter @trotxi/maps glyphs
pnpm --filter @trotxi/maps test:coverage
```

`MAP_TILES_URL`, `MAP_STYLE_URL` and `MAP_STYLE_DARK_URL` populate the public
flags response. They are public configuration, not secrets.

## Code

- `maps/`
- `apps/trotxi_map/`
- `services/api/src/modules/flags/`
- [ADR-0004](../adr/0004-flutter-mobile.md)
