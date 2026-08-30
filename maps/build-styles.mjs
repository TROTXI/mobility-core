// Generates the MapLibre styles our three clients share: the rider app, the
// driver app (#180) and the ops console (#170).
//
// One generator rather than two hand-written JSON files, because the light and
// dark basemaps differ only in palette. Kept apart, they drift: someone adds a
// layer to one, the dark map quietly loses a road class, and nobody notices
// until a driver is squinting at 6am.
//
// Emits maps/dist/style.light.json and style.dark.json for upload to R2. See
// docs/features/basemap.md.

import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const TILES_URL = process.env.TILES_URL ?? 'https://tiles.trotxi.com/ghana.pmtiles';
const GLYPHS_URL =
  process.env.GLYPHS_URL ?? 'https://tiles.trotxi.com/fonts/{fontstack}/{range}.pbf';

// Licence condition, not decoration: the tiles are OSM data (ODbL) rendered
// through the OpenMapTiles schema, and both require credit. It travels in the
// style so a client cannot render the map without carrying the notice.
const ATTRIBUTION =
  '<a href="https://www.openstreetmap.org/copyright">&copy; OpenStreetMap contributors</a> ' +
  '<a href="https://www.openmaptiles.org/">&copy; OpenMapTiles</a>';

// Pulled from apps/trotxi_commuter/lib/core/config/theme/app_colors.dart so the
// basemap sits inside the app's palette instead of next to it.
const PALETTES = {
  light: {
    background: '#F4F6F4',
    water: '#C6DCE8',
    waterway: '#AECBDA',
    wood: '#DCE8DC',
    grass: '#E2EDE1',
    sand: '#F0EBDC',
    landuseResidential: '#EDEFEC',
    park: '#DAEADB',
    building: '#E3E6E2',
    buildingOutline: '#D5D9D3',
    roadCasing: '#DADED9',
    motorway: '#FFFFFF',
    trunk: '#FFFFFF',
    primary: '#FFFFFF',
    secondary: '#FBFCFB',
    minor: '#F7F8F7',
    path: '#E4E8E3',
    rail: '#CDD3CC',
    boundary: '#B4BEB6',
    label: '#2C3A32',
    labelHalo: '#FFFFFF',
    labelMinor: '#5D6B62',
    waterLabel: '#5C7F92',
  },
  dark: {
    // homeDarkMap — the designs already reserve this for the map surface.
    background: '#0A0D0B',
    water: '#0E1A22',
    waterway: '#122630',
    wood: '#101613',
    grass: '#111814',
    sand: '#181712',
    landuseResidential: '#0E1210',
    park: '#101A14',
    building: '#141917',
    buildingOutline: '#1B211E',
    roadCasing: '#0C100E',
    motorway: '#39423D',
    trunk: '#333B36',
    primary: '#2C332E',
    secondary: '#252B27',
    minor: '#1E2320',
    path: '#1A1F1C',
    rail: '#232925',
    boundary: '#2A322D',
    label: '#E6EBE8',
    labelHalo: '#0A0D0B',
    labelMinor: '#ABB5B0',
    waterLabel: '#6E8C9C',
  },
};

const REGULAR = ['Noto Sans Regular'];
const MEDIUM = ['Noto Sans Medium'];

/**
 * Road width ramp, shared by casing and fill so they cannot drift apart.
 *
 * `extra` widens every stop rather than wrapping the result in an addition: the
 * style spec only allows `zoom` as the direct input of a top-level interpolate,
 * so `['+', ['interpolate', ['zoom'], ...], 4]` is rejected and the layer never
 * draws. Baking the offset into the stops keeps one ramp for casing and fill.
 *
 * @param {number} base - width at z10.
 * @param {number} extra - constant added at every stop (casing overhang).
 * @returns {unknown[]} a MapLibre interpolate expression.
 */
const roadWidth = (base, extra = 0) => [
  'interpolate',
  ['exponential', 1.4],
  ['zoom'],
  6,
  base * 0.4 + extra,
  10,
  base + extra,
  14,
  base * 2.2 + extra,
  18,
  base * 5 + extra,
];

/**
 * Build one complete style document.
 *
 * @param {'light'|'dark'} theme - which palette to render with.
 * @returns {object} a MapLibre style spec.
 */
