import { Button, Tab, TabList } from '@fluentui/react-components';
import { AddRegular } from '@fluentui/react-icons';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';

type Driver = components['schemas']['Driver'];
type Vehicle = components['schemas']['Vehicle'];

export function Fleet() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'drivers' | 'vehicles'>('drivers');
  const [creating, setCreating] = useState(false);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [license, setLicense] = useState('');
  const [plate, setPlate] = useState('');
  const [capacity, setCapacity] = useState(18);
  const query = useQuery<{ drivers: Driver[]; vehicles: Vehicle[] }>(
    async (signal) => {
      const [drivers, vehicles] = await Promise.all([
        session.client.GET('/v1/ops/drivers', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/vehicles', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
      ]);
      if (drivers.error) throw new Error(drivers.error.error.message);
      if (vehicles.error) throw new Error(vehicles.error.error.message);
      return { drivers: drivers.data.data, vehicles: vehicles.data.data };
    },
    [session],
  );
  return (
    <Page
      title="Drivers & vehicles"
      description="Keep the operating fleet ready, linked and capacity-safe."
      actions={
        <Button appearance="primary" icon={<AddRegular />} onClick={() => setCreating(true)}>
          Add {tab === 'drivers' ? 'driver' : 'vehicle'}
        </Button>
      }
    >
      <TabList
        selectedValue={tab}
        onTabSelect={(_, data) => setTab(data.value as typeof tab)}
        style={{ marginBottom: 18 }}
      >
        <Tab value="drivers">Drivers</Tab>
        <Tab value="vehicles">Vehicles</Tab>
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel title={tab === 'drivers' ? 'Driver register' : 'Vehicle register'}>
        {query.loading ? (
          <LoadingRows />
        ) : tab === 'drivers' ? (
          <DriverTable rows={query.data?.drivers ?? []} />
        ) : (
          <VehicleTable rows={query.data?.vehicles ?? []} />
        )}
      </Panel>
      <ActionDialog
        open={creating}
        title={`Add ${tab === 'drivers' ? 'driver' : 'vehicle'}`}
        confirmLabel="Create"
        onClose={() => setCreating(false)}
        onConfirm={async () => {
          const header = { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID() };
          if (tab === 'drivers') {
            const response = await session.client.POST('/v1/ops/drivers', {
              params: { header },
              body: {
                name,
                ...(phone ? { phone } : {}),
                ...(license ? { licenseNumber: license } : {}),
              },
            });
            if (response.error) throw new Error(response.error.error.message);
          } else {
            const response = await session.client.POST('/v1/ops/vehicles', {
              params: { header },
              body: { plate, label: name || null, make: null, colour: null, capacity },
            });
            if (response.error) throw new Error(response.error.error.message);
          }
          setName('');
          setPhone('');
          setLicense('');
          setPlate('');
          query.retry();
        }}
      >
        {tab === 'drivers' ? (
          <>
            <label>
              Name
              <input required value={name} onChange={(event) => setName(event.target.value)} />
            </label>
            <label>
              Phone
              <input value={phone} onChange={(event) => setPhone(event.target.value)} />
            </label>
            <label>
              Licence number
              <input value={license} onChange={(event) => setLicense(event.target.value)} />
            </label>
          </>
        ) : (
          <>
            <label>
              Plate
              <input
                required
                value={plate}
                onChange={(event) => setPlate(event.target.value.toUpperCase())}
              />
            </label>
            <label>
              Label
              <input value={name} onChange={(event) => setName(event.target.value)} />
            </label>
            <label>
              Seat capacity
              <input
                type="number"
                min="1"
                max="500"
                required
                value={capacity}
                onChange={(event) => setCapacity(Number(event.target.value))}
              />
            </label>
          </>
        )}
      </ActionDialog>
    </Page>
  );
}

function DriverTable({ rows }: { rows: Driver[] }) {
  if (!rows.length) return <Empty>No drivers have been provisioned.</Empty>;
  return (
    <div style={{ overflowX: 'auto' }}>
      <table className="data-table">
        <thead>
          <tr>
            <th>Driver</th>
            <th>Phone</th>
            <th>Licence</th>
            <th>Account</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id}>
              <td>
                <strong>{row.name}</strong>
                <div className="mono muted">{row.id.slice(0, 8)}</div>
              </td>
              <td>{row.phone}</td>
              <td>{row.licenseNumber ?? '—'}</td>
              <td>
                {row.userId ? <StatusBadge value="linked" /> : <StatusBadge value="invite" />}
              </td>
              <td>
                <StatusBadge value={row.archived ? 'archived' : 'operating'} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function VehicleTable({ rows }: { rows: Vehicle[] }) {
  if (!rows.length) return <Empty>No vehicles have been added.</Empty>;
  return (
    <div style={{ overflowX: 'auto' }}>
      <table className="data-table">
        <thead>
          <tr>
            <th>Registration</th>
            <th>Vehicle</th>
            <th>Capacity</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id}>
              <td>
                <strong>{row.plate}</strong>
              </td>
              <td>{row.label ?? ([row.colour, row.make].filter(Boolean).join(' ') || '—')}</td>
              <td>
                {row.capacity} seats<div className="muted">Reservation ceiling</div>
              </td>
              <td>
                <StatusBadge value={row.archived ? 'archived' : 'operating'} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
