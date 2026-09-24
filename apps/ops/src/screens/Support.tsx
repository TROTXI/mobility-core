import { Button, Tab, TabList } from '@fluentui/react-components';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';

type Selection =
  | { kind: 'incident'; row: Incident }
  | { kind: 'driver'; row: WorkRequest }
  | { kind: 'commute'; row: CommuteRequest };

type Incident = components['schemas']['OpsIncident'];
type WorkRequest = components['schemas']['OpsWorkRequest'];
type CommuteRequest = components['schemas']['OpsCommuteRequest'];
type CommuteSlot = components['schemas']['CommuteSlot'];
type DecisionEvent = components['schemas']['DecisionEvent'];

export function Support() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'incidents' | 'driver' | 'commute'>('incidents');
  const [selected, setSelected] = useState<Selection | null>(null);
  const [decision, setDecision] = useState('resolved');
  const [note, setNote] = useState('');
  const [slotId, setSlotId] = useState('');
  const [effectiveDate, setEffectiveDate] = useState('');
  const query = useQuery<{
    incidents: Incident[];
    driver: WorkRequest[];
    commute: CommuteRequest[];
    slots: CommuteSlot[];
  }>(
    async (signal) => {
      const [incidents, driver, commute, slots] = await Promise.all([
        session.client.GET('/v1/ops/incidents', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/driver-requests', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/commute-requests', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/commute-slots', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
      ]);
      if (incidents.error) throw new Error(incidents.error.error.message);
      if (driver.error) throw new Error(driver.error.error.message);
      if (commute.error) throw new Error(commute.error.error.message);
      if (slots.error) throw new Error(slots.error.error.message);
      return {
        incidents: incidents.data.data,
        driver: driver.data.data,
        commute: commute.data.data,
        slots: slots.data.data,
      };
    },
    [session],
  );
  const history = useQuery<DecisionEvent[]>(
    async (signal) => {
      if (selected?.kind !== 'commute') return [];
      const response = await session.client.GET('/v1/ops/commute-requests/{id}/events', {
        params: {
          path: { id: selected.row.id },
          query: { limit: 100 },
          header: opsHeaders,
        },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session, selected?.kind === 'commute' ? selected.row.id : null],
  );
  const availableSlots =
    selected?.kind === 'commute'
      ? (query.data?.slots ?? []).filter(
          (slot) => slot.state === 'available' && slot.routeId === selected.row.requested.routeId,
        )
      : [];
  return (
    <Page
      title="Support & requests"
      description="Exceptions find the dispatcher and every decision keeps its actor and reason."
    >
      <TabList
        selectedValue={tab}
        onTabSelect={(_, data) => setTab(data.value as typeof tab)}
        style={{ marginBottom: 18 }}
      >
        <Tab value="incidents">Incidents</Tab>
        <Tab value="driver">Driver requests</Tab>
        <Tab value="commute">Commute changes</Tab>
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel
        title={
          tab === 'incidents'
            ? 'Incident queue'
            : tab === 'driver'
              ? 'Driver request queue'
              : 'Commute request queue'
        }
      >
        {query.loading ? (
          <LoadingRows />
        ) : tab === 'incidents' ? (
          <IncidentRows
            rows={query.data?.incidents ?? []}
            onSelect={(row) => {
              setSelected({ kind: 'incident', row });
              setDecision('resolved');
            }}
          />
        ) : tab === 'driver' ? (
          <RequestRows
            rows={query.data?.driver ?? []}
            onSelect={(row) => {
              setSelected({ kind: 'driver', row });
              setDecision('approved');
            }}
          />
        ) : (
          <CommuteRows
            rows={query.data?.commute ?? []}
            onSelect={(row) => {
              setSelected({ kind: 'commute', row });
              setDecision('waitlist');
            }}
          />
        )}
      </Panel>
      <ActionDialog
        open={Boolean(selected)}
        title="Record a decision"
        description="This decision is attributed to your administrator account and cannot be silently rewritten."
        confirmLabel="Record decision"
        onClose={() => {
          setSelected(null);
          setNote('');
        }}
        onConfirm={async () => {
          if (!selected) return;
          const headers = {
            ...opsHeaders,
            'Idempotency-Key': crypto.randomUUID(),
            'If-Match': selected.row.editToken,
          };
          if (selected.kind === 'incident') {
            const response = await session.client.POST('/v1/ops/incidents/{id}/decisions', {
              params: { path: { id: selected.row.id }, header: headers },
              body: { status: decision as 'acknowledged' | 'resolved', resolution: note },
            });
            if (response.error) throw new Error(response.error.error.message);
          } else if (selected.kind === 'driver') {
            const response = await session.client.POST('/v1/ops/driver-requests/{id}/decisions', {
              params: { path: { id: selected.row.id }, header: headers },
              body: { status: decision as 'approved' | 'declined', decisionNote: note },
            });
            if (response.error) throw new Error(response.error.error.message);
          } else {
            const body: components['schemas']['CommuteDecision'] =
              decision === 'approve'
                ? { action: 'approve', slotId, effectiveDate, note }
                : {
                    action: decision as
                      'waitlist' | 'pause' | 'resume' | 'apply' | 'cancel' | 'reject',
                    note,
                  };
            const response = await session.client.POST('/v1/ops/commute-requests/{id}/decisions', {
              params: { path: { id: selected.row.id }, header: headers },
              body,
            });
            if (response.error) throw new Error(response.error.error.message);
          }
          query.retry();
        }}
      >
        <label>
          Decision
          <select value={decision} onChange={(event) => setDecision(event.target.value)}>
            {selected?.kind === 'incident' ? (
              <>
                <option value="acknowledged">Acknowledge</option>
                <option value="resolved">Resolve</option>
              </>
            ) : selected?.kind === 'driver' ? (
              <>
                <option value="approved">Approve</option>
                <option value="declined">Decline</option>
              </>
            ) : (
              <>
                <option value="approve">Approve with slot</option>
                <option value="waitlist">Waitlist</option>
                <option value="pause">Pause</option>
                <option value="resume">Resume</option>
                <option value="apply">Apply</option>
                <option value="reject">Reject</option>
                <option value="cancel">Cancel</option>
              </>
            )}
          </select>
        </label>
        {selected?.kind === 'commute' && decision === 'approve' && (
          <>
            <label>
              Available slot
              <select required value={slotId} onChange={(event) => setSlotId(event.target.value)}>
                <option value="">Select a slot</option>
                {availableSlots.map((slot) => (
                  <option key={slot.id} value={slot.id}>
                    {slot.availableFrom} · {slot.legs.length} legs · {slot.id.slice(0, 8)}
                  </option>
                ))}
              </select>
            </label>
            <label>
              Effective date
              <input
                type="date"
                required
                value={effectiveDate}
                onChange={(event) => setEffectiveDate(event.target.value)}
              />
            </label>
          </>
        )}
        <label>
          Reason / note
          <textarea
            rows={4}
            required
            value={note}
            onChange={(event) => setNote(event.target.value)}
          />
        </label>
        {selected?.kind === 'commute' && (
          <div>
            <strong>Decision history</strong>
            {history.loading ? (
              <p className="muted">Loading history…</p>
            ) : history.error ? (
              <p className="muted">{history.error}</p>
            ) : history.data?.length ? (
              <div className="stack-list compact">
                {history.data.map((event) => (
                  <div className="stack-row" key={event.id}>
                    <span>
                      <strong>{event.action.replaceAll('_', ' ')}</strong>
                      <small>{event.note ?? 'No note'}</small>
                    </span>
                    <small>{when(event.occurredAt)}</small>
                  </div>
                ))}
              </div>
            ) : (
              <p className="muted">No decisions recorded yet.</p>
            )}
          </div>
        )}
      </ActionDialog>
    </Page>
  );
}
function IncidentRows({ rows, onSelect }: { rows: Incident[]; onSelect: (row: Incident) => void }) {
  if (!rows.length) return <Empty>No incidents need review.</Empty>;
  return (
    <table className="data-table">
      <thead>
        <tr>
          <th>Opened</th>
          <th>Category</th>
          <th>Driver</th>
          <th>Status</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr key={row.id}>
            <td>{when(row.createdAt)}</td>
            <td>{row.category.replaceAll('_', ' ')}</td>
            <td className="mono">{row.driverId.slice(0, 8)}</td>
            <td>
              <StatusBadge value={row.status} />
            </td>
            <td>
              <Button
                appearance="subtle"
                disabled={row.status === 'resolved'}
                onClick={() => onSelect(row)}
              >
                Review
              </Button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
function RequestRows({
  rows,
  onSelect,
}: {
  rows: WorkRequest[];
  onSelect: (row: WorkRequest) => void;
}) {
  if (!rows.length) return <Empty>No driver requests need review.</Empty>;
  return (
    <table className="data-table">
      <thead>
        <tr>
          <th>Created</th>
          <th>Request</th>
          <th>Driver</th>
          <th>Status</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr key={row.id}>
            <td>{when(row.createdAt)}</td>
            <td>{row.request.kind.replaceAll('_', ' ')}</td>
            <td className="mono">{row.driverId.slice(0, 8)}</td>
            <td>
              <StatusBadge value={row.status} />
            </td>
            <td>
              <Button
                appearance="subtle"
                disabled={row.status !== 'pending'}
                onClick={() => onSelect(row)}
              >
                Decide
              </Button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
function CommuteRows({
  rows,
  onSelect,
}: {
  rows: CommuteRequest[];
  onSelect: (row: CommuteRequest) => void;
}) {
  if (!rows.length) return <Empty>No commute requests need review.</Empty>;
  return (
    <table className="data-table">
      <thead>
        <tr>
          <th>Created</th>
          <th>Rider</th>
          <th>Requested route</th>
          <th>Status</th>
          <th />
        </tr>
      </thead>
      <tbody>
        {rows.map((row) => (
          <tr key={row.id}>
            <td>{when(row.createdAt)}</td>
            <td className="mono">{row.riderId.slice(0, 8)}</td>
            <td className="mono">{row.requested.routeId.slice(0, 8)}</td>
            <td>
              <StatusBadge value={row.status} />
            </td>
            <td>
              <Button appearance="subtle" onClick={() => onSelect(row)}>
                Consider
              </Button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
