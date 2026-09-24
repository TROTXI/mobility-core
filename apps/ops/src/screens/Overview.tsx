import { Button, Tab, TabList } from '@fluentui/react-components';
import { ArrowClockwiseRegular } from '@fluentui/react-icons';
import { useEffect, useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { LiveMap } from '../components/LiveMap';

type OverviewData = components['schemas']['OpsOverview'];

export function Overview() {
  const { session } = useAuth();
  const [windowName, setWindowName] = useState<'morning' | 'evening'>('morning');
  const [date, setDate] = useState('');
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
  return (
    <Page
      title="Live operations"
      description="One view of every run, seat and exception in the current service window."
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
      <div className="stat-grid">
        <Stat label="Active trips" value={tiles?.inProgress} />
        <Stat label="Seats confirmed" value={tiles?.seatsConfirmed} />
        <Stat label="Boarded" value={tiles?.boarded} />
        <Stat
          label="Needs attention"
          value={tiles ? tiles.staleGps + tiles.unassigned + tiles.awaitingResolution : undefined}
          attention={Boolean(
            tiles && tiles.staleGps + tiles.unassigned + tiles.awaitingResolution > 0,
          )}
        />
      </div>
      <div className="split-grid">
        <Panel title="Runs in this window">
          {query.loading ? (
            <LoadingRows />
          ) : !query.data?.trips.length ? (
            <Empty>No runs are scheduled in this service window.</Empty>
          ) : (
            <div style={{ overflowX: 'auto' }}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Departure</th>
                    <th>Route</th>
                    <th>Driver / bus</th>
                    <th>Seats</th>
                    <th>Signal</th>
                  </tr>
                </thead>
                <tbody>
                  {query.data.trips.map((trip) => (
                    <tr key={trip.tripId}>
                      <td>
                        <strong>
                          {new Date(trip.scheduledAt).toLocaleTimeString('en-GH', {
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </strong>
                        <div className="muted">{trip.status}</div>
                      </td>
                      <td>{trip.routeName ?? 'Unpublished route'}</td>
                      <td>
                        {trip.driverName ?? 'Driver unassigned'}
                        <div className="muted">
                          {trip.vehiclePlate ?? trip.vehicleLabel ?? 'Bus unassigned'}
                        </div>
                      </td>
                      <td>
                        {trip.boarded} / {trip.confirmed}
                        <div className="muted">capacity {trip.capacity ?? '—'}</div>
                      </td>
                      <td>
                        <StatusBadge value={trip.badge} />
                        {trip.fixAgeSeconds != null && (
                          <div className="muted">{Math.floor(trip.fixAgeSeconds / 60)}m ago</div>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </Panel>
        <Panel title="Network position">
          <LiveMap
            markers={(query.data?.trips ?? []).flatMap((trip) =>
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
            )}
          />
          {query.data && (
            <div className="map-meta">
              Snapshot {when(query.data.generatedAt)} · refreshes every 10 seconds
            </div>
          )}
        </Panel>
      </div>
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
