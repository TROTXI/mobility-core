import { Button, Input, Tab, TabList } from '@fluentui/react-components';
import { AddRegular, ArrowClockwiseRegular, SearchRegular } from '@fluentui/react-icons';
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';

type Driver = components['schemas']['Driver'];
type Vehicle = components['schemas']['Vehicle'];
type CredentialSecret = components['schemas']['CredentialSecret'];
/**
 * What ops is shown after issuing or resetting. When the PIN was emailed it is
 * never held here at all; when it was not, it is shown once and dropped.
 */
type Issued = {
  code: string;
  pin: string | null;
  emailedTo: string | null;
  expiresAt: string;
};

/** Plain words for each sign-in email state. Nothing here confirms delivery. */
export const EMAIL_STATE: Record<string, string> = {
  queued: 'Queued. Waiting for the email worker; not sent yet.',
  provider_accepted: 'Accepted by the email provider. Delivery to the inbox is not confirmed.',
  cancelled: 'Cancelled. The PIN in it was replaced, or the address changed, before it was sent.',
  failed:
    'Rejected by the email provider. Check the address, then reset the PIN to send a new one.',
  unknown: 'Outcome unknown after retries. Reset the PIN to send a fresh one.',
};

export function pinState(driver: Driver): string {
  const credential = driver.credential;
  if (!credential) return 'Not issued';
  if (credential.status === 'suspended') return 'Suspended';
  if (!credential.mustChangePin) return 'Private PIN set';
  const until = credential.temporaryPinExpiresAt;
  if (until && Date.parse(until) <= Date.now()) return 'Temporary PIN expired';
  return until
    ? `Temporary PIN until ${new Date(until).toLocaleString('en-GB', { timeZone: 'UTC' })} UTC`
    : 'Temporary PIN';
}
type Mode =
  | 'driver-create'
  | 'driver-edit'
  | 'credential-issue'
  | 'credential-reset'
  | 'credential-state'
  | 'vehicle-create'
  | 'vehicle-edit';

