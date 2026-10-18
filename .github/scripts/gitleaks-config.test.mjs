import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');

test('Gitleaks exceptions cover only reviewed Firebase fields and SDK inventory prose', () => {
  const fixture = mkdtempSync(join(tmpdir(), 'trotxi-gitleaks-'));
  const write = (path, content) => {
    const target = join(fixture, path);
    mkdirSync(dirname(target), { recursive: true });
    writeFileSync(target, content);
  };
  try {
    // Generated scanner fixtures, never working provider credentials.
    const google = ['AI', 'za'].join('') + randomBytes(27).toString('base64url').slice(0, 35);
    const payment = ['sk', 'live', randomBytes(24).toString('hex')].join('_');
    const fields = {
      FIREBASE_ANDROID_API_KEY: google,
      FIREBASE_IOS_API_KEY: google,
    };
    const json = (value) => JSON.stringify(value, null, 2);
    write('apps/trotxi_commuter/config/staging.json', json(fields));
    write('apps/trotxi_commuter/config/production.json', json(fields));
    write('apps/unreviewed/config/staging.json', json(fields));
    // A different provider's secret is still caught in an approved field/path.
    write(
      'apps/trotxi_driver/config/staging.json',
      json({
        FIREBASE_ANDROID_API_KEY: payment,
        FIREBASE_IOS_API_KEY: google,
        SERVER_API_KEY: google,
      }),
    );
    const row = readFileSync(join(root, 'docs/mobile-release-readiness.md'), 'utf8')
      .split('\n')
      .find((line) => line.startsWith('| Analytics,'));
    assert.ok(row, 'SDK inventory row must exist');
    const historical = row
      .replace('Analytics,', 'Analytics, Crashlytics, Performance,')
      .replace(
        'No collection through these absent SDKs',
        'No mobile collection through these removed SDKs',
      );
    write(
      'docs/mobile-release-readiness.md',
      `${row}\n${historical}\nSERVER_API_KEY="${google}"\n`,
    );
    write('docs/unreviewed.md', row);
    const docker = process.env.GITLEAKS_DOCKER === '1';
    const prefix = docker
      ? [
          'run',
          '--rm',
          '-v',
          `${fixture}:/repo`,
          '-v',
          `${join(root, '.gitleaks.toml')}:/gitleaks.toml:ro`,
          '-w',
          '/repo',
          'ghcr.io/gitleaks/gitleaks:latest',
        ]
      : [];
    const scan = spawnSync(
      docker ? 'docker' : 'gitleaks',
      [
        ...prefix,
        'detect',
        '--no-git',
        '--source',
        '.',
        '--config',
        docker ? '/gitleaks.toml' : join(root, '.gitleaks.toml'),
        '--redact',
        '--report-format=json',
        '--report-path=-',
        '--no-banner',
        '--log-level=error',
      ],
      { encoding: 'utf8', cwd: fixture },
    );
    assert.equal(scan.error, undefined, 'Gitleaks must be installed');
    assert.equal(scan.status, 1, 'Negative controls must be detected');
    const findings = JSON.parse(scan.stdout);
    const found = (suffix, rule) =>
      findings.filter((f) => f.File.endsWith(suffix) && f.RuleID === rule);
    assert.equal(found('apps/trotxi_commuter/config/staging.json', 'gcp-api-key').length, 0);
    assert.equal(found('apps/trotxi_driver/config/staging.json', 'gcp-api-key').length, 1);
    assert.ok(
      findings.some(
        (f) =>
          f.File.endsWith('apps/trotxi_driver/config/staging.json') && f.RuleID !== 'gcp-api-key',
      ),
    );
    assert.equal(found('apps/trotxi_commuter/config/production.json', 'gcp-api-key').length, 2);
    assert.equal(found('apps/unreviewed/config/staging.json', 'gcp-api-key').length, 2);
    assert.equal(
      found('docs/mobile-release-readiness.md', 'generic-api-key').filter((f) => f.StartLine <= 2)
        .length,
      0,
    );
    assert.equal(found('docs/mobile-release-readiness.md', 'gcp-api-key').length, 1);
    assert.equal(found('docs/unreviewed.md', 'generic-api-key').length, 1);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});
