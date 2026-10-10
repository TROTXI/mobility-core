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
  const [unavailable, setUnavailable] = useState(false);
  const [error, setError] = useState('');
  const valid = /^[A-Za-z0-9_-]{43}$/.test(linkToken);
  return (
    <main className="auth-page auth-simple email-access-page">
      <div className="auth-layout">
        <section className="auth-card">
          <div className="auth-logo" role="img" aria-label="Trotxi">
            <img className="logo-light" src="/trotxi-wordmark-light.png" alt="" />
            <img className="logo-dark" src="/trotxi-wordmark-dark.png" alt="" />
          </div>
          <h1>
            {unavailable
              ? 'Link already used or expired'
              : contactOnly
                ? done
                  ? 'Email verified'
                  : 'Verify your email'
                : done
                  ? 'Password saved'
                  : 'Set your commuter password'}
          </h1>
          {done ? (
            <div role="status">
              <span className="email-access-check" aria-hidden="true">
                ✓
              </span>
              <p>
                {contactOnly
                  ? 'Your contact email is verified for account recovery and important updates. Close this tab and return to the Trotxi app. You do not need to use this link again.'
                  : 'Your password is saved. Close this tab, return to the Trotxi app and sign in with your phone number and new password. Previous sessions have been signed out.'}
              </p>
            </div>
          ) : unavailable ? (
            <p role="alert">
              If you just verified successfully, no further action is needed. Close this tab and
              return to Trotxi. If the app still shows your email as unverified, request a fresh
              link from Profile.
            </p>
          ) : !valid ? (
            <p>This link is incomplete. Request a new email from the Trotxi app.</p>
          ) : contactOnly ? (
            <form
              className="email-access-form"
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
                  if (result.error?.error.code === 'invalid_email_link') setUnavailable(true);
                  else if (result.error) setError(result.error.error.message);
                  else setDone(true);
                } catch {
                  setError('Could not connect. Please try again.');
                } finally {
                  setBusy(false);
                }
              }}
            >
              <p>
                Confirm this address for account recovery and important updates. This link works
                once.
              </p>
              {error && <p role="alert">{error}</p>}
              <Button appearance="primary" type="submit" disabled={busy}>
                {busy ? 'Verifying...' : 'Verify email'}
              </Button>
            </form>
          ) : (
            <form
              className="email-access-form"
              onSubmit={async (e) => {
                e.preventDefault();
                if (busy) return;
                if (
                  [...password].length < 12 ||
                  password.length > 128 ||
                  !/[A-Z]/.test(password) ||
                  !/[0-9]/.test(password) ||
                  !/[\x21-\x2f\x3a-\x40\x5b-\x60\x7b-\x7e]/.test(password) ||
                  password !== confirm
                ) {
                  setError(
                    'Use 12 to 128 characters with a capital letter, number and symbol. Enter the same password twice.',
                  );
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
                    if (result.error.error.code === 'invalid_email_link') setUnavailable(true);
                    else setError(result.error.error.message);
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
              <p>
                Use 12 to 128 characters with a capital letter, number and symbol. Choose a unique
                password.
              </p>
              <label htmlFor="new-password">New password</label>
              <input
                id="new-password"
                type="password"
                autoComplete="new-password"
                required
                minLength={12}
                maxLength={128}
                value={password}
                disabled={busy}
                onChange={(e) => setPassword(e.target.value)}
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
              />
              {error && <p role="alert">{error}</p>}
              <Button appearance="primary" type="submit" disabled={busy}>
                {busy ? 'Saving...' : 'Save password'}
              </Button>
            </form>
          )}
        </section>
      </div>
    </main>
  );
}
