import { Button, Input, Tab, TabList } from '@fluentui/react-components';
import { AddRegular, ArrowClockwiseRegular } from '@fluentui/react-icons';
import { useMemo, useState, type ReactNode } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { accraLocalToIso } from '../api/accra-time';
import { ActionDialog } from '../components/ActionDialog';
import { LiveMap } from '../components/LiveMap';
import { buildRouteGeometry, type RoutePoint } from './routeGeometry';

type Route = components['schemas']['Route'];
type Stop = components['schemas']['Stop'];
type Pattern = components['schemas']['Pattern'];
type PatternVersion = components['schemas']['PatternVersion'];
type Schedule = components['schemas']['Schedule'];
type CommuteSlot = components['schemas']['CommuteSlot'];
type Fare = components['schemas']['Fare'];
type PlanPricing = components['schemas']['PlanPricing'];
type TabName = 'routes' | 'stops' | 'patterns' | 'schedules' | 'fares' | 'pricing' | 'slots';
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
  | 'pricing-edit'
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
  return accraLocalToIso(value);
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
  const [selectedPricing, setSelectedPricing] = useState<PlanPricing | null>(null);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [acceptsDriverRequests, setAcceptsDriverRequests] = useState(false);
  const [archived, setArchived] = useState(false);
  const [latitude, setLatitude] = useState('5.6037');
  const [longitude, setLongitude] = useState('-0.1870');
  const [routeId, setRouteId] = useState('');
  const [direction, setDirection] = useState<'outbound' | 'return'>('outbound');
  const [versionStops, setVersionStops] = useState<string[]>([]);
  const [routeWaypoints, setRouteWaypoints] = useState<Record<number, RoutePoint[]>>({});
  const [confirmedSegments, setConfirmedSegments] = useState<number[]>([]);
  const [activeSegment, setActiveSegment] = useState(0);
  const [nextStopId, setNextStopId] = useState('');
  const [waypointLatitude, setWaypointLatitude] = useState('');
  const [waypointLongitude, setWaypointLongitude] = useState('');
  const [effectiveFrom, setEffectiveFrom] = useState(today());
  const [effectiveTo, setEffectiveTo] = useState('');
  const [reason, setReason] = useState('');
  const [patternVersionId, setPatternVersionId] = useState('');
  const [serviceWindow, setServiceWindow] = useState<'morning' | 'evening'>('morning');
  const [localDeparture, setLocalDeparture] = useState('06:30');
  const [selectedWeekdays, setSelectedWeekdays] = useState([1, 2, 3, 4, 5]);
  const [amountGhs, setAmountGhs] = useState('6');
  const [ridesPerPeriod, setRidesPerPeriod] = useState(44);
  const [priceMultiplierBp, setPriceMultiplierBp] = useState(10000);
  const [takeRateBp, setTakeRateBp] = useState(0);
  const [creditPerRideGhs, setCreditPerRideGhs] = useState('0');
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
    pricing: PlanPricing[];
  }>(
    async (signal) => {
      const [routes, stops, patterns, schedules, slots, pricing] = await Promise.all([
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
        session.client.GET('/v1/ops/plan-pricing', {
          params: { query: { limit: 10 }, header: opsHeaders },
          signal,
        }),
      ]);
      const failure =
        routes.error ??
        stops.error ??
        patterns.error ??
        schedules.error ??
        slots.error ??
        pricing.error;
      if (failure) throw new Error(failure.error.message);
      if (
        !routes.data ||
        !stops.data ||
        !patterns.data ||
        !schedules.data ||
        !slots.data ||
        !pricing.data
      ) {
        throw new Error('The network workspace returned an incomplete response.');
      }
      return {
        routes: routes.data.data,
        stops: stops.data.data,
        patterns: patterns.data.data,
        schedules: schedules.data.data,
        slots: slots.data.data,
        pricing: pricing.data.data,
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

  const versionDetailQuery = useQuery<PatternVersion | null>(
    async (signal) => {
      if (!selectedPattern || !selectedVersion) return null;
      const { data, error } = await session.client.GET(
        '/v1/ops/route-patterns/{id}/versions/{versionId}',
        {
          params: {
            path: { id: selectedPattern.id, versionId: selectedVersion.id },
            header: opsHeaders,
          },
          signal,
        },
      );
      if (error) throw new Error(error.error.message);
      return data.data;
    },
    [session, selectedPattern?.id, selectedVersion?.id],
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
  const draftStops = useMemo(
    () =>
      versionStops
        .map((id) => query.data?.stops.find((stop) => stop.id === id))
        .filter((stop): stop is Stop => Boolean(stop)),
    [versionStops, query.data?.stops],
  );
  const draftLine = useMemo(() => {
    if (!draftStops.length) return [];
    const points: RoutePoint[] = [draftStops[0].location];
    for (let segment = 0; segment < draftStops.length - 1; segment += 1)
      points.push(...(routeWaypoints[segment] ?? []), draftStops[segment + 1].location);
    return points;
  }, [draftStops, routeWaypoints]);

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
      setRouteWaypoints({});
      setConfirmedSegments([]);
      setActiveSegment(0);
      setNextStopId('');
      setWaypointLatitude('');
      setWaypointLongitude('');
    } else if (kind === 'version-publish') {
      setEffectiveFrom(new Date().toISOString().slice(0, 16));
    } else if (kind === 'schedule-create') {
      setPatternVersionId('');
      setEffectiveFrom(today());
      setEffectiveTo('');
    } else if (kind === 'fare-create') {
      setAmountGhs('6');
      setEffectiveFrom(new Date().toISOString().slice(0, 16));
    } else if (kind === 'pricing-edit' && selectedPricing) {
      setRidesPerPeriod(selectedPricing.ridesPerPeriod);
      setPriceMultiplierBp(selectedPricing.priceMultiplierBp);
      setTakeRateBp(selectedPricing.takeRateBp);
      setCreditPerRideGhs(String(selectedPricing.creditPerRide.amountMinor / 100));
    } else if (kind === 'slot-create') {
      setRouteId(query.data?.routes[0]?.id ?? '');
      setEffectiveFrom(today());
    }
  };

  const refreshAll = () => {
    query.retry();
    versionQuery.retry();
    versionDetailQuery.retry();
    fareQuery.retry();
  };

  const actionLabel: Record<TabName, string> = {
    routes: 'New route',
    stops: 'New stop',
    patterns: 'New pattern',
    schedules: 'New schedule',
    fares: 'New fare',
    pricing: 'Edit plan',
    slots: 'New slot',
  };
  const actionKind: Record<TabName, DialogKind> = {
    routes: 'route-create',
    stops: 'stop-create',
    patterns: 'pattern-create',
    schedules: 'schedule-create',
    fares: 'fare-create',
    pricing: 'pricing-edit',
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
          {tab !== 'pricing' && (
            <Button
              appearance="primary"
              icon={<AddRegular />}
              onClick={() => startDialog(actionKind[tab])}
            >
              {actionLabel[tab]}
            </Button>
          )}
        </>
      }
    >
      <TabList selectedValue={tab} onTabSelect={(_, data) => setTab(data.value as TabName)}>
        <Tab value="routes">Routes</Tab>
        <Tab value="stops">Stops</Tab>
        <Tab value="patterns">Patterns & versions</Tab>
        <Tab value="schedules">Schedules</Tab>
        <Tab value="fares">Fares</Tab>
        <Tab value="pricing">Plan pricing</Tab>
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
                  {(versionDetailQuery.data ?? selectedVersion).stops.map((stop, index) => (
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

      {tab === 'pricing' && (
        <Panel title="Membership plan pricing">
          <TableState loading={query.loading} empty={!query.data?.pricing.length}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Plan</th>
                  <th>Rides</th>
                  <th>Price multiplier</th>
                  <th>Take rate</th>
                  <th>Conversion credit</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {query.data?.pricing.map((row) => (
                  <tr key={row.plan}>
                    <td>
                      <strong>{row.plan}</strong>
                    </td>
                    <td>{row.ridesPerPeriod}</td>
                    <td>{(row.priceMultiplierBp / 100).toFixed(2)}%</td>
                    <td>{(row.takeRateBp / 100).toFixed(2)}%</td>
                    <td>GHS {(row.creditPerRide.amountMinor / 100).toFixed(2)} / ride</td>
                    <td>
                      <Button
                        appearance="subtle"
                        onClick={() => {
                          setSelectedPricing(row);
                          setRidesPerPeriod(row.ridesPerPeriod);
                          setPriceMultiplierBp(row.priceMultiplierBp);
                          setTakeRateBp(row.takeRateBp);
                          setCreditPerRideGhs(String(row.creditPerRide.amountMinor / 100));
                          setDialog('pricing-edit');
                        }}
                      >
                        Edit
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </TableState>
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
        wide={dialog === 'version-create'}
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
              Add stops in travel order, then trace each leg by clicking the map. This is a manual
              path—not an automatically optimised road route. Check the drawn line before
              publishing.
            </p>
            <div className="route-draft-layout">
              <div className="route-draft-controls">
                <label>
                  Add stop occurrence
                  <select
                    value={nextStopId}
                    onChange={(event) => setNextStopId(event.target.value)}
                  >
                    <option value="">Choose a stop</option>
                    {query.data?.stops
                      .filter((stop) => !stop.archived)
                      .map((stop) => (
                        <option key={stop.id} value={stop.id}>
                          {stop.name}
                        </option>
                      ))}
                  </select>
                </label>
                <Button
                  disabled={!nextStopId}
                  onClick={() => {
                    setActiveSegment(Math.max(0, versionStops.length - 1));
                    setVersionStops((current) => [...current, nextStopId]);
                    setConfirmedSegments([]);
                    setNextStopId('');
                  }}
                >
                  Add to route
                </Button>
                <ol className="route-draft-stops">
                  {draftStops.map((stop, index) => (
                    <li key={`${stop.id}-${index}`}>
                      <span>{stop.name}</span>
                      <Button
                        size="small"
                        aria-label={`Remove occurrence ${index + 1}: ${stop.name}`}
                        onClick={() => {
                          setVersionStops((current) => current.filter((_, at) => at !== index));
                          setRouteWaypoints({});
                          setConfirmedSegments([]);
                          setActiveSegment(0);
                        }}
                      >
                        Remove
                      </Button>
                    </li>
                  ))}
                </ol>
                {draftStops.length >= 2 && (
                  <>
                    <label>
                      Draw leg
                      <select
                        value={activeSegment}
                        onChange={(event) => setActiveSegment(Number(event.target.value))}
                      >
                        {draftStops.slice(0, -1).map((stop, index) => (
                          <option key={index} value={index}>
                            {index + 1}. {stop.name} → {draftStops[index + 1].name} (
                            {routeWaypoints[index]?.length ?? 0} waypoints
                            {confirmedSegments.includes(index) ? ', confirmed' : ', needs review'})
                          </option>
                        ))}
                      </select>
                    </label>
                    <div className="route-draft-coordinate-inputs">
                      <label>
                        Latitude
                        <input
                          type="number"
                          step="any"
                          value={waypointLatitude}
                          onChange={(event) => setWaypointLatitude(event.target.value)}
                        />
                      </label>
                      <label>
                        Longitude
                        <input
                          type="number"
                          step="any"
                          value={waypointLongitude}
                          onChange={(event) => setWaypointLongitude(event.target.value)}
                        />
                      </label>
                    </div>
                    <Button
                      disabled={
                        !waypointLatitude ||
                        !waypointLongitude ||
                        !Number.isFinite(Number(waypointLatitude)) ||
                        !Number.isFinite(Number(waypointLongitude))
                      }
                      onClick={() => {
                        const point = {
                          latitude: Number(waypointLatitude),
                          longitude: Number(waypointLongitude),
                        };
                        setRouteWaypoints((current) => ({
                          ...current,
                          [activeSegment]: [...(current[activeSegment] ?? []), point],
                        }));
                        setConfirmedSegments((current) =>
                          current.filter((segment) => segment !== activeSegment),
                        );
                        setWaypointLatitude('');
                        setWaypointLongitude('');
                      }}
                    >
                      Add waypoint by coordinates
                    </Button>
                    <Button
                      disabled={!routeWaypoints[activeSegment]?.length}
                      onClick={() => {
                        setRouteWaypoints((current) => ({
                          ...current,
                          [activeSegment]: current[activeSegment]?.slice(0, -1) ?? [],
                        }));
                        setConfirmedSegments((current) =>
                          current.filter((segment) => segment !== activeSegment),
                        );
                      }}
                    >
                      Undo last waypoint
                    </Button>
                    <Button
                      appearance={
                        confirmedSegments.includes(activeSegment) ? 'secondary' : 'primary'
                      }
                      onClick={() =>
                        setConfirmedSegments((current) =>
                          current.includes(activeSegment) ? current : [...current, activeSegment],
                        )
                      }
                    >
                      {confirmedSegments.includes(activeSegment)
                        ? 'Leg reviewed'
                        : 'Confirm this leg follows the planned road'}
                    </Button>
                  </>
                )}
              </div>
              <div className="route-draft-map">
                <LiveMap
                  markers={draftStops.map((stop, index) => ({
                    id: `${stop.id}-${index}`,
                    ...stop.location,
                    label: `${index + 1}. ${stop.name}`,
                    state: 'stop',
                  }))}
                  line={draftLine}
                  onMapClick={(point) => {
                    if (draftStops.length < 2) return;
                    setRouteWaypoints((current) => ({
                      ...current,
                      [activeSegment]: [...(current[activeSegment] ?? []), point],
                    }));
                    setConfirmedSegments((current) =>
                      current.filter((segment) => segment !== activeSegment),
                    );
                  }}
                />
                <p className="muted">
                  Click along the road for leg {activeSegment + 1}. If the map is unavailable, enter
                  waypoint coordinates on the left. The line is operator-configured, not snapped to
                  roads.
                </p>
              </div>
            </div>
          </>
        )}
        {dialog === 'version-publish' && (
          <>
            <label>
              Effective from (Accra time, GMT)
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
              Effective from (service date)
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
              Effective from (Accra time, GMT)
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
        {dialog === 'pricing-edit' && selectedPricing && (
          <>
            <p className="dialog-note">
              Editing the {selectedPricing.plan} plan changes future purchases only.
            </p>
            <label>
              Rides per period
              <input
                type="number"
                min="1"
                required
                value={ridesPerPeriod}
                onChange={(event) => setRidesPerPeriod(Number(event.target.value))}
              />
            </label>
            <label>
              Price multiplier (basis points)
              <input
                type="number"
                min="1"
                required
                value={priceMultiplierBp}
                onChange={(event) => setPriceMultiplierBp(Number(event.target.value))}
              />
            </label>
            <label>
              Operator take rate (basis points)
              <input
                type="number"
                min="0"
                max="10000"
                required
                value={takeRateBp}
                onChange={(event) => setTakeRateBp(Number(event.target.value))}
              />
            </label>
            <label>
              Credit per unused ride (GHS)
              <input
                type="number"
                min="0"
                step="0.01"
                required
                value={creditPerRideGhs}
                onChange={(event) => setCreditPerRideGhs(event.target.value)}
              />
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
      const chosen = draftStops;
      if (chosen.slice(0, -1).some((_, index) => !confirmedSegments.includes(index)))
        throw new Error('Review and confirm every route leg before creating the draft.');
      const geometry = buildRouteGeometry(chosen, routeWaypoints);
      const response = await session.client.POST('/v1/ops/route-patterns/{id}/versions', {
        params: { path: { id: selectedPattern.id }, header: mutation },
        body: {
          stops: chosen.map((stop) => ({
            stopId: stop.id,
            name: stop.name,
            location: stop.location,
          })),
          geometry,
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
    } else if (dialog === 'pricing-edit' && selectedPricing) {
      const response = await session.client.PATCH('/v1/ops/plan-pricing/{plan}', {
        params: {
          path: { plan: selectedPricing.plan },
          header: {
            ...mutation,
            'If-Match': selectedPricing.editToken,
          },
        },
        body: {
          ridesPerPeriod,
          priceMultiplierBp,
          takeRateBp,
          creditPerRide: {
            amountMinor: Math.round(Number(creditPerRideGhs) * 100),
            currency: 'GHS',
          },
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
      'pricing-edit': 'Edit plan pricing',
      'slot-create': 'Create commute slot',
      'slot-retire': 'Retire commute slot',
    } satisfies Record<DialogKind, string>
  )[dialog];
}
