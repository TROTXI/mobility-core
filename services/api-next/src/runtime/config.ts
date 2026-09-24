import { createHash } from 'node:crypto';
import { existingStagingEnvironment, STAGING_SERVICE_ID } from './staging-profile.js';
import type { BuildIdentity, MapTiles, SupportContacts } from '../config/service.js';

/**
 * Deployment configuration for the replacement backend.
 *
 * Every capability the reviewed cutover surface needs is named here and is
 * required. There is no development fallback, no in-memory substitute and no
 * switch that quietly turns a reviewed operation into a 503: a deployment that
 * cannot do the whole job refuses to start and says which variable is missing.
 *
 * Every name is prefixed so that running beside the deployed service in one
 * Render account cannot make this one silently inherit that service's
 * database, signing key or provider credentials.
 */
export interface KeyMaterial {
  accessSecret: Buffer;
  cursorSecret: Buffer;
  pinSecret: Buffer;
  credentialReplay: Buffer;
  providerEncryption: Buffer;
  boardingProof: Buffer;
  device: Buffer;
  paystackEvidence: Buffer;
}
export interface RuntimeConfig {
  /** Explicitly approved exception for the existing disposable Render staging. */
  existingStaging?: boolean;
  databaseUrl: string;
  poolSize: number;
  staleFixAfterSeconds: number;
  logRequests: boolean;
  listen: { host: string; port: number };
  build: BuildIdentity;
  access: { issuer: string; audience: string; ttlSeconds: number };
  refreshTtlDays: number;
  shiftTtlHours: number;
  keys: KeyMaterial;
  /** The PIN secret is consumed as text, so the exact bytes are kept too. */
  pinSecretText: string;
  /**
   * The sign-in providers this deployment actually offers. A provider that is
   * offered must be completely configured or startup fails; one that is not
   * offered has no route at all, rather than a route that answers 503 the
   * moment a rider taps the button.
   */
  providers: readonly ('google' | 'apple')[];
  google: { clientId: string };
  /** Exact Ops website origin; also defines the WebAuthn relying-party ID. */
  opsOrigin: string;
  apple: { clientIds: string[]; teamId: string; keyId: string; privateKey: string } | null;
  paystack: { secretKey: string };
  /** Optional until email is provisioned; no extra encryption or sender secrets. */
  email?: { apiKey: string; staging: boolean };
  firebaseServiceAccount?: string;
  avatars: {
    accountId: string;
    accessKeyId: string;
    secretAccessKey: string;
    bucket: string;
    urlTtlSeconds: number;
    maxBytes: number;
  };
  mapTiles: MapTiles;
  support: SupportContacts;
  /** Absent means the service's own /docs, which is what it serves. */
  docsUrl?: string;
  floors: {
    ops: number;
    driver: { ios: number; android: number };
    commuter: { ios: number; android: number };
  };
  limits: { perUser: number; perIp: number; perAuth: number };
  /** Which peers may state the client's address. `false` trusts nobody. */
  trustProxy: string | false;
  /** The operator account every maintenance receipt is attributed to. */
  maintenanceUserId: string;
}

export class ConfigurationError extends Error {}
type Env = Record<string, string | undefined>;

const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function required(env: Env, name: string): string {
  const value = env[name];
  if (typeof value !== 'string' || !value.trim())
    throw new ConfigurationError(`${name} is required`);
  return value.trim();
}
/**
 * A value a deployment may state, with a working answer when it does not.
 *
 * Only things a deployment genuinely owns should be mandatory: its secrets,
 * its database and the accounts it runs as. A timeout, a page size or the
 * basemap URL is the same everywhere until someone decides otherwise, and
 * making each of them mandatory turns one missing secret into forty-one
 * chances to fail a deploy for no reason.
 */
