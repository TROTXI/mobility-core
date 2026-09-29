import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';

type AuditEvent = components['schemas']['OpsAuditEvent'];
type AuditPage = { items: AuditEvent[]; nextCursor: string | null };
type AuditFilters = {
  actorId: string;
  action: string;
  targetId: string;
  fromDate: string;
  toDate: string;
};
const emptyFilters: AuditFilters = {
  actorId: '',
  action: '',
  targetId: '',
  fromDate: '',
  toDate: '',
};

export function Audit() {
  const { session } = useAuth();
  const [area, setArea] = useState('');
  const [draft, setDraft] = useState<AuditFilters>(emptyFilters);
  const [filters, setFilters] = useState<AuditFilters>(emptyFilters);
  const [cursor, setCursor] = useState<string | undefined>();
  const [history, setHistory] = useState<(string | undefined)[]>([]);
  const query = useQuery<AuditPage>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/audit-events', {
        params: {
          query: {
            limit: 50,
            ...(area ? { area } : {}),
            ...(cursor ? { cursor } : {}),
            ...(filters.actorId ? { actorId: filters.actorId } : {}),
            ...(filters.action ? { action: filters.action } : {}),
            ...(filters.targetId ? { targetId: filters.targetId } : {}),
            ...(filters.fromDate ? { fromDate: filters.fromDate } : {}),
            ...(filters.toDate ? { toDate: filters.toDate } : {}),
          },
          header: opsHeaders,
        },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return { items: response.data.data, nextCursor: response.data.page.nextCursor ?? null };
    },
    [session, area, filters, cursor],
  );
  return (
    <Page
      title="Audit log & roles"
      description="Append-only operational evidence, unified without copying sensitive request bodies."
    >
      <div className="filter-bar">
        <label>
          Area
          <select
            value={area}
            onChange={(event) => {
              setArea(event.target.value);
              setCursor(undefined);
              setHistory([]);
            }}
          >
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
              'payments',
              'gps',
            ].map((value) => (
              <option key={value} value={value}>
                {value}
              </option>
            ))}
          </select>
        </label>
      </div>
      <details className="audit-search">
        <summary>Find a specific event</summary>
        <form
          className="filter-bar"
          onSubmit={(event) => {
            event.preventDefault();
            setFilters(draft);
            setCursor(undefined);
            setHistory([]);
          }}
        >
          <label>
            Operator ID
            <input
              value={draft.actorId}
              onChange={(event) => setDraft({ ...draft, actorId: event.target.value.trim() })}
              placeholder="UUID"
            />
          </label>
          <label>
            Action
            <input
              value={draft.action}
              onChange={(event) => setDraft({ ...draft, action: event.target.value })}
              placeholder="Exact action"
            />
          </label>
          <label>
            Target ID
            <input
              value={draft.targetId}
              onChange={(event) => setDraft({ ...draft, targetId: event.target.value.trim() })}
              placeholder="Resource ID"
            />
          </label>
          <label>
            From (UTC)
            <input
              type="date"
              value={draft.fromDate}
              onChange={(event) => setDraft({ ...draft, fromDate: event.target.value })}
            />
          </label>
          <label>
            To (UTC)
            <input
              type="date"
              value={draft.toDate}
              onChange={(event) => setDraft({ ...draft, toDate: event.target.value })}
            />
          </label>
          <button type="submit">Search</button>
        </form>
      </details>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel title="Recent changes">
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.items.length ? (
          <Empty>No audited changes match this view.</Empty>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Time</th>
                <th>Area</th>
                <th>Action</th>
                <th>Actor</th>
                <th>Target</th>
                <th>Reason</th>
              </tr>
            </thead>
            <tbody>
              {query.data.items.map((row) => (
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
        {(history.length > 0 || query.data?.nextCursor) && (
          <div className="filter-bar">
            <button
              type="button"
              disabled={!history.length || query.loading}
              onClick={() => {
                const previous = history.at(-1);
                setHistory(history.slice(0, -1));
                setCursor(previous);
              }}
            >
              Newer
            </button>
            <button
              type="button"
              disabled={!query.data?.nextCursor || query.loading}
              onClick={() => {
                setHistory([...history, cursor]);
                setCursor(query.data!.nextCursor!);
              }}
            >
              Older
            </button>
          </div>
        )}
      </Panel>
    </Page>
  );
}
