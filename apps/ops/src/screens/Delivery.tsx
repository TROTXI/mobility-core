import { Button } from '@fluentui/react-components';
import { useState } from 'react';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';

export function Delivery() {
  const { session } = useAuth();
  const [channel, setChannel] = useState<'' | 'email' | 'push'>('');
  const [cursor, setCursor] = useState<string | undefined>();
  const [previous, setPrevious] = useState<(string | undefined)[]>([]);
  const query = useQuery(
    async (signal) => {
      const r = await session.client.GET('/v1/ops/deliveries', {
        params: { query: { limit: 50, cursor, channel: channel || undefined }, header: opsHeaders },
        signal,
      });
      if (r.error) throw new Error(r.error.error.message);
      return r.data;
    },
    [session, channel, cursor],
  );
  return (
    <Page
      title="Delivery status"
      description="Email and push delivery evidence. Team accounts and passkey resets are managed in Team & access."
    >
      <div className="filter-bar">
        <label>
          Channel
          <select
            value={channel}
            onChange={(e) => {
              setChannel(e.target.value as typeof channel);
              setCursor(undefined);
              setPrevious([]);
            }}
          >
            <option value="">All</option>
            <option value="email">Email</option>
            <option value="push">Push</option>
          </select>
        </label>
      </div>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel
        title="Recent delivery attempts"
        action={<Button onClick={query.retry}>Refresh</Button>}
      >
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.data.length ? (
          <Empty>No delivery attempts yet.</Empty>
        ) : (
          <div style={{ overflowX: 'auto' }}>
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
                {query.data.data.map((row) => (
                  <tr key={row.id}>
                    <td>{when(row.createdAt)}</td>
                    <td>{row.channel}</td>
                    <td>{row.kind.replaceAll('_', ' ')}</td>
                    <td>
                      <StatusBadge value={row.state} />
                    </td>
                    <td>{row.attempts}</td>
                    <td>{row.failureCode?.replaceAll('_', ' ') ?? '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        <div className="filter-bar">
          <Button
            disabled={!previous.length || query.loading}
            onClick={() => {
              setCursor(previous.at(-1));
              setPrevious((old) => old.slice(0, -1));
            }}
          >
            Previous page
          </Button>
          <Button
            disabled={!query.data?.page.nextCursor || query.loading}
            onClick={() => {
              setPrevious((old) => [...old, cursor]);
              setCursor(query.data!.page.nextCursor!);
            }}
          >
            Next page
          </Button>
        </div>
      </Panel>
    </Page>
  );
}