function buildStyle(theme) {
  const c = PALETTES[theme];
  return {
    version: 8,
    name: `Trotxi ${theme === 'dark' ? 'Dark' : 'Light'}`,
    glyphs: GLYPHS_URL,
    sources: {
      openmaptiles: {
        type: 'vector',
        url: `pmtiles://${TILES_URL}`,
        attribution: ATTRIBUTION,
        // The archive stops at z14. Without this MapLibre asks for z15+, gets
        // nothing, and renders blank exactly when a rider zooms to find their
        // stop. Set here so every client inherits it (vector tiles overzoom
        // cleanly, so the map still sharpens past 14).
        maxzoom: 14,
      },
    },
    layers: [
      { id: 'background', type: 'background', paint: { 'background-color': c.background } },

      fill('landcover-wood', 'landcover', c.wood, ['==', ['get', 'class'], 'wood'], 0.7),
      fill('landcover-grass', 'landcover', c.grass, ['==', ['get', 'class'], 'grass'], 0.7),
      fill('landcover-sand', 'landcover', c.sand, ['==', ['get', 'class'], 'sand'], 0.7),
      fill('landuse-residential', 'landuse', c.landuseResidential, [
        '==',
        ['get', 'class'],
        'residential',
      ]),
      fill('park', 'park', c.park, null, 0.8),

      fill('water', 'water', c.water, ['!=', ['get', 'brunnel'], 'tunnel']),
      {
        id: 'waterway',
        type: 'line',
        source: 'openmaptiles',
        'source-layer': 'waterway',
        paint: { 'line-color': c.waterway, 'line-width': roadWidth(0.6) },
      },

      {
        id: 'building',
        type: 'fill',
        source: 'openmaptiles',
        'source-layer': 'building',
        minzoom: 13,
        paint: {
          'fill-color': c.building,
          'fill-outline-color': c.buildingOutline,
          'fill-opacity': ['interpolate', ['linear'], ['zoom'], 13, 0, 15, 1],
        },
      },

      // Casing first, then fill, so junctions read as continuous road rather
      // than a stack of outlined segments.
      road('road-casing-major', c.roadCasing, ROAD_MAJOR, 3.4, 4),
      road('road-minor', c.minor, ROAD_MINOR, 1.2, 0, 12),
      road('road-path', c.path, [['==', ['get', 'class'], 'path']], 0.8, 0, 14),
      road('road-secondary', c.secondary, [['==', ['get', 'class'], 'secondary']], 2, 0),
      road('road-primary', c.primary, [['==', ['get', 'class'], 'primary']], 2.6, 0),
      road('road-trunk', c.trunk, [['==', ['get', 'class'], 'trunk']], 3, 0),
      road('road-motorway', c.motorway, [['==', ['get', 'class'], 'motorway']], 3.4, 0),
      road('rail', c.rail, [['==', ['get', 'class'], 'rail']], 1, 0, 11),

      {
        id: 'boundary',
        type: 'line',
        source: 'openmaptiles',
        'source-layer': 'boundary',
        filter: ['<=', ['get', 'admin_level'], 4],
        paint: {
          'line-color': c.boundary,
          'line-width': ['interpolate', ['linear'], ['zoom'], 4, 0.6, 12, 1.6],
          'line-dasharray': [3, 2],
        },
      },

      {
        id: 'road-label',
        type: 'symbol',
        source: 'openmaptiles',
        'source-layer': 'transportation_name',
        minzoom: 13,
        layout: {
          'text-field': ['get', 'name'],
          'text-font': REGULAR,
          'text-size': 11,
          'symbol-placement': 'line',
        },
        paint: {
          'text-color': c.labelMinor,
          'text-halo-color': c.labelHalo,
          'text-halo-width': 1.2,
        },
      },
      {
        id: 'water-label',
        type: 'symbol',
        source: 'openmaptiles',
        'source-layer': 'water_name',
        layout: { 'text-field': ['get', 'name'], 'text-font': REGULAR, 'text-size': 11 },
        paint: { 'text-color': c.waterLabel, 'text-halo-color': c.labelHalo, 'text-halo-width': 1 },
      },
      placeLabel(
        c,
        'place-suburb',
        ['suburb', 'neighbourhood', 'quarter'],
        11,
        REGULAR,
        c.labelMinor,
        12,
      ),
      placeLabel(c, 'place-town', ['town', 'village'], 12, MEDIUM, c.label, 8),
      placeLabel(c, 'place-city', ['city'], 14, MEDIUM, c.label, 4),
    ],
  };
}

const ROAD_MAJOR = [['in', ['get', 'class'], ['literal', ['motorway', 'trunk', 'primary']]]];
const ROAD_MINOR = [['in', ['get', 'class'], ['literal', ['minor', 'service', 'tertiary']]]];

function fill(id, sourceLayer, color, filter, opacity = 1) {
  const layer = {
    id,
    type: 'fill',
    source: 'openmaptiles',
    'source-layer': sourceLayer,
    paint: { 'fill-color': color, 'fill-opacity': opacity },
  };
  if (filter) layer.filter = filter;
  return layer;
}

function road(id, color, filters, base, casingExtra, minzoom) {
  const layer = {
    id,
    type: 'line',
    source: 'openmaptiles',
    'source-layer': 'transportation',
    layout: { 'line-cap': 'round', 'line-join': 'round' },
    paint: { 'line-color': color, 'line-width': roadWidth(base, casingExtra) },
  };
  if (filters.length === 1) layer.filter = filters[0];
  else if (filters.length > 1) layer.filter = ['all', ...filters];
  if (minzoom) layer.minzoom = minzoom;
  return layer;
}

// Halo is the theme's own halo colour, so labels stay legible over any fill.
function placeLabel(palette, id, classes, size, font, color, maxzoom) {
  return {
    id,
    type: 'symbol',
    source: 'openmaptiles',
    'source-layer': 'place',
    maxzoom,
    filter: ['in', ['get', 'class'], ['literal', classes]],
    layout: { 'text-field': ['get', 'name'], 'text-font': font, 'text-size': size },
    paint: {
      'text-color': color,
      'text-halo-color': palette.labelHalo,
      'text-halo-width': 1.4,
    },
  };
}

const outDir = process.env.OUT_DIR ?? join(HERE, 'dist');
mkdirSync(outDir, { recursive: true });
for (const theme of ['light', 'dark']) {
  const style = buildStyle(theme);
  const path = join(outDir, `style.${theme}.json`);
  writeFileSync(path, `${JSON.stringify(style, null, 2)}\n`);
  console.log(`wrote ${path} (${style.layers.length} layers)`);
}
