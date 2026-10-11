import { Button, Switch, Tab, TabList } from '@fluentui/react-components';
import { PlayRegular } from '@fluentui/react-icons';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge, when } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { accraLocalToIso } from '../api/accra-time';
import { ActionDialog } from '../components/ActionDialog';
import { ReasonField } from '../components/ReasonField';

type Flag = components['schemas']['Flag'];
type Minimum = components['schemas']['MinimumVersion'];
type TraceHold = components['schemas']['TraceHold'];
const jobs = [
  {
    label: 'Generate trips',
    path: '/v1/ops/maintenance/trip-generation',
    description: 'Create departures from published schedules for the selected service date.',
    group: 'Service',
    scope: 'date',
  },
  {
    label: 'Ask riders',
    path: '/v1/ops/maintenance/ask-dispatch',
    description: 'Send seat requests for the selected service date and direction.',
    group: 'Service',
    scope: 'direction',
  },
  {
    label: 'Apply reservation defaults',
    path: '/v1/ops/maintenance/reservation-defaults',
    description: 'Resolve unanswered seat requests for the selected service date and direction.',
    group: 'Service',
    scope: 'direction',
  },
  {
    label: 'Resolve no-shows',
    path: '/v1/ops/maintenance/no-shows',
    description: 'Settle unboarded reservations for the selected service date and direction.',
    group: 'Service',
    scope: 'direction',
  },
  {
    label: 'Run payment maintenance',
    path: '/v1/ops/maintenance/payments',
    description: 'Process payment events, reconcile provider results and close eligible periods.',
    group: 'Payments & coverage',
    scope: 'global',
  },
  {
    label: 'Resume pauses',
    path: '/v1/ops/maintenance/personal-pause-resumes',
    description: 'End personal pauses whose resume time has arrived.',
    group: 'Payments & coverage',
    scope: 'global',
  },
  {
    label: 'Learn route speeds',
    path: '/v1/ops/maintenance/route-learning',
    description: 'Update route timing estimates from eligible trip evidence.',
    group: 'System upkeep',
    scope: 'global',
  },
  {
    label: 'Apply GPS retention',
    path: '/v1/ops/maintenance/gps-retention',
    description: 'Remove expired GPS evidence, excluding active holds.',
    group: 'System upkeep',
    scope: 'global',
  },
  {
    label: 'Process payment inbox',
    path: '/v1/ops/maintenance/payment-inbox',
    description: 'Only consume queued provider events.',
    group: 'Payment recovery steps',
    scope: 'global',
  },
  {
    label: 'Reconcile payments',
    path: '/v1/ops/maintenance/payment-reconciliation',
    description: 'Only reconcile payment states with provider evidence.',
    group: 'Payment recovery steps',
    scope: 'global',
  },
  {
    label: 'Close periods',
    path: '/v1/ops/maintenance/period-close',
    description: 'Only close eligible coverage periods.',
    group: 'Payment recovery steps',
    scope: 'global',
  },
] as const;
type Job = (typeof jobs)[number];

export function Platform() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'flags' | 'versions' | 'jobs' | 'traces'>('flags');
  const [minimum, setMinimum] = useState<Minimum | null>(null);
  const [minimumBuild, setMinimumBuild] = useState(1);
  const [storeUrl, setStoreUrl] = useState('');
  const [flagChange, setFlagChange] = useState<{ row: Flag; enabled: boolean } | null>(null);
  const [reason, setReason] = useState('');
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
      description="Manage releases, recovery jobs and GPS evidence holds. Your passkeys are in My profile."
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
                        onChange={(_, data) => {
                          setReason('');
                          setFlagChange({ row, enabled: data.checked });
                        }}
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
                          setReason('');
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
      <ActionDialog
        open={Boolean(minimum)}
        title="Update minimum supported build"
        description="Clients below this build receive an update-required response. Confirm the store URL before raising the floor."
        confirmLabel="Update floor"
        confirmDisabled={!reason.trim() || !storeUrl.trim() || minimumBuild < 1}
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
            body: { minSupportedBuild: minimumBuild, apiMajor: 1, storeUrl, reason: reason.trim() },
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
        <ReasonField value={reason} onChange={setReason} />
      </ActionDialog>
      <ActionDialog
        open={Boolean(flagChange)}
        title={
          flagChange ? `${flagChange.enabled ? 'Turn on' : 'Turn off'} ${flagChange.row.key}` : ''
        }
        description={flagChange?.row.description}
        confirmLabel={flagChange?.enabled ? 'Turn on' : 'Turn off'}
        confirmDisabled={!reason.trim()}
        onClose={() => setFlagChange(null)}
        onConfirm={async () => {
          if (!flagChange) return;
          await setFlag(session, flagChange.row, flagChange.enabled, reason.trim());
          query.retry();
        }}
      >
        <ReasonField value={reason} onChange={setReason} />
      </ActionDialog>
    </Page>
  );
}

