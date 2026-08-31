# Basemap

## Overview

We host our own map tiles instead of using Google or Mapbox. It's a bucket and a
CDN, so there's no per-request bill and nobody can reprice us once riders depend
on the map.

There are four pieces: the tile archive, a light and a dark style, the font
atlases, and a bit of `GET /flags` that tells clients where all of it is. They're
all live and serving from `https://tiles.trotxi.com`. It's public and CORS is
open, so there are no keys to hand out.

Status: live. #178, #179 and #181 are done. The clients still have to wire it up,
which is #180 for the apps and #170 for the ops console.

## Concepts

PMTiles is the whole tile pyramid in one file, read over HTTP range requests.
That's why there's no tile server to run.

The archive is just geometry and attributes. It doesn't say water is blue. That's
the style's job, and a client with no style draws an empty canvas.

Glyphs are the font atlases MapLibre uses to draw text. There's no fallback to
system fonts for Latin, so if they're missing you don't get ugly labels, you get
none.

The basemap has no idea Trotxi exists. It's roads, water, landcover, buildings,
boundaries and place names. The van, the route line and the pickup pin are all
things the client draws on top.

## API

`GET /flags` is public and already fetched at launch:

```jsonc
{
  "mapTiles": {
    "url": "https://tiles.trotxi.com/ghana.pmtiles",
    "styleUrl": "https://tiles.trotxi.com/style.light.json",
    "darkStyleUrl": "https://tiles.trotxi.com/style.dark.json",
    "attribution": "© OpenStreetMap contributors · © OpenMapTiles",
  },
}
```

`styleUrl` and `darkStyleUrl` are what you load. `url` is the raw archive and you
probably don't want it. `attribution` is a licence notice you have to show.

Any of them can be null, which means it isn't configured yet. Handle that by
dropping the basemap and carrying on. Someone whose van is six minutes out still
needs the ETA and their boarding code.

## Consuming it

For whoever picks up #180 and #170.

### Load the style, not the archive

The style already knows the archive URL, the zoom ceiling and the attribution.
Load `url` yourself and you have to redo all three, and you'll get one of them
wrong.

Don't hardcode any of these URLs. We already moved the bucket hostname once. Next
time should be a config change, not three app releases on the same day.

### Register the pmtiles protocol first

The style's source is `pmtiles://https://tiles.trotxi.com/ghana.pmtiles`. Map
libraries don't know that scheme. Register the handler before you construct the
map. If you forget, the source never resolves, nothing errors, and you sit there
looking at a blank canvas wondering why.

On web:

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

Flutter is the open question, and it's worth settling before you build screens on
top of it. MapLibre Native doesn't give you `addProtocol` like the JS library
does. So either the binding surfaces PMTiles support natively, or you read the
archive in Dart and feed the map through a local shim, or you ask us for a plain
`{z}/{x}/{y}` endpoint in front of the archive. That last one is fine by me. It
means we run a small service, which is a real cost, but it makes the whole problem
go away. Just raise it early.

### Light and dark

The designs have a dark variant of every screen and the map is part of that, so
there's a second full style rather than a filter over the first. Its background is
`#0A0D0B`, the same `homeDarkMap` in the app's `app_colors.dart`. The whole
palette came from there so the map sits inside the design instead of next to it.

Swap themes by setting the other style URL. Your overlays won't survive that, so
re-add the van, the line and the pins once the new style loads. That's the bug
everyone hits the first time they wire up a theme toggle.

### Overlays

You can draw these today:

- Stop pins from `GET /routes/:id`, which returns stops in order with lat/lng.
- The van from `GET /trips/:id/position`.
- Per-stop ETAs from the same call, in `etaToStops[]`.
- "2 of 4 stops" by comparing the route's stop count against what's left in
  `etaToStops`.

For the route line, call `GET /routes/:id/geometry`. You get the road-following
path we derived from our own GPS traces when the corridor has run enough times,
and a straight line through the stops when it hasn't. The `source` field says
which you got, `traces` or `stops`, so you can render the fallback differently
instead of implying it follows the road.

For "the van is approaching _your_ pickup", `GET /trips/:id/position` returns
`riderStop`: the caller's own entry, already picked out of `etaToStops`. It's
null when they have no reservation on that trip or no stop recorded.

Riders choose a pickup and drop-off when they subscribe, and both come back on
`GET /me/reservations` as well.

### Polling

The rate limit is 100 requests a minute per user across everything, not per
endpoint. Poll position once a second and you've spent 60 of those before the app
does anything else, and the rest starts 429ing.

Drivers report roughly every 5 seconds, so polling faster just re-reads the same
row. Use 5s while a trip is running, back right off when it isn't, and stop when
the app is backgrounded.

### Things that catch people out

The archive stops at zoom 14 and the style sets `maxzoom: 14` so MapLibre
stretches those tiles instead of asking for z15 and getting nothing. If you write
your own style and leave it out, the map goes white exactly when someone zooms in
to find their stop.

