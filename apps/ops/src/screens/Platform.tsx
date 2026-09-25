import { Button, Switch, Tab, TabList } from '@fluentui/react-components';
import { PlayRegular } from '@fluentui/react-icons';
import { startRegistration } from '@simplewebauthn/browser';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { accraLocalToIso } from '../api/accra-time';
import { ActionDialog } from '../components/ActionDialog';

type Flag = components['schemas']['Flag'];
type Minimum = components['schemas']['MinimumVersion'];
type TraceHold = components['schemas']['TraceHold'];
const jobs = [
  ['Run payment maintenance', '/v1/ops/maintenance/payments'],
  ['Generate trips', '/v1/ops/maintenance/trip-generation'],
  ['Ask riders', '/v1/ops/maintenance/ask-dispatch'],
  ['Apply reservation defaults', '/v1/ops/maintenance/reservation-defaults'],
  ['Resume pauses', '/v1/ops/maintenance/personal-pause-resumes'],
  ['Process payment inbox', '/v1/ops/maintenance/payment-inbox'],
  ['Reconcile payments', '/v1/ops/maintenance/payment-reconciliation'],
  ['Close periods', '/v1/ops/maintenance/period-close'],
  ['Resolve no-shows', '/v1/ops/maintenance/no-shows'],
  ['Learn route speeds', '/v1/ops/maintenance/route-learning'],
  ['Apply GPS retention', '/v1/ops/maintenance/gps-retention'],
] as const;

