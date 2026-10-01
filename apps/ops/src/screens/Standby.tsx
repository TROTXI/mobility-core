import { Button } from '@fluentui/react-components';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { opsHeaders } from '../api/session';
import { useQuery } from '../hooks/useQuery';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge } from '../components/Page';
import { ActionDialog } from '../components/ActionDialog';

type Application = components['schemas']['StandbyApplication'];
type PageResult = { data: Application[]; nextCursor: string | null };

export function Standby() {
  const { session } = useAuth();
  const [selected, setSelected] = useState<Application | null>(null);
  const [days, setDays] = useState(2);
  const [loadingMore, setLoadingMore] = useState(false);
  const [moreError, setMoreError] = useState('');
  const [offerAttempt, setOfferAttempt] = useState<{
    applicationId: string;
    key: string;
    expiresAt: string;
  } | null>(null);
  const query = useQuery<PageResult>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/standby', {
        params: { header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return { data: response.data.data, nextCursor: response.data.page.nextCursor };
    },
    [session],
  );

  return (
    <Page
      title="Standby"
      description="Review new-rider route requests and issue time-limited offers. Riders choose whether to pay."
    >
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel title="Applications" action={<Button onClick={query.retry}>Refresh</Button>}>
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.data.length ? (
          <Empty />
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Rider</th>
                  <th>Route</th>
                  <th>Status</th>
                  <th>Offer expiry</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {query.data.data.map((application) => (
                  <tr key={application.id}>
                    <td>{application.riderName}</td>
                    <td>{application.routeName}</td>
                    <td>
                      <StatusBadge value={application.state} />
                    </td>
                    <td>
                      {application.offer
                        ? new Date(application.offer.expiresAt).toLocaleString()
                        : '—'}
                    </td>
                    <td>
                      {application.state === 'submitted' && (
                        <Button
                          appearance="subtle"
                          onClick={() => {
                            setOfferAttempt(null);
                            setSelected(application);
                          }}
                        >
                          Send offer
                        </Button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {query.data.nextCursor && (
              <>
                {moreError && <ErrorState message={moreError} retry={() => setMoreError('')} />}
                <Button
                  disabled={loadingMore}
                  onClick={async () => {
                    if (!query.data?.nextCursor) return;
                    setLoadingMore(true);
                    setMoreError('');
                    try {
                      const response = await session.client.GET('/v1/ops/standby', {
                        params: {
                          header: opsHeaders,
                          query: { cursor: query.data.nextCursor },
                        },
                      });
                      if (response.error) throw new Error(response.error.error.message);
                      query.setData((current) =>
                        current
                          ? {
                              data: [...current.data, ...response.data.data],
                              nextCursor: response.data.page.nextCursor,
                            }
                          : current,
                      );
                    } catch (error) {
                      setMoreError(
                        error instanceof Error
                          ? error.message
                          : 'Could not load more applications.',
                      );
                    } finally {
                      setLoadingMore(false);
                    }
                  }}
                >
                  {loadingMore ? 'Loading…' : 'Load more'}
                </Button>
              </>
            )}
          </div>
        )}
      </Panel>
      <ActionDialog
        open={selected !== null}
        title="Offer route place"
        description="The rider must accept this offer and explicitly complete a fresh Paystack checkout. No payment is taken automatically."
        confirmLabel="Send offer"
        onClose={() => {
          setSelected(null);
          setOfferAttempt(null);
        }}
        onConfirm={async () => {
          if (!selected) return;
          const attempt =
            offerAttempt?.applicationId === selected.id
              ? offerAttempt
              : {
                  applicationId: selected.id,
                  key: crypto.randomUUID(),
                  expiresAt: new Date(Date.now() + days * 86400000).toISOString(),
                };
          setOfferAttempt(attempt);
          const response = await session.client.POST('/v1/ops/standby/{id}/offers', {
            params: {
              path: { id: selected.id },
              header: { ...opsHeaders, 'Idempotency-Key': attempt.key },
            },
            body: { expiresAt: attempt.expiresAt },
          });
          if (response.error) throw new Error(response.error.error.message);
          setOfferAttempt(null);
          setSelected(null);
          query.retry();
        }}
      >
        <label>
          Offer duration
          <select value={days} onChange={(event) => setDays(Number(event.target.value))}>
            <option value={1}>1 day</option>
            <option value={2}>2 days</option>
            <option value={3}>3 days</option>
          </select>
        </label>
      </ActionDialog>
    </Page>
  );
}