Labels only cover `U+0000`-`U+024F`, and the styles ask for `name` on purpose. The
tiles also carry `name:zh`, `name:ko`, `name:ka` and `name:ru`. Point `text-field`
at one of those and the labels quietly disappear instead of erroring. Widen
`maps/build-glyphs.mjs` first.

A broken style doesn't throw, it renders grey. That looks identical to the tiles
being down, so check the style first.

Anything you put in front of the archive has to keep range requests working: 206
responses, `accept-ranges`, and `content-range` listed in
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

The archive is PMTiles v3, clustered, gzipped MVT, zoom 0 to 14, covering
lon -3.807 to 1.394 and lat 3.704 to 11.178. OpenMapTiles 3.16.0 schema, 16 vector
layers, 101 MB, 79,193 tiles.

One generator produces both styles because they only differ in palette. If they
were two files someone would add a layer to one and forget the other, and we'd
find out when a driver couldn't read the dark map at 6am.

Glyphs come from Noto Sans via Fontsource, which only ships woff2, so the build
decompresses each subset back to sfnt before fontnik slices it into 256-codepoint
ranges. `latin` and `latin-ext` get composited together because Fontsource splits
Latin across both and a name like "Nsawam Adoagyiri" needs characters from each.
Two stacks, Regular (400) and Medium (500).

## Configuration

`MAP_TILES_URL`, `MAP_STYLE_URL` and `MAP_STYLE_DARK_URL` map onto the three
fields in `/flags`. Leave one unset and its field comes back null.

They're all public values, so they live in `render.yaml` rather than the Render
dashboard. Nothing in this feature is a secret.

## Security

The bucket is world-readable on purpose. It's public OSM data. Putting auth on it
would just mean shipping a credential to every client for no benefit.

The things worth actually watching:

Attribution is a licence condition. OSM is ODbL and the schema is OpenMapTiles,
and both want credit. It's baked into the style as well as `/flags` so it's hard
to ship the map without it. Don't shrink it to nothing or bury it behind a tap.

Noto Sans is OFL-1.1, which is why we can serve the glyphs at all. If anyone
swaps the font, check the licence allows redistribution.

Nothing rider-specific goes near the tile host. Overlays are drawn client-side
from authenticated API calls, so the bucket never learns who's looking or where
they are.

## Local development and testing

```bash
pnpm --filter @trotxi/maps build           # styles  -> maps/dist/
pnpm --filter @trotxi/maps glyphs          # glyphs  -> maps/dist/fonts/
pnpm --filter @trotxi/maps test:coverage   # validate, and check dist matches the generator
```

To look at both themes against the real hosted tiles:

```bash
python3 -m http.server 8788 --directory maps   # then open /preview/
```

Style validation runs in CI and it earns its keep. It caught a road casing whose
width wrapped a zoom interpolation inside an addition, which the spec doesn't
allow, so that layer had been silently not drawing.

### Deploying

Upload everything in `maps/dist/` to the bucket root, keeping the `fonts/` prefix.
Nine objects when you're done:

```
ghana.pmtiles
style.light.json
style.dark.json
fonts/Noto Sans Regular/{0-255,256-511,512-767}.pbf
fonts/Noto Sans Medium/{0-255,256-511,512-767}.pbf
```

The spaces in the font directory names matter. They have to match `text-font` in
the styles exactly, and MapLibre asks for them as `%20`.

```bash
for k in style.light.json style.dark.json "fonts/Noto%20Sans%20Regular/0-255.pbf" ghana.pmtiles; do
  printf "%-45s %s\n" "$k" "$(curl -s -o /dev/null -w '%{http_code}' "https://tiles.trotxi.com/$k")"
done
```

### Rebuilding the archive

The OSM snapshot is baked into the file. `planetiler:osm:osmosisreplicationtime`
in the metadata tells you how old it is. Needs Java 21; it won't start on 17.

```bash
brew install openjdk@21
java -jar planetiler.jar --download --area=ghana --output=ghana.pmtiles
```

Upload, then purge the Cloudflare cache for that object.

## Where the code lives

Everything generator-side is in `maps/`: `build-styles.mjs` and
`build-glyphs.mjs` produce the artifacts, `validate-styles.mjs` checks them
against the spec, and `check-styles.mjs` is the CI gate that also verifies
`dist/` still matches the generator. `preview/` is the local harness and `dist/`
is what gets uploaded.

The API side is small: the `mapTiles` shape lives in
`services/api/src/modules/flags/flags.schema.ts` and it's served from
`flags.routes.ts`. The three URLs are in `render.yaml`.

## Related

#178 for the hosting, #179 for route geometry, #181 for segment speeds. #180 and
#170 are the clients. [live-positions.md](live-positions.md) covers the position
and ETA payloads. ADR-0006 for the telemetry path, ADR-0008 for the contract.
