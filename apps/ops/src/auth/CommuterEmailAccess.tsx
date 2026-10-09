import { useState } from 'react';
import { Button } from '@fluentui/react-components';
import createClient from 'openapi-fetch';
import type { paths } from '../generated/api';
import { apiBaseUrl, opsHeaders } from '../api/session';

// Fragment secrets never reach the web server or enter persistent storage.
const fragment = typeof window === 'undefined' ? '' : window.location.hash.slice(1);
const linkToken = new URLSearchParams(fragment).get('token') ?? '';
const contactOnly = new URLSearchParams(fragment).get('purpose') === 'contact';
if (typeof window !== 'undefined' && window.location.pathname === '/account-access')
  window.history.replaceState(null, '', '/account-access');
const api = createClient<paths>({ baseUrl: apiBaseUrl });

export function CommuterEmailAccess() {
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState(false);
  const [error, setError] = useState('');
  const valid = /^[A-Za-z0-9_-]{43}$/.test(linkToken);
  return (
    <main className="auth-simple" style={{ maxWidth: 440, margin: '0 auto', padding: '64px 24px' }}>
      <div className="auth-logo" role="img" aria-label="Trotxi">
        <img className="logo-light" src="/trotxi-wordmark-light.png" alt="" />
        <img className="logo-dark" src="/trotxi-wordmark-dark.png" alt="" />
      </div>
      <h1>
        {contactOnly
          ? done
            ? 'Email verified'
            : 'Verify your email'
          : done
            ? 'Password saved'
            : 'Set your commuter password'}
      </h1>
      {done ? (
        <p>
          {contactOnly
            ? 'Your contact email is verified. Return to the Trotxi app.'
            : 'Return to the Trotxi app and sign in with your phone number and new password. Previous sessions have been signed out.'}
        </p>
      ) : !valid ? (
        <p>This link is incomplete. Request a new email from the Trotxi app.</p>
      ) : contactOnly ? (
        <form
          onSubmit={async (e) => {
            e.preventDefault();
            if (busy) return;
            setBusy(true);
            setError('');
            try {
              const result = await api.POST('/v1/auth/email/verify', {
                params: { header: opsHeaders },
                body: { token: linkToken },
              });
              if (result.error) setError(result.error.error.message);
              else setDone(true);
            } catch {
              setError('Could not connect. Please try again.');
            } finally {
              setBusy(false);
            }
          }}
        >
          <p>Confirm this address for account recovery and important updates.</p>
          {error && <p role="alert">{error}</p>}
          <Button appearance="primary" type="submit" disabled={busy}>
            {busy ? 'Verifying...' : 'Verify email'}
          </Button>
        </form>
      ) : (
        <form
          onSubmit={async (e) => {
            e.preventDefault();
            if (busy) return;
            if ([...password].length < 15 || password.length > 128 || password !== confirm) {
              setError('Use 15 to 128 characters and enter the same password twice.');
              return;
            }
            setBusy(true);
            setError('');
            try {
              // Public web recovery does not start an Ops session or read its tokens.
              const result = await api.POST('/v1/auth/email/complete', {
                params: { header: opsHeaders },
                body: { token: linkToken, password },
              });
              if (result.error) {
                setError(result.error.error.message);
                return;
              }
              setPassword('');
              setConfirm('');
              setDone(true);
            } catch {
              setError('Could not connect. Please try again.');
            } finally {
              setBusy(false);
            }
          }}
        >
          <p>Use a long, unique password or a password manager.</p>
          <label htmlFor="new-password">New password</label>
          <input
            id="new-password"
            type="password"
            autoComplete="new-password"
            required
            minLength={15}
            maxLength={128}
            value={password}
            disabled={busy}
            onChange={(e) => setPassword(e.target.value)}
            style={{ display: 'block', width: '100%', margin: '8px 0 20px', padding: 12 }}
          />
          <label htmlFor="confirm-password">Confirm password</label>
          <input
            id="confirm-password"
            type="password"
            autoComplete="new-password"
            required
            maxLength={128}
            value={confirm}
            disabled={busy}
            onChange={(e) => setConfirm(e.target.value)}
            style={{ display: 'block', width: '100%', margin: '8px 0 20px', padding: 12 }}
          />
          {error && <p role="alert">{error}</p>}
          <Button appearance="primary" type="submit" disabled={busy}>
            {busy ? 'Saving...' : 'Save password'}
          </Button>
        </form>
      )}
    </main>
  );
}
