import { Button, Input, Tab, TabList } from '@fluentui/react-components';
import { AddRegular, ArrowClockwiseRegular } from '@fluentui/react-icons';
import { useMemo, useState, type ReactNode } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';
import { LiveMap } from '../components/LiveMap';

type Route = components['schemas']['Route'];
type Stop = components['schemas']['Stop'];
type Pattern = components['schemas']['Pattern'];
type PatternVersion = components['schemas']['PatternVersion'];
type Schedule = components['schemas']['Schedule'];
type CommuteSlot = components['schemas']['CommuteSlot'];
type Fare = components['schemas']['Fare'];
type TabName = 'routes' | 'stops' | 'patterns' | 'schedules' | 'fares' | 'slots';
type DialogKind =
  | 'route-create'
  | 'route-edit'
  | 'stop-create'
  | 'stop-edit'
  | 'pattern-create'
  | 'version-create'
  | 'version-publish'
  | 'schedule-create'
  | 'fare-create'
  | 'slot-create'
  | 'slot-retire';

const weekdays = [
  [1, 'Mon'],
  [2, 'Tue'],
  [3, 'Wed'],
  [4, 'Thu'],
  [5, 'Fri'],
  [6, 'Sat'],
  [7, 'Sun'],
] as const;

function today() {
  return new Date().toISOString().slice(0, 10);
}

function toIso(value: string) {
  return new Date(value).toISOString();
}

function distance(a: Stop['location'], b: Stop['location']) {
  const radians = (value: number) => (value * Math.PI) / 180;
  const earth = 6_371_000;
  const lat = radians(b.latitude - a.latitude);
  const lon = radians(b.longitude - a.longitude);
  const x =
    Math.sin(lat / 2) ** 2 +
    Math.cos(radians(a.latitude)) * Math.cos(radians(b.latitude)) * Math.sin(lon / 2) ** 2;
  return 2 * earth * Math.atan2(Math.sqrt(x), Math.sqrt(1 - x));
}

function straightLineDistances(stops: Stop[]) {
  const values = [0];
  for (let index = 1; index < stops.length; index += 1) {
    values.push(values[index - 1] + distance(stops[index - 1].location, stops[index].location));
  }
  return values;
}

