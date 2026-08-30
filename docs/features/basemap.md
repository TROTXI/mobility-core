# Basemap

## Overview

We host our own map. No Google Maps, no Mapbox, no per-request billing, and no
vendor who can reprice us once riders depend on the map being there.

Four parts make that work, and all four are live: a tile archive, two styles
(light and dark), the glyph atlases that let text draw at all, and a contract on
`GET /flags` that hands clients all three. Everything is served anonymously from
`https://tiles.trotxi.com` with CORS open, so there are no keys to distribute
and nothing to rotate.

**Status:** live. Phases 1, 2 and 4 shipped (#178, #179, #181). Client
integration is #180 (rider and driver apps) and #170 (ops console).

## Concepts

**PMTiles** is a single file holding the whole tile pyramid, read with HTTP
range requests. There is no tile server to run or pay for; a bucket and a CDN
are the entire serving stack.

**A style is not the map data.** The archive is only geometry and attributes.
Nothing in it says water is blue. The style maps the 16 vector layers onto
colours, widths and label rules. Without one, a client renders an empty canvas.

**Glyphs are not optional.** MapLibre draws text from pre-baked SDF atlases and
has no system-font fallback for Latin. Missing glyphs do not mean plain labels,
they mean no labels.

**The basemap knows nothing about Trotxi.** It is roads, water, landcover,
buildings, boundaries and place names. The vehicle marker, route line, pickup
pin and the rider's own location are all overlays a client draws on top.

## API

One contract, fetched on launch alongside the feature flags:

```jsonc
GET /flags        // public, no auth
{
  "mapTiles": {
    "url":          "https://tiles.trotxi.com/ghana.pmtiles",
    "styleUrl":     "https://tiles.trotxi.com/style.light.json",
    "darkStyleUrl": "https://tiles.trotxi.com/style.dark.json",
    "attribution":  "© OpenStreetMap contributors · © OpenMapTiles"
  }
}
```

| Field          | Meaning                                                     |
| -------------- | ----------------------------------------------------------- |
| `url`          | The PMTiles archive. You rarely want this directly.         |
| `styleUrl`     | Light theme style. **This is what you load.**               |
| `darkStyleUrl` | Dark theme style.                                           |
| `attribution`  | Licence notice. Displaying it is a condition, not a choice. |

Every field is nullable, meaning not configured. Clients **degrade to no basemap
rather than failing**: a rider whose van is 6 minutes away still needs the ETA
and the boarding code even when the map cannot draw.

## Consuming it

Written for #180 and #170. Three clients draw the same basemap, which is exactly
why none of them should hardcode any of it.

### Load the style, not the archive

The style already points at the archive, already sets the zoom ceiling, and
already carries the attribution. Pointing a client at `url` directly means
reimplementing all three and getting one of them wrong.

Never bake these URLs into a build. The bucket hostname changed once already,
and changing it again should be a config change rather than three simultaneous
app releases.

### Register the `pmtiles://` protocol first

The style's source URL is `pmtiles://https://tiles.trotxi.com/ghana.pmtiles`.
That scheme is not native to the map library. **Register the handler before
constructing the map**, or the source silently fails to resolve and you get an
empty canvas with no error.

Web (ops console):

```js
import maplibregl from 'maplibre-gl';
import { Protocol } from 'pmtiles';

maplibregl.addProtocol('pmtiles', new Protocol().tile); // before new Map()

const { mapTiles } = await api.flags();
const map = new maplibregl.Map({
  container: 'map',
  style: mapTiles.styleUrl,
  center: [-0.1869, 5.6037], // Accra
  zoom: 12,
});
```

Flutter (rider and driver): **verify this before building screens on top of it.
It is the biggest unknown in #180.** MapLibre Native does not expose
`addProtocol` the way the JS library does. Confirm early which of these applies:

1. Native PMTiles support in the MapLibre Native version the Flutter binding
   wraps, if the binding surfaces it.
2. A Dart PMTiles reader feeding the map through a local shim.
3. Asking us to expose a plain `{z}/{x}/{y}` endpoint in front of the archive.

Option 3 is a legitimate answer, not a defeat. It trades a service to run for
the problem disappearing. Raise it early, because it changes what we operate.

### Light and dark

Every screen in the designs has a dark variant and the map is part of the
screen. `darkStyleUrl` is a full second style, not a filter.

Its background is `#0A0D0B`, which is `homeDarkMap` in
`apps/trotxi_commuter/lib/core/config/theme/app_colors.dart`. The basemap was
built from the app palette so it sits inside the design rather than beside it.

Swap by calling the library's set-style method with the other URL. **Overlays do
not survive a style swap.** Re-add the vehicle marker, route line and pins after
the new style loads. This is the most common bug when wiring a theme toggle.

### Overlays, and one gap

| Overlay                       | Source                                                        | State           |
| ----------------------------- | ------------------------------------------------------------- | --------------- |
| Stop pins                     | `GET /routes/:id`, stops in order with `latitude`/`longitude` | Ready           |
| Vehicle marker                | `GET /trips/:id/position`, latest fix                         | Ready           |
| ETA per stop                  | Same call, `etaToStops[]` with `distanceMeters`, `etaSeconds` | Ready           |
| Stop progress ("2 of 4")      | Route stop count minus `etaToStops` remaining                 | Ready           |
| **Road-following route line** | Learned geometry (#179)                                       | **Not exposed** |

The last row is a real gap. We derive the road the vehicle actually follows from
our own GPS traces, but nothing serves it to clients. Today you can only draw a
straight polyline between consecutive stops, which visibly cuts corners against
the basemap's roads. If the designs need the line to follow the road, say so and
we will expose it. Do not spend time approximating it.

Also missing, tracked from the #199 review: nothing pins a rider to a boarding
stop, so "the van is approaching **your** pickup" cannot be derived from
`etaToStops` alone.

### Polling

`GET /trips/:id/position` shares a budget of **100 requests per 60 seconds per
user across every endpoint**, not per route. Polling once a second costs 60 of
your 100 and starts returning 429 for the rest of the app. Drivers publish a fix
roughly every 5 seconds, so anything faster re-reads the same row. Poll at 5s
while a trip is live, back off hard when it is not, stop when backgrounded.

### Things that will bite you

- **Zoom past 14.** The archive stops at z14 and the style sets `maxzoom: 14` so
  MapLibre overzooms cleanly rather than requesting tiles that do not exist.
  Omit it in a style of your own and the map blanks exactly when a rider zooms
  in to find their stop. Inherit the shipped style and this is free.
- **Labels are Latin only.** Glyphs cover `U+0000`-`U+024F` and the styles use
  `['get', 'name']` deliberately. The tiles also carry `name:zh`, `name:ko`,
  `name:ka` and `name:ru`; switching to a localised field makes those labels
  silently vanish rather than error. Widen `maps/build-glyphs.mjs` first.
- **A malformed style does not throw.** It renders a blank grey canvas that is
  indistinguishable from the tiles being down. If the map is empty, suspect the
  style before the network.
- **Range requests are mandatory.** Any proxy or cache in front of the archive
  must preserve `206`, `accept-ranges`, and `content-range` inside
  `access-control-expose-headers`.

## How it works

```
Geofabrik Ghana extract
        │  planetiler (Java 21)
        ▼
   ghana.pmtiles ──────────┐
                           │
maps/build-styles.mjs ─────┤ upload ──▶  R2  ──▶  tiles.trotxi.com
   style.{light,dark}.json │                            │
                           │                            │ styleUrl / darkStyleUrl
maps/build-glyphs.mjs ─────┘                            │
   fonts/{stack}/{range}.pbf                            ▼
                                    GET /flags ──▶ rider · driver · ops
```

The archive:

```
format   PMTiles v3, clustered, gzip, MVT vector
zoom     0 to 14
bounds   lon -3.807 to 1.394, lat 3.704 to 11.178
schema   OpenMapTiles 3.16.0, 16 vector layers
size     101 MB, 79,193 addressed tiles
```

Both styles come from one generator rather than two hand-written files, because
they differ only in palette. Kept apart they drift: a layer gets added to one,
the dark map quietly loses a road class, and nobody notices until a driver is
squinting at it at 6am.

Glyphs are built from Noto Sans (OFL-1.1) via Fontsource, which publishes woff2
only, so each subset is decompressed back to sfnt before fontnik slices it into
256-codepoint ranges. `latin` and `latin-ext` are composited per range because
Fontsource splits Latin across both and a name like "Nsawam Adoagyiri" can draw
from either. Two stacks: `Noto Sans Regular` (400) and `Noto Sans Medium` (500).

## Configuration

| Var                  | Effect                                            |
| -------------------- | ------------------------------------------------- |
| `MAP_TILES_URL`      | Archive URL on `/flags`. Unset means `url: null`. |
| `MAP_STYLE_URL`      | Light style URL. Unset means `styleUrl: null`.    |
| `MAP_STYLE_DARK_URL` | Dark style URL. Unset means `darkStyleUrl: null`. |

All three are **public values** and live in `render.yaml`, not the dashboard.
There is no secret anywhere in this feature.

## Security

The bucket is world-readable **by design**. Tiles are public OSM data; there is
nothing to protect and adding auth would only mean shipping a credential to
every client.

What actually matters:

- **Licence compliance.** ODbL (OSM) and the OpenMapTiles schema both require
  credit. `attribution` travels inside the style as well as on `/flags`, so it
  is hard to render the map without the notice. Do not shrink it to unreadable
  or hide it behind a tap.
- **Redistribution.** Noto Sans is OFL-1.1, which permits shipping the glyph
  atlases. Do not swap in a font without checking its licence allows this.
- **No PII.** Nothing rider-specific ever goes to the tile host. Overlays are
  drawn client-side from authenticated API responses; the bucket never learns
  who is looking or where they are.

## Local development and testing

```bash
pnpm --filter @trotxi/maps build           # styles  -> maps/dist/
pnpm --filter @trotxi/maps glyphs          # glyphs  -> maps/dist/fonts/
pnpm --filter @trotxi/maps test:coverage   # validate + check dist matches generator
```

Preview both themes against the live hosted tiles:

```bash
python3 -m http.server 8788 --directory maps   # then open /preview/
```

Style validation is gated in CI and is not ceremony. It already caught a road
casing whose width wrapped a zoom interpolation in an addition, which the spec
forbids, so that layer silently never drew.

### Deploying

Upload the contents of `maps/dist/` to the bucket root, preserving the `fonts/`
prefix. Nine objects:

```
ghana.pmtiles
style.light.json
style.dark.json
fonts/Noto Sans Regular/{0-255,256-511,512-767}.pbf
fonts/Noto Sans Medium/{0-255,256-511,512-767}.pbf
```

The spaces in the font stack directory names are significant: they must match
the `text-font` values in the styles exactly. MapLibre requests them as `%20`.

```bash
for k in style.light.json style.dark.json "fonts/Noto%20Sans%20Regular/0-255.pbf" ghana.pmtiles; do
  printf "%-45s %s\n" "$k" "$(curl -s -o /dev/null -w '%{http_code}' "https://tiles.trotxi.com/$k")"
done
```

### Rebuilding the archive

The OSM snapshot is baked in; check `planetiler:osm:osmosisreplicationtime` in
the metadata to see how stale it is. Needs **Java 21**, planetiler refuses to
start on 17.

```bash
brew install openjdk@21
java -jar planetiler.jar --download --area=ghana --output=ghana.pmtiles
```

Then upload and purge the Cloudflare cache for the object.

## Where the code lives

| Path                                             | What                                                        |
| ------------------------------------------------ | ----------------------------------------------------------- |
| `maps/build-styles.mjs`                          | Generates both styles from one palette                      |
| `maps/build-glyphs.mjs`                          | Generates the SDF glyph atlases                             |
| `maps/validate-styles.mjs`                       | Style-spec validation                                       |
| `maps/check-styles.mjs`                          | CI gate: validates and checks `dist/` matches the generator |
| `maps/dist/`                                     | The upload artifacts                                        |
| `maps/preview/`                                  | Local light/dark preview harness                            |
| `services/api/src/modules/flags/flags.schema.ts` | The `mapTiles` contract                                     |
| `services/api/src/modules/flags/flags.routes.ts` | `GET /flags`                                                |
| `render.yaml`                                    | The three public URL vars                                   |

## Related

- #178 basemap hosting, #179 route geometry, #181 segment speeds
- #180 MapLibre in the apps, #170 ops console
- [live-positions.md](live-positions.md) for the position and ETA payloads
- ADR-0006 (telemetry path), ADR-0008 (Zod/OpenAPI contract)