export function Fleet({ view = 'drivers' }: { view?: 'drivers' | 'vehicles' }) {
  const { session } = useAuth();
  const navigate = useNavigate();
  const tab = view;
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
  const [email, setEmail] = useState('');
  const [onboardNow, setOnboardNow] = useState(true);
  const [emailInstructions, setEmailInstructions] = useState(true);
  const [issuedSecret, setIssuedSecret] = useState<Issued | null>(null);
  // One key per dialog opening, reused by every retry of it: an uncertain
  // network result can be retried without creating a second driver or PIN.
  const [keys, setKeys] = useState({ primary: '', issue: '' });
  // A driver created by this dialog whose onboarding step then failed. The
  // retry continues from here instead of creating the driver again.
  const [created, setCreated] = useState<Driver | null>(null);

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

  // Keep the open driver in step with the register: after issuing or editing,
  // its PIN state and edit token come from the refreshed row, not a stale copy.
  const freshDrivers = query.data?.drivers;
  useEffect(() => {
    setSelectedDriver((current) =>
      current ? (freshDrivers?.find((driver) => driver.id === current.id) ?? current) : current,
    );
  }, [freshDrivers]);

  const needle = search.trim().toLowerCase();
  const drivers = (query.data?.drivers ?? []).filter((driver) =>
    [driver.name, driver.phone, driver.email, driver.licenseNumber, driver.userId].some((value) =>
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
    setCreated(null);
    setKeys({ primary: crypto.randomUUID(), issue: crypto.randomUUID() });
    setEmailInstructions(next === 'driver-create' || !!selectedDriver?.email);
    if (next === 'driver-create') {
      setName('');
      setPhone('');
      setEmail('');
      setOnboardNow(true);
      setLicense('');
      setUserId('');
      setArchived(false);
    } else if (next === 'driver-edit' && selectedDriver) {
      setName(selectedDriver.name);
      setPhone(selectedDriver.phone ?? '');
      setEmail(selectedDriver.email ?? '');
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
      title={tab === 'drivers' ? 'Drivers' : 'Fleet & vehicles'}
      description={
        tab === 'drivers'
          ? 'Manage driver accounts, credentials and availability.'
          : 'Register vehicles, inspect capacity and manage the operating fleet.'
      }
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
      <TabList
        selectedValue={tab}
        onTabSelect={(_, data) => navigate(data.value === 'drivers' ? '/drivers' : '/fleet')}
      >
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
          <DriverTable
            rows={drivers}
            selected={selectedDriver?.id}
            onSelect={(driver) => {
              setSelectedDriver(driver);
              // A PIN shown for one driver never lingers beside another.
              setIssuedSecret(null);
            }}
          />
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
            <Detail label="Email" value={selectedDriver.email ?? 'Not supplied'} />
            <Detail label="Licence" value={selectedDriver.licenseNumber ?? 'Not supplied'} />
            <Detail
              label="App account"
              value={selectedDriver.userId ? 'Linked' : 'Invite pending'}
            />
            <Detail label="State" value={selectedDriver.archived ? 'Archived' : 'Operating'} />
            <Detail
              label="Driver code"
              value={selectedDriver.credential?.driverCode ?? 'Not issued'}
            />
            <Detail label="PIN" value={pinState(selectedDriver)} />
            <Detail
              label="Sign-in email"
              value={
                selectedDriver.credentialEmail
                  ? `${selectedDriver.credentialEmail.purpose === 'pin_reset' ? 'PIN reset' : 'Onboarding'}: ${EMAIL_STATE[selectedDriver.credentialEmail.state]}`
                  : 'None sent'
              }
            />
          </dl>
          <p className="dialog-note">
            Old sign-in details are never resent: if an email did not arrive, reset the PIN. That
            cancels the old message and emails a new temporary PIN. Operations never sees the PIN a
            driver chooses.
          </p>
          <div className="drawer-actions">
            <Button appearance="primary" onClick={() => open('driver-edit')}>
              Edit driver
            </Button>
            {selectedDriver.credential ? (
              <Button onClick={() => open('credential-reset')}>
                Reset PIN and email instructions
              </Button>
            ) : (
              <Button onClick={() => open('credential-issue')}>Issue sign-in details</Button>
            )}
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
          {issuedSecret.emailedTo ? (
            <div>
              <span className="eyebrow">Email queued</span>
              <strong>Driver code {issuedSecret.code}</strong>
              <span>
                The temporary PIN is queued for email to {issuedSecret.emailedTo}. Queued is not
                sent: check the sign-in email status on the driver.
              </span>
            </div>
          ) : (
            <div>
              <span className="eyebrow">Show once</span>
              <strong>Driver code {issuedSecret.code}</strong>
              <strong>Temporary PIN {issuedSecret.pin}</strong>
              <span>
                Give it to the driver directly. It works until{' '}
                {new Date(issuedSecret.expiresAt).toLocaleString('en-GB', { timeZone: 'UTC' })} UTC,
                and the driver must choose their own PIN after signing in.
              </span>
            </div>
          )}
          {issuedSecret.pin && (
            <Button
              onClick={() =>
                void navigator.clipboard
                  .writeText(`${issuedSecret.code} ${issuedSecret.pin}`)
                  .catch(() => undefined)
              }
            >
              Copy
            </Button>
          )}
          <Button appearance="subtle" onClick={() => setIssuedSecret(null)}>
            Dismiss
          </Button>
        </div>
      )}

      <ActionDialog
        open={mode !== null}
        title={title(mode)}
        confirmLabel={
          mode?.includes('edit')
            ? 'Save'
            : mode === 'driver-create'
              ? created
                ? 'Retry sign-in details'
                : onboardNow
                  ? 'Create and issue'
                  : 'Create'
              : mode?.includes('credential')
                ? 'Apply'
                : 'Create'
        }
        danger={
          (mode?.includes('edit') && archived) ||
          (mode === 'credential-state' && credentialAction === 'suspend')
        }
        onClose={() => {
          setMode(null);
          // A driver created before onboarding failed is real: refresh so it
          // shows, rather than leaving ops to create it again.
          if (created) query.retry();
        }}
        onConfirm={async () => {
          await submit();
          setMode(null);
          query.retry();
        }}
      >
        {created && (
          <p className="dialog-note" role="status">
            {created.name} was created. Retrying issues the sign-in details only; the driver is not
            created again.
          </p>
        )}
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
              Email for sign-in instructions
              <input
                type="email"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
              />
            </label>
            <p className="dialog-note">
              Operations uses this address to send the driver code and temporary PIN. It is not a
              sign-in method and does not change the driver&apos;s account email.
            </p>
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
            {mode === 'driver-create' && (
              <>
                <label className="check-row">
                  <input
                    type="checkbox"
                    checked={onboardNow}
                    disabled={!!created}
                    onChange={(event) => setOnboardNow(event.target.checked)}
                  />
                  Issue a driver code and temporary PIN now
                </label>
                {onboardNow && (
                  <label className="check-row">
                    <input
                      type="checkbox"
                      checked={emailInstructions && !!email}
                      disabled={!email}
                      onChange={(event) => setEmailInstructions(event.target.checked)}
                    />
                    Email the sign-in instructions to this address
                  </label>
                )}
              </>
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
              Leave the code blank to generate both the driver code and a six-digit temporary PIN.
              The driver must choose their own PIN after signing in.
            </p>
            <EmailChoice
              email={selectedDriver?.email ?? null}
              checked={emailInstructions}
              onChange={setEmailInstructions}
            />
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
          <>
            <p className="dialog-note">
              The current PIN stops working, every signed-in device is signed out, and any earlier
              sign-in email still waiting is cancelled. A suspended driver stays suspended.
            </p>
            <label>
              Reason (kept in the audit log)
              <textarea
                rows={3}
                required
                value={reason}
                onChange={(event) => setReason(event.target.value)}
              />
            </label>
            <EmailChoice
              email={selectedDriver?.email ?? null}
              checked={emailInstructions}
              onChange={setEmailInstructions}
            />
          </>
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

  function reveal(secret: CredentialSecret) {
    setIssuedSecret({
      code: secret.code,
      pin: secret.email ? null : secret.pin,
      emailedTo: secret.email?.to ?? null,
      expiresAt: secret.temporaryPinExpiresAt,
    });
  }

  async function issue(driver: Driver) {
    const wantsEmail = emailInstructions && !!driver.email;
    const response = await session.client.POST('/v1/ops/drivers/{id}/credentials', {
      params: {
        path: { id: driver.id },
        header: { ...opsHeaders, 'Idempotency-Key': keys.issue },
      },
      body: {
        ...(credentialCode && mode === 'credential-issue' ? { code: credentialCode } : {}),
        ...(wantsEmail ? { emailInstructions: true } : {}),
      },
    });
    if (response.error) throw new Error(response.error.error.message);
    reveal(response.data.data);
  }

  async function submit() {
    const mutation = { ...opsHeaders, 'Idempotency-Key': keys.primary };
    if (mode === 'driver-create') {
      let driver = created;
      if (!driver) {
        const response = await session.client.POST('/v1/ops/drivers', {
          params: { header: mutation },
          body: {
            name,
            ...(phone ? { phone } : {}),
            ...(email ? { email } : {}),
            ...(license ? { licenseNumber: license } : {}),
            ...(userId ? { userId } : {}),
          },
        });
        if (response.error) throw new Error(response.error.error.message);
        driver = response.data.data;
        setSelectedDriver(driver);
      }
      if (!onboardNow) return;
      try {
        await issue(driver);
      } catch (error) {
        setCreated(driver);
        throw new Error(
          `${driver.name} was created, but issuing sign-in details failed: ${
            error instanceof Error ? error.message : 'unknown error'
          } Retry to issue them.`,
        );
      }
    } else if (mode === 'driver-edit' && selectedDriver) {
      const response = await session.client.PATCH('/v1/ops/drivers/{id}', {
        params: {
          path: { id: selectedDriver.id },
          header: { ...mutation, 'If-Match': selectedDriver.editToken },
        },
        body: {
          name,
          phone: phone || null,
          email: email || null,
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
      await issue(selectedDriver);
    } else if (mode === 'credential-reset' && selectedDriver) {
      const wantsEmail = emailInstructions && !!selectedDriver.email;
      const response = await session.client.POST('/v1/ops/drivers/{id}/credentials/reset-pin', {
        params: { path: { id: selectedDriver.id }, header: mutation },
        body: { reason, ...(wantsEmail ? { emailInstructions: true } : {}) },
      });
      if (response.error) throw new Error(response.error.error.message);
      reveal(response.data.data);
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
            <th>Sign-in</th>
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
                <StatusBadge
                  value={
                    !row.credential
                      ? 'not_issued'
                      : row.credential.status === 'suspended'
                        ? 'suspended'
                        : row.credential.mustChangePin
                          ? 'temporary_pin'
                          : 'pin_set'
                  }
                />
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

/** Offer email only where there is an address to send to, and say why not. */
function EmailChoice({
  email,
  checked,
  onChange,
}: {
  email: string | null;
  checked: boolean;
  onChange: (value: boolean) => void;
}) {
  if (!email)
    return (
      <p className="dialog-note">
        This driver has no email address. Add one with Edit driver to email the details; otherwise
        the temporary PIN is shown here once.
      </p>
    );
  return (
    <label className="check-row">
      <input
        type="checkbox"
        checked={checked}
        onChange={(event) => onChange(event.target.checked)}
      />
      Email the driver code and temporary PIN to {email}
    </label>
  );
}
