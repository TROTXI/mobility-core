/**
 * Put a week of believable service into a staging database.
 *
 * Three corridors, five buses, five drivers who can actually sign in, and
 * seven days of runs around today. Riders and their reservations land in a
 * second pass (see `riders()` below).
 *
 *   REPLACEMENT_DATABASE_URL=<owner> \
 *   REPLACEMENT_PIN_SECRET=<the service's PIN secret> \
 *   SEED_STAGING=yes \
 *     node --import tsx scripts/seed-staging.ts
 *
 * Without SEED_STAGING it prints the plan and stops.
 *
 * Written against the schema rather than the API because the rider and ops
 * surfaces both need a signed-in session, and nobody can mint a Google token
 * for twenty people. The consequence is stated plainly at the end: the
 * *_commands and *_events tables stay empty for what this writes, so the audit
 * trail shows state with no receipts behind it. Everything else is real: every
 * row here passes the same triggers and constraints a live write would.
 */
import pg from 'pg';
import { randomUUID } from 'node:crypto';
import { generateDriverCode, generatePin, hashDriverPin } from '../src/auth/driver-pin.js';

const url = process.env.REPLACEMENT_DATABASE_URL;
const pinSecret = process.env.REPLACEMENT_PIN_SECRET;
if (!url) throw new Error('REPLACEMENT_DATABASE_URL (the owner connection) is required');
if (!pinSecret) throw new Error('REPLACEMENT_PIN_SECRET is required to mint usable driver PINs');
const confirmed = process.env.SEED_STAGING === 'yes';

/** Corridors real enough to recognise on a board, with plausible stop names. */
const CORRIDORS = [
  { name: 'Circle - Madina', stops: ['Circle', 'Sankara', 'Legon', 'Madina'] },
  { name: 'Kaneshie - Lapaz', stops: ['Kaneshie', 'Awudome', 'Darkuman', 'Lapaz'] },
  {
    name: 'Achimota - Tema Station',
    stops: ['Achimota', 'Nkrumah Circle', 'Tudu', 'Tema Station'],
  },
];
const BUSES = [
  { plate: 'GT 4821-21', label: 'Bus 1', capacity: 18 },
  { plate: 'GT 5537-20', label: 'Bus 2', capacity: 18 },
  { plate: 'GR 1194-22', label: 'Bus 3', capacity: 14 },
  { plate: 'GT 7702-19', label: null, capacity: 18 },
  { plate: 'GW 3318-23', label: 'Bus 5', capacity: 22 },
];
const DRIVERS = ['Kwame Mensah', 'Ama Boateng', 'Yaw Owusu', 'Akosua Darko', 'Kofi Asante'];
/** Three days behind, today, three ahead: history to look at and runs to drive. */
const DAYS = [-3, -2, -1, 0, 1, 2, 3];

const pool = new pg.Pool({ connectionString: url, max: 4 });
const q = async <T extends pg.QueryResultRow = pg.QueryResultRow>(sql: string, v: unknown[] = []) =>
  (await pool.query<T>(sql, v)).rows;
const one = async (sql: string, v: unknown[] = []) =>
  (await q<{ id: string }>(sql + ' RETURNING id', v))[0]!.id;
const day = (offset: number) => new Date(Date.now() + offset * 86400000).toISOString().slice(0, 10);

