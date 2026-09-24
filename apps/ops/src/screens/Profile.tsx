import { Button } from '@fluentui/react-components';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';

type Session = components['schemas']['Session'];

export function Profile() {
  const { account, session } = useAuth();
  const query = useQuery<Session[]>(
    async (signal) => {
      const response = await session.client.GET('/v1/me/sessions', {
        params: { query: { limit: 200 }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session],
  );
  return (
    <Page
      title="Profile & account"
      description="Your operations identity, passkey posture and signed-in sessions."
    >
      <div className="split-grid">
        <Panel title="Operator profile">
          <div className="profile-card">
            <div className="profile-avatar">{account?.displayName.slice(0, 1).toUpperCase()}</div>
            <div>
              <h2>{account?.displayName}</h2>
              <p>{account?.email ?? 'No email on record'}</p>
              <StatusBadge value={account?.role ?? 'admin'} />
            </div>
          </div>
          <dl className="detail-grid">
            <div>
              <dt>Operator ID</dt>
              <dd className="mono">{account?.id}</dd>
            </div>
            <div>
              <dt>Joined</dt>
              <dd>{account ? when(account.createdAt) : '—'}</dd>
            </div>
          </dl>
        </Panel>
        <Panel title="Access policy">
          <div className="panel-body">
            <p>
              <strong>Google identity + passkey</strong>
            </p>
            <p className="muted">
              Every privileged request uses current database role facts. Passkey elevation expires
              after one eight-hour shift.
            </p>
            <Button onClick={() => window.location.assign('/platform')}>Manage passkeys</Button>
          </div>
        </Panel>
      </div>
      <div style={{ height: 18 }} />
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel title="Active sessions">
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.length ? (
          <Empty>No active sessions.</Empty>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Created</th>
                <th>Expires</th>
                <th>State</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {query.data.map((row) => (
                <tr key={row.id}>
                  <td>{when(row.createdAt)}</td>
                  <td>{when(row.expiresAt)}</td>
                  <td>
                    <StatusBadge value={row.current ? 'current' : 'active'} />
                  </td>
                  <td>
                    <Button
                      appearance="subtle"
                      disabled={row.current}
                      onClick={() => void revoke(session, row.id).then(query.retry)}
                    >
                      Revoke
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Panel>
    </Page>
  );
}

async function revoke(session: ReturnType<typeof useAuth>['session'], id: string) {
  const response = await session.client.DELETE('/v1/me/sessions/{id}', {
    params: { path: { id }, header: { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID() } },
  });
  if (response.error) throw new Error(response.error.error.message);
}
