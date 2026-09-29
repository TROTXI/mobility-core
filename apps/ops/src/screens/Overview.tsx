import { Button, Tab, TabList } from '@fluentui/react-components';
import { ArrowClockwiseRegular } from '@fluentui/react-icons';
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { LiveMap } from '../components/LiveMap';
import { formatAccraClock } from '../api/accra-time';
import {
  fixDescription,
  homeTrips,
  homeTripStatus,
  needsOperatorAttention,
  withObservedAge,
} from './overview-view';

type OverviewData = components['schemas']['OpsOverview'];
type Point = { latitude: number; longitude: number };
type TripLine = {
  versionId: string;
  points: Point[];
  source: 'geometry' | 'stops' | 'unavailable';
};
const emptyLine: Point[] = [];

export function Overview() {
  const { session } = useAuth();
  const [windowName, setWindowName] = useState<'morning' | 'evening'>('morning');
  const [date, setDate] = useState('');
  const [selectedTripId, setSelectedTripId] = useState<string | null>(null);
  const [attentionOnly, setAttentionOnly] = useState(false);
  const [search, setSearch] = useState('');
  const [tripLine, setTripLine] = useState<TripLine | null>(null);
  const [clockNow, setClockNow] = useState(() => Date.now());
  const [snapshot, setSnapshot] = useState<{ data: OverviewData | null; receivedAt: number }>({
    data: null,
    receivedAt: Date.now(),
  });
  const query = useQuery<OverviewData>(
    async (signal) => {
      const { data, error } = await session.client.GET('/v1/ops/overview', {
        params: { query: { window: windowName, ...(date ? { date } : {}) }, header: opsHeaders },
        signal,
      });
      if (error) throw new Error(error.error.message);
      return data.data;
    },
    [session, windowName, date],
  );

  useEffect(() => {
    const timer = window.setInterval(query.retry, 10_000);
    return () => window.clearInterval(timer);
  }, [query.retry]);

  useEffect(() => {
    setSnapshot({ data: query.data, receivedAt: Date.now() });
  }, [query.data]);
  useEffect(() => {
    const timer = window.setInterval(() => setClockNow(Date.now()), 10_000);
    return () => window.clearInterval(timer);
  }, []);

  const tiles = query.data?.tiles;
  const elapsedSeconds =
    snapshot.data === query.data ? Math.max(0, (clockNow - snapshot.receivedAt) / 1000) : 0;
  const trips = (query.data?.trips ?? []).map((trip) =>
    withObservedAge(trip, elapsedSeconds, query.data?.staleFixAfterSeconds ?? 300),
  );
  const priorityTrips = homeTrips(trips);
  const visibleTrips = priorityTrips.filter((trip) => {
    if (attentionOnly && !needsOperatorAttention(trip)) return false;
    const needle = search.trim().toLowerCase();
    return (
      !needle ||
      [trip.routeName, trip.driverName, trip.vehiclePlate, trip.vehicleLabel].some((value) =>
        value?.toLowerCase().includes(needle),
      )
    );
  });
  const selectedTrip =
    visibleTrips.find((trip) => trip.tripId === selectedTripId) ?? visibleTrips[0];
  const selectedPatternId = selectedTrip?.patternId;
  const selectedVersionId = selectedTrip?.patternVersionId;
  useEffect(() => {
    setTripLine(null);
    if (!selectedPatternId || !selectedVersionId) return;
    const controller = new AbortController();
    const load = async () => {
      const version = await session.client.GET('/v1/ops/route-patterns/{id}/versions/{versionId}', {
        params: {
          path: { id: selectedPatternId, versionId: selectedVersionId },
          header: opsHeaders,
        },
        signal: controller.signal,
      });
      if (version.error || !version.data) {
        if (!controller.signal.aborted)
          setTripLine({ versionId: selectedVersionId, points: [], source: 'unavailable' });
        return;
      }
      const fallback = [...version.data.data.stops]
        .sort((a, b) => a.ordinal - b.ordinal)
        .map((stop) => stop.location);
      const geometryId = version.data.data.geometryId;
      if (geometryId) {
        try {
          const geometry = await session.client.GET('/v1/route-geometries/{id}', {
            params: { path: { id: geometryId }, header: opsHeaders },
            signal: controller.signal,
          });
          if (!geometry.error && geometry.data && geometry.data.data.points.length >= 2) {
            if (!controller.signal.aborted)
              setTripLine({
                versionId: selectedVersionId,
                points: geometry.data.data.points,
                source: 'geometry',
              });
            return;
          }
        } catch {
          // A missing geometry does not hide the ordered stop path.
        }
      }
      if (!controller.signal.aborted)
        setTripLine({
          versionId: selectedVersionId,
          points: fallback.length >= 2 ? fallback : [],
          source: fallback.length >= 2 ? 'stops' : 'unavailable',
        });
    };
    void load().catch(() => {
      if (!controller.signal.aborted)
        setTripLine({ versionId: selectedVersionId, points: [], source: 'unavailable' });
    });
    return () => controller.abort();
  }, [session, selectedPatternId, selectedVersionId]);
  const liveMarkers = trips.flatMap((trip) =>
    trip.status === 'active' && trip.lastPosition
      ? [
          {
            id: trip.tripId,
            ...trip.lastPosition,
            label: `${trip.routeName ?? 'Route'} · ${trip.vehiclePlate ?? trip.vehicleLabel ?? 'vehicle'} · ${fixDescription(trip)}`,
            state: trip.badge,
          },
        ]
      : [],
  );
  return (
    <Page
      title="Live operations"
      description="Running trips and issues that need action."
      actions={
        <>
          <input
            aria-label="Service date"
            type="date"
            value={date}
            onChange={(event) => setDate(event.target.value)}
          />
          <Button appearance="subtle" icon={<ArrowClockwiseRegular />} onClick={query.retry}>
            Refresh
          </Button>
        </>
      }
    >
      <TabList
        selectedValue={windowName}
        onTabSelect={(_, data) => setWindowName(data.value as 'morning' | 'evening')}
        style={{ marginBottom: 20 }}
      >
        <Tab value="morning">Morning</Tab>
        <Tab value="evening">Evening</Tab>
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      {(query.data || !query.error) && (
        <>
          <div className="stat-grid overview-stat-grid">
            <Stat label="Active trips" value={tiles?.inProgress} />
            <Stat
              label="Boarded / confirmed"
              value={tiles ? `${tiles.boarded} / ${tiles.seatsConfirmed}` : undefined}
            />
            <Stat
              label="Needs attention"
              value={
                tiles
                  ? trips.filter((trip) => trip.badge === 'stale_gps').length +
                    tiles.unassigned +
                    tiles.awaitingResolution
                  : undefined
              }
              attention={Boolean(
                tiles &&
                trips.filter((trip) => trip.badge === 'stale_gps').length +
                  tiles.unassigned +
                  tiles.awaitingResolution >
                  0,
              )}
            />
          </div>
          <div
            className={`overview-stage${liveMarkers.length ? '' : ' overview-stage--list-only'}`}
          >
            <section className="overview-trips" aria-label="Live runs and exceptions">
              <div className="overview-section-heading">
                <h2>Trips to monitor</h2>
                <span>{priorityTrips.length} to monitor</span>
              </div>
              {priorityTrips.length > 0 && (
                <>
                  <input
                    className="overview-search"
                    aria-label="Find a trip or driver"
                    placeholder="Find a trip or driver"
                    value={search}
                    onChange={(event) => setSearch(event.target.value)}
                  />
                  <div className="overview-filters">
                    <button
                      type="button"
                      className={!attentionOnly ? 'active' : ''}
                      onClick={() => setAttentionOnly(false)}
                    >
                      All
                    </button>
                    <button
                      type="button"
                      className={attentionOnly ? 'active' : ''}
                      onClick={() => setAttentionOnly(true)}
                    >
                      Needs attention
                    </button>
                  </div>
                </>
              )}
              {query.loading ? (
                <LoadingRows />
              ) : !visibleTrips.length ? (
                <div className="overview-empty">
                  <p>
                    {priorityTrips.length
                      ? 'No runs match this filter.'
                      : `No buses are running or need attention in this window. ${trips.filter((trip) => trip.status === 'scheduled').length} departures are scheduled.`}
                  </p>
                  <Link to="/trips">View scheduled departures in Dispatch</Link>
                </div>
              ) : (
                <div className="overview-trip-scroll">
                  {visibleTrips.map((trip) => (
                    <button
                      key={trip.tripId}
                      type="button"
                      className={`overview-trip${selectedTrip?.tripId === trip.tripId ? ' selected' : ''}`}
                      onClick={() => setSelectedTripId(trip.tripId)}
                    >
                      <span className="overview-trip-main">
                        <strong>{trip.routeName ?? 'Unpublished route'}</strong>
                        <StatusBadge value={homeTripStatus(trip)} />
                      </span>
                      <span>
                        {trip.driverName ?? 'Driver unassigned'} ·{' '}
                        {trip.vehiclePlate ?? trip.vehicleLabel ?? 'Bus unassigned'}
                      </span>
                      <small>
                        {formatAccraClock(trip.scheduledAt)} · {trip.boarded}/{trip.confirmed}{' '}
                        boarded
                      </small>
                      {fixDescription(trip) && <small>{fixDescription(trip)}</small>}
                    </button>
                  ))}
                </div>
              )}
            </section>
            {trips.some((trip) => trip.status === 'active') && (
              <section className="overview-map-panel" aria-label="Accra network live map">
                <div className="overview-section-heading">
                  <h2>Live map</h2>
                </div>
                <LiveMap
                  markers={liveMarkers}
                  line={tripLine?.versionId === selectedVersionId ? tripLine.points : emptyLine}
                />
                {liveMarkers.length === 0 && (
                  <p className="map-meta">No vehicle has sent a GPS fix in this window.</p>
                )}
                {tripLine?.versionId === selectedVersionId && tripLine.source === 'stops' && (
                  <p className="map-meta">
                    Showing the ordered stops; route geometry is unavailable.
                  </p>
                )}
                {tripLine?.versionId === selectedVersionId && tripLine.source === 'unavailable' && (
                  <p className="map-meta">
                    Route unavailable; live vehicle positions remain visible.
                  </p>
                )}
                <div className="overview-map-footer">
                  {selectedTrip ? (
                    <div className="overview-selected-trip">
                      <div>
                        <span className="eyebrow">Selected trip</span>
                        <h3>{selectedTrip.routeName ?? 'Unpublished route'}</h3>
                        <p>
                          {selectedTrip.driverName ?? 'Driver unassigned'} ·{' '}
                          {selectedTrip.vehiclePlate ??
                            selectedTrip.vehicleLabel ??
                            'Bus unassigned'}
                        </p>
                      </div>
                      <div className="overview-selected-details">
                        <StatusBadge value={homeTripStatus(selectedTrip)} />
                        {fixDescription(selectedTrip) && (
                          <span>{fixDescription(selectedTrip)}</span>
                        )}
                        <span>
                          {selectedTrip.boarded} of {selectedTrip.confirmed} boarded
                        </span>
                        <Link to={`/trips?search=${encodeURIComponent(selectedTrip.tripId)}`}>
                          Open dispatch
                        </Link>
                      </div>
                    </div>
                  ) : (
                    <Empty>Select a trip to see its context.</Empty>
                  )}
                </div>
                {query.data && (
                  <div className="map-meta">Updated {when(query.data.generatedAt)}</div>
                )}
              </section>
            )}
          </div>
        </>
      )}
    </Page>
  );
}

function Stat({
  label,
  value,
  attention = false,
}: {
  label: string;
  value?: number | string;
  attention?: boolean;
}) {
  return (
    <div className={`stat-card${attention ? ' attention' : ''}`}>
      <div className="stat-label">{label}</div>
      <div className="stat-value">{value ?? '—'}</div>
    </div>
  );
}
