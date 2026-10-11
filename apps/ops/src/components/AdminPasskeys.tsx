import { Button } from '@fluentui/react-components';
import { startRegistration } from '@simplewebauthn/browser';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { opsHeaders } from '../api/session';
import { ErrorState, LoadingRows, Panel } from './Page';
import { useQuery } from '../hooks/useQuery';

export function AdminPasskeys() {
  const { session } = useAuth();
  const status = useQuery<components['schemas']['PasskeyStatus']>(
    async (signal) => {
      const { data, error } = await session.client.GET('/v1/auth/passkeys', {
        params: { header: opsHeaders },
        signal,
      });
      if (error) throw new Error(error.error.message);
      return data.data;
    },
    [session],
  );
  const [working, setWorking] = useState(false);
  const [message, setMessage] = useState('');
  const addPasskey = async () => {
    setWorking(true);
    setMessage('');
    try {
      const options = await session.client.POST('/v1/auth/passkeys/registration/options', {
        params: { header: opsHeaders },
      });
      if (options.error) throw new Error(options.error.error.message);
      const credential = await startRegistration({ optionsJSON: options.data.data as never });
      const result = await session.client.POST('/v1/auth/passkeys/registration/verification', {
        params: { header: opsHeaders },
        body: credential as never,
      });
      if (result.error) throw new Error(result.error.error.message);
      setMessage('Passkey added.');
      status.retry();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Passkey registration failed.');
    } finally {
      setWorking(false);
    }
  };
  return (
    <Panel title="My passkeys">
      {status.error ? (
        <div className="panel-body">
          <ErrorState message={status.error} retry={status.retry} />
        </div>
      ) : status.loading ? (
        <LoadingRows rows={2} />
      ) : (
        <div className="panel-body">
          <p>
            <strong>{status.data?.passkeyCount ?? 0} passkeys registered</strong>
          </p>
          <p className="muted">
            This session is{' '}
            {status.data?.verified ? 'verified for operational access' : 'not elevated'}. Add
            another passkey only after verifying an existing one.
          </p>
          {message && <p role="status">{message}</p>}
          <Button
            appearance="primary"
            disabled={working || !status.data?.verified}
            onClick={() => void addPasskey()}
          >
            {working ? 'Waiting for passkey…' : 'Add another passkey'}
          </Button>
        </div>
      )}
    </Panel>
  );
}
