import { Button, Input } from '@fluentui/react-components';
import { useState } from 'react';
import { AddRegular, ArrowClockwiseRegular } from '@fluentui/react-icons';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';

type Trip = components['schemas']['OpsTrip'];

function range() {
  const today = new Date();
  const end = new Date(today);
  end.setDate(end.getDate() + 7);
  const iso = (date: Date) => date.toISOString().slice(0, 10);
  return { fromDate: iso(today), toDate: iso(end) };
}

export function Trips() {
  const { session } = useAuth();
  const [selected, setSelected] = useState<Trip | null>(null);
  const [mode, setMode] = useState<'create' | 'assign' | 'reschedule' | 'cancel' | null>(null);
  const [scheduleId, setScheduleId] = useState('');
  const [serviceDate, setServiceDate] = useState('');
  const [scheduledAt, setScheduledAt] = useState('');
  const [driverId, setDriverId] = useState('');
  const [vehicleId, setVehicleId] = useState('');
  const [reason, setReason] = useState('');
  const dates = range();
  const query = useQuery<Trip[]>(
    async (signal) => {
      const { data, error } = await session.client.GET('/v1/ops/trips', {
        params: { query: { ...dates, limit: 100 }, header: opsHeaders },
        signal,
      });
      if (error) throw new Error(error.error.message);
      return data.data;
    },
    [session],
  );

  return (
    <Page
      title="Trips"
      description="Assign, reschedule and cancel the next seven days of departures."
      actions={
        <>
          <Button icon={<ArrowClockwiseRegular />} onClick={query.retry}>
            Refresh
          </Button>
          <Button appearance="primary" icon={<AddRegular />} onClick={() => setMode('create')}>
            New trip
          </Button>
        </>
      }
    >
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel
        title="Upcoming departures"
        action={<Input placeholder="Filter routes" aria-label="Filter routes" />}
      >
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.length ? (
          <Empty>No departures in this period.</Empty>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Date & time</th>
                  <th>Direction</th>
                  <th>Driver</th>
                  <th>Vehicle</th>
                  <th>Stops</th>
                  <th>Status</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {query.data.map((trip) => (
                  <tr key={trip.id}>
                    <td>
                      <strong>{trip.serviceDate}</strong>
                      <div className="muted">{when(trip.scheduledAt)}</div>
                    </td>
                    <td>{trip.direction}</td>
                    <td>
                      {trip.assignedDriverId ? (
                        <span className="mono">{trip.assignedDriverId.slice(0, 8)}</span>
                      ) : (
                        'Assign driver'
                      )}
                    </td>
                    <td>{trip.vehiclePlate ?? trip.vehicleLabel ?? 'Assign bus'}</td>
                    <td>{trip.stops.length}</td>
                    <td>
                      <StatusBadge value={trip.status} />
                    </td>
                    <td>
                      <Button appearance="subtle" onClick={() => setSelected(trip)}>
                        Open
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Panel>
      {selected && (
        <div className="selection-bar">
          <div>
            <strong>
              {selected.direction} · {when(selected.scheduledAt)}
            </strong>
            <div className="muted">{selected.id}</div>
          </div>
          <Button
            onClick={() => {
              setDriverId(selected.assignedDriverId ?? '');
              setVehicleId(selected.vehicleId ?? '');
              setMode('assign');
            }}
          >
            Assign
          </Button>
          <Button
            onClick={() => {
              setScheduledAt(selected.scheduledAt.slice(0, 16));
              setMode('reschedule');
            }}
          >
            Reschedule
          </Button>
          <Button
            appearance="subtle"
            disabled={selected.status === 'cancelled' || selected.status === 'completed'}
            onClick={() => setMode('cancel')}
          >
            Cancel
          </Button>
          <Button appearance="subtle" onClick={() => setSelected(null)}>
            Close
          </Button>
        </div>
      )}
      <ActionDialog
        open={mode !== null}
        title={
          mode === 'create'
            ? 'Create trip'
            : mode === 'assign'
              ? 'Assign trip'
              : mode === 'reschedule'
                ? 'Reschedule trip'
                : 'Cancel trip'
        }
        confirmLabel={mode === 'cancel' ? 'Cancel trip' : mode === 'create' ? 'Create' : 'Save'}
        danger={mode === 'cancel'}
        onClose={() => setMode(null)}
        onConfirm={async () => {
          const key = crypto.randomUUID();
          if (mode === 'create') {
            const response = await session.client.POST('/v1/ops/trips', {
              params: { header: { ...opsHeaders, 'Idempotency-Key': key } },
              body: { scheduleId, serviceDate, scheduledAt: new Date(scheduledAt).toISOString() },
            });
            if (response.error) throw new Error(response.error.error.message);
          } else if (selected) {
            const header = {
              ...opsHeaders,
              'Idempotency-Key': key,
              'If-Match': selected.editToken,
            };
            if (mode === 'assign') {
              const response = await session.client.PUT('/v1/ops/trips/{id}/assignment', {
                params: { path: { id: selected.id }, header },
                body: { driverId: driverId || null, vehicleId: vehicleId || null },
              });
              if (response.error) throw new Error(response.error.error.message);
            } else if (mode === 'reschedule') {
              const response = await session.client.PATCH('/v1/ops/trips/{id}', {
                params: { path: { id: selected.id }, header },
                body: { scheduledAt: new Date(scheduledAt).toISOString() },
              });
              if (response.error) throw new Error(response.error.error.message);
            } else {
              const response = await session.client.POST('/v1/ops/trips/{id}/cancel', {
                params: { path: { id: selected.id }, header },
                body: { reason },
              });
              if (response.error) throw new Error(response.error.error.message);
            }
          }
          setSelected(null);
          query.retry();
        }}
      >
        {mode === 'create' && (
          <>
            <label>
              Schedule ID
              <input
                required
                value={scheduleId}
                onChange={(event) => setScheduleId(event.target.value)}
              />
            </label>
            <label>
              Service date
              <input
                type="date"
                required
                value={serviceDate}
                onChange={(event) => setServiceDate(event.target.value)}
              />
            </label>
            <label>
              Departure time
              <input
                type="datetime-local"
                required
                value={scheduledAt}
                onChange={(event) => setScheduledAt(event.target.value)}
              />
            </label>
          </>
        )}
        {mode === 'assign' && (
          <>
            <label>
              Driver ID
              <input value={driverId} onChange={(event) => setDriverId(event.target.value)} />
            </label>
            <label>
              Vehicle ID
              <input value={vehicleId} onChange={(event) => setVehicleId(event.target.value)} />
            </label>
          </>
        )}
        {mode === 'reschedule' && (
          <label>
            New departure time
            <input
              type="datetime-local"
              required
              value={scheduledAt}
              onChange={(event) => setScheduledAt(event.target.value)}
            />
          </label>
        )}
        {mode === 'cancel' && (
          <label>
            Reason
            <textarea
              rows={4}
              required
              value={reason}
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
        )}
      </ActionDialog>
    </Page>
  );
}
