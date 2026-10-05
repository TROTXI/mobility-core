import { Button, Tab, TabList } from '@fluentui/react-components';
import { ArrowClockwiseRegular } from '@fluentui/react-icons';
import { useState } from 'react';
import { Link } from 'react-router-dom';
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
import { ActionDialog } from '../components/ActionDialog';

type Purchase = components['schemas']['OpsPurchase'];
type Review = components['schemas']['PaymentReview'];
type Refund = components['schemas']['RefundInitiation'];
type Renewal = components['schemas']['OpsAutoRenewal'];
type RenewalFilter = 'attention' | 'open' | 'all';

export function Payments() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'purchases' | 'reviews' | 'renewals'>('purchases');
  const [renewalFilter, setRenewalFilter] = useState<RenewalFilter>('attention');
  const [purchase, setPurchase] = useState<Purchase | null>(null);
  const [detailPurchase, setDetailPurchase] = useState<Purchase | null>(null);
  const [review, setReview] = useState<Review | null>(null);
  const [amount, setAmount] = useState('');
  const [reason, setReason] = useState('');
  const [decision, setDecision] = useState<'resolved' | 'waived'>('resolved');
  const purchasesQuery = useQuery<Purchase[]>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/purchases', {
        params: { query: { limit: 200 }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session],
  );
  const reviewsQuery = useQuery<Review[]>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/payments/reviews', {
        params: { query: { limit: 200 }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session],
  );
  const renewalsQuery = useQuery<Renewal[]>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/auto-renewals', {
        params: { query: { limit: 200, filter: renewalFilter }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session, renewalFilter],
  );
  const activeQuery =
    tab === 'purchases' ? purchasesQuery : tab === 'reviews' ? reviewsQuery : renewalsQuery;
  return (
    <Page
      title="Payments & credits"
      description="Provider facts, rider value and human decisions stay separate."
      actions={
        <Button
          icon={<ArrowClockwiseRegular />}
          onClick={() => {
            purchasesQuery.retry();
            reviewsQuery.retry();
            renewalsQuery.retry();
          }}
        >
          Refresh
        </Button>
      }
    >
      <TabList
        selectedValue={tab}
        onTabSelect={(_, data) => setTab(data.value as typeof tab)}
        style={{ marginBottom: 18 }}
      >
        <Tab value="purchases">Purchases</Tab>
        <Tab value="reviews">Manual reviews</Tab>
        <Tab value="renewals">Card renewals</Tab>
      </TabList>
      {activeQuery.error ? (
        <ErrorState message={activeQuery.error} retry={activeQuery.retry} />
      ) : (
        <Panel
          title={
            tab === 'purchases'
              ? 'Purchase ledger'
              : tab === 'reviews'
                ? 'Review queue'
                : 'Automatic card renewals'
          }
          action={
            tab === 'renewals' ? (
              <label className="filter-bar">
                Show
                <select
                  value={renewalFilter}
                  onChange={(event) => setRenewalFilter(event.target.value as RenewalFilter)}
                >
                  <option value="attention">Needs attention</option>
                  <option value="open">Open</option>
                  <option value="all">All</option>
                </select>
              </label>
            ) : undefined
          }
        >
          {activeQuery.loading ? (
            <LoadingRows />
          ) : tab === 'renewals' ? (
            <RenewalRows rows={renewalsQuery.data ?? []} filter={renewalFilter} />
          ) : tab === 'purchases' ? (
            <PurchaseRows
              rows={purchasesQuery.data ?? []}
              onDetail={setDetailPurchase}
              onRefund={(row) => {
                setPurchase(row);
                setAmount(String(row.cashDue.amountMinor / 100));
              }}
            />
          ) : (
            <ReviewRows rows={reviewsQuery.data ?? []} onResolve={setReview} />
          )}
        </Panel>
      )}
      {detailPurchase && (
        <PurchaseDetail purchase={detailPurchase} onClose={() => setDetailPurchase(null)} />
      )}
      <ActionDialog
        open={Boolean(purchase)}
        title="Initiate refund"
        description="This sends a request to Paystack in the configured environment and records the administrator reason."
        confirmLabel="Initiate refund"
        danger
        onClose={() => {
          setPurchase(null);
          setReason('');
        }}
        onConfirm={async () => {
          if (!purchase) return;
          const response = await session.client.POST('/v1/ops/purchases/{id}/refunds', {
            params: {
              path: { id: purchase.id },
              header: { ...opsHeaders, 'Idempotency-Key': crypto.randomUUID() },
            },
            body: {
              amount: { amountMinor: Math.round(Number(amount) * 100), currency: 'GHS' },
              reason,
            },
          });
          if (response.error) throw new Error(response.error.error.message);
          purchasesQuery.retry();
        }}
      >
        <label>
          Amount (GHS)
          <input
            type="number"
            min="0.01"
            step="0.01"
            value={amount}
            onChange={(event) => setAmount(event.target.value)}
          />
        </label>
        <label>
          Reason
          <textarea rows={4} value={reason} onChange={(event) => setReason(event.target.value)} />
        </label>
      </ActionDialog>
      <ActionDialog
        open={Boolean(review)}
        title="Resolve payment review"
        confirmLabel="Record decision"
        onClose={() => {
          setReview(null);
          setReason('');
        }}
        onConfirm={async () => {
          if (!review) return;
          const response = await session.client.POST('/v1/ops/payments/reviews/{id}/decisions', {
            params: {
              path: { id: review.id },
              header: {
                ...opsHeaders,
                'Idempotency-Key': crypto.randomUUID(),
                'If-Match': review.editToken,
              },
            },
            body: { decision, reason },
          });
          if (response.error) throw new Error(response.error.error.message);
          reviewsQuery.retry();
        }}
      >
        <label>
          Decision
          <select
            value={decision}
            onChange={(event) => setDecision(event.target.value as typeof decision)}
          >
            <option value="resolved">Resolved</option>
            <option value="waived">Waived</option>
          </select>
        </label>
        <label>
          Reason
          <textarea rows={4} value={reason} onChange={(event) => setReason(event.target.value)} />
        </label>
      </ActionDialog>
    </Page>
  );
}
// What stopped a renewal, in the words an operator acts on.
const renewalReason: Record<string, string> = {
  card_declined: 'Card declined. Retrying daily.',
  charge_unconfirmed: 'Charge not confirmed by Paystack.',
  fare_changed: 'Fare changed. Send a new offer.',
  service_changed: 'Service changed. Send a new offer.',
  renewal_blocked: 'Account needs attention before it can renew.',
  no_card: 'No saved card.',
  coverage_conflict: 'Rider already renewed another way.',
};

