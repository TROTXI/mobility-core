import { Avatar, Button } from '@fluentui/react-components';
import { Link } from 'react-router-dom';
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
      title="My profile"
      description="Your sign-in and active sessions."
      className="profile-page"
    >
      <section className="profile-summary" aria-label="Operator profile">
        <Avatar
          name={account?.displayName}
          image={account?.avatarUrl ? { src: account.avatarUrl } : undefined}
          size={64}
        />
        <div className="profile-summary-identity">
          <h2>{account?.displayName}</h2>
          <p>{account?.email ?? 'No email on record'}</p>
        </div>
        <span className="profile-role">Admin</span>
      </section>

      <div className="profile-sections">
        <Panel title="Security">
          <div className="panel-body profile-security">
            <p>Google sign-in and a passkey protect Ops access.</p>
            <p className="muted">Passkey elevation lasts for one eight-hour shift.</p>
            <Link to="/platform">Manage passkeys</Link>
          </div>
        </Panel>
        <div>
          <Panel title="Sessions">
            {query.error ? (
              <div className="panel-body">
                <ErrorState message={query.error} retry={query.retry} />
              </div>
            ) : query.loading ? (
              <LoadingRows />
            ) : !query.data?.length ? (
              <Empty>No active sessions.</Empty>
            ) : (
              <div className="profile-sessions">
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
              </div>
            )}
          </Panel>
        </div>
      </div>

      <details className="profile-account-details">
        <summary>Account details</summary>
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
      </details>
    </Page>
  );
}

async function revoke(session: ReturnType<typeof useAuth>['session'], id: string) {
  const response = await session.client.DELETE('/v1/me/sessions/{id}', {
    params: { path: { id }, header: { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID() } },
  });
  if (response.error) throw new Error(response.error.error.message);
}
