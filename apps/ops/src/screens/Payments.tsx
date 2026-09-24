import { Button, Tab, TabList } from '@fluentui/react-components';
import { ArrowClockwiseRegular } from '@fluentui/react-icons';
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
import { ActionDialog } from '../components/ActionDialog';

type Purchase = components['schemas']['OpsPurchase'];
type Review = components['schemas']['PaymentReview'];

export function Payments() {
  const { session } = useAuth();
  const [tab, setTab] = useState<'purchases' | 'reviews'>('purchases');
  const [purchase, setPurchase] = useState<Purchase | null>(null);
  const [review, setReview] = useState<Review | null>(null);
  const [amount, setAmount] = useState('');
  const [reason, setReason] = useState('');
  const [decision, setDecision] = useState<'resolved' | 'waived'>('resolved');
  const query = useQuery<{ purchases: Purchase[]; reviews: Review[] }>(
    async (signal) => {
      const [purchases, reviews] = await Promise.all([
        session.client.GET('/v1/ops/purchases', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
        session.client.GET('/v1/ops/payments/reviews', {
          params: { query: { limit: 200 }, header: opsHeaders },
          signal,
        }),
      ]);
      if (purchases.error) throw new Error(purchases.error.error.message);
      if (reviews.error) throw new Error(reviews.error.error.message);
      return { purchases: purchases.data.data, reviews: reviews.data.data };
    },
    [session],
  );
  return (
    <Page
      title="Payments & credits"
      description="Provider facts, rider value and human decisions stay separate."
      actions={
        <Button icon={<ArrowClockwiseRegular />} onClick={query.retry}>
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
      </TabList>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel title={tab === 'purchases' ? 'Purchase ledger' : 'Review queue'}>
        {query.loading ? (
          <LoadingRows />
        ) : tab === 'purchases' ? (
          <PurchaseRows
            rows={query.data?.purchases ?? []}
            onRefund={(row) => {
              setPurchase(row);
              setAmount(String(row.cashDue.amountMinor / 100));
            }}
          />
        ) : (
          <ReviewRows rows={query.data?.reviews ?? []} onResolve={setReview} />
        )}
      </Panel>
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
          query.retry();
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
          query.retry();
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
function PurchaseRows({ rows, onRefund }: { rows: Purchase[]; onRefund: (row: Purchase) => void }) {
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
