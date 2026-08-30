// Validates the generated styles against the MapLibre style spec.
//
// A malformed style does not error at runtime, it renders an empty grey canvas,
// which is indistinguishable from "tiles are down" when you are staring at a
// phone. Catching it here is the difference between a failed CI job and a
// debugging session during QA.

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { validateStyleMin } from '@maplibre/maplibre-gl-style-spec';

const HERE = dirname(fileURLToPath(import.meta.url));
let failed = false;

for (const theme of ['light', 'dark']) {
  const path = join(HERE, 'dist', `style.${theme}.json`);
  const style = JSON.parse(readFileSync(path, 'utf8'));
  // pmtiles:// is our protocol, registered by each client at startup; the spec
  // validator only knows http(s), so the source url is checked separately.
  const probe = structuredClone(style);
  probe.sources.openmaptiles.url = 'https://example.com/tiles.json';
  const errors = validateStyleMin(probe);

  if (errors.length > 0) {
    failed = true;
    console.error(`✗ style.${theme}.json`);
    for (const e of errors) console.error(`    ${e.message}`);
  } else {
    console.log(`✓ style.${theme}.json — ${style.layers.length} layers`);
  }

  if (!style.sources.openmaptiles.url.startsWith('pmtiles://https://')) {
    failed = true;
    console.error(`✗ style.${theme}.json — source url must be pmtiles://https://…`);
  }
  if (style.sources.openmaptiles.maxzoom !== 14) {
    failed = true;
    console.error(`✗ style.${theme}.json — maxzoom must be 14 (the archive stops there)`);
  }
  if (!style.glyphs) {
    failed = true;
    console.error(`✗ style.${theme}.json — no glyphs url, every text label would fail to render`);
  }
}

process.exit(failed ? 1 : 0);
