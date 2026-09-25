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
import { homeTrips, homeTripStatus, needsOperatorAttention } from './overview-view';

type OverviewData = components['schemas']['OpsOverview'];

export function Overview() {
  const { session } = useAuth();
  const [windowName, setWindowName] = useState<'morning' | 'evening'>('morning');
  const [date, setDate] = useState('');
  const [selectedTripId, setSelectedTripId] = useState<string | null>(null);
  const [attentionOnly, setAttentionOnly] = useState(false);
  const [search, setSearch] = useState('');
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

  const tiles = query.data?.tiles;
  const trips = query.data?.trips ?? [];
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
  const liveMarkers = trips.flatMap((trip) =>
    trip.status === 'active' && trip.lastPosition
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
  return (
    <Page
      title="Live operations"
      description="Active runs and exceptions in this service window. Scheduled departures are in Dispatch."
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
        <Tab value="morning">Morning window</Tab>
        <Tab value="evening">Evening window</Tab>
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      {(query.data || !query.error) && (
        <>
          <div className="stat-grid overview-stat-grid">
            <Stat label="Active trips" value={tiles?.inProgress} />
            <Stat label="Seats confirmed" value={tiles?.seatsConfirmed} />
            <Stat label="Boarded" value={tiles?.boarded} />
            <Stat
              label="Needs attention"
              value={
                tiles ? tiles.staleGps + tiles.unassigned + tiles.awaitingResolution : undefined
              }
              attention={Boolean(
                tiles && tiles.staleGps + tiles.unassigned + tiles.awaitingResolution > 0,
              )}
            />
          </div>
          <div
            className={`overview-stage${liveMarkers.length ? '' : ' overview-stage--list-only'}`}
          >
            <section className="overview-trips" aria-label="Live runs and exceptions">
              <div className="overview-section-heading">
                <h2>Live runs & exceptions</h2>
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
                    </button>
                  ))}
                </div>
              )}
            </section>
            {liveMarkers.length > 0 && (
              <section className="overview-map-panel" aria-label="Accra network live map">
                <div className="overview-section-heading">
                  <div>
                    <h2>Accra network · live</h2>
                    <span>Driver positions and trip context</span>
                  </div>
                  <span className="map-live-badge">Network view</span>
                </div>
                <LiveMap markers={liveMarkers} />
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
                  <div className="map-meta">
                    Snapshot {when(query.data.generatedAt)} · refreshes every 10 seconds
                  </div>
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
  value?: number;
  attention?: boolean;
}) {
  return (
    <div className={`stat-card${attention ? ' attention' : ''}`}>
      <div className="stat-label">{label}</div>
      <div className="stat-value">{value ?? '—'}</div>
    </div>
  );
}
