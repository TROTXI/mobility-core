// Generates the SDF glyph atlases MapLibre needs to draw any text at all.
//
// MapLibre has no system-font fallback for Latin: without these files the map
// renders geometry and not a single place name. That makes them part of the
// basemap, not a nicety.
//
// Built from Noto Sans (OFL-1.1, redistributable) via Fontsource, which ships
// woff2 only, so each subset is decompressed back to sfnt before fontnik turns
// it into 256-codepoint ranges. Subsets are composited per range because
// Fontsource splits Latin across `latin` and `latin-ext`, and a place name like
// "Nsawam Adoagyiri" can draw from either.
//
// Output: maps/dist/fonts/{fontstack}/{start}-{end}.pbf — the layout the
// `glyphs` url in the styles points at.

import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import fontnik from 'fontnik';
import { combine } from 'glyph-pbf-composite';
import wawoff2 from 'wawoff2';

const HERE = dirname(fileURLToPath(import.meta.url));
const FILES = join(HERE, 'node_modules', '@fontsource', 'noto-sans', 'files');
const OUT = process.env.OUT_DIR ?? join(HERE, 'dist', 'fonts');

// The stacks the styles ask for, and the weight each maps to.
const STACKS = { 'Noto Sans Regular': 400, 'Noto Sans Medium': 500 };

// Latin covers Ghanaian place names; latin-ext picks up the accented forms.
// Deliberately not shipping cyrillic/devanagari/greek/vietnamese: they would
// quadruple the output for scripts our OSM extract does not contain.
const SUBSETS = ['latin', 'latin-ext'];

// 0x0000–0x024F: Basic Latin, Latin-1, Latin Extended-A and -B. Everything the
// extract's names use. Ranges past this would be empty files.
const LAST_CODEPOINT = 0x024f;

/**
 * fontnik's range() is callback-based; promisify one range.
 *
 * @param {Buffer} font - sfnt font data.
 * @param {number} start - first codepoint.
 * @param {number} end - last codepoint.
 * @returns {Promise<Buffer>} the encoded glyph PBF.
 */
const range = (font, start, end) =>
  new Promise((res, rej) => fontnik.range({ font, start, end }, (e, d) => (e ? rej(e) : res(d))));

let written = 0;
for (const [stack, weight] of Object.entries(STACKS)) {
  const fonts = [];
  for (const subset of SUBSETS) {
    const woff2 = readFileSync(join(FILES, `noto-sans-${subset}-${weight}-normal.woff2`));
    fonts.push(Buffer.from(await wawoff2.decompress(woff2)));
  }

  const dir = join(OUT, stack);
  mkdirSync(dir, { recursive: true });

  for (let start = 0; start <= LAST_CODEPOINT; start += 256) {
    const end = start + 255;
    const parts = await Promise.all(fonts.map((f) => range(f, start, end)));
    writeFileSync(join(dir, `${start}-${end}.pbf`), combine(parts));
    written++;
  }
  console.log(`${stack}: ${(1 + LAST_CODEPOINT / 256) | 0} ranges from ${SUBSETS.join(' + ')}`);
}
console.log(`wrote ${written} glyph ranges to ${OUT}`);
