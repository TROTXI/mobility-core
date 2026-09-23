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
import { hkdfSync } from 'node:crypto';
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
/** GHS 4.50 a ride at a 1.0 multiplier. Placeholders until real fares land. */
const FARE_PESEWAS = 450;
const MULTIPLIER_BP = 10000;
const DRIVERS = ['Kwame Mensah', 'Ama Boateng', 'Yaw Owusu', 'Akosua Darko', 'Kofi Asante'];
/** Three days behind, today, three ahead: history to look at and runs to drive. */
const DAYS = [-3, -2, -1, 0, 1, 2, 3];

// A hosted database refuses a plaintext connection, and pg sends one unless
// the URL says otherwise. Anything explicit in the URL wins; no-verify is the
// honest default for a one-off admin connection with no root for the
// certificate chain.
const connection = new URL(url);
if (
  !connection.searchParams.has('sslmode') &&
  !['localhost', '127.0.0.1', '[::1]'].includes(connection.hostname)
)
  connection.searchParams.set('sslmode', 'no-verify');

const pool = new pg.Pool({ connectionString: connection.href, max: 4 });
const q = async <T extends pg.QueryResultRow = pg.QueryResultRow>(sql: string, v: unknown[] = []) =>
  (await pool.query<T>(sql, v)).rows;
const one = async (sql: string, v: unknown[] = []) =>
  (await q<{ id: string }>(sql + ' RETURNING id', v))[0]!.id;
/**
 * Several of the schema's checks are CONSTRAINT TRIGGERs deferred to commit: a
 * commute selection is judged once its legs are in, not as each row lands. So
 * anything the schema judges as a unit has to arrive as one transaction, or it
 * is validated half-built and refused.
 */
async function tx<T>(
  work: (
    cq: (sql: string, v?: unknown[]) => Promise<pg.QueryResultRow[]>,
    cone: (sql: string, v?: unknown[]) => Promise<string>,
  ) => Promise<T>,
): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const cq = async (sql: string, v: unknown[] = []) => (await client.query(sql, v)).rows;
    const cone = async (sql: string, v: unknown[] = []) =>
      ((await client.query(sql + ' RETURNING id', v)).rows[0] as { id: string }).id;
    const result = await work(cq, cone);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}
const day = (offset: number) => new Date(Date.now() + offset * 86400000).toISOString().slice(0, 10);

/**
 * Attach real Google subjects to accounts that are already seeded.
 *
 * Separated from the seed so choosing not to supply subjects on the day does
 * not cost a wipe later: sign-in resolves a user by (provider, subject), so
 * swapping a synthetic subject for a real one is all it takes to make that
 * account reachable. The first subject takes the operations account, which is
 * the ops console login; the rest take riders in the order they were created.
 */
async function link(subjects: string[]): Promise<void> {
  const targets = await q<{ id: string; role: string; display_name: string }>(
    `SELECT id, role, display_name FROM app.users
     WHERE role IN ('admin','commuter') AND deleted_at IS NULL
     ORDER BY role, created_at`,
  );
  if (!targets.length) throw new Error('Nothing seeded here yet. Run the seed first.');
  if (subjects.length > targets.length)
    throw new Error(`${subjects.length} subjects for ${targets.length} accounts`);
  for (const [index, subject] of subjects.entries()) {
    const target = targets[index]!;
    // A subject already used by another account would collide on the unique
    // index, so say which rather than let Postgres name a constraint.
    const held = await q<{ id: string }>(
      "SELECT user_id AS id FROM app.auth_identities WHERE provider='google' AND subject=$1",
      [subject],
    );
    if (held.length && held[0]!.id !== target.id)
      throw new Error(`That subject already belongs to another account: ${subject.slice(0, 8)}...`);
    await q("UPDATE app.auth_identities SET subject=$2 WHERE user_id=$1 AND provider='google'", [
      target.id,
      subject,
    ]);
    process.stdout.write(`  linked ${target.role.padEnd(9)} ${target.display_name}\n`);
  }
  process.stdout.write(`\n${subjects.length} account(s) can now sign in.\n`);
}

/**
 * Rewrite every driver PIN and prove the result against the live service.
 *
 * The hash is a keyed HMAC under a secret this script derives the same way the
 * service does. If the two derivations ever disagree the codes look right and
 * every sign-in fails, which is a miserable thing to debug from a phone. So
 * this does not report success on having written a row: it asks the running
 * service to accept one of the credentials it just wrote, and says plainly
 * whether it did.
 */
