/** Real composed backend, unique local DB, real TEST providers; no fake sessions
 * or pricing adapters. Seed credentials stay in a private local artifact. */
import { randomBytes, randomUUID } from 'node:crypto';
import { lstat, readFile, mkdtemp, writeFile } from 'node:fs/promises';
import { parseEnv } from 'node:util';
import { fileURLToPath } from 'node:url';
import pg from 'pg';
import { readConfiguration } from '../src/runtime/config.js';
import { composeBackend } from '../src/runtime/compose.js';
import { migrate, grantRuntime, readMigrations, runtimeRoleIdentifier } from '../src/db/migrate.js';
import { rehearsalEnvironment, localRehearsalAdmin } from '../src/runtime/rehearsal.js';

const args = process.argv.slice(2);
if (args.length !== 2 || args[0] !== '--env-file' || !args[1]?.startsWith('/'))
  throw new Error('Usage: local-rehearsal --env-file /absolute/private.env');
const adminUrl = localRehearsalAdmin(process.env.HARNESS_ADMIN_DATABASE_URL);
if (process.env.HARNESS_ALLOW_CREATE_DATABASES !== '1')
  throw new Error('Explicit permission to create disposable local databases is required');
const info = await lstat(args[1]);
if (!info.isFile() || info.mode & 0o077 || info.uid !== process.getuid?.() || info.size > 1048576)
  throw new Error('An owner-only regular credential file is required');
const source = parseEnv(await readFile(args[1], 'utf8'));
const paystack = rehearsalEnvironment(source, 'paystack');
const r2 = rehearsalEnvironment(source, 'r2');
const run = randomBytes(6).toString('hex');
const database = `trotxi_rehearsal_${run}`,
  role = `trotxi_runtime_rehearsal_${run}`;
runtimeRoleIdentifier(role);
const ownerUrl = new URL(adminUrl);
ownerUrl.pathname = '/' + database;
const runtimeUrl = new URL(ownerUrl);
runtimeUrl.username = role;
runtimeUrl.password = randomBytes(32).toString('hex');
const adminId = randomUUID();
const env: Record<string, string> = {
  ...paystack,
  REPLACEMENT_DEPLOYMENT_ENVIRONMENT: 'staging',
  REPLACEMENT_RUNTIME_DATABASE_URL: runtimeUrl.href,
  REPLACEMENT_POOL_SIZE: '8',
  PORT: '3002',
  REPLACEMENT_HOST: '127.0.0.1',
  REPLACEMENT_SERVICE_NAME: 'trotxi-local-rehearsal',
  REPLACEMENT_SERVICE_VERSION: '0.1.0',
  REPLACEMENT_GIT_COMMIT: 'local-stage5-working',
  REPLACEMENT_ACCESS_ISSUER: `trotxi-local-rehearsal:${run}`,
  REPLACEMENT_ACCESS_AUDIENCE: 'trotxi-clients',
  REPLACEMENT_ACCESS_TTL_SECONDS: '900',
  REPLACEMENT_REFRESH_TTL_DAYS: '30',
  REPLACEMENT_SHIFT_TTL_HOURS: '12',
  REPLACEMENT_AUTH_PROVIDERS: 'google',
  REPLACEMENT_GOOGLE_CLIENT_ID: source.GOOGLE_CLIENT_ID ?? '',
  REPLACEMENT_MAINTENANCE_USER_ID: adminId,
  REPLACEMENT_R2_ACCOUNT_ID: r2.R2_ACCOUNT_ID!,
  REPLACEMENT_R2_ACCESS_KEY_ID: r2.R2_ACCESS_KEY_ID!,
  REPLACEMENT_R2_SECRET_ACCESS_KEY: r2.R2_SECRET_ACCESS_KEY!,
  REPLACEMENT_R2_BUCKET_NAME: r2.R2_BUCKET!,
  REPLACEMENT_AVATAR_URL_TTL_SECONDS: '300',
  REPLACEMENT_AVATAR_MAX_BYTES: '2097152',
  REPLACEMENT_MAP_TILES_URL: source.MAP_TILES_URL ?? '',
  REPLACEMENT_MAP_STYLE_URL: source.MAP_STYLE_URL ?? '',
  REPLACEMENT_MAP_STYLE_DARK_URL: source.MAP_STYLE_DARK_URL ?? '',
  REPLACEMENT_MAP_ATTRIBUTION: '© OpenStreetMap contributors · © OpenMapTiles',
  REPLACEMENT_DOCS_URL: 'https://github.com/TROTXI/mobility-core',
  REPLACEMENT_MINIMUM_BUILD_OPS: '1',
  REPLACEMENT_MINIMUM_BUILD_DRIVER_IOS: '1',
  REPLACEMENT_MINIMUM_BUILD_DRIVER_ANDROID: '1',
  REPLACEMENT_MINIMUM_BUILD_COMMUTER_IOS: '1',
  REPLACEMENT_MINIMUM_BUILD_COMMUTER_ANDROID: '1',
  REPLACEMENT_REQUESTS_PER_MINUTE: '120',
  REPLACEMENT_REQUESTS_PER_IP_PER_MINUTE: '600',
  REPLACEMENT_AUTH_REQUESTS_PER_MINUTE: '10',
  REPLACEMENT_TRUST_PROXY: 'none',
};
for (const name of [
  'ACCESS_SECRET',
  'CURSOR_SECRET',
  'PIN_SECRET',
  'CREDENTIAL_REPLAY_KEY',
  'PROVIDER_ENCRYPTION_KEY',
  'BOARDING_PROOF_KEY',
  'DEVICE_KEY',
  'PAYSTACK_EVIDENCE_KEY',
])
  env[`REPLACEMENT_${name}`] = randomBytes(32).toString('base64');