async function main() {
  if (!(await q("SELECT to_regnamespace('app') AS s"))[0]!.s)
    throw new Error('No app schema here. Install the replacement first.');
  const existing = (await q<{ n: number }>('SELECT count(*)::int AS n FROM app.routes'))[0]!.n;
  if (existing)
    throw new Error(`${existing} routes already exist. Seeding twice would double the catalogue.`);

  process.stdout.write(
    `Plan\n` +
      `  ${CORRIDORS.length} corridors, both directions, 4 stops each\n` +
      `  ${BUSES.length} buses (one deliberately unlabelled, to exercise the plate)\n` +
      `  ${DRIVERS.length} drivers with working codes and PINs\n` +
      `  ${DAYS.length} service days: ${day(DAYS[0]!)} to ${day(DAYS.at(-1)!)}\n` +
      `  ${CORRIDORS.length * 2 * DAYS.length} runs (morning outbound, evening return)\n\n`,
  );
  if (!confirmed) {
    process.stdout.write('Nothing written. Set SEED_STAGING=yes to proceed.\n');
    return;
  }

  // Buses and drivers first: a trip cannot be assigned what does not exist.
  const buses: string[] = [];
  for (const b of BUSES)
    buses.push(
      await one('INSERT INTO app.vehicles(plate,label,capacity) VALUES ($1,$2,$3)', [
        b.plate,
        b.label,
        b.capacity,
      ]),
    );

  const credentials: { name: string; code: string; pin: string }[] = [];
  const drivers: string[] = [];
  for (const name of DRIVERS) {
    const id = await one('INSERT INTO app.drivers(name,phone,license_number) VALUES ($1,$2,$3)', [
      name,
      `+2332${Math.floor(10000000 + Math.random() * 89999999)}`,
      `GHA-${randomUUID().slice(0, 8).toUpperCase()}`,
    ]);
    drivers.push(id);
    // A fresh code and PIN, hashed the way the service hashes them, so these
    // sign in for real rather than only looking right in the table.
    const code = generateDriverCode();
    const pin = generatePin();
    await q(
      'INSERT INTO app.driver_credentials(driver_id,driver_code,pin_hash,must_change_pin) VALUES ($1,$2,$3,false)',
      [id, code, hashDriverPin(pin, pinSecret!)],
    );
    credentials.push({ name, code, pin });
  }

  // One corridor is two patterns, and a pattern is only usable once its version
  // is published with stops and a geometry.
  let trips = 0;
  for (const [index, corridor] of CORRIDORS.entries()) {
    const route = await one('INSERT INTO app.routes(name) VALUES ($1)', [corridor.name]);
    for (const direction of ['outbound', 'return'] as const) {
      const ordered = direction === 'outbound' ? corridor.stops : [...corridor.stops].reverse();
      const pattern = await one(
        'INSERT INTO app.route_patterns(route_id,direction) VALUES ($1,$2)',
        [route, direction],
      );
      const version = await one(
        'INSERT INTO app.route_pattern_versions(pattern_id,revision) VALUES ($1,1)',
        [pattern],
      );
      const occurrences: string[] = [];
      for (const [ordinal, name] of ordered.entries()) {
        const lat = 5.56 + ordinal * 0.012 + index * 0.02;
        const lon = -0.2 - ordinal * 0.014 - index * 0.02;
        const stop = await one('INSERT INTO app.stops(name,latitude,longitude) VALUES ($1,$2,$3)', [
          name,
          lat,
          lon,
        ]);
        occurrences.push(
          await one(
            `INSERT INTO app.route_pattern_stops(pattern_version_id,stop_id,ordinal,name,latitude,longitude)
             VALUES ($1,$2,$3,$4,$5,$6)`,
            [version, stop, ordinal, name, lat, lon],
          ),
        );
      }
      const line = ordered
        .map(
          (_, o) =>
            `${(-0.2 - o * 0.014 - index * 0.02).toFixed(4)} ${(5.56 + o * 0.012 + index * 0.02).toFixed(4)}`,
        )
        .join(',');
      const geometry = await one(
        `INSERT INTO app.route_geometries(pattern_version_id,source,line)
         VALUES ($1,'configured',ST_GeomFromText('LINESTRING(${line})',4326))`,
        [version],
      );
      // Derived from the line rather than invented: the schema refuses any
      // distance past the geometry's true length, and projecting each stop onto
      // the line gives ordered distances that fit by construction.
      await q(
        `INSERT INTO app.geometry_stop_distances
         SELECT $1, $2, s.id,
           ST_Length(ST_LineSubstring(g.line, 0,
             ST_LineLocatePoint(g.line,
               ST_SetSRID(ST_MakePoint(s.longitude, s.latitude), 4326)))::geography)
         FROM app.route_pattern_stops s, app.route_geometries g
         WHERE s.pattern_version_id = $2 AND g.id = $1
         ORDER BY s.ordinal`,
        [geometry, version],
      );
      await q("UPDATE app.route_geometries SET state='published' WHERE id=$1", [geometry]);
      await q(
        `UPDATE app.route_pattern_versions
         SET state='published',geometry_id=$2,effective_from='2025-01-01' WHERE id=$1`,
        [version, geometry],
      );

      const departure = await one('INSERT INTO app.service_departures(pattern_id) VALUES ($1)', [
        pattern,
      ]);
      const window_ = direction === 'outbound' ? 'morning' : 'evening';
      const at = direction === 'outbound' ? '06:30' : '17:30';
      const schedule = await one(
        `INSERT INTO app.service_schedules(departure_id,pattern_id,pattern_version_id,service_window,local_departure,weekdays,effective_from)
         VALUES ($1,$2,$3,$4,$5,ARRAY[1,2,3,4,5,6,7]::smallint[],'2025-01-01')`,
        [departure, pattern, version, window_, at],
      );

      for (const offset of DAYS) {
        const date = day(offset);
        const driver =
          drivers[(index * 2 + (direction === 'return' ? 1 : 0) + offset + 7) % drivers.length]!;
        const bus = buses[(index + offset + 7) % buses.length]!;
        const id = await one(
          `INSERT INTO app.trips(schedule_id,departure_id,pattern_version_id,service_date,scheduled_at,assigned_driver_id,vehicle_id)
           VALUES ($1,$2,$3,$4::date,$4::date + $5::time, $6,$7)`,
          [schedule, departure, version, date, at, driver, bus],
        );
        // Days behind us already ran; today's morning is in progress. A run
        // has to pass through active on the way to completed, and started_at is
        // immutable once it is set, so this is two steps rather than one write.
        if (offset < 0) {
          await q(
            "UPDATE app.trips SET status='active',started_at=$2::date + $3::time WHERE id=$1",
            [id, date, at],
          );
          await q(
            `UPDATE app.trips SET status='completed',
               completed_at=$2::date + $3::time + interval '52 minutes' WHERE id=$1`,
            [id, date, at],
          );
        } else if (offset === 0 && direction === 'outbound')
          await q(
            "UPDATE app.trips SET status='active',started_at=clock_timestamp() - interval '20 minutes' WHERE id=$1",
            [id],
          );
        trips++;
      }
    }
  }

  process.stdout.write(
    `Wrote ${CORRIDORS.length} corridors, ${buses.length} buses, ${trips} runs.\n\n`,
  );
  process.stdout.write('Driver logins (code / PIN), for the driver app:\n');
  for (const c of credentials) process.stdout.write(`  ${c.name.padEnd(16)} ${c.code}  ${c.pin}\n`);
  process.stdout.write(
    '\nThese PINs are shown once and are not recoverable: the table stores only a\n' +
      'keyed hash. Reset one through ops if it is lost.\n',
  );
}

try {
  await main();
} finally {
  await pool.end();
}