function pinSecretsFrom(jwt: string): { label: string; secret: string }[] {
  // The service derives its PIN secret from JWT_SECRET. Reading that value back
  // out of an API is lossy in ways that only show up when a hash disagrees: a
  // trailing newline survives in one place and is stripped in another. Rather
  // than assert which happened, offer each and let the service say.
  const derive = (ikm: string) =>
    Buffer.from(
      hkdfSync('sha256', ikm, 'trotxi:replacement:staging:v1', 'PIN_SECRET', 32),
    ).toString('base64');
  const seen = new Set<string>();
  return [
    { label: 'as read', value: jwt },
    { label: 'trimmed', value: jwt.trim() },
    { label: 'with a trailing newline', value: `${jwt}\n` },
    { label: 'trimmed, trailing newline', value: `${jwt.trim()}\n` },
  ]
    .filter((c) => !seen.has(c.value) && seen.add(c.value))
    .map((c) => ({ label: c.label, secret: derive(c.value) }));
}

async function signsIn(baseUrl: string, code: string, pin: string): Promise<boolean> {
  const response = await fetch(`${baseUrl}/v1/auth/driver`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-trotxi-client': 'driver',
      'x-trotxi-build': '1',
      'x-trotxi-platform': 'android',
    },
    body: JSON.stringify({ code, pin, ownDevice: false }),
  });
  return response.ok;
}

async function resetPins(baseUrl: string): Promise<void> {
  const rows = await q<{ driver_id: string; name: string; driver_code: string }>(
    `SELECT c.driver_id, d.name, c.driver_code
     FROM app.driver_credentials c JOIN app.drivers d ON d.id = c.driver_id
     WHERE d.archived_at IS NULL ORDER BY d.name`,
  );
  if (!rows.length) throw new Error('No driver credentials here. Run the seed first.');

  // Drivers seeded before this was understood have no linked user, and sign-in
  // refuses those before it looks at the PIN. Backfill rather than require a
  // wipe: the account carries the driver role the sign-in path checks for.
  const orphans = await q<{ id: string; name: string }>(
    'SELECT id, name FROM app.drivers WHERE user_id IS NULL AND archived_at IS NULL',
  );
  for (const orphan of orphans) {
    const account = await one("INSERT INTO app.users(role,display_name) VALUES ('driver',$1)", [
      orphan.name,
    ]);
    await q('UPDATE app.drivers SET user_id=$2 WHERE id=$1', [orphan.id, account]);
  }
  if (orphans.length)
    process.stdout.write(`Linked ${orphans.length} driver(s) that had no account.\n`);

  // The service inherits JWT_SECRET from an env group, and the service env-vars
  // endpoint returns only what is set directly on the service. So every value
  // found across both is offered here, and one driver is the probe: find the
  // derivation the service verifies with before rewriting the rest under a
  // secret that might be wrong.
  const supplied = (process.env.SEED_JWT_SECRETS ?? '')
    .split('\n')
    .map((value) => value.replace(/\r$/, ''))
    .filter(Boolean);
  const candidates = supplied.length
    ? supplied.flatMap((value, index) =>
        pinSecretsFrom(value).map((c) => ({ ...c, label: `secret ${index + 1}, ${c.label}` })),
      )
    : [{ label: 'supplied', secret: pinSecret! }];
  const first = rows[0]!;
  let agreed: { label: string; secret: string } | null = null;
  for (const candidate of candidates) {
    const pin = generatePin();
    await q('UPDATE app.driver_credentials SET pin_hash=$2 WHERE driver_id=$1', [
      first.driver_id,
      hashDriverPin(pin, candidate.secret),
    ]);
    if (await signsIn(baseUrl, first.driver_code, pin)) {
      agreed = candidate;
      process.stdout.write(`The service verifies with JWT_SECRET ${candidate.label}.\n`);
      break;
    }
    process.stdout.write(`  not ${candidate.label}\n`);
  }
  if (!agreed)
    throw new Error(
      `None of the ${candidates.length} derivations were accepted. The service starts from a ` +
        `JWT_SECRET this workflow never read.`,
    );

  const issued: { name: string; code: string; pin: string }[] = [];
  for (const row of rows) {
    const pin = generatePin();
    await q(
      `UPDATE app.driver_credentials
       SET pin_hash=$2, must_change_pin=false, failed_attempts=0, locked_until=NULL,
           pin_version=pin_version+1, pin_set_at=clock_timestamp(), updated_at=clock_timestamp()
       WHERE driver_id=$1`,
      [row.driver_id, hashDriverPin(pin, agreed.secret)],
    );
    issued.push({ name: row.name, code: row.driver_code, pin });
  }

  process.stdout.write('\nDriver logins (code / PIN):\n');
  for (const one of issued)
    process.stdout.write(`  ${one.name.padEnd(16)} ${one.code}  ${one.pin}\n`);

  // Prove the set that was actually handed over, not the probe.
  const last = issued.at(-1)!;
  if (!(await signsIn(baseUrl, last.code, last.pin)))
    throw new Error(`The service refused ${last.code} after agreeing on the derivation.`);
  process.stdout.write(`\nThe service accepted ${last.code}. These PINs work.\n`);
}

