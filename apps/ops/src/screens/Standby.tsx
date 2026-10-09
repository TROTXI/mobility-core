import { Button } from '@fluentui/react-components';
import { useEffect, useRef, useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { opsHeaders } from '../api/session';
import { useQuery } from '../hooks/useQuery';
import { Empty, ErrorState, LoadingRows, Page, Panel, StatusBadge } from '../components/Page';
import { ActionDialog } from '../components/ActionDialog';
import { ReasonField } from '../components/ReasonField';
import { BulkStandbyOffers } from './BulkStandbyOffers';
import { estimateOffers, futureDate, pesewas, weekdays } from './standby-offers';
import { useStandbyPricing } from './useStandbyPricing';

type Application = components['schemas']['StandbyApplication'];
type PageResult = components['schemas']['StandbyApplicationPage'];

export function Standby() {
  const { session, account } = useAuth();
  const [routeId, setRouteId] = useState('');
  const [state, setState] = useState<Application['state'] | ''>('submitted');
  const [plan, setPlan] = useState<'' | 'monthly' | 'annual'>('');
  const [day, setDay] = useState('');
  const [search, setSearch] = useState('');
  const [name, setName] = useState('');
  const [cursor, setCursor] = useState<string | undefined>();
  const [previous, setPrevious] = useState<(string | undefined)[]>([]);
  const [checked, setChecked] = useState<Application[]>([]);
  const [batch, setBatch] = useState<Application[] | null>(null);
  const [bulkOpen, setBulkOpen] = useState(false);
  const [notice, setNotice] = useState('');
  const filters = JSON.stringify([account?.id, routeId, state, plan, day, name]);
  const filterVersion = useRef(filters);
  // Reset cursor and selection in the same render as a changed filter so no
  // request can pair a previous filter's cursor with the new filters.
  if (filterVersion.current !== filters) {
    filterVersion.current = filters;
    setCursor(undefined);
    setPrevious([]);
    setChecked([]);
  }
  useEffect(() => {
    setChecked([]);
    setBatch(null);
    setBulkOpen(false);
    setSelected(null);
  }, [session, account?.id]);
  const [selected, setSelected] = useState<Application | null>(null);
  const [days, setDays] = useState(2);
  const [coverageStart, setCoverageStart] = useState(futureDate(3));
  const [coverageEnd, setCoverageEnd] = useState(futureDate(33));
  const [price, setPrice] = useState('');
  const [outboundCredit, setOutboundCredit] = useState('');
  const [returnCredit, setReturnCredit] = useState('');
  const [reason, setReason] = useState('');
  const [offerAttempt, setOfferAttempt] = useState<{
    applicationId: string;
    key: string;
    body: components['schemas']['StandbyOfferInput'];
  } | null>(null);
  const pricing = useStandbyPricing(selected?.selection.routeId);
  const estimates =
    selected && pricing.data?.routeId === selected.selection.routeId
      ? estimateOffers(selected, pricing.data, coverageStart, coverageEnd)
      : [];
  // After a send with no answer, the terms stay as sent so a retry repeats them.
  const locked = offerAttempt !== null;
  // Directions the API would refuse to price: no fare in force for the exact stops.
  const unpriced = estimates.filter((e) => !e.fare).map((e) => e.direction);
  const query = useQuery<PageResult>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/standby', {
        params: {
          header: opsHeaders,
          query: {
            limit: 30,
            cursor,
            routeId: routeId || undefined,
            state: state || undefined,
            plan: plan || undefined,
            day: day ? Number(day) : undefined,
            q: name || undefined,
          },
        },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data;
    },
    [session, filters, cursor],
  );

  return (
    <Page
      className="standby-page"
      title="Standby"
      description="Review new subscriptions and renewals. Agree the journeys, dates, price and unused-ride credits before the rider pays."
    >
      {notice && <p role="status">{notice}</p>}
      <div className="filter-bar">
        <label>
          Status
          <select value={state} onChange={(e) => setState(e.target.value as typeof state)}>
            <option value="submitted">Needs offer</option>
            <option value="offered">Offered</option>
            <option value="checkout_open">Checkout open</option>
            <option value="completed">Completed</option>
            <option value="withdrawn">Withdrawn</option>
            <option value="">All statuses</option>
          </select>
        </label>
        <label>
          Plan
          <select value={plan} onChange={(e) => setPlan(e.target.value as typeof plan)}>
            <option value="">All plans</option>
            <option value="monthly">Monthly</option>
            <option value="annual">Annual</option>
          </select>
        </label>
        <label>
          Travel day
          <select value={day} onChange={(e) => setDay(e.target.value)}>
            <option value="">Any day</option>
            {weekdays.map((d, i) => (
              <option key={d} value={i + 1}>
                {d}
              </option>
            ))}
          </select>
        </label>
        <form
          className="standby-search"
          onSubmit={(e) => {
            e.preventDefault();
            setName(search.trim());
          }}
        >
          <label>
            Rider name
            <input
              type="search"
              maxLength={100}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </label>
          <Button type="submit">Search</Button>
        </form>
        <Button
          onClick={() => {
            setRouteId('');
            setState('submitted');
            setPlan('');
            setDay('');
            setName('');
            setSearch('');
          }}
        >
          Reset filters
        </Button>
      </div>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel title="Demand by route">
        <div className="panel-body">
          <p className="muted">
            Totals reflect your filters across all pages, not confirmed seats. Largest groups first.
          </p>
          <div className="standby-route-groups" aria-label="Route groups">
            <Button aria-pressed={!routeId} onClick={() => setRouteId('')}>
              All routes
            </Button>
            {query.data?.routeDemand?.map((group) => (
              <Button
                key={group.routeId}
                aria-pressed={routeId === group.routeId}
                onClick={() => setRouteId(group.routeId)}
              >
                {group.routeName} ({group.requests})
              </Button>
            ))}
          </div>
          {routeId && <p>One route selected. Use All routes to remove this filter.</p>}
        </div>
      </Panel>
      <Panel
        title="Applications"
        action={
          <Button
            onClick={() => {
              setChecked([]);
              query.retry();
            }}
          >
            Refresh
          </Button>
        }
      >
        <div className="filter-bar">
          <span>{checked.length} selected (maximum 25, one route per batch)</span>
          <Button
            disabled={
              !routeId ||
              !!batch ||
              query.loading ||
              !!query.error ||
              checked.length >= 25 ||
              !query.data?.data.some((a) => a.state === 'submitted')
            }
            title="Select a route, then add up to 25 requests from this page"
            onClick={() =>
              setChecked((current) => {
                const rows = new Map(current.map((a) => [a.id, a]));
                for (const application of query.data?.data ?? []) {
                  if (rows.size >= 25) break;
                  if (
                    application.state === 'submitted' &&
                    application.selection.routeId === routeId
                  )
                    rows.set(application.id, application);
                }
                return [...rows.values()];
              })
            }
          >
            Select this page
          </Button>
          <Button
            disabled={!checked.length || !!batch || query.loading || !!query.error}
            onClick={() => {
              setBatch(checked);
              setBulkOpen(true);
              setNotice('');
            }}
          >
            Prepare bulk offers
          </Button>
          <Button disabled={!checked.length} onClick={() => setChecked([])}>
            Clear selection
          </Button>
          {batch && <Button onClick={() => setBulkOpen(true)}>Resume bulk offers</Button>}
        </div>
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.data.length ? (
          <Empty />
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Select</th>
                  <th>Rider</th>
                  <th>Route</th>
                  <th>Travel days</th>
                  <th>Plan</th>
                  <th>Status</th>
                  <th>Offer expiry</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {query.data.data.map((application) => (
                  <tr key={application.id}>
                    <td>
                      <input
                        type="checkbox"
                        aria-label={`Select ${application.riderName}`}
                        checked={checked.some((a) => a.id === application.id)}
                        disabled={
                          application.state !== 'submitted' ||
                          !!batch ||
                          (!checked.some((a) => a.id === application.id) &&
                            (checked.length >= 25 ||
                              (checked.length > 0 &&
                                checked[0]!.selection.routeId !== application.selection.routeId)))
                        }
                        onChange={(e) =>
                          setChecked((old) =>
                            e.target.checked
                              ? [...old, application]
                              : old.filter((a) => a.id !== application.id),
                          )
                        }
                      />
                    </td>
                    <td>{application.riderName}</td>
                    <td>{application.routeName}</td>
                    <td>
                      {application.travelDays.map((d) => weekdays[d - 1]).join(', ') ||
                        'New request needed'}
                    </td>
                    <td>{application.selection.plan}</td>
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
                          disabled={!!batch}
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
          </div>
        )}
        <div className="filter-bar">
          <Button
            disabled={!previous.length || query.loading}
            onClick={() => {
              setCursor(previous.at(-1));
              setPrevious((old) => old.slice(0, -1));
            }}
          >
            Previous page
          </Button>
          <span>Page {previous.length + 1}</span>
          <Button
            disabled={!query.data?.page.nextCursor || query.loading}
            onClick={() => {
              setPrevious((old) => [...old, cursor]);
              setCursor(query.data!.page.nextCursor!);
            }}
          >
            Next page
          </Button>
        </div>
      </Panel>
      {batch && (
        <BulkStandbyOffers
          applications={batch}
          open={bulkOpen}
          onClose={() => setBulkOpen(false)}
          onDiscard={() => {
            setBatch(null);
            setBulkOpen(false);
          }}
          onCompleted={(sentCount) => {
            setNotice(
              `${sentCount} of ${batch.length} offers sent. Unsent requests were left unchanged. Riders can review their terms before paying.`,
            );
            setBatch(null);
            setBulkOpen(false);
            setChecked([]);
            query.retry();
          }}
        />
      )}
      <ActionDialog
        open={selected !== null}
        title="Prepare subscription offer"
        description="Terms cannot be edited after sending. Coverage ends at the start of the end date. Payment does not guarantee a particular trip seat; normal confirmation and capacity rules still apply."
        confirmLabel="Send offer"
        confirmDisabled={
          unpriced.length > 0 ||
          pricing.loading ||
          !!pricing.error ||
          estimates.length !== 2 ||
          !reason.trim()
        }
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
          setChecked((current) => current.filter((application) => application.id !== selected.id));
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
