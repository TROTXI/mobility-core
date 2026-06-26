// Shared constants for the DB-backed e2e run. Imported by playwright.config.ts
// (to configure the server under test), global-setup.ts (to seed), and the specs
// (to mint matching tokens). Single source so the secret/user never drift apart.

/** Test-only signing secret; also passed to the API under test as JWT_SECRET. */
export const E2E_JWT_SECRET = 'e2e-only-secret-at-least-32-characters-0000';

/** Must match the API's JWT issuer/audience defaults (config/env.ts). */
export const JWT_ISSUER = 'trotxi';
export const JWT_AUDIENCE = 'trotxi-api';

/** A user seeded into the e2e database (fixed id so specs can mint its token). */
export const SEED_USER = {
  id: '00000000-0000-0000-0000-0000000000e2',
  displayName: 'E2E User',
  role: 'commuter' as const,
};