/**
 * Give every signed-in commuter who has no membership the same history a
 * seeded rider has, so a real Google account can walk the whole journey.
 */
async function enroll(): Promise<void> {
  // Print who is actually in there before touching anything. Every run so far
  // has turned on a question this answers: which account is which, and whether
  // the one we mean already has a membership.
  const roster = await q<{
    id: string;
    name: string;
    email: string | null;
    memberships: number;
    providers: string | null;
  }>(
    `SELECT u.id, COALESCE(u.display_name, 'Rider') AS name, u.email,
       count(DISTINCT m.id)::int AS memberships,
       string_agg(DISTINCT i.provider, ',') AS providers
     FROM app.users u
     LEFT JOIN app.memberships m ON m.user_id = u.id
     LEFT JOIN app.auth_identities i ON i.user_id = u.id
     WHERE u.role = 'commuter' AND u.deleted_at IS NULL
     GROUP BY u.id
     ORDER BY u.created_at`,
  );
  process.stdout.write(`Commuters on staging (${roster.length}):\n`);
  for (const one of roster)
    process.stdout.write(
      `  ${one.name.padEnd(24)} ${(one.email ?? '(no email)').padEnd(32)}` +
        ` ${one.memberships} membership(s)  ${one.providers ?? 'no identity'}\n`,
    );

  const wanted = (process.env.SEED_ENROLL_EMAIL ?? '').trim().toLowerCase();
  let waiting = roster.filter((one) => one.memberships === 0);
  if (wanted) {
    const match = roster.find((one) => (one.email ?? '').toLowerCase() === wanted);
    if (!match) throw new Error(`No commuter on staging has the address ${wanted}.`);
    if (match.memberships > 0) {
      process.stdout.write(`\n${wanted} already has a membership. Nothing to do.\n`);
      return;
    }
    waiting = [match];
  }

  if (!waiting.length) {
    process.stdout.write(
      '\nEvery commuter already has a membership. Sign in with Google first, then run this.\n',
    );
    return;
  }
  process.stdout.write(`\nEnrolling ${waiting.length} account(s):\n`);
  for (const one of waiting)
    process.stdout.write(`  ${one.name}${one.email ? `  <${one.email}>` : ''}\n`);
  await riders(waiting);
  process.stdout.write('\nThey now have a membership, a commute and reservations to confirm.\n');
}

/**
 * Read one account's money state and say what the app would show for it.
 *
 * Every question so far has been "the app says zero, is that right", and
 * answering it meant guessing from the UI. This reproduces the arithmetic in
 * membership/service.ts exactly, so the numbers here are the numbers the app
 * renders, and the rows underneath say how they got there. Reads only.
 */
