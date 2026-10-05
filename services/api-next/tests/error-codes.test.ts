import assert from 'node:assert/strict';
import { readdir, readFile } from 'node:fs/promises';
import test from 'node:test';
// @ts-expect-error The catalog is a plain .mjs module beside the contract.
import { errorActions, errorCodes } from '../../../docs/design/contracts/error-codes.mjs';

const catalog = errorCodes as Record<string, [number | number[], string, string]>;

async function sources(dir: URL): Promise<string[]> {
  const out: string[] = [];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const url = new URL(entry.name + (entry.isDirectory() ? '/' : ''), dir);
    if (entry.isDirectory()) out.push(...(await sources(url)));
    else if (entry.name.endsWith('.ts')) out.push(await readFile(url, 'utf8'));
  }
  return out;
}
const files = await sources(new URL('../src/', import.meta.url));
const all = files.join('\n');

// Every code a request can fail with, and the status it is raised with.
const raised = new Map<string, Set<number>>();
const add = (code: string, status: number) =>
  (raised.get(code) ?? raised.set(code, new Set()).get(code)!).add(status);
for (const [, status, code] of all.matchAll(
  /(?:\bfail|new TransportError)\(\s*(\d{3}),\s*'([a-z_]+)'/g,
))
  add(code!, Number(status));
// Lockouts carry 423 through LockedError subclasses.
for (const [, code] of all.matchAll(/extends LockedError[\s\S]*?super\(\s*'([a-z_]+)'/g))
  add(code!, 423);
// Database refusals that mapDatabaseError passes through by name.
const passed = /e\.code === '23514' &&\s*\[([^\]]+)\]\.includes\(e\.message/.exec(all);
assert.ok(passed, 'mapDatabaseError no longer passes database refusals through by name');
for (const [, code] of passed[1]!.matchAll(/'([a-z_]+)'/g)) add(code!, 409);

test('ERR-01 every error code the API raises says what a client does next', () => {
  const missing = [...raised.keys()].filter((code) => !catalog[code]).sort();
  assert.deepEqual(missing, [], 'add these to docs/design/contracts/error-codes.mjs');
  for (const [code, statuses] of raised) {
    const listed = [catalog[code]![0]].flat();
    for (const status of statuses)
      assert.ok(
        listed.includes(status),
        `${code} is raised with ${status} but listed as ${listed}`,
      );
  }
});

test('ERR-02 the catalog lists no code the API no longer raises, and every entry is complete', () => {
  for (const [code, [, action, next]] of Object.entries(catalog)) {
    assert.ok(raised.has(code) || all.includes(`'${code}'`), `${code} is never raised`);
    assert.ok(
      (errorActions as Record<string, string>)[action],
      `${code}: unknown action ${action}`,
    );
    assert.ok(next.trim().length > 0 && next.length <= 120, `${code}: next step must be one line`);
  }
});
