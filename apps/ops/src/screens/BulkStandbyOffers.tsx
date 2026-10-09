import { Button } from '@fluentui/react-components';
import { useEffect, useRef, useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { opsHeaders } from '../api/session';
import { ActionDialog } from '../components/ActionDialog';
import { ErrorState } from '../components/Page';
import { ReasonField } from '../components/ReasonField';
import {
  estimateOffers,
  futureDate,
  pesewas,
  weekdays,
  type StandbyApplication,
} from './standby-offers';
import { useStandbyPricing } from './useStandbyPricing';

type Terms = { price: string; outbound: string; return: string };
type Attempt = { key: string; body: components['schemas']['StandbyOfferInput'] };
type Result = { state: 'sent' | 'refused' | 'unknown'; message: string };

/** A reviewed set of independent offers, never one price blindly applied to a route. */
export function BulkStandbyOffers({
  applications,
  open,
  onClose,
  onCompleted,
  onDiscard,
}: {
  applications: StandbyApplication[];
  open: boolean;
  onClose: () => void;
  onCompleted: (sentCount: number) => void;
  onDiscard: () => void;
}) {
  const { session } = useAuth();
  const owner = useRef(session);
  const ownerId = useRef(session.account?.id);
  const currentSession = useRef(session);
  currentSession.current = session;
  const attempts = useRef(new Map<string, Attempt>());
  const sent = useRef(new Set<string>());
  const uncertain = useRef(new Set<string>());
  const mounted = useRef(true);
  useEffect(() => {
    mounted.current = true;
    return () => {
      mounted.current = false;
    };
  }, []);
  const [results, setResults] = useState<Record<string, Result>>({});
  const [terms, setTerms] = useState<Record<string, Terms>>(() =>
    Object.fromEntries(applications.map((a) => [a.id, { price: '', outbound: '', return: '' }])),
  );
  const [start, setStart] = useState(futureDate(3));
  const [end, setEnd] = useState(futureDate(33));
  const [days, setDays] = useState(2);
  const [reason, setReason] = useState('');
  const [reviewed, setReviewed] = useState(false);
  const [sending, setSending] = useState(false);
  const pricing = useStandbyPricing(applications[0]?.selection.routeId);
  const estimates = Object.fromEntries(
    applications.map((a) => [
      a.id,
      pricing.data ? estimateOffers(a, pricing.data, start, end) : [],
    ]),
  );
  const started = attempts.current.size > 0 || sent.current.size > 0;
  useEffect(() => {
    if (!started) return;
    const warn = (event: BeforeUnloadEvent) => {
      event.preventDefault();
      event.returnValue = '';
    };
    window.addEventListener('beforeunload', warn);
    return () => window.removeEventListener('beforeunload', warn);
  }, [started]);
  const update = (id: string, field: keyof Terms, value: string) => {
    setReviewed(false);
    setTerms((old) => ({ ...old, [id]: { ...old[id]!, [field]: value } }));
  };
  const unavailable = applications.some(
    (a) =>
      !sent.current.has(a.id) &&
      !attempts.current.has(a.id) &&
      (estimates[a.id]!.length !== 2 ||
        estimates[a.id]!.some((e) => !e.fare || !e.schedule || e.rides === 0)),
  );

  return (
    <ActionDialog
      open={open}
      wide
      title={`Review ${applications.length} subscription offers`}
      description="Each rider receives their own immutable offer. Review stops, days, price and credits separately. Sending an offer does not reserve bus seats. A partial failure does not undo offers already sent."
      confirmLabel={started ? 'Retry unsent offers' : 'Send reviewed offers'}
      confirmDisabled={
        !reviewed || !reason.trim() || pricing.loading || !!pricing.error || unavailable
      }
      onClose={started ? onClose : onDiscard}
      onConfirm={async () => {
        if (owner.current !== currentSession.current || ownerId.current !== session.account?.id)
          throw new Error('Account changed. Reopen standby.');
        // Validate the whole batch before the first write. Freeze every payload and
        // key before sending, including rows not yet attempted when a send stops.
        const prepared = new Map(attempts.current);
        for (const a of applications) {
          if (sent.current.has(a.id) || prepared.has(a.id)) continue;
          const t = terms[a.id]!;
          const price = pesewas(t.price);
          if (price.amountMinor < 100)
            throw new Error(`Enter a package price of at least GHS 1 for ${a.riderName}.`);
          const credits = [
            { direction: 'outbound' as const, creditPerUnusedRide: pesewas(t.outbound) },
            { direction: 'return' as const, creditPerUnusedRide: pesewas(t.return) },
          ];
          const es = estimates[a.id]!;
          if (
            credits.some(
              (c) =>
                c.creditPerUnusedRide.amountMinor >
                es.find((e) => e.direction === c.direction)!.fare!.amount.amountMinor,
            ) ||
            credits.reduce(
              (sum, c) =>
                sum +
                c.creditPerUnusedRide.amountMinor *
                  es.find((e) => e.direction === c.direction)!.rides,
              0,
            ) > price.amountMinor
          )
            throw new Error(`Credits for ${a.riderName} exceed the journey fare or package price.`);
          const expiresAt = new Date(
            Math.min(Date.now() + days * 86400000, new Date(`${start}T00:00:00Z`).getTime()),
          ).toISOString();
          if (new Date(expiresAt).getTime() <= Date.now() || end <= start)
            throw new Error('Choose future coverage dates and a future payment deadline.');
          prepared.set(a.id, {
            key: crypto.randomUUID(),
            body: {
              coverageStart: start,
              coverageEnd: end,
              expiresAt,
              price,
              credits,
              reason: reason.trim(),
            },
          });
        }
        attempts.current = prepared;
        setSending(true);
        try {
          for (const a of applications) {
            if (sent.current.has(a.id)) continue;
            if (
              !mounted.current ||
              owner.current !== currentSession.current ||
              ownerId.current !== session.account?.id
            )
              break;
            const attempt = attempts.current.get(a.id)!;
            try {
              const response = await session.client.POST('/v1/ops/standby/{id}/offers', {
                params: {
                  path: { id: a.id },
                  header: { ...opsHeaders, 'Idempotency-Key': attempt.key },
                },
                body: attempt.body,
              });
              if (response.error) {
                const status = response.response?.status ?? 0;
                if (status >= 400 && status < 500) {
                  // A refusal now does not prove a previous unanswered send
                  // failed. Retain its receipt key through auth/rate limits.
                  const transient = status === 401 || status === 403 || status === 429;
                  if (!transient && !uncertain.current.has(a.id)) attempts.current.delete(a.id);
                  setResults((old) => ({
                    ...old,
                    [a.id]: {
                      state: uncertain.current.has(a.id) ? 'unknown' : 'refused',
                      message: response.error.error.message,
                    },
                  }));
                  if (transient || uncertain.current.has(a.id)) break;
                  continue;
                }
                throw new Error(response.error.error.message);
              }
              sent.current.add(a.id);
              uncertain.current.delete(a.id);
              setResults((old) => ({ ...old, [a.id]: { state: 'sent', message: 'Offer sent' } }));
            } catch (error) {
              uncertain.current.add(a.id);
              setResults((old) => ({
                ...old,
                [a.id]: {
                  state: 'unknown',
                  message:
                    error instanceof Error
                      ? error.message
                      : 'No response. Retry with the saved terms.',
                },
              }));
              break;
            }
          }
          if (sent.current.size !== applications.length)
            throw new Error(
              `${sent.current.size} of ${applications.length} offers sent. Review the remaining rows. Retry keeps saved terms and never repeats successful offers.`,
            );
          onCompleted(sent.current.size);
        } finally {
          setSending(false);
        }
      }}
    >
      <p>
        <strong>{applications[0]?.routeName}</strong>. Amounts entered in GHS are sent as whole
        pesewas.
      </p>
      <div className="filter-bar">
        <label>
          Coverage start
          <input
            type="date"
            value={start}
            disabled={started || sending}
            onChange={(e) => {
              setStart(e.target.value);
              setReviewed(false);
            }}
          />
        </label>
        <label>
          Coverage end (exclusive)
          <input
            type="date"
            value={end}
            disabled={started || sending}
            onChange={(e) => {
              setEnd(e.target.value);
              setReviewed(false);
            }}
          />
        </label>
        <label>
          Offer duration
          <select
            value={days}
            disabled={started || sending}
            onChange={(e) => {
              setDays(Number(e.target.value));
              setReviewed(false);
            }}
          >
            <option value={1}>1 day</option>
            <option value={2}>2 days</option>
            <option value={3}>3 days</option>
          </select>
        </label>
      </div>
      {pricing.error && <ErrorState message={pricing.error} retry={pricing.retry} />}
      {applications.map((a) => {
        const es = estimates[a.id]!;
        const locked = sending || attempts.current.has(a.id) || sent.current.has(a.id);
        return (
          <section className="bulk-offer-row" key={a.id} aria-label={`Offer for ${a.riderName}`}>
            <h3>{a.riderName}</h3>
            <p>
              {a.selection.plan} · {a.travelDays.map((d) => weekdays[d - 1]).join(', ')}
            </p>
            {es.map((e) => (
              <p key={e.direction}>
                {e.direction}: {e.fare?.journey?.pickup ?? 'Unpriced pickup'} →{' '}
                {e.fare?.journey?.dropoff ?? 'drop-off'} ·{' '}
                {e.schedule?.localDeparture ?? 'schedule unavailable'} · {e.rides} rides
              </p>
            ))}
            {!es.length || es.some((e) => !e.fare || !e.rides) ? (
              <p>Publish valid fares and schedules for these journeys before sending.</p>
            ) : (
              <Button
                disabled={locked}
                onClick={() =>
                  update(
                    a.id,
                    'price',
                    (
                      es.reduce((sum, e) => sum + e.fare!.amount.amountMinor * e.rides, 0) / 100
                    ).toFixed(2),
                  )
                }
              >
                Use fare-based total for {a.riderName}
              </Button>
            )}
            <div className="filter-bar">
              {(['price', 'outbound', 'return'] as const).map((field) => (
                <label key={field}>
                  {field === 'price' ? 'Package price (GHS)' : `Unused ${field} credit (GHS)`}
                  <input
                    type="text"
                    inputMode="decimal"
                    required
                    disabled={locked}
                    value={terms[a.id]![field]}
                    onChange={(e) => update(a.id, field, e.target.value)}
                  />
                </label>
              ))}
            </div>
            {results[a.id] && (
              <p role="status">
                {results[a.id]!.state}: {results[a.id]!.message}
              </p>
            )}
          </section>
        );
      })}
      <ReasonField
        value={reason}
        disabled={started || sending}
        onChange={(v) => {
          setReason(v);
          setReviewed(false);
        }}
      />
      <label className="checkbox-field">
        <input
          type="checkbox"
          checked={reviewed}
          disabled={sending}
          onChange={(e) => setReviewed(e.target.checked)}
        />
        I reviewed each rider’s journeys, dates, price and credit values.
      </label>
      {started && (
        <p>
          Shared dates and reason are locked. Sent offers are final. Keep this page open until
          uncertain outcomes are resolved; you can close and resume this dialog.
        </p>
      )}
      {started &&
        !sending &&
        uncertain.current.size === 0 &&
        sent.current.size < applications.length && (
          <Button onClick={() => onCompleted(sent.current.size)}>
            Finish batch with {sent.current.size} sent; leave remaining requests unchanged
          </Button>
        )}
    </ActionDialog>
  );
}
