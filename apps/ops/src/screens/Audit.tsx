import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';

type AuditEvent = components['schemas']['OpsAuditEvent'];

export function Audit() {
  const { session } = useAuth();
  const [area, setArea] = useState('');
  const query = useQuery<AuditEvent[]>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/audit-events', {
        params: { query: { limit: 200, ...(area ? { area } : {}) }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session, area],
  );
  return (
    <Page
      title="Audit log & roles"
      description="Append-only operational evidence, unified without copying sensitive request bodies."
    >
      <div className="filter-bar">
        <label>
          Area
          <select value={area} onChange={(event) => setArea(event.target.value)}>
            <option value="">All activity</option>
            {[
              'catalog',
              'trip',
              'schedule',
              'fleet',
              'driver',
              'membership',
              'boarding',
              'pricing',
              'configuration',
              'security',
            ].map((value) => (
              <option key={value} value={value}>
                {value}
              </option>
            ))}
          </select>
        </label>
      </div>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel title="Recent changes">
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.length ? (
          <Empty>No audited changes match this view.</Empty>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Time</th>
                <th>Area</th>
                <th>Action</th>
                <th>Operator</th>
                <th>Target</th>
                <th>Reason</th>
              </tr>
            </thead>
            <tbody>
              {query.data.map((row) => (
                <tr key={row.id}>
                  <td>{when(row.occurredAt)}</td>
                  <td>
                    <StatusBadge value={row.area} />
                  </td>
                  <td>{row.action.replaceAll('_', ' ')}</td>
                  <td>
                    <strong>{row.actorName}</strong>
                    <div className="muted mono">{row.actorId.slice(0, 8)}</div>
                  </td>
                  <td className="mono">
                    {row.targetId.length > 18 ? `${row.targetId.slice(0, 14)}…` : row.targetId}
                  </td>
                  <td>{row.reason ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Panel>
    </Page>
  );
}