async function inspect(email: string): Promise<void> {
  const user = (
    await q<{
      id: string;
      role: string;
      display_name: string | null;
      email: string | null;
      created_at: Date;
      deleted_at: Date | null;
    }>(
      `SELECT id, role, display_name, email, created_at, deleted_at
       FROM app.users WHERE lower(email)=lower($1) ORDER BY created_at`,
      [email],
    )
  )[0];
  if (!user) {
    process.stdout.write(`No account on staging has the address ${email}.\n`);
    return;
  }
  const line = (label: string, value: unknown) =>
    process.stdout.write(`  ${label.padEnd(22)} ${value}\n`);

  process.stdout.write(`\n${user.display_name ?? '(no name)'}  <${user.email}>\n`);
  line('user id', user.id);
  line('role', user.role);
  line('created', user.created_at.toISOString().slice(0, 10));
  if (user.deleted_at) line('DELETED', user.deleted_at.toISOString());

  const providers = await q<{ provider: string }>(
    'SELECT provider FROM app.auth_identities WHERE user_id=$1',
    [user.id],
  );
  line('identities', providers.map((r) => r.provider).join(', ') || 'none');

  const membership = (
    await q<{ id: string; lifecycle: string }>(
      'SELECT id, lifecycle FROM app.memberships WHERE user_id=$1',
      [user.id],
    )
  )[0];
  line('membership', membership ? `${membership.id} (${membership.lifecycle})` : 'NONE');

  const purchases = await q<{
    id: string;
    state: string;
    plan: string;
    rides_granted: number;
    price_pesewas: number;
    applied_credit_pesewas: number;
  }>(
    `SELECT id, state, plan, rides_granted, price_pesewas, applied_credit_pesewas
     FROM app.purchases WHERE user_id=$1 ORDER BY created_at`,
    [user.id],
  );
  process.stdout.write(`\nPurchases (${purchases.length}):\n`);
  for (const p of purchases)
    process.stdout.write(
      `  ${p.state.padEnd(12)} ${p.plan.padEnd(8)} ${String(p.rides_granted).padStart(4)} rides` +
        `  price ${p.price_pesewas}  credit applied ${p.applied_credit_pesewas}\n`,
    );

  const attempts = await q<{ state: string; amount_pesewas: number; paid_at: Date | null }>(
    `SELECT state, amount_pesewas, paid_at FROM app.payment_attempts
     WHERE user_id=$1 ORDER BY created_at`,
    [user.id],
  );
  process.stdout.write(`\nPayment attempts (${attempts.length}):\n`);
  for (const a of attempts)
    process.stdout.write(
      `  ${a.state.padEnd(12)} ${a.amount_pesewas}` +
        `  paid ${a.paid_at ? a.paid_at.toISOString().slice(0, 10) : 'never'}\n`,
    );

  const periods = await q<{
    id: string;
    state: string;
    starts_at: Date;
    effective_ends_at: Date;
  }>(
    `SELECT id, state, starts_at, effective_ends_at FROM app.billing_periods
     WHERE user_id=$1 ORDER BY starts_at`,
    [user.id],
  );
  const now = new Date();
  process.stdout.write(`\nBilling periods (${periods.length}), now ${now.toISOString()}:\n`);
  for (const b of periods)
    process.stdout.write(
      `  ${b.state.padEnd(9)} ${b.starts_at.toISOString().slice(0, 10)}` +
        ` -> ${b.effective_ends_at.toISOString().slice(0, 10)}` +
        `${b.effective_ends_at > now ? '  (covers now)' : '  (ended)'}\n`,
    );

  // service.ts picks the open period, then treats it as current only while it
  // still covers now, or while a pause holds it open. Rides are summed against
  // that period alone, which is why an ended period reads as zero rides even
  // though the allocation row is still there.
  const open = periods.find((b) => b.state === 'open') ?? null;
  const pauses = await q<{ n: string }>(
    `SELECT count(*)::text AS n FROM app.membership_pauses
     WHERE period_id=$1 AND ended_at IS NULL`,
    [open?.id ?? null],
  );
  const paused = Number(pauses[0]?.n ?? 0) > 0;
  const current = open && (open.effective_ends_at > now || paused) ? open : null;

  const rides = await q<{ reason: string; total: string }>(
    `SELECT reason, sum(delta_rides)::text AS total FROM app.ride_entries
     WHERE user_id=$1 GROUP BY reason ORDER BY reason`,
    [user.id],
  );
  process.stdout.write('\nRide entries by reason (all periods):\n');
  for (const r of rides) line(r.reason, r.total);
  if (!rides.length) process.stdout.write('  none\n');

  const credits = await q<{ reason: string; total: string }>(
    `SELECT reason, sum(delta_pesewas)::text AS total FROM app.credit_entries
     WHERE user_id=$1 GROUP BY reason ORDER BY reason`,
    [user.id],
  );
  process.stdout.write('\nCredit entries by reason:\n');
  for (const r of credits) line(r.reason, r.total);
  if (!credits.length)
    process.stdout.write('  none, which is normal until a period closes with rides unspent\n');

  const totals = (
    await q<{ rides: string; credit: string; held: string }>(
      `SELECT coalesce((SELECT sum(delta_rides) FROM app.ride_entries WHERE period_id=$2),0)::text AS rides,
         coalesce((SELECT sum(delta_pesewas) FROM app.credit_entries WHERE user_id=$1),0)::text AS credit,
         coalesce((SELECT sum(amount_pesewas) FROM app.credit_holds WHERE user_id=$1 AND state='held'),0)::text AS held`,
      [user.id, current?.id ?? null],
    )
  )[0]!;

  const assignment = current
    ? await q<{ id: string }>(
        `SELECT id FROM app.commute_assignments
         WHERE period_id=$1 AND effective_from<=$2::date AND (effective_to IS NULL OR $2::date<effective_to)`,
        [current.id, now.toISOString().slice(0, 10)],
      )
    : [];

  process.stdout.write('\nWhat GET /v1/me/membership will report:\n');
  line('current period', current ? current.id : 'NONE (nothing covers now)');
  line('remainingRides', totals.rides);
  line('credit', `${totals.credit} pesewas`);
  line('heldCredit', `${totals.held} pesewas`);
  line('availableCredit', `${Number(totals.credit) - Number(totals.held)} pesewas`);
  line('assignment', assignment.length ? assignment[0]!.id : 'none');
  line(
    'canReserve',
    !!current && assignment.length > 0 && Number(totals.rides) > 0
      ? 'true'
      : 'false (needs a current period, an assignment and rides > 0)',
  );

  const reservations = await q<{ status: string; n: string }>(
    `SELECT status, count(*)::text AS n FROM app.reservations
     WHERE user_id=$1 GROUP BY status ORDER BY status`,
    [user.id],
  );
  process.stdout.write('\nReservations by status:\n');
  for (const r of reservations) line(r.status, r.n);
  if (!reservations.length) process.stdout.write('  none\n');
}