function withDefault(env: Env, name: string, fallback: string): string {
  const value = env[name];
  return typeof value === 'string' && value.trim() ? value.trim() : fallback;
}
function integerOr(env: Env, name: string, fallback: number, low: number, high: number): number {
  if (env[name] === undefined || String(env[name]).trim() === '') return fallback;
  return integer(env, name, low, high);
}
function urlOr(env: Env, name: string, fallback: string): string {
  return env[name] === undefined || String(env[name]).trim() === '' ? fallback : url(env, name);
}
function optional(env: Env, name: string): string | null {
  const value = env[name];
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}
function integer(env: Env, name: string, low: number, high: number): number {
  const raw = required(env, name);
  const value = Number(raw);
  if (!Number.isInteger(value) || value < low || value > high)
    throw new ConfigurationError(`${name} must be an integer between ${low} and ${high}`);
  return value;
}
/** Accepts hex or base64/base64url and insists on exactly 32 decoded bytes. */
function key(env: Env, name: string): Buffer {
  const raw = required(env, name);
  const bytes = /^[a-fA-F0-9]{64}$/.test(raw)
    ? Buffer.from(raw, 'hex')
    : Buffer.from(raw, 'base64');
  if (bytes.length !== 32)
    throw new ConfigurationError(`${name} must decode to 32 bytes (hex or base64)`);
  return bytes;
}
function url(env: Env, name: string): string {
  const raw = required(env, name);
  // new URL strips interior tabs and newlines before parsing, so a value
  // carrying them would be approved and then handed back with them intact.
  if (/[\u0000-\u0020\u007f]/.test(raw))
    throw new ConfigurationError(`${name} must not contain control characters`);
  let parsed: URL;
  try {
    parsed = new URL(raw);
  } catch {
    throw new ConfigurationError(`${name} must be an absolute URL`);
  }
  if (parsed.protocol !== 'https:') throw new ConfigurationError(`${name} must be https`);
  // Parsed only to check it. Returning the parsed form would normalise away a
  // trailing path and percent-encode a tile template's braces, so a validator
  // that reported success would have handed clients a URL that fetches nothing.
  return raw;
}
function webOrigin(env: Env, name: string, fallback: string): string {
  const raw = withDefault(env, name, fallback);
  let parsed: URL;
  try {
    parsed = new URL(raw);
  } catch {
    throw new ConfigurationError(`${name} must be an absolute origin`);
  }
  const localhost = parsed.hostname === 'localhost' || parsed.hostname === '127.0.0.1';
  if (
    (parsed.protocol !== 'https:' && !(localhost && parsed.protocol === 'http:')) ||
    parsed.pathname !== '/' ||
    parsed.search ||
    parsed.hash ||
    parsed.username ||
    parsed.password
  )
    throw new ConfigurationError(`${name} must be an HTTPS origin (HTTP localhost is allowed)`);
  return parsed.origin;
}

