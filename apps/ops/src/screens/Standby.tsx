import { Button } from '@fluentui/react-components';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { opsHeaders } from '../api/session';
import { useQuery } from '../hooks/useQuery';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge } from '../components/Page';
import { ActionDialog } from '../components/ActionDialog';
import { ReasonField } from '../components/ReasonField';

type Application = components['schemas']['StandbyApplication'];
type PageResult = { data: Application[]; nextCursor: string | null };
const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const futureDate = (days: number) =>
  new Date(Date.now() + days * 86400000).toISOString().slice(0, 10);
function pesewas(value: string) {
  if (!/^\d+(\.\d{1,2})?$/.test(value))
    throw new Error('Enter amounts in GHS, with at most two decimal places.');
  const amount = Math.round(Number(value) * 100);
  if (!Number.isSafeInteger(amount) || amount > 2147483647)
    throw new Error('Amount is out of range.');
  return { amountMinor: amount, currency: 'GHS' as const };
}

export function Standby() {
  const { session } = useAuth();
  const [selected, setSelected] = useState<Application | null>(null);
  const [days, setDays] = useState(2);
  const [coverageStart, setCoverageStart] = useState(futureDate(3));
  const [coverageEnd, setCoverageEnd] = useState(futureDate(33));
  const [price, setPrice] = useState('');
  const [outboundCredit, setOutboundCredit] = useState('');
  const [returnCredit, setReturnCredit] = useState('');
  const [reason, setReason] = useState('');
  const [loadingMore, setLoadingMore] = useState(false);
  const [moreError, setMoreError] = useState('');
  const [offerAttempt, setOfferAttempt] = useState<{
    applicationId: string;
    key: string;
    body: components['schemas']['StandbyOfferInput'];
  } | null>(null);
  const pricing = useQuery(
    async (signal) => {
      if (!selected) return null;
      const [fares, schedules] = await Promise.all([
        session.client.GET('/v1/ops/routes/{id}/fares', {
          params: {
            path: { id: selected.selection.routeId },
            header: opsHeaders,
            query: { limit: 200 },
          },
          signal,
        }),
        session.client.GET('/v1/ops/service-schedules', {
          params: {
            header: opsHeaders,
            query: { limit: 200, routeId: selected.selection.routeId },
          },
          signal,
        }),
      ]);
      if (fares.error) throw new Error(fares.error.error.message);
      if (schedules.error) throw new Error(schedules.error.error.message);
      return { applicationId: selected.id, fares: fares.data.data, schedules: schedules.data.data };
    },
    [session, selected?.id],
  );
  const estimates =
    selected && pricing.data?.applicationId === selected.id
      ? selected.selection.legs.map((leg) => {
          const start = new Date(`${coverageStart}T00:00:00Z`).getTime(),
            end = new Date(`${coverageEnd}T00:00:00Z`).getTime();
          const schedule = pricing.data!.schedules.find((s) => s.id === leg.scheduleId);
          const fare = pricing.data!.fares.find(
            (f) =>
              // The API prices a leg only from a fare on that direction's pattern.
              (!f.journey || f.journey.direction === leg.direction) &&
              f.patternVersionId === leg.patternVersionId &&
              f.pickupOccurrenceId === leg.pickupOccurrenceId &&
              f.dropoffOccurrenceId === leg.dropoffOccurrenceId &&
              new Date(f.effectiveFrom).getTime() <= start &&
              (!f.effectiveTo || new Date(f.effectiveTo).getTime() > start),
          );
          let rides = 0;
          if (Number.isFinite(start) && end > start && end - start <= 366 * 86400000)
            for (let ms = start; ms < end; ms += 86400000) {
              const day = new Date(ms).getUTCDay() || 7;
              if (selected.travelDays.includes(day) && schedule?.weekdays.includes(day)) rides++;
            }
          return { direction: leg.direction, fare, rides };
        })
      : [];
  // After a send with no answer, the terms stay as sent so a retry repeats them.
  const locked = offerAttempt !== null;
  // Directions the API would refuse to price: no fare in force for the exact stops.
  const unpriced = estimates.filter((e) => !e.fare).map((e) => e.direction);
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
      description="Review new subscriptions and renewals. Agree the journeys, dates, price and unused-ride credits before the rider pays."
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
                  <th>Travel days</th>
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
                      {application.travelDays.map((d) => weekdays[d - 1]).join(', ') ||
                        'New request needed'}
                    </td>
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
                            setPrice('');
                            setOutboundCredit('');
                            setReturnCredit('');
                            setReason('');
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
        title="Prepare subscription offer"
        description="Terms cannot be edited after sending. Coverage ends at the start of the end date. Payment does not guarantee a particular trip seat; normal confirmation and capacity rules still apply."
        confirmLabel="Send offer"
        confirmDisabled={unpriced.length > 0 || pricing.loading || !reason.trim()}
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
                  body: {
                    expiresAt: new Date(
                      Math.min(
                        Date.now() + days * 86400000,
                        new Date(`${coverageStart}T00:00:00Z`).getTime(),
                      ),
                    ).toISOString(),
                    coverageStart,
                    coverageEnd,
                    price: pesewas(price),
                    credits: [
                      {
                        direction: 'outbound' as const,
                        creditPerUnusedRide: pesewas(outboundCredit),
                      },
                      { direction: 'return' as const, creditPerUnusedRide: pesewas(returnCredit) },
                    ],
                    reason: reason.trim(),
                  },
                };
          setOfferAttempt(attempt);
          const response = await session.client.POST('/v1/ops/standby/{id}/offers', {
            params: {
              path: { id: selected.id },
              header: { ...opsHeaders, 'Idempotency-Key': attempt.key },
            },
            body: attempt.body,
          });
          if (response.error) {
            // A 4xx is the API's answer: no offer was created, so the terms can
            // be changed. Without an answer the outcome is unknown, and the
            // form stays locked so a retry repeats exactly the same offer.
            const status = response.response?.status ?? 0;
            if (status >= 400 && status < 500) setOfferAttempt(null);
            throw new Error(response.error.error.message);
          }
          setOfferAttempt(null);
          setSelected(null);
          query.retry();
        }}
      >
        {/* Not a <fieldset>: Safari lost focus from inputs inside one in this
            dialog. Each control is locked on its own instead. */}
        <div className="offer-terms" role="group" aria-label="Agreed terms">
          <h3 className="offer-terms-title">Agreed terms</h3>
          <p>
            {selected?.routeName}: {selected?.travelDays.map((d) => weekdays[d - 1]).join(', ')}
          </p>
          <label>
            Coverage start
            <input
              disabled={locked}
              type="date"
              required
              value={coverageStart}
              onChange={(e) => setCoverageStart(e.target.value)}
            />
          </label>
          <label>
            Coverage end (exclusive)
            <input
              disabled={locked}
              type="date"
              required
              value={coverageEnd}
              onChange={(e) => setCoverageEnd(e.target.value)}
            />
          </label>
          {pricing.error && <ErrorState message={pricing.error} retry={pricing.retry} />}
          {unpriced.length > 0 && (
            <p role="status">
              No fare is published for the {unpriced.join(' and ')} stops on {coverageStart}.
              Publish an exact stop-pair fare in Routes &amp; stops, then send the offer.
            </p>
          )}
          {estimates.map((estimate) => (
            <p key={estimate.direction}>
              {estimate.direction}: {estimate.rides} rides.{' '}
              {estimate.fare
                ? `${estimate.fare.journey?.pickup ?? 'Pickup'} → ${estimate.fare.journey?.dropoff ?? 'Drop-off'}, GHS ${(estimate.fare.amount.amountMinor / 100).toFixed(2)} per ride.`
                : 'Publish an exact stop-pair fare in Routes & stops first.'}
            </p>
          ))}
          {estimates.length === 2 && estimates.every((e) => e.fare && e.rides > 0) && (
            <Button
              disabled={locked}
              onClick={() =>
                setPrice(
                  (
                    estimates.reduce((sum, e) => sum + e.fare!.amount.amountMinor * e.rides, 0) /
                    100
                  ).toFixed(2),
                )
              }
            >
              Use fare-based total (GHS{' '}
              {(
                estimates.reduce((sum, e) => sum + (e.fare?.amount.amountMinor ?? 0) * e.rides, 0) /
                100
              ).toFixed(2)}
              )
            </Button>
          )}
          <label>
            Agreed package price (GHS)
            <input
              disabled={locked}
              type="number"
              step="0.01"
              min="1"
              required
              value={price}
              onChange={(e) => setPrice(e.target.value)}
            />
          </label>
          <label>
            Credit per unused outbound ride (GHS)
            <input
              disabled={locked}
              type="number"
              step="0.01"
              min="0"
              required
              value={outboundCredit}
              onChange={(e) => setOutboundCredit(e.target.value)}
            />
          </label>
          <label>
            Credit per unused return ride (GHS)
            <input
              disabled={locked}
              type="number"
              step="0.01"
              min="0"
              required
              value={returnCredit}
              onChange={(e) => setReturnCredit(e.target.value)}
            />
          </label>
          <label>
            Offer duration
            <select
              disabled={locked}
              value={days}
              onChange={(event) => setDays(Number(event.target.value))}
            >
              <option value={1}>1 day</option>
              <option value={2}>2 days</option>
              <option value={3}>3 days</option>
            </select>
          </label>
          <ReasonField value={reason} onChange={setReason} disabled={locked} />
        </div>
        {offerAttempt && <p>The last attempt is saved. Retry sends exactly the same terms.</p>}
      </ActionDialog>
    </Page>
  );
}
