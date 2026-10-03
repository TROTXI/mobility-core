import type { ConnectionOptions } from 'node:tls';

export const STAGING_DATABASE_HOST = 'dpg-d8sugvv7f7vs73bifff0-a.frankfurt-postgres.render.com';

/** External staging connections always authenticate the server certificate.
 * Remove URL TLS options before pg parses them: otherwise they override ssl.
 * The optional CA is PEM content, never a runner-local path from the URL.
 */
export function stagingDatabase(
  value: string | undefined,
  ca: string | undefined,
  purpose: 'runtime' | 'installer' = 'runtime',
): { connectionString: string; ssl: ConnectionOptions } {
  let url: URL;
  try {
    url = new URL(value ?? '');
  } catch {
    throw new Error('A valid external staging database URL is required');
  }
  if (
    !['postgres:', 'postgresql:'].includes(url.protocol) ||
    url.hostname !== STAGING_DATABASE_HOST ||
    url.pathname !== '/trotxi' ||
    (url.port && url.port !== '5432') ||
    url.hash ||
    !url.password ||
    (purpose === 'installer'
      ? url.username !== 'trotxi'
      : !/^trotxi_runtime_[a-z0-9_]{1,40}$/.test(url.username)) ||
    [...url.searchParams.keys()].some((name) => name !== 'sslmode') ||
    (url.searchParams.has('sslmode') &&
      (url.searchParams.getAll('sslmode').length !== 1 ||
        url.searchParams.get('sslmode') !== 'verify-full'))
  )
    throw new Error('Use the pinned staging database, the intended role and verified TLS');
  if (ca && !ca.includes('-----BEGIN CERTIFICATE-----'))
    throw new Error('The staging database CA must be a PEM certificate');
  url.search = '';
  return {
    connectionString: url.href,
    ssl: { rejectUnauthorized: true, ...(ca ? { ca } : {}) },
  };
}