const config = readConfiguration(env); // fail before creating anything
const directory = await mkdtemp('/private/tmp/trotxi-local-rehearsal-');
const manifest = {
  database,
  role,
  realm: `local-replacement-${run}`,
  api: 'http://127.0.0.1:3002',
};
await writeFile(`${directory}/manifest.json`, JSON.stringify(manifest, null, 2), { mode: 0o600 });
await writeFile(
  `${directory}/runtime.env`,
  Object.entries(env)
    .map(([k, v]) => `${k}=${JSON.stringify(v)}`)
    .join('\n') + '\n',
  { mode: 0o600 },
);
console.log(JSON.stringify({ preparing: manifest, privateArtifacts: directory }));
const admin = new pg.Pool({ connectionString: adminUrl.href, max: 1 });
const owner = new pg.Pool({ connectionString: ownerUrl.href, max: 1 });
try {
  await admin.query(`CREATE DATABASE "${database}"`);
  await migrate(
    owner,
    await readMigrations(fileURLToPath(new URL('../migrations/', import.meta.url))),
  );
  await admin.query(
    `CREATE ROLE "${role}" LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE PASSWORD '${runtimeUrl.password}'`,
  );
  await grantRuntime(owner, role);
  await owner.query(
    "INSERT INTO app.users(id,role,display_name) VALUES ($1,'admin','Local rehearsal operator')",
    [adminId],
  );
} finally {
  await owner.end();
  await admin.end();
}
const backend = await composeBackend(config);
try {
  const session = (
    await backend.pool.query(
      `INSERT INTO app.auth_sessions(user_id,expires_at)
    VALUES ($1,clock_timestamp()+interval '15 minutes') RETURNING id,created_at,expires_at`,
      [adminId],
    )
  ).rows[0];
  const token = await backend.auth.tokens.sign(
    { userId: adminId, sessionId: session.id },
    'admin',
    session.created_at,
    session.expires_at,
  );
  const command = async (
    url: string,
    payload: unknown,
    status = 201,
    match?: string,
    method: 'POST' | 'PUT' = 'POST',
  ) => {
    const response = await backend.app.inject({
      method,
      url,
      payload: payload as never,
      headers: {
        authorization: `Bearer ${token}`,
        'x-trotxi-client': 'ops',
        'x-trotxi-build': '1',
        'idempotency-key': randomUUID(),
        ...(match ? { 'if-match': match } : {}),
      },
    });
    if (response.statusCode !== status)
      throw new Error(
        `Rehearsal seed refused: ${url} HTTP ${response.statusCode} code ${response.json()?.error?.code ?? 'unknown'}`,
      );
    return response.json().data;
  };
  try {
    const driver = await command('/v1/ops/drivers', { name: 'Local TEST Driver' });
    const credential = await command(`/v1/ops/drivers/${driver.id}/credentials`, {});
    await writeFile(`${directory}/driver.json`, JSON.stringify(credential), { mode: 0o600 });
    const vehicle = await command('/v1/ops/vehicles', {
      plate: `TEST-${run}`,
      capacity: 18,
      label: 'Local rehearsal bus',
      make: null,
      colour: null,
    });
    const route = await command('/v1/ops/routes', {
      name: 'LOCAL TEST corridor',
      description: 'Synthetic route for replacement walkthrough only',
      acceptsDriverRequests: false,
    });
    const locations = [
      { latitude: 5.6, longitude: -0.2 },
      { latitude: 5.61, longitude: -0.2 },
    ];
    const physical: Array<{ id: string; name: string }> = [];
    for (const [index, location] of locations.entries())
      physical.push(await command('/v1/ops/stops', { name: `TEST Stop ${index + 1}`, location }));
    const distance = (
      await backend.pool.query(
        "SELECT ST_Length(ST_GeomFromText('LINESTRING(-0.2 5.6,-0.2 5.61)',4326)::geography) AS meters",
      )
    ).rows[0].meters;
    const yesterday = new Date(Date.now() - 86400000).toISOString();
    const trips = [];
    for (const direction of ['outbound', 'return']) {
      const pattern = await command('/v1/ops/route-patterns', { routeId: route.id, direction });
      const order = direction === 'outbound' ? [0, 1] : [1, 0];
      const version = await command(`/v1/ops/route-patterns/${pattern.id}/versions`, {
        stops: order.map((i) => ({
          stopId: physical[i]!.id,
          name: physical[i]!.name,
          location: locations[i],
        })),
        geometry: { points: order.map((i) => locations[i]), stopDistancesMeters: [0, distance] },
      });
      await command(
        `/v1/ops/route-patterns/${pattern.id}/versions/${version.id}/publish`,
        { reason: 'Local synthetic rehearsal', effectiveFrom: yesterday },
        200,
        version.editToken,
      );
      const scheduledAt = new Date(
        Date.now() + (direction === 'outbound' ? 30 : 90) * 60000,
      ).toISOString();
      const schedule = await command('/v1/ops/service-schedules', {
        departure: { kind: 'new' },
        patternVersionId: version.id,
        serviceWindow: direction === 'outbound' ? 'morning' : 'evening',
        localDeparture: scheduledAt.slice(11, 16),
        timeZone: 'Africa/Accra',
        weekdays: [1, 2, 3, 4, 5, 6, 7],
        effectiveFrom: yesterday.slice(0, 10),
        effectiveTo: null,
      });
      const trip = await command('/v1/ops/trips', {
        scheduleId: schedule.id,
        serviceDate: scheduledAt.slice(0, 10),
        scheduledAt,
      });
      trips.push(
        await command(
          `/v1/ops/trips/${trip.id}/assignment`,
          { driverId: driver.id, vehicleId: vehicle.id },
          200,
          trip.editToken,
          'PUT',
        ),
      );
    }
    await command(`/v1/ops/routes/${route.id}/fares`, {
      amount: { amountMinor: 600, currency: 'GHS' },
      effectiveFrom: yesterday,
    });
    await writeFile(
      `${directory}/fixture.json`,
      JSON.stringify({ route, driverId: driver.id, vehicleId: vehicle.id, trips }, null, 2),
      { mode: 0o600 },
    );
  } finally {
    await backend.pool.query(
      'UPDATE app.auth_sessions SET revoked_at=clock_timestamp() WHERE id=$1',
      [session.id],
    );
  }
  await backend.app.listen(config.listen);
  console.log(
    JSON.stringify({
      ready: true,
      ...manifest,
      privateArtifacts: directory,
      payments: 'test',
      seededViaHttp: true,
    }),
  );
  for (const signal of ['SIGINT', 'SIGTERM'])
    process.once(signal, () => {
      void backend.close().then(
        () => process.exit(0),
        () => process.exit(1),
      );
    });
} catch (error) {
  await backend.close();
  // Preserve this explicitly named DB and evidence; never silently reset a
  // rehearsal that could later contain real TEST-provider facts.
  console.error(
    JSON.stringify({
      failed: error instanceof Error ? error.message : 'rehearsal_failed',
      retained: manifest,
      privateArtifacts: directory,
    }),
  );
  process.exitCode = 1;
}