export function Platform() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'flags' | 'versions' | 'jobs' | 'traces' | 'security'>('flags');
  const [minimum, setMinimum] = useState<Minimum | null>(null);
  const [minimumBuild, setMinimumBuild] = useState(1);
  const [storeUrl, setStoreUrl] = useState('');
  const query = useQuery<{ flags: Flag[]; versions: Minimum[] }>(
    async (signal) => {
      const [flags, versions] = await Promise.all([
        session.client.GET('/v1/ops/flags', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/min-versions', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
      ]);
      if (flags.error) throw new Error(flags.error.error.message);
      if (versions.error) throw new Error(versions.error.error.message);
      return { flags: flags.data.data, versions: versions.data.data };
    },
    [session],
  );
  return (
    <Page
      title="Platform controls"
      description="Release safety, maintenance and administrator access in one guarded workspace."
    >
      <TabList
        selectedValue={tab}
        onTabSelect={(_, data) => setTab(data.value as typeof tab)}
        style={{ marginBottom: 18 }}
      >
        <Tab value="flags">Feature flags</Tab>
        <Tab value="versions">Minimum versions</Tab>
        <Tab value="jobs">Manual jobs</Tab>
        <Tab value="traces">Trace holds</Tab>
        <Tab value="security">Security</Tab>
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      {tab === 'flags' && (
        <Panel title="Feature controls">
          {query.loading ? (
            <LoadingRows />
          ) : !query.data?.flags.length ? (
            <Empty />
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Flag</th>
                  <th>Enabled</th>
                  <th>Rollout</th>
                  <th>Version</th>
                </tr>
              </thead>
              <tbody>
                {query.data.flags.map((row) => (
                  <tr key={row.key}>
                    <td>
                      <strong>{row.key}</strong>
                      <div className="muted">{row.description}</div>
                    </td>
                    <td>
                      <Switch
                        checked={row.enabled}
                        onChange={(_, data) =>
                          void setFlag(session, row, data.checked).then(query.retry)
                        }
                      />
                    </td>
                    <td>{row.rolloutPercentage}%</td>
                    <td>{row.version}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </Panel>
      )}
      {tab === 'versions' && (
        <Panel title="Supported app builds">
          {query.loading ? (
            <LoadingRows />
          ) : !query.data?.versions.length ? (
            <Empty />
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>App</th>
                  <th>Platform</th>
                  <th>Minimum build</th>
                  <th>API</th>
                  <th>State</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {query.data.versions.map((row) => (
                  <tr key={`${row.app}-${row.platform}`}>
                    <td>{row.app}</td>
                    <td>{row.platform}</td>
                    <td>{row.minSupportedBuild}</td>
                    <td>v{row.apiMajor}</td>
                    <td>
                      <StatusBadge value="enforced" />
                    </td>
                    <td>
                      <Button
                        appearance="subtle"
                        onClick={() => {
                          setMinimum(row);
                          setMinimumBuild(row.minSupportedBuild);
                          setStoreUrl(row.storeUrl);
                        }}
                      >
                        Edit
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </Panel>
      )}
      {tab === 'jobs' && <MaintenanceJobs session={session} />}
      {tab === 'traces' && <TraceHolds />}
      {tab === 'security' && <SecurityPanel />}
      <ActionDialog
        open={Boolean(minimum)}
        title="Update minimum supported build"
        description="Clients below this build receive an update-required response. Confirm the store URL before raising the floor."
        confirmLabel="Update floor"
        onClose={() => setMinimum(null)}
        onConfirm={async () => {
          if (!minimum) return;
          const response = await session.client.PUT('/v1/ops/min-versions/{app}/{platform}', {
            params: {
              path: { app: minimum.app, platform: minimum.platform },
              header: {
                ...opsHeaders,
                'Idempotency-Key': crypto.randomUUID(),
                'If-Match': minimum.editToken,
              },
            },
            body: { minSupportedBuild: minimumBuild, apiMajor: 1, storeUrl },
          });
          if (response.error) throw new Error(response.error.error.message);
          query.retry();
        }}
      >
        <label>
          Minimum build
          <input
            type="number"
            min="0"
            value={minimumBuild}
            onChange={(event) => setMinimumBuild(Number(event.target.value))}
          />
        </label>
        <label>
          Store URL
          <input
            type="url"
            value={storeUrl}
            onChange={(event) => setStoreUrl(event.target.value)}
          />
        </label>
      </ActionDialog>
    </Page>
  );
}

function SecurityPanel() {
  const { session } = useAuth();
  const status = useQuery<components['schemas']['PasskeyStatus']>(
    async (signal) => {
      const { data, error } = await session.client.GET('/v1/auth/passkeys', {
        params: { header: opsHeaders },
        signal,
      });
      if (error) throw new Error(error.error.message);
      return data.data;
    },
    [session],
  );
  const [working, setWorking] = useState(false);
  const [message, setMessage] = useState('');
  const addPasskey = async () => {
    setWorking(true);
    setMessage('');
    try {
      const options = await session.client.POST('/v1/auth/passkeys/registration/options', {
        params: { header: opsHeaders },
      });
      if (options.error) throw new Error(options.error.error.message);
      const credential = await startRegistration({ optionsJSON: options.data.data as never });
      const result = await session.client.POST('/v1/auth/passkeys/registration/verification', {
        params: { header: opsHeaders },
        body: credential as never,
      });
      if (result.error) throw new Error(result.error.error.message);
      setMessage('Passkey added.');
      status.retry();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : 'Passkey registration failed.');
    } finally {
      setWorking(false);
    }
  };
  return (
    <Panel title="Administrator passkeys">
      {status.loading ? (
        <LoadingRows rows={2} />
      ) : (
        <div className="panel-body">
          <p>
            <strong>{status.data?.passkeyCount ?? 0} passkeys registered</strong>
          </p>
          <p className="muted">
            This session is{' '}
            {status.data?.verified ? 'verified for operational access' : 'not elevated'}. Add
            another passkey only after verifying an existing one.
          </p>
          {message && <p>{message}</p>}
          <Button
            appearance="primary"
            disabled={working || !status.data?.verified}
            onClick={() => void addPasskey()}
          >
            {working ? 'Waiting for passkey…' : 'Add another passkey'}
          </Button>
        </div>
      )}
    </Panel>
  );
}

async function setFlag(
  session: ReturnType<typeof useAuth>['session'],
  row: Flag,
  enabled: boolean,
) {
  const response = await session.client.PUT('/v1/ops/flags/{key}', {
    params: {
      path: { key: row.key },
      header: { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID(), 'If-Match': row.editToken },
    },
    body: { enabled, rolloutPercentage: row.rolloutPercentage, description: row.description },
  });
  if (response.error) throw new Error(response.error.error.message);
}

function MaintenanceJobs({ session }: { session: ReturnType<typeof useAuth>['session'] }) {
  const [running, setRunning] = useState<string | null>(null);
  const [result, setResult] = useState('');
  const [serviceDate, setServiceDate] = useState(() =>
    new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Africa/Accra',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(new Date()),
  );
  const [direction, setDirection] = useState<'outbound' | 'return'>('outbound');
  const run = async (path: (typeof jobs)[number][1]) => {
    setRunning(path);
    setResult('');
    try {
      const maintenance = { params: { header: opsHeaders }, body: { limit: 100 } } as const;
      const serviceDay = {
        params: { header: opsHeaders },
        body: { travelDate: serviceDate, direction, limit: 100 },
      } as const;
      const response =
        path === '/v1/ops/maintenance/payments'
          ? await session.client.POST(path, maintenance)
          : path === '/v1/ops/maintenance/trip-generation'
            ? await session.client.POST(path, {
                params: { header: opsHeaders },
                body: { serviceDate, limit: 100 },
              })
            : path === '/v1/ops/maintenance/ask-dispatch'
              ? await session.client.POST(path, serviceDay)
              : path === '/v1/ops/maintenance/reservation-defaults'
                ? await session.client.POST(path, serviceDay)
                : path === '/v1/ops/maintenance/no-shows'
                  ? await session.client.POST(path, serviceDay)
                  : path === '/v1/ops/maintenance/personal-pause-resumes'
                    ? await session.client.POST(path, maintenance)
                    : path === '/v1/ops/maintenance/payment-inbox'
                      ? await session.client.POST(path, maintenance)
                      : path === '/v1/ops/maintenance/payment-reconciliation'
                        ? await session.client.POST(path, maintenance)
                        : path === '/v1/ops/maintenance/period-close'
                          ? await session.client.POST(path, maintenance)
                          : path === '/v1/ops/maintenance/route-learning'
                            ? await session.client.POST(path, maintenance)
                            : await session.client.POST(
                                '/v1/ops/maintenance/gps-retention',
                                maintenance,
                              );
      if (response.error) throw new Error(response.error.error.message);
      setResult(`${path.split('/').at(-1)} completed: ${JSON.stringify(response.data.data)}`);
    } catch (error) {
      setResult(error instanceof Error ? error.message : 'Job failed.');
    } finally {
      setRunning(null);
    }
  };
  return (
    <Panel title="Manual maintenance">
      <div className="panel-body" style={{ display: 'grid', gap: 12 }}>
        <div className="toolbar">
          <label>
            Service date{' '}
            <input
              type="date"
              value={serviceDate}
              onChange={(event) => setServiceDate(event.target.value)}
            />
          </label>
          <label>
            Direction{' '}
            <select
              value={direction}
              onChange={(event) => setDirection(event.target.value as typeof direction)}
            >
              <option value="outbound">Outbound</option>
              <option value="return">Return</option>
            </select>
          </label>
        </div>
        {jobs.map(([label, path]) => (
          <div
            key={path}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              padding: '12px 0',
              borderBottom: '1px solid #eeeaf1',
            }}
          >
            <div style={{ flex: 1 }}>
              <strong>{label}</strong>
              <div className="mono muted">{path}</div>
            </div>
            <Button
              icon={<PlayRegular />}
              disabled={Boolean(running)}
              onClick={() => void run(path)}
            >
              {running === path ? 'Running…' : 'Run'}
            </Button>
          </div>
        ))}
        {result && <div className="job-result">{result}</div>}
      </div>
    </Panel>
  );
}

function TraceHolds() {
  const { session } = useAuth();
  const [creating, setCreating] = useState(false);
  const [releasing, setReleasing] = useState<TraceHold | null>(null);
  const [incidentId, setIncidentId] = useState('');
  const [tripId, setTripId] = useState('');
  const [receivedFrom, setReceivedFrom] = useState('');
  const [receivedTo, setReceivedTo] = useState('');
  const [reviewAt, setReviewAt] = useState('');
  const [reason, setReason] = useState('');
  const query = useQuery<TraceHold[]>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/trace-holds', {
        params: { query: { limit: 200 }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session],
  );
  const clear = () => {
    setCreating(false);
    setReleasing(null);
    setIncidentId('');
    setTripId('');
    setReceivedFrom('');
    setReceivedTo('');
    setReviewAt('');
    setReason('');
  };
  return (
    <>
      <Panel
        title="GPS evidence holds"
        action={<Button onClick={() => setCreating(true)}>Create hold</Button>}
      >
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.length ? (
          <Empty>No GPS evidence is currently held.</Empty>
        ) : (
          <table className="data-table">
            <thead>
              <tr>
                <th>Incident</th>
                <th>Trip</th>
                <th>Evidence window</th>
                <th>Review</th>
                <th>State</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {query.data.map((row) => (
                <tr key={row.id}>
                  <td className="mono">{row.incidentId.slice(0, 8)}</td>
                  <td className="mono">{row.tripId.slice(0, 8)}</td>
                  <td>
                    {when(row.receivedFrom)} – {when(row.receivedTo)}
                  </td>
                  <td>{when(row.reviewAt)}</td>
                  <td>
                    <StatusBadge value={row.state} />
                  </td>
                  <td>
                    <Button
                      appearance="subtle"
                      disabled={row.state !== 'active'}
                      onClick={() => setReleasing(row)}
                    >
                      Release
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Panel>
      <ActionDialog
        open={creating}
        title="Hold GPS evidence"
        description="Preserves a bounded trace window for an existing incident beyond normal retention."
        confirmLabel="Create hold"
        onClose={clear}
        onConfirm={async () => {
          const response = await session.client.POST('/v1/ops/trace-holds', {
            params: { header: { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID() } },
            body: {
              incidentId,
              tripId,
              receivedFrom: accraLocalToIso(receivedFrom),
              receivedTo: accraLocalToIso(receivedTo),
              reviewAt: accraLocalToIso(reviewAt),
              reason,
            },
          });
          if (response.error) throw new Error(response.error.error.message);
          clear();
          query.retry();
        }}
      >
        <label>
          Incident ID
          <input
            required
            value={incidentId}
            onChange={(event) => setIncidentId(event.target.value)}
          />
        </label>
        <label>
          Trip ID
          <input required value={tripId} onChange={(event) => setTripId(event.target.value)} />
        </label>
        <label>
          Evidence from (Accra time, GMT)
          <input
            type="datetime-local"
            required
            value={receivedFrom}
            onChange={(event) => setReceivedFrom(event.target.value)}
          />
        </label>
        <label>
          Evidence to (Accra time, GMT)
          <input
            type="datetime-local"
            required
            value={receivedTo}
            onChange={(event) => setReceivedTo(event.target.value)}
          />
        </label>
        <label>
          Review at (Accra time, GMT)
          <input
            type="datetime-local"
            required
            value={reviewAt}
            onChange={(event) => setReviewAt(event.target.value)}
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
      </ActionDialog>
      <ActionDialog
        open={Boolean(releasing)}
        title="Release GPS evidence hold"
        description="The trace returns to the normal retention policy."
        confirmLabel="Release hold"
        onClose={clear}
        onConfirm={async () => {
          if (!releasing) return;
          const response = await session.client.POST('/v1/ops/trace-holds/{id}/release', {
            params: {
              path: { id: releasing.id },
              header: {
                ...opsHeaders,
                'Idempotency-Key': crypto.randomUUID(),
                'If-Match': releasing.editToken,
              },
            },
            body: { reason },
          });
          if (response.error) throw new Error(response.error.error.message);
          clear();
          query.retry();
        }}
      >
        <label>
          Reason
          <textarea
            rows={3}
            required
            value={reason}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
      </ActionDialog>
    </>
  );
}