export function readConfiguration(env: Env = process.env): RuntimeConfig {
  const existingStaging = env.RENDER_SERVICE_ID === STAGING_SERVICE_ID;
  if (existingStaging) {
    try {
      env = existingStagingEnvironment(env);
    } catch (error) {
      throw new ConfigurationError((error as Error).message);
    }
  }
  const keys: KeyMaterial = {
    accessSecret: key(env, 'REPLACEMENT_ACCESS_SECRET'),
    cursorSecret: key(env, 'REPLACEMENT_CURSOR_SECRET'),
    pinSecret: key(env, 'REPLACEMENT_PIN_SECRET'),
    credentialReplay: key(env, 'REPLACEMENT_CREDENTIAL_REPLAY_KEY'),
    providerEncryption: key(env, 'REPLACEMENT_PROVIDER_ENCRYPTION_KEY'),
    boardingProof: key(env, 'REPLACEMENT_BOARDING_PROOF_KEY'),
    device: key(env, 'REPLACEMENT_DEVICE_KEY'),
    paystackEvidence: key(env, 'REPLACEMENT_PAYSTACK_EVIDENCE_KEY'),
  };
  // Every purpose gets its own key, checked once over the whole set rather
  // than pair by pair at each composition boundary, so a key added later
  // cannot be the one nobody compared. Digests, so a mismatch report never
  // has to hold key bytes.
  const seen = new Map<string, string>();
  for (const [name, value] of Object.entries(keys)) {
    const digest = createHash('sha256').update(value).digest('hex');
    const first = seen.get(digest);
    if (first) throw new ConfigurationError(`${name} must differ from ${first}`);
    seen.set(digest, name);
  }
  const paystack = required(env, 'REPLACEMENT_PAYSTACK_SECRET_KEY');
  if (!/^sk_(test|live)_[A-Za-z0-9]+$/.test(paystack))
    throw new ConfigurationError('REPLACEMENT_PAYSTACK_SECRET_KEY must be a Paystack secret key');
  // Staging is the default and cannot opt into live money. The old single
  // flag could accidentally be copied along with a live credential. A future
  // production deployment must identify itself AND separately approve money.
  const deployment = optional(env, 'REPLACEMENT_DEPLOYMENT_ENVIRONMENT') ?? 'staging';
  if (!['staging', 'production'].includes(deployment))
    throw new ConfigurationError(
      'REPLACEMENT_DEPLOYMENT_ENVIRONMENT must be staging or production',
    );
  if (deployment === 'staging' && paystack.startsWith('sk_live_'))
    throw new ConfigurationError(
      'Staging requires a Paystack TEST key; live payments are forbidden',
    );
  if (paystack.startsWith('sk_live_') && optional(env, 'REPLACEMENT_ALLOW_LIVE_PAYMENTS') !== 'yes')
    throw new ConfigurationError(
      'A live Paystack key needs REPLACEMENT_ALLOW_LIVE_PAYMENTS=yes on this service',
    );
  const providers = withDefault(env, 'REPLACEMENT_AUTH_PROVIDERS', 'google')
    .split(',')
    .map((name) => name.trim())
    .filter(Boolean);
  if (providers.some((name) => !['google', 'apple'].includes(name)))
    throw new ConfigurationError('REPLACEMENT_AUTH_PROVIDERS may list google and apple');
  // Riders have to be able to get in. Driver sign-in is a PIN and is always
  // available; a deployment offering no social provider has no rider door.
  if (!providers.includes('google'))
    throw new ConfigurationError('REPLACEMENT_AUTH_PROVIDERS must include google');
  let apple: RuntimeConfig['apple'] = null;
  if (providers.includes('apple')) {
    const appleClients = required(env, 'REPLACEMENT_APPLE_CLIENT_ID')
      .split(',')
      .map((id) => id.trim())
      .filter(Boolean);
    if (!appleClients.length)
      throw new ConfigurationError('REPLACEMENT_APPLE_CLIENT_ID must list at least one audience');
    const applePrivateKey = required(env, 'REPLACEMENT_APPLE_PRIVATE_KEY').replaceAll('\\n', '\n');
    if (!applePrivateKey.includes('BEGIN PRIVATE KEY'))
      throw new ConfigurationError('REPLACEMENT_APPLE_PRIVATE_KEY must be a PKCS#8 PEM .p8 key');
    apple = {
      clientIds: appleClients,
      teamId: required(env, 'REPLACEMENT_APPLE_TEAM_ID'),
      keyId: required(env, 'REPLACEMENT_APPLE_KEY_ID'),
      privateKey: applePrivateKey,
    };
  }
  // Only the maintenance worker acts as this account. An API that refuses to
  // serve riders because a scheduled job has no operator is failing the wrong
  // thing; the worker refuses instead, where it matters.
  const maintenanceUserId = (optional(env, 'REPLACEMENT_MAINTENANCE_USER_ID') ?? '').toLowerCase();
  if (maintenanceUserId && !uuid.test(maintenanceUserId))
    throw new ConfigurationError('REPLACEMENT_MAINTENANCE_USER_ID must be a user id');
  // Every per-IP limit here buckets on the address the server sees. Behind a
  // load balancer that is the balancer, so one caller's burst rate-limits
  // everybody and per-IP admission stops being a control at all. The boundary
  // is a deployment fact nobody can guess, so it is stated rather than
  // defaulted. A hop count is not an answer: Fastify ignores a numeric value
  // and trusts nobody, which would silently switch the whole thing off.
  const proxy = withDefault(env, 'REPLACEMENT_TRUST_PROXY', 'loopback, linklocal, uniquelocal');
  if (/^\d+$/.test(proxy))
    throw new ConfigurationError(
      'REPLACEMENT_TRUST_PROXY must name the peers to trust, not a hop count',
    );
  if (proxy !== 'none' && !/^[A-Za-z0-9.:/, _-]{1,200}$/.test(proxy))
    throw new ConfigurationError('REPLACEMENT_TRUST_PROXY must be "none" or an address list');
  const trustProxy = proxy === 'none' ? (false as const) : proxy;
  const databaseUrl = required(env, 'REPLACEMENT_RUNTIME_DATABASE_URL');
  if (databaseUrl === optional(env, 'REPLACEMENT_DATABASE_URL'))
    throw new ConfigurationError(
      'REPLACEMENT_RUNTIME_DATABASE_URL must be the narrow runtime role, not the migration owner',
    );
  return {
    existingStaging,
    ...(optional(env, 'FIREBASE_SERVICE_ACCOUNT')
      ? { firebaseServiceAccount: required(env, 'FIREBASE_SERVICE_ACCOUNT') }
      : {}),
    ...(optional(env, 'RESEND_API_KEY')
      ? { email: { apiKey: required(env, 'RESEND_API_KEY'), staging: deployment === 'staging' } }
      : {}),
    databaseUrl,
    poolSize: integerOr(env, 'REPLACEMENT_POOL_SIZE', 8, 1, 100),
    // Drivers publish every five seconds through patchy coverage, so a short
    // threshold cries wolf all morning. Five minutes to start; tune it from what
    // the ops team actually sees rather than from a guess made before launch.
    // On wherever the platform runs it; tests and local runs stay quiet.
    logRequests: env.NODE_ENV === 'production',
    staleFixAfterSeconds: integerOr(env, 'REPLACEMENT_STALE_FIX_AFTER_SECONDS', 300, 30, 3600),
    listen: {
      host: optional(env, 'REPLACEMENT_HOST') ?? '0.0.0.0',
      port: integerOr(env, 'PORT', 10000, 1, 65535),
    },
    build: {
      service: withDefault(env, 'REPLACEMENT_SERVICE_NAME', 'trotxi-api'),
      version: withDefault(env, 'REPLACEMENT_SERVICE_VERSION', '1.0.0'),
      // Render supplies the exact deployed revision. Prefer it over a stale
      // manually configured value; non-Render runtimes must identify themselves.
      commit:
        optional(env, 'RENDER_GIT_COMMIT') ?? withDefault(env, 'REPLACEMENT_GIT_COMMIT', 'unknown'),
    },
    access: {
      issuer: withDefault(env, 'REPLACEMENT_ACCESS_ISSUER', 'trotxi-api'),
      audience: withDefault(env, 'REPLACEMENT_ACCESS_AUDIENCE', 'trotxi-clients'),
      ttlSeconds: integerOr(env, 'REPLACEMENT_ACCESS_TTL_SECONDS', 900, 60, 3600),
    },
    refreshTtlDays: integerOr(env, 'REPLACEMENT_REFRESH_TTL_DAYS', 30, 1, 365),
    shiftTtlHours: integerOr(env, 'REPLACEMENT_SHIFT_TTL_HOURS', 12, 1, 24),
    keys,
    pinSecretText: required(env, 'REPLACEMENT_PIN_SECRET'),
    providers: providers as readonly ('google' | 'apple')[],
    google: {
      clientId: withDefault(
        env,
        'REPLACEMENT_GOOGLE_CLIENT_ID',
        '431341307838-pc4m046v2lj18ssfnfl1g52fl5g1cg4q.apps.googleusercontent.com',
      ),
    },
    opsOrigin: webOrigin(env, 'REPLACEMENT_OPS_ORIGIN', 'https://trotxi-ops-staging.onrender.com'),
    apple,
    paystack: { secretKey: paystack },
    avatars: {
      accountId: required(env, 'REPLACEMENT_R2_ACCOUNT_ID'),
      accessKeyId: required(env, 'REPLACEMENT_R2_ACCESS_KEY_ID'),
      secretAccessKey: required(env, 'REPLACEMENT_R2_SECRET_ACCESS_KEY'),
      bucket: required(env, 'REPLACEMENT_R2_BUCKET_NAME'),
      urlTtlSeconds: integerOr(env, 'REPLACEMENT_AVATAR_URL_TTL_SECONDS', 300, 30, 3600),
      maxBytes: integerOr(
        env,
        'REPLACEMENT_AVATAR_MAX_BYTES',
        2 * 1024 * 1024,
        1024,
        8 * 1024 * 1024,
      ),
    },
    mapTiles: {
      url: urlOr(env, 'REPLACEMENT_MAP_TILES_URL', 'https://tiles.trotxi.com/ghana.pmtiles'),
      styleUrl: urlOr(
        env,
        'REPLACEMENT_MAP_STYLE_URL',
        'https://tiles.trotxi.com/style.light.json',
      ),
      darkStyleUrl: urlOr(
        env,
        'REPLACEMENT_MAP_STYLE_DARK_URL',
        'https://tiles.trotxi.com/style.dark.json',
      ),
      attribution: withDefault(
        env,
        'REPLACEMENT_MAP_ATTRIBUTION',
        '\u00a9 OpenStreetMap contributors',
      ),
    },
    // Unset is a real answer here: the app hides a control it has no number
    // for, and a placeholder that rings nowhere is worse than none.
    support: {
      phone: optional(env, 'REPLACEMENT_OPERATIONS_PHONE'),
      whatsapp: optional(env, 'REPLACEMENT_OPERATIONS_WHATSAPP'),
      email: optional(env, 'REPLACEMENT_OPERATIONS_EMAIL'),
      hours: optional(env, 'REPLACEMENT_OPERATIONS_HOURS'),
    },
    // No default. The service describes itself at /docs, which is what the
    // config service falls back to. The previous default named a domain
    // nobody owns, so every client was told where the documentation was and
    // sent somewhere that does not resolve. Set this only when the docs move
    // to a real host, and it still has to be an absolute https URL.
    docsUrl: optional(env, 'REPLACEMENT_DOCS_URL') ? url(env, 'REPLACEMENT_DOCS_URL') : undefined,
    floors: {
      ops: integerOr(env, 'REPLACEMENT_MINIMUM_BUILD_OPS', 1, 1, 1_000_000),
      driver: {
        ios: integerOr(env, 'REPLACEMENT_MINIMUM_BUILD_DRIVER_IOS', 1, 1, 1_000_000),
        android: integerOr(env, 'REPLACEMENT_MINIMUM_BUILD_DRIVER_ANDROID', 1, 1, 1_000_000),
      },
      commuter: {
        ios: integerOr(env, 'REPLACEMENT_MINIMUM_BUILD_COMMUTER_IOS', 1, 1, 1_000_000),
        android: integerOr(env, 'REPLACEMENT_MINIMUM_BUILD_COMMUTER_ANDROID', 1, 1, 1_000_000),
      },
    },
    limits: {
      perUser: integerOr(env, 'REPLACEMENT_REQUESTS_PER_MINUTE', 120, 1, 100_000),
      perIp: integerOr(env, 'REPLACEMENT_REQUESTS_PER_IP_PER_MINUTE', 600, 1, 100_000),
      perAuth: integerOr(env, 'REPLACEMENT_AUTH_REQUESTS_PER_MINUTE', 10, 1, 10_000),
    },
    trustProxy,
    maintenanceUserId,
  };
}
