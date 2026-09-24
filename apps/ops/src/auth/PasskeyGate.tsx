import { Button, MessageBar, MessageBarBody, Spinner } from '@fluentui/react-components';
import { startAuthentication, startRegistration } from '@simplewebauthn/browser';
import { useCallback, useEffect, useState, type ReactNode } from 'react';
import type { components } from '../generated/api';
import { opsHeaders } from '../api/session';
import { useAuth } from './AuthContext';

type Status = components['schemas']['PasskeyStatus'];

export function PasskeyGate({ children }: { children: ReactNode }) {
  const { session } = useAuth();
  const [status, setStatus] = useState<Status | null>(null);
  const [working, setWorking] = useState(false);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    const { data, error: responseError } = await session.client.GET('/v1/auth/passkeys', {
      params: { header: opsHeaders },
    });
    if (responseError) throw new Error(responseError.error.message);
    setStatus(data.data);
  }, [session]);

  useEffect(() => {
    void load().catch((value: Error) => setError(value.message));
  }, [load]);

  const verify = async () => {
    setWorking(true);
    setError('');
    try {
      if (!status?.registered) {
        const started = await session.client.POST('/v1/auth/passkeys/registration/options', {
          params: { header: opsHeaders },
        });
        if (started.error) throw new Error(started.error.error.message);
        const credential = await startRegistration({ optionsJSON: started.data.data as never });
        const finished = await session.client.POST('/v1/auth/passkeys/registration/verification', {
          params: { header: opsHeaders },
          body: credential as never,
        });
        if (finished.error) throw new Error(finished.error.error.message);
      } else {
        const started = await session.client.POST('/v1/auth/passkeys/authentication/options', {
          params: { header: opsHeaders },
        });
        if (started.error) throw new Error(started.error.error.message);
        const credential = await startAuthentication({ optionsJSON: started.data.data as never });
        const finished = await session.client.POST(
          '/v1/auth/passkeys/authentication/verification',
          { params: { header: opsHeaders }, body: credential as never },
        );
        if (finished.error) throw new Error(finished.error.error.message);
      }
      await load();
    } catch (value) {
      setError(
        value instanceof Error ? value.message : 'The passkey check could not be completed.',
      );
    } finally {
      setWorking(false);
    }
  };

  if (!status && !error)
    return (
      <AuthFrame title="Checking secure access" copy="Your operator session is being verified.">
        <Spinner size="large" />
      </AuthFrame>
    );
  if (status?.verified) return children;
  return (
    <AuthFrame
      title={status?.registered ? 'One final security check' : 'Create secure access'}
      copy={
        status?.registered
          ? 'Use your passkey to protect live routes, commuter data and operational decisions.'
          : 'Create a passkey with this device or a security key. No password or recovery code will be stored.'
      }
    >
      {error && (
        <MessageBar intent="error">
          <MessageBarBody>{error}</MessageBarBody>
        </MessageBar>
      )}
      <Button appearance="primary" size="large" disabled={working} onClick={() => void verify()}>
        {working
          ? 'Waiting for passkey…'
          : status?.registered
            ? 'Verify with passkey'
            : 'Create passkey'}
      </Button>
      <div className="auth-note">
        Passkeys are bound to this Ops website and require your device unlock. If every passkey is
        lost, another verified administrator must reset access.
      </div>
    </AuthFrame>
  );
}

export function AuthFrame({
  title,
  copy,
  children,
}: {
  title: string;
  copy: string;
  children: ReactNode;
}) {
  const now = new Date();
  return (
    <main className="auth-page">
      <div className="auth-clock" aria-hidden="true">
        <span className="clock-cell">{String(now.getHours()).padStart(2, '0')}</span>
        <span>:</span>
        <span className="clock-cell">{String(now.getMinutes()).padStart(2, '0')}</span>
        <span className="clock-cell">{now.getHours() < 12 ? 'am' : 'pm'}</span>
        <span className="clock-date">
          {new Intl.DateTimeFormat('en-GB', {
            day: '2-digit',
            month: 'short',
            year: 'numeric',
          }).format(now)}
        </span>
      </div>
      <section className="auth-card">
        <div className="brand-mark" style={{ justifyContent: 'center' }}>
          <span className="brand-symbol" aria-hidden="true" />
          <span>Trotxi</span>
        </div>
        <h1>{title}</h1>
        <p>{copy}</p>
        <div className="auth-actions">{children}</div>
      </section>
    </main>
  );
}
