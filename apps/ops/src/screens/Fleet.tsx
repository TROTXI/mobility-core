import { Button, Input, Tab, TabList } from '@fluentui/react-components';
import { AddRegular, ArrowClockwiseRegular, SearchRegular } from '@fluentui/react-icons';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';

type Driver = components['schemas']['Driver'];
type Vehicle = components['schemas']['Vehicle'];
type Mode =
  | 'driver-create'
  | 'driver-edit'
  | 'credential-issue'
  | 'credential-reset'
  | 'credential-state'
  | 'vehicle-create'
  | 'vehicle-edit';

export function Fleet() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'drivers' | 'vehicles'>('drivers');
  const [search, setSearch] = useState('');
  const [mode, setMode] = useState<Mode | null>(null);
  const [selectedDriver, setSelectedDriver] = useState<Driver | null>(null);
  const [selectedVehicle, setSelectedVehicle] = useState<Vehicle | null>(null);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [license, setLicense] = useState('');
  const [userId, setUserId] = useState('');
  const [plate, setPlate] = useState('');
  const [make, setMake] = useState('');
  const [colour, setColour] = useState('');
  const [capacity, setCapacity] = useState(18);
  const [archived, setArchived] = useState(false);
  const [credentialCode, setCredentialCode] = useState('');
  const [credentialAction, setCredentialAction] = useState<'suspend' | 'activate' | 'unlock'>(
    'unlock',
  );
  const [reason, setReason] = useState('');
  const [issuedSecret, setIssuedSecret] = useState<{ code: string; pin: string } | null>(null);

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
      const failure = drivers.error ?? vehicles.error;
      if (failure) throw new Error(failure.error.message);
      if (!drivers.data || !vehicles.data)
        throw new Error('The fleet register returned an incomplete response.');
      return { drivers: drivers.data.data, vehicles: vehicles.data.data };
    },
    [session],
  );

  const needle = search.trim().toLowerCase();
  const drivers = (query.data?.drivers ?? []).filter((driver) =>
    [driver.name, driver.phone, driver.licenseNumber, driver.userId].some((value) =>
      value?.toLowerCase().includes(needle),
    ),
  );
  const vehicles = (query.data?.vehicles ?? []).filter((vehicle) =>
    [vehicle.plate, vehicle.label, vehicle.make, vehicle.colour].some((value) =>
      value?.toLowerCase().includes(needle),
    ),
  );

  const open = (next: Mode) => {
    setMode(next);
    setReason('');
    setIssuedSecret(null);
    if (next === 'driver-create') {
      setName('');
      setPhone('');
      setLicense('');
      setUserId('');
      setArchived(false);
    } else if (next === 'driver-edit' && selectedDriver) {
      setName(selectedDriver.name);
      setPhone(selectedDriver.phone ?? '');
      setLicense(selectedDriver.licenseNumber ?? '');
      setUserId(selectedDriver.userId ?? '');
      setArchived(selectedDriver.archived);
    } else if (next === 'vehicle-create') {
      setPlate('');
      setName('');
      setMake('');
      setColour('');
      setCapacity(18);
      setArchived(false);
    } else if (next === 'vehicle-edit' && selectedVehicle) {
      setPlate(selectedVehicle.plate);
      setName(selectedVehicle.label ?? '');
      setMake(selectedVehicle.make ?? '');
      setColour(selectedVehicle.colour ?? '');
      setCapacity(selectedVehicle.capacity);
      setArchived(selectedVehicle.archived);
    }
  };

  return (
    <Page
      title="Fleet & people"
      description="Keep drivers linked, credentials controlled, and every operating bus capacity-safe."
      actions={
        <>
          <Input
            contentBefore={<SearchRegular />}
            value={search}
            onChange={(_, data) => setSearch(data.value)}
            placeholder={`Search ${tab}`}
          />
          <Button icon={<ArrowClockwiseRegular />} onClick={query.retry}>
            Refresh
          </Button>
          <Button
            appearance="primary"
            icon={<AddRegular />}
            onClick={() => open(tab === 'drivers' ? 'driver-create' : 'vehicle-create')}
          >
            Add {tab === 'drivers' ? 'driver' : 'vehicle'}
          </Button>
        </>
      }
    >
      <TabList selectedValue={tab} onTabSelect={(_, data) => setTab(data.value as typeof tab)}>
        <Tab value="drivers">Drivers</Tab>
        <Tab value="vehicles">Vehicles</Tab>
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <div className="stat-grid fleet-stats">
        <Stat
          label="Operating drivers"
          value={drivers.filter((driver) => !driver.archived).length}
        />
        <Stat
          label="Linked accounts"
          value={drivers.filter((driver) => driver.userId && !driver.archived).length}
        />
        <Stat
          label="Operating vehicles"
          value={vehicles.filter((vehicle) => !vehicle.archived).length}
        />
        <Stat
          label="Seat capacity"
          value={vehicles
            .filter((vehicle) => !vehicle.archived)
            .reduce((sum, vehicle) => sum + vehicle.capacity, 0)}
        />
      </div>
      <Panel title={tab === 'drivers' ? 'Driver register' : 'Vehicle register'}>
        {query.loading ? (
          <LoadingRows />
        ) : tab === 'drivers' ? (
          <DriverTable rows={drivers} selected={selectedDriver?.id} onSelect={setSelectedDriver} />
        ) : (
          <VehicleTable
            rows={vehicles}
            selected={selectedVehicle?.id}
            onSelect={setSelectedVehicle}
          />
        )}
      </Panel>

      {tab === 'drivers' && selectedDriver && (
        <aside className="detail-drawer" aria-label="Driver detail">
          <DrawerHeader title={selectedDriver.name} onClose={() => setSelectedDriver(null)} />
          <dl className="detail-grid">
            <Detail label="Phone" value={selectedDriver.phone ?? 'Not supplied'} />
            <Detail label="Licence" value={selectedDriver.licenseNumber ?? 'Not supplied'} />
            <Detail
              label="App account"
              value={selectedDriver.userId ? 'Linked' : 'Invite pending'}
            />
            <Detail label="State" value={selectedDriver.archived ? 'Archived' : 'Operating'} />
          </dl>
          <div className="drawer-actions">
            <Button appearance="primary" onClick={() => open('driver-edit')}>
              Edit driver
            </Button>
            <Button onClick={() => open('credential-issue')}>Issue credential</Button>
            <Button onClick={() => open('credential-reset')}>Reset PIN</Button>
            <Button onClick={() => open('credential-state')}>Credential state</Button>
          </div>
        </aside>
      )}
      {tab === 'vehicles' && selectedVehicle && (
        <aside className="detail-drawer" aria-label="Vehicle detail">
          <DrawerHeader title={selectedVehicle.plate} onClose={() => setSelectedVehicle(null)} />
          <dl className="detail-grid">
            <Detail label="Label" value={selectedVehicle.label ?? 'Not supplied'} />
            <Detail
              label="Vehicle"
              value={
                [selectedVehicle.colour, selectedVehicle.make].filter(Boolean).join(' ') ||
                'Not supplied'
              }
            />
            <Detail label="Capacity" value={`${selectedVehicle.capacity} seats`} />
            <Detail label="State" value={selectedVehicle.archived ? 'Archived' : 'Operating'} />
          </dl>
          <p className="dialog-note">
            Capacity is the reservation ceiling. Reducing it is refused when confirmed seats would
            no longer fit.
          </p>
          <div className="drawer-actions">
            <Button appearance="primary" onClick={() => open('vehicle-edit')}>
              Edit vehicle
            </Button>
          </div>
        </aside>
      )}

      {issuedSecret && (
        <div className="secret-reveal" role="status">
          <div>
            <span className="eyebrow">Show once</span>
            <strong>Driver code {issuedSecret.code}</strong>
            <strong>PIN {issuedSecret.pin}</strong>
          </div>
          <Button
            onClick={() =>
              navigator.clipboard.writeText(`${issuedSecret.code} ${issuedSecret.pin}`)
            }
          >
            Copy
          </Button>
          <Button appearance="subtle" onClick={() => setIssuedSecret(null)}>
            Dismiss
          </Button>
        </div>
      )}

      <ActionDialog
        open={mode !== null}
        title={title(mode)}
        confirmLabel={
          mode?.includes('edit') ? 'Save' : mode?.includes('credential') ? 'Apply' : 'Create'
        }
        danger={
          (mode?.includes('edit') && archived) ||
          (mode === 'credential-state' && credentialAction === 'suspend')
        }
        onClose={() => setMode(null)}
        onConfirm={async () => {
          await submit();
          setMode(null);
          query.retry();
        }}
      >
        {(mode === 'driver-create' || mode === 'driver-edit') && (
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
            <label>
              Linked user ID (optional)
              <input value={userId} onChange={(event) => setUserId(event.target.value)} />
            </label>
            {mode === 'driver-edit' && (
              <label className="check-row">
                <input
                  type="checkbox"
                  checked={archived}
                  onChange={(event) => setArchived(event.target.checked)}
                />
                Archive driver
              </label>
            )}
          </>
        )}
        {(mode === 'vehicle-create' || mode === 'vehicle-edit') && (
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
              Make
              <input value={make} onChange={(event) => setMake(event.target.value)} />
            </label>
            <label>
              Colour
              <input value={colour} onChange={(event) => setColour(event.target.value)} />
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
            {mode === 'vehicle-edit' && (
              <label className="check-row">
                <input
                  type="checkbox"
                  checked={archived}
                  onChange={(event) => setArchived(event.target.checked)}
                />
                Archive vehicle
              </label>
            )}
          </>
        )}
        {mode === 'credential-issue' && (
          <>
            <p className="dialog-note">
              Leave the code blank to generate both the driver code and a six-digit PIN.
            </p>
            <label>
              Preferred code (optional)
              <input
                value={credentialCode}
                onChange={(event) => setCredentialCode(event.target.value.toUpperCase())}
              />
            </label>
          </>
        )}
        {mode === 'credential-reset' && (
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
        {mode === 'credential-state' && (
          <>
            <label>
              Action
              <select
                value={credentialAction}
                onChange={(event) =>
                  setCredentialAction(event.target.value as typeof credentialAction)
                }
              >
                <option value="unlock">Unlock</option>
                <option value="activate">Activate</option>
                <option value="suspend">Suspend and revoke sessions</option>
              </select>
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
      </ActionDialog>
    </Page>
  );

  async function submit() {
    const key = crypto.randomUUID();
    const mutation = { ...opsHeaders, 'Idempotency-Key': key };
    if (mode === 'driver-create') {
      const response = await session.client.POST('/v1/ops/drivers', {
        params: { header: mutation },
        body: {
          name,
          ...(phone ? { phone } : {}),
          ...(license ? { licenseNumber: license } : {}),
          ...(userId ? { userId } : {}),
        },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (mode === 'driver-edit' && selectedDriver) {
      const response = await session.client.PATCH('/v1/ops/drivers/{id}', {
        params: {
          path: { id: selectedDriver.id },
          header: { ...mutation, 'If-Match': selectedDriver.editToken },
        },
        body: {
          name,
          phone: phone || null,
          licenseNumber: license || null,
          userId: userId || null,
          archived,
        },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (mode === 'vehicle-create') {
      const response = await session.client.POST('/v1/ops/vehicles', {
        params: { header: mutation },
        body: { plate, label: name || null, make: make || null, colour: colour || null, capacity },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (mode === 'vehicle-edit' && selectedVehicle) {
      const response = await session.client.PATCH('/v1/ops/vehicles/{id}', {
        params: {
          path: { id: selectedVehicle.id },
          header: { ...mutation, 'If-Match': selectedVehicle.editToken },
        },
        body: {
          plate,
          label: name || null,
          make: make || null,
          colour: colour || null,
          capacity,
          archived,
        },
      });
      if (response.error) throw new Error(response.error.error.message);
    } else if (mode === 'credential-issue' && selectedDriver) {
      const response = await session.client.POST('/v1/ops/drivers/{id}/credentials', {
        params: { path: { id: selectedDriver.id }, header: mutation },
        body: credentialCode ? { code: credentialCode } : {},
      });
      if (response.error) throw new Error(response.error.error.message);
      setIssuedSecret(response.data.data);
    } else if (mode === 'credential-reset' && selectedDriver) {
      const response = await session.client.POST('/v1/ops/drivers/{id}/credentials/reset-pin', {
        params: { path: { id: selectedDriver.id }, header: mutation },
        body: { reason },
      });
      if (response.error) throw new Error(response.error.error.message);
      setIssuedSecret(response.data.data);
    } else if (mode === 'credential-state' && selectedDriver) {
      const response = await session.client.POST('/v1/ops/drivers/{id}/credentials/actions', {
        params: { path: { id: selectedDriver.id }, header: mutation },
        body: { action: credentialAction, reason },
      });
      if (response.error) throw new Error(response.error.error.message);
    }
  }
}

function DriverTable({
  rows,
  selected,
  onSelect,
}: {
  rows: Driver[];
  selected?: string;
  onSelect: (driver: Driver) => void;
}) {
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
            <th />
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id} className={selected === row.id ? 'selected-row' : ''}>
              <td>
                <strong>{row.name}</strong>
                <div className="mono muted">{row.id.slice(0, 8)}</div>
              </td>
              <td>{row.phone ?? '—'}</td>
              <td>{row.licenseNumber ?? '—'}</td>
              <td>
                <StatusBadge value={row.userId ? 'linked' : 'invite'} />
              </td>
              <td>
                <StatusBadge value={row.archived ? 'archived' : 'operating'} />
              </td>
              <td>
                <Button appearance="subtle" onClick={() => onSelect(row)}>
                  Manage
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function VehicleTable({
  rows,
  selected,
  onSelect,
}: {
  rows: Vehicle[];
  selected?: string;
  onSelect: (vehicle: Vehicle) => void;
}) {
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
            <th />
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id} className={selected === row.id ? 'selected-row' : ''}>
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
              <td>
                <Button appearance="subtle" onClick={() => onSelect(row)}>
                  Manage
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function DrawerHeader({ title: value, onClose }: { title: string; onClose: () => void }) {
  return (
    <div className="detail-drawer-heading">
      <div>
        <span className="eyebrow">Fleet record</span>
        <h2>{value}</h2>
      </div>
      <Button appearance="subtle" onClick={onClose}>
        Close
      </Button>
    </div>
  );
}
function Detail({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <dt>{label}</dt>
      <dd>{value}</dd>
    </div>
  );
}
function Stat({ label, value }: { label: string; value: number }) {
  return (
    <div className="stat-card">
      <div className="stat-label">{label}</div>
      <div className="stat-value">{value}</div>
    </div>
  );
}
function title(mode: Mode | null) {
  if (!mode) return '';
  return (
    {
      'driver-create': 'Add driver',
      'driver-edit': 'Edit driver',
      'credential-issue': 'Issue driver credential',
      'credential-reset': 'Reset driver PIN',
      'credential-state': 'Change credential state',
      'vehicle-create': 'Add vehicle',
      'vehicle-edit': 'Edit vehicle',
    } satisfies Record<Mode, string>
  )[mode];
}