function RenewalRows({ rows, filter }: { rows: Renewal[]; filter: RenewalFilter }) {
  if (!rows.length)
    return (
      <Empty>
        {filter === 'attention'
          ? 'No card renewals need attention.'
          : 'No card renewals match this view.'}
      </Empty>
    );
  return (
    <div style={{ overflowX: 'auto' }}>
      <table className="data-table">
        <thead>
          <tr>
            <th>Rider</th>
            <th>Coverage ends</th>
            <th>Status</th>
            <th>What happened</th>
            <th>Card</th>
            <th>Price</th>
            <th>Next try</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id}>
              <td>{row.riderName ?? row.riderId.slice(0, 8)}</td>
              <td>{when(row.periodEndsAt)}</td>
              <td>
                <StatusBadge value={row.state} />
              </td>
              <td>
                {row.failureCode ? (renewalReason[row.failureCode] ?? row.failureCode) : '—'}
                {row.state === 'needs_offer' && (
                  <>
                    {' '}
                    <Link to="/standby">Open Standby</Link>
                  </>
                )}
              </td>
              <td>{row.card ? `${row.card.brand} •••• ${row.card.last4}` : 'None'}</td>
              <td>{money(row.price)}</td>
              <td>{row.nextAttemptAt ? when(row.nextAttemptAt) : '—'}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function PurchaseRows({
  rows,
  onDetail,
  onRefund,
}: {
  rows: Purchase[];
  onDetail: (row: Purchase) => void;
  onRefund: (row: Purchase) => void;
}) {
  if (!rows.length) return <Empty>No purchases match this view.</Empty>;
  return (
    <div style={{ overflowX: 'auto' }}>
      <table className="data-table">
        <thead>
          <tr>
            <th>Created</th>
            <th>Rider</th>
            <th>Plan</th>
            <th>Cash due</th>
            <th>Collection</th>
            <th>State</th>
            <th />
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id}>
              <td>{when(row.createdAt)}</td>
              <td className="mono">{row.riderId.slice(0, 8)}</td>
              <td>{row.plan}</td>
              <td>{money(row.cashDue)}</td>
              <td>
                <StatusBadge value={row.collectionState} />
              </td>
              <td>
                <StatusBadge value={row.state} />
              </td>
              <td>
                <Button appearance="subtle" onClick={() => onDetail(row)}>
                  Details
                </Button>
                <Button
                  appearance="subtle"
                  disabled={row.collectionState !== 'successful'}
                  onClick={() => onRefund(row)}
                >
                  Refund
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function PurchaseDetail({ purchase, onClose }: { purchase: Purchase; onClose: () => void }) {
  const { session } = useAuth();
  const query = useQuery<{ purchase: Purchase; refunds: Refund[] }>(
    async (signal) => {
      const [detail, refunds] = await Promise.all([
        session.client.GET('/v1/ops/purchases/{id}', {
          params: { path: { id: purchase.id }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/purchases/{id}/refunds', {
          params: { path: { id: purchase.id }, header: opsHeaders },
          signal,
        }),
      ]);
      if (detail.error) throw new Error(detail.error.error.message);
      if (refunds.error) throw new Error(refunds.error.error.message);
      return { purchase: detail.data.data, refunds: refunds.data.data.items };
    },
    [session, purchase.id],
  );
  const detail = query.data?.purchase;
  return (
    <aside className="detail-drawer">
      <div className="detail-drawer-heading">
        <div>
          <div className="eyebrow">Purchase</div>
          <h2 className="mono">{purchase.id.slice(0, 12)}</h2>
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
                <dt>Rider</dt>
                <dd className="mono">{detail.riderId.slice(0, 12)}</dd>
              </div>
              <div>
                <dt>State</dt>
                <dd>
                  <StatusBadge value={detail.state} />
                </dd>
              </div>
              <div>
                <dt>Price</dt>
                <dd>{money(detail.price)}</dd>
              </div>
              <div>
                <dt>Credit applied</dt>
                <dd>{money(detail.appliedCredit)}</dd>
              </div>
              <div>
                <dt>Cash due</dt>
                <dd>{money(detail.cashDue)}</dd>
              </div>
              <div>
                <dt>Created</dt>
                <dd>{when(detail.createdAt)}</dd>
              </div>
            </dl>
            <h3>Provider attempts</h3>
            <div className="stack-list">
              {detail.attempts.length ? (
                detail.attempts.map((row) => (
                  <div className="stack-row" key={row.id}>
                    <span>
                      <strong>{row.providerReference}</strong>
                      <small>{row.environment} environment</small>
                    </span>
                    <StatusBadge value={row.status} />
                  </div>
                ))
              ) : (
                <p className="muted">No provider attempt recorded.</p>
              )}
            </div>
            <h3>Refund requests</h3>
            <div className="stack-list">
              {query.data?.refunds.length ? (
                query.data.refunds.map((row) => (
                  <div className="stack-row" key={row.id}>
                    <span>
                      <strong>{money(row.amount)}</strong>
                      <small>{row.reason}</small>
                    </span>
                    <StatusBadge value={row.state} />
                  </div>
                ))
              ) : (
                <p className="muted">No refund request recorded.</p>
              )}
            </div>
          </>
        )
      )}
    </aside>
  );
}
function ReviewRows({ rows, onResolve }: { rows: Review[]; onResolve: (row: Review) => void }) {
  if (!rows.length) return <Empty>No payment reviews need a decision.</Empty>;
  return (
    <div style={{ overflowX: 'auto' }}>
      <table className="data-table">
        <thead>
          <tr>
            <th>Updated</th>
            <th>Kind</th>
            <th>Purchase</th>
            <th>Amount</th>
            <th>Status</th>
            <th />
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.id}>
              <td>{when(row.updatedAt)}</td>
              <td>{row.kind.replaceAll('_', ' ')}</td>
              <td className="mono">{row.purchaseId.slice(0, 8)}</td>
              <td>{money(row.amount)}</td>
              <td>
                <StatusBadge value={row.status} />
              </td>
              <td>
                <Button
                  appearance="subtle"
                  disabled={row.status !== 'open'}
                  onClick={() => onResolve(row)}
                >
                  Resolve
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
