import { Button, Input } from '@fluentui/react-components';
import { SearchRegular } from '@fluentui/react-icons';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import {
  Empty,
  ErrorState,
  LoadingRows,
  Page,
  Panel,
  StatusBadge,
  money,
  when,
} from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';
import { accraLocalToIso } from '../api/accra-time';
import { ActionDialog } from '../components/ActionDialog';

type Rider = components['schemas']['OpsRider'];
type Summary = components['schemas']['OpsRiderSummary'];

export function Riders() {
  const { session } = useAuth();
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState<Rider | null>(null);
  const [mode, setMode] = useState<'restrict' | 'role' | null>(null);
  const [reason, setReason] = useState('');
  const [reviewAt, setReviewAt] = useState('');
  const [role, setRole] = useState<'commuter' | 'driver' | 'admin'>('commuter');
  const query = useQuery<{ riders: Rider[]; summary: Summary }>(
    async (signal) => {
      const [riders, summary] = await Promise.all([
        session.client.GET('/v1/ops/riders', {
          params: { query: { limit: 200, ...(search ? { q: search } : {}) }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/riders/summary', { params: { header: opsHeaders }, signal }),
      ]);
      if (riders.error) throw new Error(riders.error.error.message);
      if (summary.error) throw new Error(summary.error.error.message);
      return { riders: riders.data.data, summary: summary.data.data };
    },
    [session, search],
  );
  const summary = query.data?.summary;
  return (
    <Page
      title="Riders"
      description="Membership, route and credit context without exposing provider credentials."
      actions={
        <Input
          contentBefore={<SearchRegular />}
          value={search}
          onChange={(_, data) => setSearch(data.value)}
          placeholder="Search riders"
        />
      }
    >
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <div className="stat-grid">
        <Stat label="Active" value={summary?.active} />
        <Stat label="Paused" value={summary?.paused} />
        <Stat
          label="Monthly / annual"
          value={summary ? `${summary.monthly} / ${summary.annual}` : undefined}
        />
        <Stat
          label="Credit outstanding"
          value={summary ? money(summary.creditOutstanding) : undefined}
        />
      </div>
      <Panel title="Rider directory">
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.riders.length ? (
          <Empty />
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Rider</th>
                  <th>Membership</th>
                  <th>Route</th>
                  <th>Rides left</th>
                  <th>Credit</th>
                  <th>Role</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {query.data.riders.map((row) => (
                  <tr key={row.id}>
                    <td>
                      <strong>{row.displayName}</strong>
                      <div className="muted">{row.email ?? row.phone ?? 'No contact'}</div>
                    </td>
                    <td>
                      <StatusBadge value={row.status} />
                      <div className="muted">{row.plan ?? 'No plan'}</div>
                    </td>
                    <td>{row.routeName ?? '—'}</td>
                    <td>{row.ridesLeft ?? '—'}</td>
                    <td>{money(row.availableCredit)}</td>
                    <td>{row.role}</td>
                    <td>
                      <Button appearance="subtle" onClick={() => setSelected(row)}>
                        Manage
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Panel>
      {selected && (
        <RiderDetail
          rider={selected}
          onClose={() => setSelected(null)}
          onRestrict={() => {
            setMode('restrict');
            setReviewAt(new Date(Date.now() + 7 * 86400000).toISOString().slice(0, 16));
          }}
          onRole={() => {
            setRole(selected.role);
            setMode('role');
          }}
          onChanged={() => {
            query.retry();
            setSelected(null);
          }}
        />
      )}
      <ActionDialog
        open={mode !== null}
        title={mode === 'restrict' ? 'Restrict rider account' : 'Change account role'}
        description={
          mode === 'role'
            ? 'Role changes take effect from current database facts. Promoting to admin grants access only after passkey registration.'
            : 'A restriction blocks access account-wide until an attributed release decision.'
        }
        confirmLabel={mode === 'restrict' ? 'Create restriction' : 'Change role'}
        danger={mode === 'restrict'}
        onClose={() => setMode(null)}
        onConfirm={async () => {
          if (!selected) return;
          const key = crypto.randomUUID();
          if (mode === 'restrict') {
            const response = await session.client.POST('/v1/ops/users/{id}/restrictions', {
              params: {
                path: { id: selected.id },
                header: { ...opsHeaders, 'Idempotency-Key': key },
              },
              body: { reason, reviewAt: accraLocalToIso(reviewAt) },
            });
            if (response.error) throw new Error(response.error.error.message);
          } else {
            const response = await session.client.PATCH('/v1/ops/users/{id}/role', {
              params: {
                path: { id: selected.id },
                header: { ...opsHeaders, 'Idempotency-Key': key, 'If-Match': selected.editToken },
              },
              body: { role, reason },
            });
            if (response.error) throw new Error(response.error.error.message);
          }
          setSelected(null);
          setReason('');
          query.retry();
        }}
      >
        {mode === 'restrict' && (
          <label>
            Review at (Accra time, GMT)
            <input
              type="datetime-local"
              required
              value={reviewAt}
              onChange={(event) => setReviewAt(event.target.value)}
            />
          </label>
        )}
        {mode === 'role' && (
          <label>
            Role
            <select value={role} onChange={(event) => setRole(event.target.value as typeof role)}>
              <option value="commuter">Commuter</option>
              <option value="driver">Driver</option>
              <option value="admin">Administrator</option>
            </select>
          </label>
        )}
        <label>
          Reason
          <textarea
            rows={4}
            required
            value={reason}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
      </ActionDialog>
    </Page>
  );
}

function RiderDetail({
  rider,
  onClose,
  onRestrict,
  onRole,
  onChanged,
}: {
  rider: Rider;
  onClose: () => void;
  onRestrict: () => void;
  onRole: () => void;
  onChanged: () => void;
}) {
  const { session } = useAuth();
  const [release, setRelease] = useState<components['schemas']['Restriction'] | null>(null);
  const [reason, setReason] = useState('');
  const query = useQuery<components['schemas']['OpsRiderDetail']>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/riders/{id}', {
        params: { path: { id: rider.id }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session, rider.id],
  );
  const detail = query.data;
  return (
    <>
      <aside className="detail-drawer">
        <div className="detail-drawer-heading">
          <div>
            <div className="eyebrow">Rider account</div>
            <h2>{rider.displayName}</h2>
          </div>
          <Button appearance="subtle" onClick={onClose}>
            Close
          </Button>
        </div>
        {query.error && <ErrorState message={query.error} retry={query.retry} />}
        {query.loading ? (
          <LoadingRows rows={5} />
        ) : (
          detail && (
            <>
              <dl className="detail-grid">
                <div>
                  <dt>Membership</dt>
                  <dd>
                    <StatusBadge value={detail.rider.status} />
                  </dd>
                </div>
                <div>
                  <dt>Coverage ends</dt>
                  <dd>{detail.membership?.endsAt ? when(detail.membership.endsAt) : '—'}</dd>
                </div>
                <div>
                  <dt>Rides left</dt>
                  <dd>{detail.rider.ridesLeft ?? '—'}</dd>
                </div>
                <div>
                  <dt>Credit</dt>
                  <dd>{money(detail.rider.availableCredit)}</dd>
                </div>
              </dl>
              <h3>Access restrictions</h3>
              <div className="stack-list">
                {detail.restrictions.length ? (
                  detail.restrictions.map((row) => (
                    <div className="stack-row" key={row.id}>
                      <span>
                        <strong>{row.reason}</strong>
                        <small>
                          Review {when(row.reviewAt)} · {row.active ? 'active' : 'released'}
                        </small>
                      </span>
                      {row.active && (
                        <Button appearance="subtle" onClick={() => setRelease(row)}>
                          Release
                        </Button>
                      )}
                    </div>
                  ))
                ) : (
                  <p className="muted">No restrictions.</p>
                )}
              </div>
              <h3>Recent purchases</h3>
              <div className="stack-list">
                {detail.purchases.slice(0, 5).map((row) => (
                  <div className="stack-row" key={row.id}>
                    <span>
                      <strong>
                        {row.plan} · {money(row.cashDue)}
                      </strong>
                      <small>{when(row.createdAt)}</small>
                    </span>
                    <StatusBadge value={row.state} />
                  </div>
                ))}
              </div>
              <h3>Recent reservations</h3>
              <div className="stack-list">
                {detail.reservations.slice(0, 5).map((row) => (
                  <div className="stack-row" key={row.id}>
                    <span>
                      <strong>{row.routeName ?? row.direction}</strong>
                      <small>{row.serviceDate}</small>
                    </span>
                    <StatusBadge value={row.status} />
                  </div>
                ))}
              </div>
              <div className="drawer-actions">
                <Button onClick={onRestrict}>Restrict account</Button>
                <Button onClick={onRole}>Change role</Button>
              </div>
            </>
          )
        )}
      </aside>
      <ActionDialog
        open={Boolean(release)}
        title="Release account restriction"
        description="The release is attributed to your administrator account and leaves the restriction history intact."
        confirmLabel="Release restriction"
        onClose={() => {
          setRelease(null);
          setReason('');
        }}
        onConfirm={async () => {
          if (!release) return;
          const response = await session.client.POST(
            '/v1/ops/users/{id}/restrictions/{restrictionId}/release',
            {
              params: {
                path: { id: rider.id, restrictionId: release.id },
                header: {
                  ...opsHeaders,
                  'Idempotency-Key': crypto.randomUUID(),
                  'If-Match': release.editToken,
                },
              },
              body: { reason },
            },
          );
          if (response.error) throw new Error(response.error.error.message);
          setRelease(null);
          setReason('');
          onChanged();
        }}
      >
        <label>
          Reason
          <textarea
            rows={4}
            required
            value={reason}
            onChange={(event) => setReason(event.target.value)}
          />
        </label>
      </ActionDialog>
    </>
  );
}
function Stat({ label, value }: { label: string; value?: string | number }) {
  return (
    <div className="stat-card">
      <div className="stat-label">{label}</div>
      <div className="stat-value">{value ?? '—'}</div>
    </div>
  );
}
