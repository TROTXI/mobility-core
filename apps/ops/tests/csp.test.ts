import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

function deployedPolicy() {
  const blueprint = readFileSync(resolve(process.cwd(), '../../render.yaml'), 'utf8');
  const header = blueprint.split('name: Content-Security-Policy\n')[1]?.split('\n      - path:')[0];
  const value = header?.match(/^\s*value: "([^"]+)"\s*$/m)?.[1];
  if (!value) throw new Error('Ops Render CSP header is missing');
  const entries = value.split(';').map((entry) => entry.trim().split(/\s+/));
  const policy = new Map(entries.map(([name, ...sources]) => [name, sources]));
  if (policy.size !== entries.length) throw new Error('Ops CSP contains duplicate directives');
  return policy;
}

describe('deployed Ops CSP', () => {
  it('keeps executable code and workers on audited origins', () => {
    const policy = deployedPolicy();
    expect(policy.get('default-src')).toEqual(["'none'"]);
    expect(policy.get('script-src')).toEqual(["'self'", 'https://accounts.google.com/gsi/client']);
    expect(policy.get('worker-src')).toEqual(["'self'"]);
    expect(policy.get('object-src')).toEqual(["'none'"]);
    expect(policy.get('base-uri')).toEqual(["'none'"]);
    expect(policy.get('frame-ancestors')).toEqual(["'none'"]);
  });

  it('admits only the staging API, tile host and Google sign-in network paths', () => {
    const policy = deployedPolicy();
    expect(policy.get('connect-src')).toEqual([
      "'self'",
      'https://trotxi-api-staging.onrender.com',
      'https://tiles.trotxi.com',
      'https://accounts.google.com/gsi/',
      'https://accounts.google.com/o/fedcm/',
    ]);
    expect(policy.get('frame-src')).toEqual([
      'https://accounts.google.com/gsi/',
      'https://accounts.google.com/o/fedcm/',
    ]);
    expect(policy.get('img-src')).toEqual([
      "'self'",
      'data:',
      'blob:',
      'https://*.r2.cloudflarestorage.com',
    ]);
    expect(policy.get('style-src')).toEqual([
      "'self'",
      "'unsafe-inline'",
      'https://accounts.google.com/gsi/style',
    ]);
  });
});