export function Network() {
  const { session } = useAuth();
  const [tab, setTab] = useState<TabName>('routes');
  const [dialog, setDialog] = useState<DialogKind | null>(null);
  const [selectedRoute, setSelectedRoute] = useState<Route | null>(null);
  const [selectedStop, setSelectedStop] = useState<Stop | null>(null);
  const [selectedPattern, setSelectedPattern] = useState<Pattern | null>(null);
  const [selectedVersion, setSelectedVersion] = useState<PatternVersion | null>(null);
  const [selectedSlot, setSelectedSlot] = useState<CommuteSlot | null>(null);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [acceptsDriverRequests, setAcceptsDriverRequests] = useState(false);
  const [archived, setArchived] = useState(false);
  const [latitude, setLatitude] = useState('5.6037');
  const [longitude, setLongitude] = useState('-0.1870');
  const [routeId, setRouteId] = useState('');
  const [direction, setDirection] = useState<'outbound' | 'return'>('outbound');
  const [versionStops, setVersionStops] = useState<string[]>([]);
  const [effectiveFrom, setEffectiveFrom] = useState(today());
  const [effectiveTo, setEffectiveTo] = useState('');
  const [reason, setReason] = useState('');
  const [patternVersionId, setPatternVersionId] = useState('');
  const [serviceWindow, setServiceWindow] = useState<'morning' | 'evening'>('morning');
  const [localDeparture, setLocalDeparture] = useState('06:30');
  const [selectedWeekdays, setSelectedWeekdays] = useState([1, 2, 3, 4, 5]);
  const [amountGhs, setAmountGhs] = useState('6');
  const [note, setNote] = useState('');
  const [outboundScheduleId, setOutboundScheduleId] = useState('');
  const [returnScheduleId, setReturnScheduleId] = useState('');
  const [outboundPickup, setOutboundPickup] = useState('');
  const [outboundDropoff, setOutboundDropoff] = useState('');
  const [returnPickup, setReturnPickup] = useState('');
  const [returnDropoff, setReturnDropoff] = useState('');

  const query = useQuery<{
    routes: Route[];
    stops: Stop[];
    patterns: Pattern[];
    schedules: Schedule[];
    slots: CommuteSlot[];
  }>(
    async (signal) => {
      const [routes, stops, patterns, schedules, slots] = await Promise.all([
        session.client.GET('/v1/ops/routes', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/stops', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/route-patterns', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/service-schedules', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/commute-slots', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
      ]);
      const failure =
        routes.error ?? stops.error ?? patterns.error ?? schedules.error ?? slots.error;
      if (failure) throw new Error(failure.error.message);
      if (!routes.data || !stops.data || !patterns.data || !schedules.data || !slots.data) {
        throw new Error('The network workspace returned an incomplete response.');
      }
      return {
        routes: routes.data.data,
        stops: stops.data.data,
        patterns: patterns.data.data,
        schedules: schedules.data.data,
        slots: slots.data.data,
      };
    },
    [session],
  );

  const versionQuery = useQuery<PatternVersion[]>(
    async (signal) => {
      if (!selectedPattern) return [];
      const { data, error } = await session.client.GET('/v1/ops/route-patterns/{id}/versions', {
        params: {
          path: { id: selectedPattern.id },
          query: { limit: 200 },
          header: opsHeaders,
        },
        signal,
      });
      if (error) throw new Error(error.error.message);
      return data.data;
    },
    [session, selectedPattern?.id],
  );

  const fareQuery = useQuery<Fare[]>(
    async (signal) => {
      if (!routeId) return [];
      const { data, error } = await session.client.GET('/v1/ops/routes/{id}/fares', {
        params: { path: { id: routeId }, query: { limit: 200 }, header: opsHeaders },
        signal,
      });
      if (error) throw new Error(error.error.message);
      return data.data;
    },
    [session, routeId],
  );

  const routeById = useMemo(
    () => new Map(query.data?.routes.map((route) => [route.id, route])),
    [query.data?.routes],
  );
  const patternById = useMemo(
    () => new Map(query.data?.patterns.map((pattern) => [pattern.id, pattern])),
    [query.data?.patterns],
  );

  const startDialog = (kind: DialogKind) => {
    setDialog(kind);
    setReason('');
    setNote('');
    if (kind === 'route-create') {
      setName('');
      setDescription('');
      setAcceptsDriverRequests(false);
      setArchived(false);
    } else if (kind === 'route-edit' && selectedRoute) {
      setName(selectedRoute.name);
      setDescription(selectedRoute.description ?? '');
      setAcceptsDriverRequests(selectedRoute.acceptsDriverRequests);
      setArchived(selectedRoute.archived);
    } else if (kind === 'stop-create') {
      setName('');
      setLatitude('5.6037');
      setLongitude('-0.1870');
      setArchived(false);
    } else if (kind === 'stop-edit' && selectedStop) {
      setName(selectedStop.name);
      setLatitude(String(selectedStop.location.latitude));
      setLongitude(String(selectedStop.location.longitude));
      setArchived(selectedStop.archived);
    } else if (kind === 'pattern-create') {
      setRouteId(query.data?.routes[0]?.id ?? '');
      setDirection('outbound');
    } else if (kind === 'version-create') {
      setVersionStops([]);
    } else if (kind === 'version-publish') {
      setEffectiveFrom(new Date().toISOString().slice(0, 16));
    } else if (kind === 'schedule-create') {
      setPatternVersionId('');
      setEffectiveFrom(today());
      setEffectiveTo('');
    } else if (kind === 'fare-create') {
      setAmountGhs('6');
      setEffectiveFrom(new Date().toISOString().slice(0, 16));
    } else if (kind === 'slot-create') {
      setRouteId(query.data?.routes[0]?.id ?? '');
      setEffectiveFrom(today());
    }
  };

  const refreshAll = () => {
    query.retry();
    versionQuery.retry();
    fareQuery.retry();
  };

  const actionLabel: Record<TabName, string> = {
    routes: 'New route',
    stops: 'New stop',
    patterns: 'New pattern',
    schedules: 'New schedule',
    fares: 'New fare',
    slots: 'New slot',
  };
  const actionKind: Record<TabName, DialogKind> = {
    routes: 'route-create',
    stops: 'stop-create',
    patterns: 'pattern-create',
    schedules: 'schedule-create',
    fares: 'fare-create',
    slots: 'slot-create',
  };

  return (
    <Page
      title="Routes & network"
      description="Manage corridors, boarding points, immutable route versions, departures, fares and capacity."
      actions={
        <>
          <Button icon={<ArrowClockwiseRegular />} onClick={refreshAll}>
            Refresh
          </Button>
          <Button
            appearance="primary"
            icon={<AddRegular />}
            onClick={() => startDialog(actionKind[tab])}
          >
            {actionLabel[tab]}
          </Button>
        </>
      }
    >
      <TabList selectedValue={tab} onTabSelect={(_, data) => setTab(data.value as TabName)}>
        <Tab value="routes">Routes</Tab>
        <Tab value="stops">Stops</Tab>
        <Tab value="patterns">Patterns & versions</Tab>
        <Tab value="schedules">Schedules</Tab>
        <Tab value="fares">Fares</Tab>
        <Tab value="slots">Commute slots</Tab>
      </TabList>

      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      {tab === 'routes' && (
        <div className="split-grid network-grid">
          <Panel title="Corridors">
            <TableState loading={query.loading} empty={!query.data?.routes.length}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Patterns</th>
                    <th>Driver requests</th>
                    <th>State</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {query.data?.routes.map((route) => (
                    <tr
                      key={route.id}
                      className={selectedRoute?.id === route.id ? 'selected-row' : ''}
                    >
                      <td>
                        <strong>{route.name}</strong>
                        <div className="muted">{route.description || 'No description'}</div>
                      </td>
                      <td>{route.patternIds.length}</td>
                      <td>{route.acceptsDriverRequests ? 'Open' : 'Closed'}</td>
                      <td>
                        <StatusBadge value={route.archived ? 'archived' : 'active'} />
                      </td>
                      <td>
                        <Button appearance="subtle" onClick={() => setSelectedRoute(route)}>
                          Select
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TableState>
            {selectedRoute && (
              <div className="inline-actions">
                <strong>{selectedRoute.name}</strong>
                <Button onClick={() => startDialog('route-edit')}>Edit route</Button>
              </div>
            )}
          </Panel>
          <NetworkMap stops={query.data?.stops ?? []} routes={query.data?.routes.length ?? 0} />
        </div>
      )}

      {tab === 'stops' && (
        <div className="split-grid network-grid">
          <Panel title="Boarding points">
            <TableState loading={query.loading} empty={!query.data?.stops.length}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Name</th>
                    <th>Coordinates</th>
                    <th>State</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {query.data?.stops.map((stop) => (
                    <tr
                      key={stop.id}
                      className={selectedStop?.id === stop.id ? 'selected-row' : ''}
                    >
                      <td>
                        <strong>{stop.name}</strong>
                      </td>
                      <td className="mono">
                        {stop.location.latitude.toFixed(5)}, {stop.location.longitude.toFixed(5)}
                      </td>
                      <td>
                        <StatusBadge value={stop.archived ? 'archived' : 'active'} />
                      </td>
                      <td>
                        <Button appearance="subtle" onClick={() => setSelectedStop(stop)}>
                          Select
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TableState>
            {selectedStop && (
              <div className="inline-actions">
                <strong>{selectedStop.name}</strong>
                <Button onClick={() => startDialog('stop-edit')}>Edit stop</Button>
              </div>
            )}
          </Panel>
          <NetworkMap stops={query.data?.stops ?? []} routes={query.data?.routes.length ?? 0} />
        </div>
      )}

      {tab === 'patterns' && (
        <div className="split-grid network-grid">
          <Panel title="Directional patterns">
            <TableState loading={query.loading} empty={!query.data?.patterns.length}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Route</th>
                    <th>Direction</th>
                    <th>Published</th>
                    <th />
                  </tr>
                </thead>
                <tbody>
                  {query.data?.patterns.map((pattern) => (
                    <tr
                      key={pattern.id}
                      className={selectedPattern?.id === pattern.id ? 'selected-row' : ''}
                    >
                      <td>{routeById.get(pattern.routeId)?.name ?? pattern.routeId}</td>
                      <td>
                        <StatusBadge value={pattern.direction} />
                      </td>
                      <td>
                        {pattern.publishedVersionId
                          ? pattern.publishedVersionId.slice(0, 8)
                          : 'Draft only'}
                      </td>
                      <td>
                        <Button
                          appearance="subtle"
                          onClick={() => {
                            setSelectedPattern(pattern);
                            setSelectedVersion(null);
                          }}
                        >
                          Open
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </TableState>
          </Panel>
          <Panel
            title={selectedPattern ? `${selectedPattern.direction} versions` : 'Pattern versions'}
            action={
              selectedPattern ? (
                <Button onClick={() => startDialog('version-create')}>New version</Button>
              ) : undefined
            }
          >
            {!selectedPattern ? (
              <Empty>Select a directional pattern.</Empty>
            ) : versionQuery.loading ? (
              <LoadingRows />
            ) : !versionQuery.data?.length ? (
              <Empty>No versions yet.</Empty>
            ) : (
              <div className="stack-list">
                {versionQuery.data.map((version) => (
                  <button
                    className="stack-row"
                    key={version.id}
                    onClick={() => setSelectedVersion(version)}
                  >
                    <span>
                      <strong>Revision {version.revision}</strong>
                      <small>
                        {version.stops.length} stops · {when(version.createdAt)}
                      </small>
                    </span>
                    <StatusBadge value={version.state} />
                  </button>
                ))}
              </div>
            )}
            {selectedVersion && (
              <div className="version-detail">
                <div className="stop-list">
                  {selectedVersion.stops.map((stop, index) => (
                    <div className="stop-item" key={stop.id}>
                      <span>{index + 1}</span>
                      <strong>{stop.name}</strong>
                    </div>
                  ))}
                </div>
                {selectedVersion.state === 'draft' && (
                  <Button appearance="primary" onClick={() => startDialog('version-publish')}>
                    Publish revision
                  </Button>
                )}
              </div>
            )}
          </Panel>
        </div>
      )}

      {tab === 'schedules' && (
        <Panel title="Recurring departures">
          <TableState loading={query.loading} empty={!query.data?.schedules.length}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Window</th>
                  <th>Departure</th>
                  <th>Pattern</th>
                  <th>Days</th>
                  <th>Effective</th>
                </tr>
              </thead>
              <tbody>
                {query.data?.schedules.map((schedule) => (
                  <tr key={schedule.id}>
                    <td>
                      <StatusBadge value={schedule.serviceWindow} />
                    </td>
                    <td>
                      <strong>{schedule.localDeparture}</strong>
                      <div className="muted">Africa/Accra</div>
                    </td>
                    <td>
                      {patternById.get(schedule.patternId)?.direction ??
                        schedule.patternId.slice(0, 8)}
                    </td>
                    <td>
                      {schedule.weekdays
                        .map((day) => weekdays.find(([id]) => id === day)?.[1])
                        .join(', ')}
                    </td>
                    <td>
                      {schedule.effectiveFrom}
                      {schedule.effectiveTo ? ` – ${schedule.effectiveTo}` : ' onward'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TableState>
        </Panel>
      )}

      {tab === 'fares' && (
        <Panel
          title="Effective-dated fares"
          action={
            <select
              aria-label="Fare route"
              value={routeId}
              onChange={(event) => setRouteId(event.target.value)}
            >
              <option value="">Choose route</option>
              {query.data?.routes.map((route) => (
                <option key={route.id} value={route.id}>
                  {route.name}
                </option>
              ))}
            </select>
          }
        >
          {!routeId ? (
            <Empty>Choose a route to see its price history.</Empty>
          ) : fareQuery.loading ? (
            <LoadingRows />
          ) : !fareQuery.data?.length ? (
            <Empty>No fare has been published for this corridor.</Empty>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Amount</th>
                  <th>Effective from</th>
                  <th>Effective to</th>
                  <th>Note</th>
                </tr>
              </thead>
              <tbody>
                {fareQuery.data.map((fare) => (
                  <tr key={fare.id}>
                    <td>
                      <strong>GHS {(fare.amount.amountMinor / 100).toFixed(2)}</strong>
                    </td>
                    <td>{when(fare.effectiveFrom)}</td>
                    <td>{fare.effectiveTo ? when(fare.effectiveTo) : 'Current'}</td>
                    <td>{fare.note || '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </Panel>
      )}

      {tab === 'slots' && (
        <Panel title="Commute capacity">
          <TableState loading={query.loading} empty={!query.data?.slots.length}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Route</th>
                  <th>Available</th>
                  <th>Outbound / return</th>
                  <th>State</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {query.data?.slots.map((slot) => (
                  <tr key={slot.id}>
                    <td>{routeById.get(slot.routeId)?.name ?? slot.routeId}</td>
                    <td>{slot.availableFrom}</td>
                    <td>
                      {slot.legs
                        .map((leg) => `${leg.direction} ${leg.scheduleId.slice(0, 8)}`)
                        .join(' · ')}
                    </td>
                    <td>
                      <StatusBadge value={slot.state} />
                    </td>
                    <td>
                      {slot.state === 'available' && (
                        <Button
                          appearance="subtle"
                          onClick={() => {
                            setSelectedSlot(slot);
                            startDialog('slot-retire');
                          }}
                        >
                          Retire
                        </Button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TableState>
        </Panel>
      )}

      <ActionDialog
        open={dialog !== null}
        title={dialogTitle(dialog)}
        confirmLabel={
          dialog === 'version-publish'
            ? 'Publish'
            : dialog === 'slot-retire'
              ? 'Retire'
              : dialog?.endsWith('edit')
                ? 'Save'
                : 'Create'
        }
        danger={dialog === 'slot-retire' || (dialog?.endsWith('edit') && archived)}
        onClose={() => setDialog(null)}
        onConfirm={async () => {
          await submit();
          setDialog(null);
          refreshAll();
        }}
      >
        {(dialog === 'route-create' || dialog === 'route-edit') && (
          <>
            <label>
              Name
              <input required value={name} onChange={(event) => setName(event.target.value)} />
            </label>
            <label>
              Description
              <textarea
                rows={3}
                value={description}
                onChange={(event) => setDescription(event.target.value)}
              />
            </label>
            <label className="check-row">
              <input
                type="checkbox"
                checked={acceptsDriverRequests}
                onChange={(event) => setAcceptsDriverRequests(event.target.checked)}
              />
              Accept driver route-change requests
            </label>
            {dialog === 'route-edit' && (
              <label className="check-row">
                <input
                  type="checkbox"
                  checked={archived}
                  onChange={(event) => setArchived(event.target.checked)}
                />
                Archive route
              </label>
            )}
          </>
        )}
        {(dialog === 'stop-create' || dialog === 'stop-edit') && (
          <>
            <label>
              Name
              <input required value={name} onChange={(event) => setName(event.target.value)} />
            </label>
            <label>
              Latitude
              <input
                type="number"
                step="any"
                required
                value={latitude}
                onChange={(event) => setLatitude(event.target.value)}
              />
            </label>
            <label>
              Longitude
              <input
                type="number"
                step="any"
                required
                value={longitude}
                onChange={(event) => setLongitude(event.target.value)}
              />
            </label>
            {dialog === 'stop-edit' && (
              <label className="check-row">
                <input
                  type="checkbox"
                  checked={archived}
                  onChange={(event) => setArchived(event.target.checked)}
                />
                Archive stop
              </label>
            )}
          </>
        )}
        {dialog === 'pattern-create' && (
          <>
            <label>
              Route
              <select required value={routeId} onChange={(event) => setRouteId(event.target.value)}>
                <option value="">Choose route</option>
                {query.data?.routes
                  .filter((route) => !route.archived)
                  .map((route) => (
                    <option key={route.id} value={route.id}>
                      {route.name}
                    </option>
                  ))}
              </select>
            </label>
            <label>
              Direction
              <select
                value={direction}
                onChange={(event) => setDirection(event.target.value as typeof direction)}
              >
                <option value="outbound">Outbound</option>
                <option value="return">Return</option>
              </select>
            </label>
          </>
        )}
        {dialog === 'version-create' && (
          <>
            <p className="dialog-note">
              Choose stops in travel order. The first draft uses the stop-to-stop line; review it
              before publishing.
            </p>
            <div className="choice-grid">
              {query.data?.stops
                .filter((stop) => !stop.archived)
                .map((stop) => (
                  <label className="check-row" key={stop.id}>
                    <input
                      type="checkbox"
                      checked={versionStops.includes(stop.id)}
                      onChange={(event) =>
                        setVersionStops((current) =>
                          event.target.checked
                            ? [...current, stop.id]
                            : current.filter((id) => id !== stop.id),
                        )
                      }
                    />
                    {versionStops.includes(stop.id) ? `${versionStops.indexOf(stop.id) + 1}. ` : ''}
                    {stop.name}
                  </label>
                ))}
            </div>
          </>
        )}
        {dialog === 'version-publish' && (
          <>
            <label>
              Effective from
              <input
                type="datetime-local"
                required
                value={effectiveFrom}
                onChange={(event) => setEffectiveFrom(event.target.value)}
              />
            </label>
            <label>
              Reason
              <textarea
                rows={3}
                required
                value={reason}
                onChange={(event) => setReason(event.target.value)}
              />
            </label>
          </>
        )}
        {dialog === 'schedule-create' && (
          <>
            <label>
              Published pattern version
              <select
                required
                value={patternVersionId}
                onChange={(event) => setPatternVersionId(event.target.value)}
              >
                <option value="">Choose version</option>
                {query.data?.patterns
                  .filter((pattern) => pattern.publishedVersionId)
                  .map((pattern) => (
                    <option key={pattern.id} value={pattern.publishedVersionId!}>
                      {routeById.get(pattern.routeId)?.name} · {pattern.direction}
                    </option>
                  ))}
              </select>
            </label>
            <label>
              Service window
              <select
                value={serviceWindow}
                onChange={(event) => setServiceWindow(event.target.value as typeof serviceWindow)}
              >
                <option value="morning">Morning</option>
                <option value="evening">Evening</option>
              </select>
            </label>
            <label>
              Departure
              <input
                type="time"
                required
                value={localDeparture}
                onChange={(event) => setLocalDeparture(event.target.value)}
              />
            </label>
            <div className="choice-grid">
              {weekdays.map(([id, label]) => (
                <label className="check-row" key={id}>
                  <input
                    type="checkbox"
                    checked={selectedWeekdays.includes(id)}
                    onChange={(event) =>
                      setSelectedWeekdays((current) =>
                        event.target.checked
                          ? [...current, id].sort()
                          : current.filter((day) => day !== id),
                      )
                    }
                  />
                  {label}
                </label>
              ))}
            </div>
            <label>
              Effective from
              <input
                type="date"
                required
                value={effectiveFrom}
                onChange={(event) => setEffectiveFrom(event.target.value)}
              />
            </label>
            <label>
              Effective to (optional)
              <input
                type="date"
                value={effectiveTo}
                onChange={(event) => setEffectiveTo(event.target.value)}
              />
            </label>
          </>
        )}
        {dialog === 'fare-create' && (
          <>
            <label>
              Route
              <select required value={routeId} onChange={(event) => setRouteId(event.target.value)}>
                <option value="">Choose route</option>
                {query.data?.routes
                  .filter((route) => !route.archived)
                  .map((route) => (
                    <option key={route.id} value={route.id}>
                      {route.name}
                    </option>
                  ))}
              </select>
            </label>
            <label>
              Fare (GHS)
              <input
                type="number"
                min="0"
                step="0.01"
                required
                value={amountGhs}
                onChange={(event) => setAmountGhs(event.target.value)}
              />
            </label>
            <label>
              Effective from
              <input
                type="datetime-local"
                required
                value={effectiveFrom}
                onChange={(event) => setEffectiveFrom(event.target.value)}
              />
            </label>
            <label>
              Note
              <textarea rows={3} value={note} onChange={(event) => setNote(event.target.value)} />
            </label>
          </>
        )}
        {dialog === 'slot-create' && (
          <>
            <label>
              Route
              <select required value={routeId} onChange={(event) => setRouteId(event.target.value)}>
                <option value="">Choose route</option>
                {query.data?.routes
                  .filter((route) => !route.archived)
                  .map((route) => (
                    <option key={route.id} value={route.id}>
                      {route.name}
                    </option>
                  ))}
              </select>
            </label>
            <label>
              Available from
              <input
                type="date"
                required
                value={effectiveFrom}
                onChange={(event) => setEffectiveFrom(event.target.value)}
              />
            </label>
            <LegFields
              label="Outbound"
              scheduleId={outboundScheduleId}
              setScheduleId={setOutboundScheduleId}
              pickup={outboundPickup}
              setPickup={setOutboundPickup}
              dropoff={outboundDropoff}
              setDropoff={setOutboundDropoff}
              schedules={(query.data?.schedules ?? []).filter(
                (schedule) => schedule.serviceWindow === 'morning',
              )}
            />
            <LegFields
              label="Return"
              scheduleId={returnScheduleId}
              setScheduleId={setReturnScheduleId}
              pickup={returnPickup}
              setPickup={setReturnPickup}
              dropoff={returnDropoff}
              setDropoff={setReturnDropoff}
              schedules={(query.data?.schedules ?? []).filter(
                (schedule) => schedule.serviceWindow === 'evening',
              )}
            />
          </>
        )}
        {dialog === 'slot-retire' && (
          <label>
            Reason
            <textarea
              rows={3}
              required
              value={reason}
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
        )}
      </ActionDialog>
    </Page>
  );

  async function submit() {
    const key = crypto.randomUUID();
    const mutation = { ...opsHeaders, 'Idempotency-Key': key };
    if (dialog === 'route-create') {
      const response = await session.client.POST('/v1/ops/routes', {
        params: { header: mutation },
        body: { name, description, acceptsDriverRequests },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'route-edit' && selectedRoute) {
      const response = await session.client.PATCH('/v1/ops/routes/{id}', {
        params: {
          path: { id: selectedRoute.id },
          header: { ...mutation, 'If-Match': selectedRoute.editToken },
        },
        body: { name, description: description || null, acceptsDriverRequests, archived },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'stop-create') {
      const response = await session.client.POST('/v1/ops/stops', {
        params: { header: mutation },
        body: { name, location: { latitude: Number(latitude), longitude: Number(longitude) } },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'stop-edit' && selectedStop) {
      const response = await session.client.PATCH('/v1/ops/stops/{id}', {
        params: {
          path: { id: selectedStop.id },
          header: { ...mutation, 'If-Match': selectedStop.editToken },
        },
        body: {
          name,
          location: { latitude: Number(latitude), longitude: Number(longitude) },
          archived,
        },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'pattern-create') {
      const response = await session.client.POST('/v1/ops/route-patterns', {
        params: { header: mutation },
        body: { routeId, direction },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'version-create' && selectedPattern) {
      const chosen = versionStops
        .map((id) => query.data?.stops.find((stop) => stop.id === id))
        .filter((stop): stop is Stop => Boolean(stop));
      if (chosen.length < 2) throw new Error('Choose at least two stops in travel order.');
      const response = await session.client.POST('/v1/ops/route-patterns/{id}/versions', {
        params: { path: { id: selectedPattern.id }, header: mutation },
        body: {
          stops: chosen.map((stop) => ({
            stopId: stop.id,
            name: stop.name,
            location: stop.location,
          })),
          geometry: {
            points: chosen.map((stop) => stop.location),
            stopDistancesMeters: straightLineDistances(chosen),
          },
        },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'version-publish' && selectedPattern && selectedVersion) {
      const response = await session.client.POST(
        '/v1/ops/route-patterns/{id}/versions/{versionId}/publish',
        {
          params: {
            path: { id: selectedPattern.id, versionId: selectedVersion.id },
            header: { ...mutation, 'If-Match': selectedVersion.editToken },
          },
          body: { reason, effectiveFrom: toIso(effectiveFrom) },
        },
      );
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'schedule-create') {
      const response = await session.client.POST('/v1/ops/service-schedules', {
        params: { header: mutation },
        body: {
          departure: { kind: 'new' },
          patternVersionId,
          serviceWindow,
          localDeparture,
          timeZone: 'Africa/Accra',
          weekdays: selectedWeekdays,
          effectiveFrom,
          effectiveTo: effectiveTo || null,
        },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'fare-create') {
      const response = await session.client.POST('/v1/ops/routes/{id}/fares', {
        params: { path: { id: routeId }, header: mutation },
        body: {
          amount: { amountMinor: Math.round(Number(amountGhs) * 100), currency: 'GHS' },
          effectiveFrom: toIso(effectiveFrom),
          note,
        },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'slot-create') {
      const outbound = query.data?.schedules.find((schedule) => schedule.id === outboundScheduleId);
      const inbound = query.data?.schedules.find((schedule) => schedule.id === returnScheduleId);
      if (!outbound || !inbound) throw new Error('Choose both departure schedules.');
      const response = await session.client.POST('/v1/ops/commute-slots', {
        params: { header: mutation },
        body: {
          routeId,
          availableFrom: effectiveFrom,
          legs: [
            {
              direction: 'outbound',
              scheduleId: outbound.id,
              patternVersionId: outbound.patternVersionId,
              pickupOccurrenceId: outboundPickup,
              dropoffOccurrenceId: outboundDropoff,
            },
            {
              direction: 'return',
              scheduleId: inbound.id,
              patternVersionId: inbound.patternVersionId,
              pickupOccurrenceId: returnPickup,
              dropoffOccurrenceId: returnDropoff,
            },
          ],
        },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (dialog === 'slot-retire' && selectedSlot) {
      const response = await session.client.POST('/v1/ops/commute-slots/{id}/retire', {
        params: {
          path: { id: selectedSlot.id },
          header: { ...mutation, 'If-Match': selectedSlot.editToken },
        },
        body: { reason },
      });
      if (response.error) throw new Error(response.error.error.message);
    }
  }
}

function TableState({
  loading,
  empty,
  children,
}: {
  loading: boolean;
  empty: boolean;
  children: ReactNode;
}) {
  if (loading) return <LoadingRows />;
  if (empty) return <Empty />;
  return <div style={{ overflowX: 'auto' }}>{children}</div>;
}

function NetworkMap({ stops, routes }: { stops: Stop[]; routes: number }) {
  return (
    <Panel title="Network map">
      <LiveMap
        markers={stops
          .filter((stop) => !stop.archived)
          .map((stop) => ({ id: stop.id, ...stop.location, label: stop.name, state: 'stop' }))}
      />
      <div className="map-meta">
        {routes} corridors · {stops.length} stops
      </div>
    </Panel>
  );
}

function LegFields({
  label,
  scheduleId,
  setScheduleId,
  pickup,
  setPickup,
  dropoff,
  setDropoff,
  schedules,
}: {
  label: string;
  scheduleId: string;
  setScheduleId: (value: string) => void;
  pickup: string;
  setPickup: (value: string) => void;
  dropoff: string;
  setDropoff: (value: string) => void;
  schedules: Schedule[];
}) {
  return (
    <fieldset className="form-section">
      <legend>{label}</legend>
      <label>
        Schedule
        <select required value={scheduleId} onChange={(event) => setScheduleId(event.target.value)}>
          <option value="">Choose schedule</option>
          {schedules.map((schedule) => (
            <option key={schedule.id} value={schedule.id}>
              {schedule.localDeparture} · {schedule.id.slice(0, 8)}
            </option>
          ))}
        </select>
      </label>
      <label>
        Pickup occurrence ID
        <input required value={pickup} onChange={(event) => setPickup(event.target.value)} />
      </label>
      <label>
        Drop-off occurrence ID
        <input required value={dropoff} onChange={(event) => setDropoff(event.target.value)} />
      </label>
    </fieldset>
  );
}

function dialogTitle(dialog: DialogKind | null) {
  if (!dialog) return '';
  return (
    {
      'route-create': 'Create route',
      'route-edit': 'Edit route',
      'stop-create': 'Create stop',
      'stop-edit': 'Edit stop',
      'pattern-create': 'Create directional pattern',
      'version-create': 'Create pattern version',
      'version-publish': 'Publish pattern version',
      'schedule-create': 'Create schedule',
      'fare-create': 'Publish fare',
      'slot-create': 'Create commute slot',
      'slot-retire': 'Retire commute slot',
    } satisfies Record<DialogKind, string>
  )[dialog];
}