async function setFlag(
  session: ReturnType<typeof useAuth>['session'],
  row: Flag,
  enabled: boolean,
  reason: string,
) {
  const response = await session.client.PUT('/v1/ops/flags/{key}', {
    params: {
      path: { key: row.key },
      header: { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID(), 'If-Match': row.editToken },
    },
    body: {
      enabled,
      rolloutPercentage: row.rolloutPercentage,
      description: row.description,
      reason,
    },
  });
  if (response.error) throw new Error(response.error.error.message);
}

function MaintenanceJobs({ session }: { session: ReturnType<typeof useAuth>['session'] }) {
  const [running, setRunning] = useState<string | null>(null);
  const [result, setResult] = useState<{
    label: string;
    message: string;
    details?: string;
    error?: boolean;
  } | null>(null);
  const [selectedJob, setSelectedJob] = useState<Job | null>(null);
  const [serviceDate, setServiceDate] = useState(() =>
    new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Africa/Accra',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(new Date()),
  );
  const [direction, setDirection] = useState<'outbound' | 'return'>('outbound');
  const run = async (job: Job) => {
    const { path, label } = job;
    setRunning(path);
    setResult(null);
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
      const data = response.data.data as Record<string, unknown>;
      const counts = ['considered', 'succeeded', 'blocked', 'failed']
        .filter((key) => typeof data[key] === 'number')
        .map((key) => `${key}: ${data[key]}`);
      setResult({
        label,
        message: counts.length ? counts.join(' · ') : 'Completed. See details for the result.',
        details: JSON.stringify(data, null, 2),
      });
    } catch (error) {
      setResult({
        label,
        message: error instanceof Error ? error.message : 'The job could not be completed.',
        error: true,
      });
    } finally {
      setRunning(null);
    }
  };
  const jobRow = (job: Job) => (
    <div className="maintenance-job" key={job.path}>
      <div>
        <strong>{job.label}</strong>
        <p>{job.description}</p>
      </div>
      <Button
        icon={<PlayRegular />}
        disabled={Boolean(running)}
        onClick={() => setSelectedJob(job)}
      >
        {running === job.path ? 'Running…' : 'Run'}
      </Button>
    </div>
  );
  return (
    <Panel title="Manual maintenance">
      <div className="panel-body maintenance-workspace">
        <p className="muted">
          These are recovery controls. Use them when a scheduled run needs investigation or a
          specific service day needs correction. Each maintenance step uses a batch limit of 100.
        </p>
        <section aria-labelledby="service-jobs-title">
          <div className="maintenance-heading">
            <h3 id="service-jobs-title">Service day</h3>
            <div className="maintenance-scope">
              <label>
                Service date
                <input
                  type="date"
                  value={serviceDate}
                  onChange={(event) => setServiceDate(event.target.value)}
                />
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
            </div>
          </div>
          <p className="muted">
            Direction applies to rider asks, defaults and no-shows. Trip generation uses the date
            only.
          </p>
          {jobs.filter((job) => job.group === 'Service').map(jobRow)}
        </section>
        <section aria-labelledby="payment-jobs-title">
          <h3 id="payment-jobs-title">Payments & coverage</h3>
          {jobs.filter((job) => job.group === 'Payments & coverage').map(jobRow)}
        </section>
        <details className="maintenance-advanced">
          <summary>System upkeep and individual recovery steps</summary>
          <p className="muted">
            Use an individual step only when diagnosing a failure in the combined workflow.
          </p>
          {jobs
            .filter(
              (job) => job.group === 'System upkeep' || job.group === 'Payment recovery steps',
            )
            .map(jobRow)}
        </details>
        {result && (
          <div className="job-result" role={result.error ? 'alert' : 'status'}>
            <strong>{result.label}</strong>
            <p>{result.message}</p>
            {result.details && (
              <details>
                <summary>Technical result</summary>
                <pre>{result.details}</pre>
              </details>
            )}
          </div>
        )}
      </div>
      <ActionDialog
        open={Boolean(selectedJob)}
        title={`Run ${selectedJob?.label.toLowerCase() ?? 'job'}?`}
        description={selectedJob?.description}
        confirmLabel="Run job"
        onClose={() => setSelectedJob(null)}
        onConfirm={async () => {
          if (selectedJob) await run(selectedJob);
        }}
      >
        <p className="dialog-note">
          {selectedJob?.scope === 'direction'
            ? `${serviceDate} · ${direction}`
            : selectedJob?.scope === 'date'
              ? serviceDate
              : 'All eligible records; service date and direction do not apply.'}
        </p>
      </ActionDialog>
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