async function main() {
  const look = (process.env.SEED_INSPECT_EMAIL ?? '').trim();
  if (look) {
    await inspect(look);
    return;
  }
  if (process.env.SEED_ENROLL === 'yes') {
    await enroll();
    return;
  }
  if (process.env.SEED_RESET_PINS === 'yes') {
    const base = process.env.SEED_STAGING_URL;
    if (!base) throw new Error('SEED_STAGING_URL is required so the result can be proved');
    await resetPins(base.replace(/\/$/, ''));
    return;
  }
  const only = (process.env.SEED_LINK_SUBJECTS ?? '')
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean);
  if (process.env.SEED_LINK_ONLY === 'yes') {
    if (!only.length) throw new Error('SEED_LINK_SUBJECTS is required to link');
    process.stdout.write(`Linking ${only.length} Google subject(s) to seeded accounts:\n`);
    await link(only);
    return;
  }
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
    // Sign-in refuses a driver with no linked user before it ever checks the
    // PIN (auth/service.ts: `if (!match?.user_id)`), which is what the app
    // means by 'ask your operator to link your driver account'. So the account
    // is created here, carrying the driver role that path also requires.
    const account = await one("INSERT INTO app.users(role,display_name) VALUES ('driver',$1)", [
      name,
    ]);
    const id = await one(
      'INSERT INTO app.drivers(user_id,name,phone,license_number) VALUES ($1,$2,$3,$4)',
      [
        account,
        name,
        `+2332${Math.floor(10000000 + Math.random() * 89999999)}`,
        `GHA-${randomUUID().slice(0, 8).toUpperCase()}`,
      ],
    );
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
    `Wrote ${CORRIDORS.length} corridors, ${buses.length} buses, ${trips} runs, ` +
      `${await riders()} riders.\n\n`,
  );
  process.stdout.write('Driver logins (code / PIN), for the driver app:\n');
  for (const c of credentials) process.stdout.write(`  ${c.name.padEnd(16)} ${c.code}  ${c.pin}\n`);
  process.stdout.write(
    '\nThese PINs are shown once and are not recoverable: the table stores only a\n' +
      'keyed hash. Reset one through ops if it is lost.\n',
  );
}

