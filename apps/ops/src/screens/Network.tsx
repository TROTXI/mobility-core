import { Button, Tab, TabList } from '@fluentui/react-components';
import { AddRegular } from '@fluentui/react-icons';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';
import { LiveMap } from '../components/LiveMap';

type Route = components['schemas']['Route'];
type Stop = components['schemas']['Stop'];

export function Network() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'routes' | 'stops'>('routes');
  const [creating, setCreating] = useState(false);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [latitude, setLatitude] = useState('5.6037');
  const [longitude, setLongitude] = useState('-0.1870');
  const query = useQuery<{ routes: Route[]; stops: Stop[] }>(
    async (signal) => {
      const [routes, stops] = await Promise.all([
        session.client.GET('/v1/ops/routes', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/stops', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
      ]);
      if (routes.error) throw new Error(routes.error.error.message);
      if (stops.error) throw new Error(stops.error.error.message);
      return { routes: routes.data.data, stops: stops.data.data };
    },
    [session],
  );
  const rows = tab === 'routes' ? query.data?.routes : query.data?.stops;
  return (
    <Page
      title="Routes & stops"
      description="Publish stable corridors while preserving every operated version."
      actions={
        <Button appearance="primary" icon={<AddRegular />} onClick={() => setCreating(true)}>
          New {tab === 'routes' ? 'route' : 'stop'}
        </Button>
      }
    >
      <TabList
        selectedValue={tab}
        onTabSelect={(_, value) => setTab(value.value as typeof tab)}
        style={{ marginBottom: 18 }}
      >
        <Tab value="routes">Routes</Tab>
        <Tab value="stops">Stops</Tab>
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <div className="split-grid">
        <Panel title={tab === 'routes' ? 'Corridors' : 'Boarding points'}>
          {query.loading ? (
            <LoadingRows />
          ) : !rows?.length ? (
            <Empty />
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>State</th>
                  <th>Version</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.id}>
                    <td>
                      <strong>{row.name}</strong>
                      <div className="mono muted">{row.id.slice(0, 8)}</div>
                    </td>
                    <td>
                      <StatusBadge value={row.archived ? 'archived' : 'active'} />
                    </td>
                    <td>{row.version}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </Panel>
        <Panel title="Network map">
          <LiveMap
            markers={(query.data?.stops ?? [])
              .filter((stop) => !stop.archived)
              .map((stop) => ({ id: stop.id, ...stop.location, label: stop.name, state: 'stop' }))}
          />
          <div className="map-meta">
            {query.data?.routes.length ?? 0} corridors · {query.data?.stops.length ?? 0} stops
          </div>
        </Panel>
      </div>
      <ActionDialog
        open={creating}
        title={`Create ${tab === 'routes' ? 'route' : 'stop'}`}
        confirmLabel="Create"
        onClose={() => setCreating(false)}
        onConfirm={async () => {
          const header = { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID() };
          const response =
            tab === 'routes'
              ? await session.client.POST('/v1/ops/routes', {
                  params: { header },
                  body: { name, description, acceptsDriverRequests: false },
                })
              : await session.client.POST('/v1/ops/stops', {
                  params: { header },
                  body: {
                    name,
                    location: { latitude: Number(latitude), longitude: Number(longitude) },
                  },
                });
          if (response.error) throw new Error(response.error.error.message);
          setName('');
          setDescription('');
          query.retry();
        }}
      >
        <label>
          Name
          <input required value={name} onChange={(event) => setName(event.target.value)} />
        </label>
        {tab === 'routes' ? (
          <label>
            Description
            <textarea
              rows={4}
              value={description}
              onChange={(event) => setDescription(event.target.value)}
            />
          </label>
        ) : (
          <>
            <label>
              Latitude
              <input
                type="number"
                step="any"
                value={latitude}
                onChange={(event) => setLatitude(event.target.value)}
              />
            </label>
            <label>
              Longitude
              <input
                type="number"
                step="any"
                value={longitude}
                onChange={(event) => setLongitude(event.target.value)}
              />
            </label>
          </>
        )}
      </ActionDialog>
    </Page>
  );
}
