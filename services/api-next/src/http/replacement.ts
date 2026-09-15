import { AuthService } from '../auth/service.js';
import type { AuthOptions } from '../auth/service.js';
import { createTransportApp } from './app.js';
import type { AppOptions } from './app.js';

// Composition boundary: no bearer-header test fallback, no stateless session
// shortcut. Still refuses startup without the real reservation coordinator.
// This is a factory, not deployment wiring or permission to start a listener.
export function createReplacementApp(
  options: Omit<AppOptions, 'auth' | 'verifyAccess' | 'authorizeSession'> & {
    identity: Omit<AuthOptions, 'pool' | 'cursorSecret'>;
  },
) {
  const auth = new AuthService({
    ...options.identity,
    pool: options.pool,
    cursorSecret: options.cursorSecret,
  });
  return createTransportApp({
    ...options,
    auth,
    verifyAccess: auth.tokens.verify,
    authorizeSession: auth.authorizeSession,
  });
}
