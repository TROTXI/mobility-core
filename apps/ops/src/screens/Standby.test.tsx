import { fireEvent, render, screen, within } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Standby } from './Standby';
const { session } = vi.hoisted(() => ({ session: { client: { GET: vi.fn(), POST: vi.fn() } } }));
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));
globalThis.ResizeObserver ??= class {
  observe() {}
  unobserve() {}
  disconnect() {}
} as unknown as typeof ResizeObserver;

const legs = ['outbound', 'return'].map((direction) => ({
  direction,
  scheduleId: direction,
  patternVersionId: direction,
  pickupOccurrenceId: `${direction}-a`,
  dropoffOccurrenceId: `${direction}-b`,
}));
/** Standby with one request; `priced` says which directions have a published fare. */
function serve(priced: string[] = ['outbound', 'return']) {
  session.client.GET.mockImplementation(async (path: string) => ({
    data: {
      data:
        path === '/v1/ops/standby'
          ? [
              {
                id: 'request',
                riderId: 'rider',
                riderName: 'Ama',
                routeName: 'B to C',
                state: 'submitted',
                travelDays: [1, 3, 5],
                offer: null,
                selection: { routeId: 'route', plan: 'monthly', useCredit: false, legs },
                createdAt: '2026-01-01T00:00:00Z',
              },
            ]
          : path === '/v1/ops/service-schedules'
            ? legs.map((l) => ({ id: l.scheduleId, weekdays: [1, 2, 3, 4, 5] }))
            : legs
                .filter((l) => priced.includes(l.direction))
                .map((l, i) => ({
                  ...l,
                  id: `fare-${i}`,
                  amount: { amountMinor: 500 + i * 300, currency: 'GHS' },
                  effectiveFrom: '2020-01-01T00:00:00Z',
                  effectiveTo: null,
                  journey: { pickup: 'B', dropoff: 'C', direction: l.direction },
                })),
      page: { nextCursor: null },
    },
  }));
}
async function openOffer() {
  render(
    <FluentProvider theme={trotxiLight}>
      <Standby />
    </FluentProvider>,
  );
  // Generous waits for loaded data: CI runs every Ops test file at once.
  fireEvent.click(await screen.findByRole('button', { name: 'Send offer' }, { timeout: 10_000 }));
  const dialog = within(screen.getByRole('dialog'));
  // Fares load first; until they do, the offer cannot be sent.
  await dialog.findByText(/^outbound: \d+ rides/, undefined, { timeout: 10_000 });
  return dialog;
}
function fill(dialog: ReturnType<typeof within>, price = '70') {
  fireEvent.change(dialog.getByLabelText('Agreed package price (GHS)'), {
    target: { value: price },
  });
  fireEvent.change(dialog.getByLabelText('Credit per unused outbound ride (GHS)'), {
    target: { value: '1' },
  });
  fireEvent.change(dialog.getByLabelText('Credit per unused return ride (GHS)'), {
    target: { value: '2' },
  });
  fireEvent.change(dialog.getByLabelText('Reason', { selector: 'textarea' }), {
    target: { value: 'Seat freed' },
  });
}

it(
  'requires explicit price and two credit rates and retries unchanged terms with one key',
  { timeout: 30_000 },
  async () => {
    serve();
    session.client.POST.mockResolvedValue({
      error: { error: { message: 'Response unavailable; retry safely.' } },
    });
    const dialog = await openOffer();
    expect(dialog.getByLabelText('Agreed package price (GHS)')).toHaveValue(null);
    expect(dialog.getByLabelText('Credit per unused outbound ride (GHS)')).toHaveValue(null);
    fireEvent.change(dialog.getByLabelText('Agreed package price (GHS)'), {
      target: { value: '70' },
    });
    fireEvent.change(dialog.getByLabelText('Credit per unused outbound ride (GHS)'), {
      target: { value: '1' },
    });
    fireEvent.change(dialog.getByLabelText('Credit per unused return ride (GHS)'), {
      target: { value: '2' },
    });
    fireEvent.change(dialog.getByLabelText('Reason', { selector: 'textarea' }), {
      target: { value: 'Seat freed' },
    });
    fireEvent.click(dialog.getByRole('button', { name: 'Send offer', hidden: true }));
    await dialog.findByText('Response unavailable; retry safely.', undefined, { timeout: 10_000 });
    expect(dialog.getByLabelText('Agreed package price (GHS)')).toBeDisabled();
    fireEvent.click(dialog.getByRole('button', { name: 'Send offer', hidden: true }));
    await vi.waitFor(() => expect(session.client.POST).toHaveBeenCalledTimes(2));
    const first = session.client.POST.mock.calls[0]![1],
      second = session.client.POST.mock.calls[1]![1];
    expect(first).toEqual(second);
    expect(first.body.price).toEqual({ amountMinor: 7000, currency: 'GHS' });
    expect(first.body.credits).toEqual([
      { direction: 'outbound', creditPerUnusedRide: { amountMinor: 100, currency: 'GHS' } },
      { direction: 'return', creditPerUnusedRide: { amountMinor: 200, currency: 'GHS' } },
    ]);
    expect(first.params.header['Idempotency-Key']).toBeTruthy();
  },
);

it(
  'unlocks the terms after the API refuses an offer, and sends the corrected one afresh',
  { timeout: 30_000 },
  async () => {
    session.client.POST.mockReset();
    serve();
    session.client.POST.mockResolvedValueOnce({
      error: { error: { message: 'Ops must publish a fare for these stops.' } },
      response: { status: 409 },
    }).mockResolvedValueOnce({ data: {}, response: { status: 201 } });
    const dialog = await openOffer();
    fill(dialog);
    fireEvent.click(dialog.getByRole('button', { name: 'Send offer', hidden: true }));
    await dialog.findByText('Ops must publish a fare for these stops.', undefined, {
      timeout: 10_000,
    });
    // A refusal created nothing: the operator can change the terms.
    const price = dialog.getByLabelText('Agreed package price (GHS)');
    expect(price).not.toBeDisabled();
    fireEvent.change(price, { target: { value: '65' } });
    fireEvent.click(dialog.getByRole('button', { name: 'Send offer', hidden: true }));
    await vi.waitFor(() => expect(session.client.POST).toHaveBeenCalledTimes(2));
    const [first, second] = session.client.POST.mock.calls.map((call) => call[1]);
    expect(second.body.price).toEqual({ amountMinor: 6500, currency: 'GHS' });
    expect(second.params.header['Idempotency-Key']).not.toBe(
      first.params.header['Idempotency-Key'],
    );
  },
);

it(
  'will not send an offer while a direction has no published fare, and says which',
  { timeout: 30_000 },
  async () => {
    session.client.POST.mockReset();
    serve(['outbound']);
    const dialog = await openOffer();
    fill(dialog);
    expect(await dialog.findByRole('status', undefined, { timeout: 10_000 })).toHaveTextContent(
      'No fare is published for the return stops',
    );
    expect(dialog.getByRole('button', { name: 'Send offer', hidden: true })).toBeDisabled();
    expect(session.client.POST).not.toHaveBeenCalled();
  },
);
