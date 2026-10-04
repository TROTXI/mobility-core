import { Button, Tab, TabList } from '@fluentui/react-components';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';

type Operator = components['schemas']['OpsOperator'];
type Delivery = components['schemas']['OpsDelivery'];

export function People() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'operators' | 'delivery'>('operators');
  const [channel, setChannel] = useState<'' | 'email' | 'push'>('');
  const [reset, setReset] = useState<Operator | null>(null);
  const [changing, setChanging] = useState<Operator | null>(null);
  const [role, setRole] = useState<'commuter' | 'driver'>('commuter');
  const [reason, setReason] = useState('');
  // One key per opening of the dialog, reused by a retry after no answer.
  const [roleKey, setRoleKey] = useState('');
  const query = useQuery<{ operators: Operator[]; deliveries: Delivery[] }>(
    async (signal) => {
      const [operators, deliveries] = await Promise.all([
        session.client.GET('/v1/ops/operators', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/deliveries', {
          params: { query: { limit: 200, ...(channel ? { channel } : {}) }, header: opsHeaders },
          signal,
        }),
      ]);
      if (operators.error) throw new Error(operators.error.error.message);
      if (deliveries.error) throw new Error(deliveries.error.error.message);
      return { operators: operators.data.data, deliveries: deliveries.data.data };
    },
    [session, channel],
  );
  return (
    <Page
      title="People & messages"
      description="Administrator access and delivery evidence without exposing message bodies or device tokens."
    >
      <TabList
        selectedValue={tab}
        onTabSelect={(_, data) => setTab(data.value as typeof tab)}
        style={{ marginBottom: 18 }}
      >
        <Tab value="operators">Operators</Tab>
        <Tab value="delivery">Delivery status</Tab>
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      {tab === 'operators' ? (
        <Panel title="Administrator directory">
          {query.loading ? (
            <LoadingRows />
          ) : !query.data?.operators.length ? (
            <Empty />
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Operator</th>
                  <th>Passkeys</th>
                  <th>Active sessions</th>
                  <th>Last used</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {query.data.operators.map((row) => (
                  <tr key={row.id}>
                    <td>
                      <strong>{row.displayName}</strong>
                      <div className="muted">{row.email ?? row.id}</div>
                    </td>
                    <td>
                      <StatusBadge value={row.passkeyCount ? 'ready' : 'missing'} />{' '}
                      <span className="muted">{row.passkeyCount}</span>
                    </td>
                    <td>{row.activeSessions}</td>
                    <td>{row.lastPasskeyUsedAt ? when(row.lastPasskeyUsedAt) : 'Never'}</td>
                    <td>
                      <Button
                        appearance="subtle"
                        disabled={!session.account?.isSuperadmin || row.id === session.account?.id}
                        onClick={() => setReset(row)}
                      >
                        Reset passkeys
                      </Button>
                      <Button
                        appearance="subtle"
                        disabled={!session.account?.isSuperadmin || row.id === session.account?.id}
                        title={
                          row.id === session.account?.id
                            ? 'Another administrator must change your role.'
                            : undefined
                        }
                        onClick={() => {
                          setChanging(row);
                          setRole('commuter');
                          setReason('');
                          setRoleKey(crypto.randomUUID());
                        }}
                      >
                        Change role
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </Panel>
      ) : (
        <>
          <div className="filter-bar">
            <label>
              Channel
              <select
                value={channel}
                onChange={(event) => setChannel(event.target.value as typeof channel)}
              >
                <option value="">All</option>
                <option value="email">Email</option>
                <option value="push">Push</option>
              </select>
            </label>
          </div>
          <Panel title="Recent delivery attempts">
            {query.loading ? (
              <LoadingRows />
            ) : !query.data?.deliveries.length ? (
              <Empty>No delivery attempts yet.</Empty>
            ) : (
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Created</th>
                    <th>Channel</th>
                    <th>Kind</th>
                    <th>State</th>
                    <th>Attempts</th>
                    <th>Failure</th>
                  </tr>
                </thead>
                <tbody>
                  {query.data.deliveries.map((row) => (
                    <tr key={row.id}>
                      <td>{when(row.createdAt)}</td>
                      <td>{row.channel}</td>
                      <td>{row.kind.replaceAll('_', ' ')}</td>
                      <td>
                        <StatusBadge value={row.state} />
                      </td>
                      <td>{row.attempts}</td>
                      <td>{row.failureCode?.replaceAll('_', ' ') ?? '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </Panel>
        </>
      )}
      <ActionDialog
        open={Boolean(reset)}
        title="Reset operator passkeys"
        description="This revokes every passkey and session for the selected administrator. They must sign in and register a new passkey."
        confirmLabel="Reset access"
        danger
        onClose={() => setReset(null)}
        onConfirm={async () => {
          if (!reset) return;
          const response = await session.client.POST('/v1/ops/users/{id}/passkeys/reset', {
            params: {
              path: { id: reset.id },
              header: { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID() },
            },
          });
          if (response.error) throw new Error(response.error.error.message);
          setReset(null);
          query.retry();
        }}
      >
        <p className="dialog-note">
          The selected administrator will be signed out on every device.
        </p>
      </ActionDialog>
      <ActionDialog
        open={Boolean(changing)}
        title="Change administrator role"
        description={
          changing
            ? `${changing.displayName} loses operations access as soon as this is saved. Their sessions stay signed in with the new role's access only.`
            : undefined
        }
        confirmLabel="Change role"
        danger
        onClose={() => setChanging(null)}
        onConfirm={async () => {
          if (!changing) return;
          if (!reason.trim()) throw new Error('Give a reason; it is kept in the audit log.');
          const response = await session.client.PATCH('/v1/ops/users/{id}/role', {
            params: {
              path: { id: changing.id },
              header: { ...opsHeaders, 'Idempotency-Key': roleKey, 'If-Match': changing.editToken },
            },
            body: { role, reason: reason.trim() },
          });
          if (response.error) throw new Error(response.error.error.message);
          setChanging(null);
          query.retry();
        }}
      >
        <label>
          New role
          <select value={role} onChange={(event) => setRole(event.target.value as typeof role)}>
            <option value="commuter">Commuter (rider app)</option>
            <option value="driver">Driver (needs a driver record)</option>
          </select>
        </label>
        <label>
          Reason (kept in the audit log)
          <textarea
            rows={3}
            required
            value={reason}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
        <p className="dialog-note">
          You cannot change your own role, and the last administrator cannot be removed.
        </p>
      </ActionDialog>
    </Page>
  );
}
