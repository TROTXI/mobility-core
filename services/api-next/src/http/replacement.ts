import { AuthService } from '../auth/service.js';
import type { AuthOptions } from '../auth/service.js';
import { createTransportApp } from './app.js';
import type { AppOptions } from './app.js';
import { DriverService } from '../auth/driver-service.js';
import { BoardingService } from '../boarding/service.js';
import type { BoardingOptions } from '../boarding/service.js';

// Composition boundary: no bearer-header test fallback, no stateless session
// shortcut. Still refuses startup without the real reservation coordinator.
// This is a factory, not deployment wiring or permission to start a listener.
export function createReplacementApp(
  options: Omit<
    AppOptions,
    'auth' | 'drivers' | 'boarding' | 'verifyAccess' | 'authorizeSession'
  > & {
    identity: Omit<AuthOptions, 'pool' | 'cursorSecret'>;
    credentialReplayKey: Buffer;
    boarding?: Omit<BoardingOptions, 'pool' | 'authorizeSession'>;
  },
) {
  const auth = new AuthService({
    ...options.identity,
    pool: options.pool,
    cursorSecret: options.cursorSecret,
  });
  if (
    options.credentialReplayKey?.equals(Buffer.from(options.identity.access.secret)) ||
    options.credentialReplayKey?.equals(options.cursorSecret) ||
    options.credentialReplayKey?.equals(Buffer.from(options.identity.pinSecret)) ||
    (options.identity.providerEncryptionKey &&
      options.credentialReplayKey?.equals(options.identity.providerEncryptionKey))
  )
    throw new Error('Credential replay key must be separate from other application keys');
  const drivers = new DriverService({
    pool: options.pool,
    auth,
    pinSecret: options.identity.pinSecret,
    replayKey: options.credentialReplayKey,
    cursorSecret: options.cursorSecret,
  });
  if (
    options.boarding &&
    [
      Buffer.from(options.identity.access.secret),
      Buffer.from(options.identity.pinSecret),
      options.cursorSecret,
      options.credentialReplayKey,
      options.identity.providerEncryptionKey,
    ].some((key) => key && options.boarding!.proofKey?.equals(key))
  )
    throw new Error('Boarding proof key must be separate from other application keys');
  const boarding = options.boarding
    ? new BoardingService({
        ...options.boarding,
        pool: options.pool,
        authorizeSession: auth.authorizeSession,
      })
    : undefined;
  return createTransportApp({
    ...options,
    auth,
    drivers,
    boarding,
    verifyAccess: auth.tokens.verify,
    authorizeSession: auth.authorizeSession,
  });
}