/**
 * Twenty riders with a month behind them.
 *
 * A reservation is only meaningful at the end of a chain: a user owns a
 * membership, a membership is funded by a purchase, a purchase opens a billing
 * period, a period carries a commute assignment, and the assignment names the
 * two legs a rider travels. Every one of those is written here because the
 * schema refuses a reservation that skips any of them.
 *
 * Identities use synthetic Google subjects, so these riders are data and nobody
 * can sign in as them. Pass real subjects in SEED_LINK_SUBJECTS to make the
 * first few drivable from the commuter app: sign-in resolves a user by
 * (provider, subject), so a real subject on a seeded row signs that person in
 * as that rider, history and all.
 */
/**
 * Enrol riders: create them, or give existing accounts the same history.
 *
 * Passing `existing` is how a real person joins. They sign in with Google
 * first, which leaves a commuter with an identity and nothing else, and this
 * then hangs the whole chain off that account. The other direction, linking a
 * seeded rider to a real subject, only works before they ever sign in, because
 * afterwards the subject already belongs to the account they just made.
 */
async function riders(existing?: { id: string; name: string }[]): Promise<number> {
  const NAMES = [
    'Abena Osei',
    'Kojo Antwi',
    'Efua Mensah',
    'Kwesi Appiah',
    'Adjoa Nyarko',
    'Yaa Asantewaa',
    'Fiifi Quartey',
    'Esi Amoah',
    'Kobby Tetteh',
    'Maame Serwaa',
    'Nii Armah',
    'Akua Frimpong',
    'Kwabena Addo',
    'Afia Danso',
    'Kwaku Bediako',
    'Araba Aidoo',
    'Selorm Agbo',
    'Dzifa Kudjo',
    'Naa Lamiley',
    'Paa Kwesi Sam',
  ];
  const linked = (process.env.SEED_LINK_SUBJECTS ?? '')
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean);

  // Somebody has to be the actor behind an ops action, and the ops console
  // needs an account to sign into. The first subject supplied links this one,
  // so the console is reachable; riders take the rest.
  // Reused when enrolling, never duplicated: enroll runs this same function
  // against accounts that already exist, and a second operations account would
  // quietly take the next linked subject.
  const existingAdmin = (
    await q<{ id: string }>(
      "SELECT id FROM app.users WHERE role='admin' ORDER BY created_at LIMIT 1",
    )
  )[0];
  const admin =
    existingAdmin?.id ??
    (await tx(async (cq, cone) => {
      const id = await cone("INSERT INTO app.users(role,display_name) VALUES ('admin',$1)", [
        'Trotxi Operations',
      ]);
      await cq('INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,$2,$3)', [
        id,
        'google',
        linked[0] ?? `seed-ops-${randomUUID()}`,
      ]);
      return id;
    }));

  const routes = await q<{ id: string; name: string }>(
    'SELECT id,name FROM app.routes ORDER BY name',
  );
  // One selection per corridor, both legs, first stop to last. Riders share
  // these rather than each inventing their own pair.
  type Leg = {
    direction: 'outbound' | 'return';
    schedule: string;
    version: string;
    first: string;
    last: string;
  };
  // A purchase carries the same two legs its commute selection does, and the
  // schema validates both the same way, so they are gathered once here.
  const legsByRoute = new Map<string, Leg[]>();
  const selections: string[] = [];
  for (const route of routes) {
    const selection = await tx(async (cq, cone) => {
      const selection = await cone('INSERT INTO app.commute_selections(route_id) VALUES ($1)', [
        route.id,
      ]);
      for (const direction of ['outbound', 'return'] as const) {
        const leg = (
          await q<{ schedule: string; version: string; first: string; last: string }>(
            `SELECT sc.id AS schedule, sc.pattern_version_id AS version,
             (SELECT id FROM app.route_pattern_stops WHERE pattern_version_id=sc.pattern_version_id ORDER BY ordinal LIMIT 1) AS first,
             (SELECT id FROM app.route_pattern_stops WHERE pattern_version_id=sc.pattern_version_id ORDER BY ordinal DESC LIMIT 1) AS last
           FROM app.service_schedules sc
           JOIN app.route_patterns p ON p.id=sc.pattern_id
           WHERE p.route_id=$1 AND p.direction=$2`,
            [route.id, direction],
          )
        )[0]!;
        await cq(
          `INSERT INTO app.commute_selection_legs(selection_id,direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id)
         VALUES ($1,$2,$3,$4,$5,$6)`,
          [selection, direction, leg.schedule, leg.version, leg.first, leg.last],
        );
        legsByRoute.set(route.id, [
          ...(legsByRoute.get(route.id) ?? []),
          {
            direction,
            schedule: leg.schedule,
            version: leg.version,
            first: leg.first,
            last: leg.last,
          },
        ]);
      }
      return selection;
    });
    selections.push(selection);
  }

  // Mid-term rather than expiring: a reservation is only eligible while its
  // trip falls inside the period, so the window has to cover every seeded day.
  const periodStart = day(-20);
  const periodEnd = day(10);
  let count = 0;
  const skipped: string[] = [];
  const targets = existing
    ? existing.map((e, index) => ({ index, name: e.name, id: e.id as string | null }))
    : NAMES.map((name, index) => ({ index, name, id: null as string | null }));
  for (const { index, name, id: joining } of targets) {
    const route = routes[index % routes.length]!;
    const selection = selections[index % selections.length]!;
    const plan = index % 5 === 0 ? 'annual' : 'monthly';
    // Two in twenty have lapsed, which is what makes "lapsed" mean anything on
    // the ops riders screen. A real person joining is never one of them.
    const lapsed = !joining && (index === 7 || index === 15);

    await tx(async (q, one) => {
      // An account that already signed in keeps its own identity; a seeded one
      // gets a synthetic subject nobody can sign in with.
      const user =
        joining ??
        (await one("INSERT INTO app.users(role,display_name) VALUES ('commuter',$1)", [name]));
      if (!joining)
        await q('INSERT INTO app.auth_identities(user_id,provider,subject) VALUES ($1,$2,$3)', [
          user,
          'google',
          linked[index + 1] ?? `seed-${randomUUID()}`,
        ]);
      const membership = await one('INSERT INTO app.memberships(user_id) VALUES ($1)', [user]);
      const rides = plan === 'annual' ? 480 : 40;
      // The schema derives the price and refuses any other number:
      // floor((fare * rides * multiplier + 5000) / 10000). Computed from the
      // same fare and multiplier the insert below states, for the same reason
      // the stop distances are derived: a guessed figure is refused.
      const price = Math.floor((FARE_PESEWAS * rides * MULTIPLIER_BP + 5000) / 10000);
      const purchase = await one(
        `INSERT INTO app.purchases(membership_id,user_id,route_id,plan,state,price_pesewas,
           applied_credit_pesewas,cash_due_pesewas,currency,rides_granted,fare_pesewas,
           price_multiplier_bp,conversion_rate_pesewas,checkout_key_hash,input_hash)
         VALUES ($1,$2,$3,$4,'fulfilled',$5,0,$5,'GHS',$6,${FARE_PESEWAS},${MULTIPLIER_BP},50,
           encode(sha256($7::bytea),'hex'), encode(sha256($8::bytea),'hex'))`,
        [membership, user, route.id, plan, price, rides, `checkout:${user}`, `input:${user}`],
      );
      // The purchase carries the same paired legs as the selection, and the
      // schema refuses a purchase without them.
      for (const leg of legsByRoute.get(route.id) ?? [])
        await q(
          `INSERT INTO app.purchase_legs(purchase_id,direction,schedule_id,pattern_version_id,pickup_occurrence_id,dropoff_occurrence_id)
           VALUES ($1,$2,$3,$4,$5,$6)`,
          [purchase, leg.direction, leg.schedule, leg.version, leg.first, leg.last],
        );
      // A period only exists behind money that arrived. The schema requires a
      // successful attempt whose paid_at is exactly the period's start, so this
      // is not decoration: without it the period is refused.
      await q(
        `INSERT INTO app.payment_attempts(purchase_id,user_id,provider,environment,reference,
           state,amount_pesewas,currency,provider_transaction_id,channel,fees_pesewas,paid_at)
         VALUES ($1,$2,'paystack','test',$3,'successful',$4,'GHS',$5,'mobile_money',$6,$7::date)`,
        [
          purchase,
          user,
          `seed-${purchase}`,
          price,
          `seed-txn-${purchase}`,
          Math.round(price * 0.0195),
          periodStart,
        ],
      );
      const period = await one(
        `INSERT INTO app.billing_periods(purchase_id,membership_id,user_id,starts_at,original_ends_at,effective_ends_at,state)
         VALUES ($1,$2,$3,$4::date,$5::date,$5::date,$6)`,
        [
          purchase,
          membership,
          user,
          periodStart,
          lapsed ? day(-2) : periodEnd,
          lapsed ? 'closed' : 'open',
        ],
      );
      const assignment = await one(
        `INSERT INTO app.commute_assignments(user_id,membership_id,period_id,selection_id,purchase_id,effective_from)
         VALUES ($1,$2,$3,$4,$5,$6::date)`,
        [user, membership, period, selection, purchase, periodStart],
      );
      await q(
        "INSERT INTO app.ride_entries(user_id,period_id,reason,delta_rides) VALUES ($1,$2,'allocation',$3)",
        [user, period, rides],
      );
      // Credit only exists behind a recorded decision: the schema matches the
      // entry against its adjustment and refuses any other amount.
      if (index % 4 === 0) {
        const delta = 500 * ((index % 3) + 1);
        const adjustment = await one(
          `INSERT INTO app.credit_adjustments(user_id,actor_user_id,delta_pesewas,reason)
           VALUES ($1,$2,$3,'Seeded goodwill credit')`,
          [user, admin, delta],
        );
        await q(
          `INSERT INTO app.credit_entries(user_id,reason,delta_pesewas,adjustment_id)
           VALUES ($1,'adjustment',$2,$3)`,
          [user, delta, adjustment],
        );
      }

      // Reservations are what put a rider on a driver's manifest. Days behind
      // us are settled, mostly boarded with the occasional no-show; today and
      // ahead are reserved and still changeable. A lapsed rider stops at the
      // day their period closed.
      for (const offset of DAYS) {
        const date = day(offset);
        if (lapsed && offset >= -2) continue;
        for (const leg of legsByRoute.get(route.id) ?? []) {
          const trip = (
            await q(
              'SELECT id,status FROM app.trips WHERE schedule_id=$1 AND service_date=$2::date',
              [leg.schedule, date],
            )
          )[0] as { id: string; status: string } | undefined;
          if (!trip) continue;
          // Only runs that have not left. A boarded or no-show reservation is
          // receipt-backed: the schema requires a matching charge, and a charge
          // requires a boarding command. Seeding those would mean inventing
          // receipts for boardings that never happened, which puts fiction in
          // the audit trail the receipts exist to protect. Past runs therefore
          // carry no riders; the driver app produces real boardings by
          // scanning, which is better evidence than anything written here.
          if (trip.status !== 'scheduled') continue;
          // The guard refuses a seat when the bus is full AND when the run has
          // no bus at all, with the same message. Read both so the log says
          // which, and skip rather than lose the whole enrolment to one run.
          const seats = (
            await q(
              `SELECT v.capacity::int AS capacity,
                 (SELECT count(*)::int FROM app.reservations r
                   WHERE r.trip_id = t.id AND r.status IN ('reserved','boarded','no_show')) AS used
               FROM app.trips t
               LEFT JOIN app.vehicles v ON v.id = t.vehicle_id
               WHERE t.id = $1`,
              [trip.id],
            )
          )[0] as { capacity: number | null; used: number } | undefined;
          if (!seats || seats.capacity === null) {
            skipped.push(`${date} ${leg.direction} (no vehicle)`);
            continue;
          }
          if (seats.used >= seats.capacity) {
            skipped.push(`${date} ${leg.direction} (full ${seats.used}/${seats.capacity})`);
            continue;
          }
          await q(
            `INSERT INTO app.reservations(user_id,period_id,assignment_id,selection_id,direction,
               service_date,trip_id,schedule_id,pattern_version_id,pickup_occurrence_id,
               dropoff_occurrence_id,status,source,settled_at)
             VALUES ($1,$2,$3,$4,$5,$6::date,$7,$8,$9,$10,$11,$12,'confirmation',$13)`,
            [
              user,
              period,
              assignment,
              selection,
              leg.direction,
              date,
              trip.id,
              leg.schedule,
              leg.version,
              leg.first,
              leg.last,
              'reserved',
              null,
            ],
          );
        }
      }
    });
    count++;
  }
  if (skipped.length)
    process.stdout.write(
      `Skipped ${skipped.length} full run(s): ${[...new Set(skipped)].join(', ')}\n`,
    );
  if (linked.length)
    process.stdout.write(
      `Linked ${Math.min(linked.length, NAMES.length)} rider(s) to the Google subjects supplied.\n`,
    );
  return count;
}

try {
  await main();
} finally {
  await pool.end();
}
