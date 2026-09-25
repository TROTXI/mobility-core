import { Button, Input, Tab, TabList } from '@fluentui/react-components';
import { AddRegular, ArrowClockwiseRegular } from '@fluentui/react-icons';
import { useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';
import { LiveMap } from '../components/LiveMap';

type Trip = components['schemas']['OpsTrip'];
type Driver = components['schemas']['Driver'];
type Vehicle = components['schemas']['Vehicle'];
type Schedule = components['schemas']['Schedule'];
type OverviewData = components['schemas']['OpsOverview'];

function isoDay(date: Date) {
  return date.toISOString().slice(0, 10);
}

function initialRange() {
  const today = new Date();
  const end = new Date(today);
  end.setDate(end.getDate() + 7);
  return { fromDate: isoDay(today), toDate: isoDay(end) };
}

export function Trips() {
  const { session } = useAuth();
  const [searchParams] = useSearchParams();
  const searchFromUrl = searchParams.get('search') ?? '';
  const defaults = useMemo(initialRange, []);
  const [selected, setSelected] = useState<Trip | null>(null);
  const [mode, setMode] = useState<'create' | 'assign' | 'reschedule' | 'cancel' | null>(null);
  const [fromDate, setFromDate] = useState(defaults.fromDate);
  const [toDate, setToDate] = useState(defaults.toDate);
  const [direction, setDirection] = useState<'all' | 'outbound' | 'return'>('all');
  const [search, setSearch] = useState(searchFromUrl);
  useEffect(() => setSearch(searchFromUrl), [searchFromUrl]);
  const [scheduleId, setScheduleId] = useState('');
  const [serviceDate, setServiceDate] = useState('');
  const [scheduledAt, setScheduledAt] = useState('');
  const [driverId, setDriverId] = useState('');
  const [vehicleId, setVehicleId] = useState('');
  const [reason, setReason] = useState('');

  const query = useQuery<{
    trips: Trip[];
    drivers: Driver[];
    vehicles: Vehicle[];
    schedules: Schedule[];
  }>(
    async (signal) => {
      const [trips, drivers, vehicles, schedules] = await Promise.all([
        session.client.GET('/v1/ops/trips', {
          params: { query: { fromDate, toDate, limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/drivers', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/vehicles', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/service-schedules', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
      ]);
      const failure = trips.error ?? drivers.error ?? vehicles.error ?? schedules.error;
      if (failure) throw new Error(failure.error.message);
      if (!trips.data || !drivers.data || !vehicles.data || !schedules.data) {
        throw new Error('The dispatch board returned an incomplete response.');
      }
      return {
        trips: trips.data.data,
        drivers: drivers.data.data,
        vehicles: vehicles.data.data,
        schedules: schedules.data.data,
      };
    },
    [session, fromDate, toDate],
  );

  const liveQuery = useQuery<OverviewData['trips']>(
    async (signal) => {
      const [morning, evening] = await Promise.all(
        (['morning', 'evening'] as const).map((windowName) =>
          session.client.GET('/v1/ops/overview', {
            params: { query: { window: windowName }, header: opsHeaders },
            signal,
          }),
        ),
      );
      if (morning.error || evening.error) {
        throw new Error(
          morning.error?.error.message ?? evening.error?.error.message ?? 'Live map unavailable.',
        );
      }
      return [...(morning.data?.data.trips ?? []), ...(evening.data?.data.trips ?? [])];
    },
    [session],
  );

  useEffect(() => {
    const timer = window.setInterval(liveQuery.retry, 10_000);
    return () => window.clearInterval(timer);
  }, [liveQuery.retry]);

  const driverById = new Map(query.data?.drivers.map((driver) => [driver.id, driver]));
  const filtered = (query.data?.trips ?? []).filter((trip) => {
    if (direction !== 'all' && trip.direction !== direction) return false;
    const needle = search.trim().toLowerCase();
    if (!needle) return true;
    const driver = trip.assignedDriverId ? driverById.get(trip.assignedDriverId) : undefined;
    return [
      trip.id,
      trip.direction,
      trip.serviceDate,
      trip.vehicleLabel,
      trip.vehiclePlate,
      driver?.name,
    ].some((value) => value?.toLowerCase().includes(needle));
  });
  const needsAssignment = filtered.filter(
    (trip) => trip.status === 'scheduled' && (!trip.assignedDriverId || !trip.vehicleId),
  );
  const liveMarkers = (liveQuery.data ?? []).flatMap((trip) =>
    trip.lastPosition
      ? [
          {
            id: trip.tripId,
            ...trip.lastPosition,
            label: `${trip.routeName ?? 'Route'} · ${trip.vehiclePlate ?? trip.vehicleLabel ?? 'vehicle'}`,
            state: trip.badge,
          },
        ]
      : [],
  );

  const openCreate = () => {
    setScheduleId('');
    setServiceDate(defaults.fromDate);
    setScheduledAt('');
    setMode('create');
  };

  return (
    <Page
      title="Dispatch & trips"
      description="Plan departures, match drivers and buses, and resolve assignment exceptions."
      actions={
        <>
          <Button icon={<ArrowClockwiseRegular />} onClick={query.retry}>
            Refresh
          </Button>
          <Button appearance="primary" icon={<AddRegular />} onClick={openCreate}>
            New trip
          </Button>
        </>
      }
    >
      <div className="stat-grid">
        <Stat label="Departures" value={filtered.length} />
        <Stat
          label="Ready to depart"
          value={filtered.filter((trip) => trip.assignedDriverId && trip.vehicleId).length}
        />
        <Stat
          label="Unassigned"
          value={filtered.filter((trip) => !trip.assignedDriverId || !trip.vehicleId).length}
          attention={filtered.some((trip) => !trip.assignedDriverId || !trip.vehicleId)}
        />
        <Stat
          label="Cancelled"
          value={filtered.filter((trip) => trip.status === 'cancelled').length}
        />
      </div>

      <div className="filter-bar">
        <label>
          From
          <input
            type="date"
            value={fromDate}
            onChange={(event) => setFromDate(event.target.value)}
          />
        </label>
        <label>
          To
          <input type="date" value={toDate} onChange={(event) => setToDate(event.target.value)} />
        </label>
        <Input
          aria-label="Search trips"
          placeholder="Search trip, driver or vehicle"
          value={search}
          onChange={(_, data) => setSearch(data.value)}
        />
        <TabList
          selectedValue={direction}
          onTabSelect={(_, data) => setDirection(data.value as typeof direction)}
        >
          <Tab value="all">All</Tab>
          <Tab value="outbound">Outbound</Tab>
          <Tab value="return">Return</Tab>
        </TabList>
      </div>

      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <div className="dispatch-stage">
        <section className="dispatch-map-panel" aria-label="Current driver positions">
          <div className="overview-section-heading">
            <div>
              <h2>Dispatch map</h2>
              <span>Driver positions in the current service day</span>
            </div>
            <Button appearance="subtle" size="small" onClick={liveQuery.retry}>
              Refresh map
            </Button>
          </div>
          {liveQuery.error && <p className="muted">Live positions could not be loaded.</p>}
          <LiveMap markers={liveMarkers} />
          <p className="dispatch-map-note">
            Showing the latest reported driver positions. Planned routes are listed in the departure
            board.
          </p>
        </section>
        <section className="dispatch-queue-panel" aria-label="Assignment queue">
          <div className="overview-section-heading">
            <div>
              <h2>Assignment queue</h2>
              <span>{needsAssignment.length} departures need crew or a vehicle</span>
            </div>
          </div>
          {query.loading ? (
            <LoadingRows />
          ) : needsAssignment.length === 0 ? (
            <Empty>Every scheduled departure in this view is assigned.</Empty>
          ) : (
            <div className="dispatch-queue-scroll">
              {needsAssignment.map((trip) => (
                <button
                  key={trip.id}
                  type="button"
                  className="dispatch-queue-item"
                  onClick={() => setSelected(trip)}
                >
                  <strong>{when(trip.scheduledAt)}</strong>
                  <span>
                    {trip.direction} · {trip.serviceDate}
                  </span>
                  <small>
                    {!trip.assignedDriverId ? 'Driver needed' : 'Driver assigned'} ·{' '}
                    {!trip.vehicleId ? 'Vehicle needed' : 'Vehicle assigned'}
                  </small>
                </button>
              ))}
            </div>
          )}
        </section>
      </div>
      <Panel title="Departure board">
        {query.loading ? (
          <LoadingRows />
        ) : !filtered.length ? (
          <Empty>No departures match this view.</Empty>
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
                {filtered.map((trip) => {
                  const driver = trip.assignedDriverId
                    ? driverById.get(trip.assignedDriverId)
                    : undefined;
                  return (
                    <tr key={trip.id} className={selected?.id === trip.id ? 'selected-row' : ''}>
                      <td>
                        <strong>{trip.serviceDate}</strong>
                        <div className="muted">{when(trip.scheduledAt)}</div>
                      </td>
                      <td>{trip.direction}</td>
                      <td>{driver?.name ?? 'Assign driver'}</td>
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
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </Panel>

      {selected && (
        <aside className="detail-drawer" aria-label="Trip detail">
          <div className="detail-drawer-heading">
            <div>
              <span className="eyebrow">Trip detail</span>
              <h2>
                {selected.direction} · {when(selected.scheduledAt)}
              </h2>
            </div>
            <Button appearance="subtle" onClick={() => setSelected(null)}>
              Close
            </Button>
          </div>
          <dl className="detail-grid">
            <div>
              <dt>Service date</dt>
              <dd>{selected.serviceDate}</dd>
            </div>
            <div>
              <dt>Status</dt>
              <dd>
                <StatusBadge value={selected.status} />
              </dd>
            </div>
            <div>
              <dt>Driver</dt>
              <dd>
                {selected.assignedDriverId
                  ? (driverById.get(selected.assignedDriverId)?.name ?? selected.assignedDriverId)
                  : 'Unassigned'}
              </dd>
            </div>
            <div>
              <dt>Vehicle</dt>
              <dd>{selected.vehiclePlate ?? selected.vehicleLabel ?? 'Unassigned'}</dd>
            </div>
          </dl>
          <div className="stop-list">
            {selected.stops.map((stop, index) => (
              <div className="stop-item" key={stop.id}>
                <span>{index + 1}</span>
                <div>
                  <strong>{stop.name}</strong>
                  <div className="muted">{stop.id}</div>
                </div>
              </div>
            ))}
          </div>
          <div className="drawer-actions">
            <Button
              appearance="primary"
              onClick={() => {
                setDriverId(selected.assignedDriverId ?? '');
                setVehicleId(selected.vehicleId ?? '');
                setMode('assign');
              }}
            >
              Assign crew
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
              Cancel trip
            </Button>
          </div>
        </aside>
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
          setMode(null);
          setSelected(null);
          query.retry();
        }}
      >
        {mode === 'create' && (
          <>
            <label>
              Schedule
              <select
                required
                value={scheduleId}
                onChange={(event) => setScheduleId(event.target.value)}
              >
                <option value="">Choose a schedule</option>
                {(query.data?.schedules ?? []).map((schedule) => (
                  <option key={schedule.id} value={schedule.id}>
                    {schedule.serviceWindow} · {schedule.localDeparture} ·{' '}
                    {schedule.patternId.slice(0, 8)}
                  </option>
                ))}
              </select>
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
              Driver
              <select value={driverId} onChange={(event) => setDriverId(event.target.value)}>
                <option value="">Unassigned</option>
                {(query.data?.drivers ?? [])
                  .filter((driver) => !driver.archived)
                  .map((driver) => (
                    <option key={driver.id} value={driver.id}>
                      {driver.name} {driver.userId ? '· linked' : '· invite pending'}
                    </option>
                  ))}
              </select>
            </label>
            <label>
              Vehicle
              <select value={vehicleId} onChange={(event) => setVehicleId(event.target.value)}>
                <option value="">Unassigned</option>
                {(query.data?.vehicles ?? [])
                  .filter((vehicle) => !vehicle.archived)
                  .map((vehicle) => (
                    <option key={vehicle.id} value={vehicle.id}>
                      {vehicle.plate} · {vehicle.capacity} seats
                    </option>
                  ))}
              </select>
            </label>
            <p className="dialog-note">
              Assignment is capacity checked. A vehicle cannot replace a larger bus if existing
              seats would no longer fit.
            </p>
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
          <>
            <p className="dialog-note">Riders holding seats on this run will be notified.</p>
            <label>
              Reason
              <textarea
                rows={4}
                required
                value={reason}
                onChange={(event) => setReason(event.target.value)}
              />
            </label>
          </>
        )}
      </ActionDialog>
    </Page>
  );
}

function Stat({
  label,
  value,
  attention = false,
}: {
  label: string;
  value: number;
  attention?: boolean;
}) {
  return (
    <div className={`stat-card${attention ? ' attention' : ''}`}>
      <div className="stat-label">{label}</div>
      <div className="stat-value">{value}</div>
    </div>
  );
}
