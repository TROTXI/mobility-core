import { fireEvent, render, screen, within } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { beforeEach, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { BulkStandbyOffers } from './BulkStandbyOffers';
import { Standby } from './Standby';
import type { StandbyApplication } from './standby-offers';
import { futureDate } from './standby-offers';

const { session } = vi.hoisted(() => ({
  session: { account: { id: 'admin' }, client: { GET: vi.fn(), POST: vi.fn() } },
}));
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session, account: session.account }) }));
globalThis.ResizeObserver ??= class {
  observe() {}
  unobserve() {}
  disconnect() {}
} as unknown as typeof ResizeObserver;
const legs = (['outbound', 'return'] as const).map((direction) => ({
  direction,
  scheduleId: direction,
  patternVersionId: direction,
  pickupOccurrenceId: direction + '-a',
  dropoffOccurrenceId: direction + '-b',
}));
const request = (id: string, routeId = 'route'): StandbyApplication => ({
  id,
  riderId: id,
  riderName: id,
  routeName: 'Circle to Madina',
  state: 'submitted',
  travelDays: [1, 3, 5],
  offer: null,
  createdAt: '2026-01-01T00:00:00Z',
  selection: { routeId, plan: 'monthly', useCredit: false, legs },
});
const pricing = (path: string) => ({
  data: {
    data:
      path === '/v1/ops/service-schedules'
        ? legs.map((l) => ({
            id: l.scheduleId,
            weekdays: [1, 2, 3, 4, 5],
            localDeparture: '06:30',
            effectiveFrom: '2020-01-01',
            effectiveTo: null,
          }))
        : legs.map((l) => ({
            ...l,
            id: l.direction,
            amount: { amountMinor: 1000, currency: 'GHS' },
            effectiveFrom: '2020-01-01T00:00:00Z',
            effectiveTo: null,
            journey: { direction: l.direction, pickup: 'Circle', dropoff: 'Madina' },
          })),
    page: { nextCursor: null },
  },
});

beforeEach(() => {
  vi.resetAllMocks();
  session.account.id = 'admin';
  session.client.GET.mockImplementation(async (path) => pricing(path));
});
async function showBulk() {
  const onCompleted = vi.fn();
  render(
    <FluentProvider theme={trotxiLight}>
      <BulkStandbyOffers
        applications={[request('Ama'), request('Kojo')]}
        open
        onClose={vi.fn()}
        onDiscard={vi.fn()}
        onCompleted={onCompleted}
      />
    </FluentProvider>,
  );
  await screen.findAllByText(/^outbound: Circle/);
  for (const [index, name] of ['Ama', 'Kojo'].entries()) {
    const row = within(screen.getByRole('region', { name: `Offer for ${name}` }));
    fireEvent.change(row.getByLabelText('Package price (GHS)'), {
      target: { value: String(70 + index * 10) },
    });
    fireEvent.change(row.getByLabelText('Unused outbound credit (GHS)'), {
      target: { value: '1' },
    });
    fireEvent.change(row.getByLabelText('Unused return credit (GHS)'), { target: { value: '2' } });
  }
  fireEvent.change(screen.getByLabelText('Reason', { selector: 'textarea' }), {
    target: { value: 'Reviewed corridor demand' },
  });
  fireEvent.click(screen.getByRole('checkbox'));
  return { onCompleted };
}

it('keeps per-rider prices and retries an uncertain send without resending successful offers', async () => {
  session.client.POST.mockResolvedValueOnce({ data: {} })
    .mockRejectedValueOnce(new Error('Connection lost'))
    .mockResolvedValueOnce({ data: {} });
  const { onCompleted } = await showBulk();
  fireEvent.click(screen.getByRole('button', { name: 'Send reviewed offers' }));
  await screen.findByText(/1 of 2 offers sent/);
  const first = session.client.POST.mock.calls[0]![1],
    second = session.client.POST.mock.calls[1]![1];
  expect(first.body.price.amountMinor).toBe(7000);
  expect(second.body.price.amountMinor).toBe(8000);
  expect(first.params.header['Idempotency-Key']).not.toBe(second.params.header['Idempotency-Key']);
  expect(screen.getByLabelText('Coverage start')).toBeDisabled();
  fireEvent.click(screen.getByRole('button', { name: 'Retry unsent offers' }));
  await vi.waitFor(() => expect(onCompleted).toHaveBeenCalledOnce());
  expect(session.client.POST).toHaveBeenCalledTimes(3);
  expect(session.client.POST.mock.calls[2]![1]).toEqual(second);
});

it('allows a definitive refusal to be corrected while preserving successful rows', async () => {
  session.client.POST.mockResolvedValueOnce({
    error: { error: { message: 'Correct package terms' } },
    response: { status: 409 },
  })
    .mockResolvedValueOnce({ data: {} })
    .mockResolvedValueOnce({ data: {} });
  const { onCompleted } = await showBulk();
  fireEvent.click(screen.getByRole('button', { name: 'Send reviewed offers' }));
  await screen.findByText(/1 of 2 offers sent/);
  const row = within(screen.getByRole('region', { name: 'Offer for Ama' }));
  expect(row.getByLabelText('Package price (GHS)')).not.toBeDisabled();
  fireEvent.change(row.getByLabelText('Package price (GHS)'), { target: { value: '75' } });
  expect(screen.getByRole('button', { name: 'Retry unsent offers' })).toBeDisabled();
  fireEvent.click(screen.getByRole('checkbox'));
  fireEvent.click(screen.getByRole('button', { name: 'Retry unsent offers' }));
  await vi.waitFor(() => expect(onCompleted).toHaveBeenCalledOnce());
  const [original, , corrected] = session.client.POST.mock.calls.map((c) => c[1]);
  expect(corrected.body.price.amountMinor).toBe(7500);
  expect(corrected.params.header['Idempotency-Key']).not.toBe(
    original.params.header['Idempotency-Key'],
  );
});

it('validates every row before making any offer request', async () => {
  await showBulk();
  const row = within(screen.getByRole('region', { name: 'Offer for Kojo' }));
  fireEvent.change(row.getByLabelText('Unused return credit (GHS)'), { target: { value: '' } });
  fireEvent.click(screen.getByRole('checkbox'));
  fireEvent.click(screen.getByRole('button', { name: 'Send reviewed offers' }));
  await screen.findByText('Enter amounts in GHS, with at most two decimal places.');
  expect(session.client.POST).not.toHaveBeenCalled();
});

it.each([
  ['starts after coverage', 4, null, false],
  ['ends before the last covered day', 3, 31, false],
  ['covers the exact inclusive boundaries', 3, 32, true],
  ['has no end date', 3, null, true],
] as const)('checks schedule dates before bulk sends: %s', async (_, from, to, available) => {
  session.client.GET.mockImplementation(async (path) => {
    const response = pricing(path);
    if (path === '/v1/ops/service-schedules') {
      return {
        data: {
          ...response.data,
          data: response.data.data.map((schedule) => ({
            ...schedule,
            effectiveFrom: futureDate(from),
            effectiveTo: to === null ? null : futureDate(to),
          })),
        },
      };
    }
    return response;
  });
  await showBulk();
  const send = screen.getByRole('button', { name: 'Send reviewed offers' });
  if (available) {
    expect(send).toBeEnabled();
    expect(screen.getByRole('button', { name: 'Use fare-based total for Ama' })).toBeEnabled();
  } else {
    expect(send).toBeDisabled();
    expect(screen.getAllByRole('status')[0]).toHaveTextContent(
      'The selected schedules must cover the complete offer period.',
    );
    expect(screen.queryByRole('button', { name: 'Use fare-based total for Ama' })).toBeNull();
    fireEvent.click(send);
    expect(session.client.POST).not.toHaveBeenCalled();
    // Correcting coverage recalculates eligibility, rather than leaving a stale error.
    fireEvent.change(screen.getByLabelText('Coverage start'), {
      target: { value: futureDate(5) },
    });
    fireEvent.change(screen.getByLabelText('Coverage end (exclusive)'), {
      target: { value: futureDate(30) },
    });
    fireEvent.click(screen.getByRole('checkbox'));
    expect(send).toBeEnabled();
  }
});

it('preserves decimal typing and clearing in all amount fields and sends whole pesewas', async () => {
  session.client.POST.mockResolvedValue({ data: {} });
  const { onCompleted } = await showBulk();
  const row = within(screen.getByRole('region', { name: 'Offer for Ama' }));
  for (const [label, value] of [
    ['Package price (GHS)', '70.50'],
    ['Unused outbound credit (GHS)', '1.25'],
    ['Unused return credit (GHS)', '2.50'],
  ]) {
    const input = row.getByRole('textbox', { name: label });
    expect(input).toHaveAttribute('inputmode', 'decimal');
    fireEvent.change(input, { target: { value: '' } });
    expect(input).toHaveValue('');
    for (let length = 1; length <= value!.length; length++) {
      fireEvent.change(input, { target: { value: value!.slice(0, length) } });
      expect(input).toHaveValue(value!.slice(0, length));
    }
  }
  fireEvent.click(screen.getByRole('checkbox'));
  fireEvent.click(screen.getByRole('button', { name: 'Send reviewed offers' }));
  await vi.waitFor(() => expect(onCompleted).toHaveBeenCalledOnce());
  expect(session.client.POST.mock.calls[0]![1].body).toMatchObject({
    price: { amountMinor: 7050, currency: 'GHS' },
    credits: [
      { direction: 'outbound', creditPerUnusedRide: { amountMinor: 125, currency: 'GHS' } },
      { direction: 'return', creditPerUnusedRide: { amountMinor: 250, currency: 'GHS' } },
    ],
  });
});

it('retains an uncertain receipt through rate limiting and supports finishing a resolved partial batch', async () => {
  session.client.POST.mockRejectedValueOnce(new Error('Lost response'))
    .mockResolvedValueOnce({
      error: { error: { message: 'Wait before retrying' } },
      response: { status: 429 },
    })
    .mockResolvedValueOnce({ data: {} })
    .mockResolvedValueOnce({
      error: { error: { message: 'Request was withdrawn' } },
      response: { status: 409 },
    });
  const { onCompleted } = await showBulk();
  fireEvent.click(screen.getByRole('button', { name: 'Send reviewed offers' }));
  await screen.findByText(/0 of 2 offers sent/);
  fireEvent.click(screen.getByRole('button', { name: 'Retry unsent offers' }));
  await screen.findByText(/unknown: Wait before retrying/);
  expect(screen.queryByRole('button', { name: /Finish batch/ })).not.toBeInTheDocument();
  fireEvent.click(screen.getByRole('button', { name: 'Retry unsent offers' }));
  await screen.findByText(/1 of 2 offers sent/);
  const calls = session.client.POST.mock.calls.map((c) => c[1]);
  expect(calls[1]).toEqual(calls[0]);
  expect(calls[2]).toEqual(calls[0]);
  fireEvent.click(screen.getByRole('button', { name: /Finish batch with 1 sent/ }));
  expect(onCompleted).toHaveBeenCalledWith(1);
  expect(session.client.POST).toHaveBeenCalledTimes(4);
});

it('uses full-queue route totals and server filters, and clears selection and cursor on filter changes', async () => {
  session.client.GET.mockImplementation(async (path, options) =>
    path !== '/v1/ops/standby'
      ? pricing(path)
      : {
          data: {
            data: [request(options.params.query.cursor ? 'Kojo' : 'Ama')],
            routeDemand: [{ routeId: 'route', routeName: 'Circle to Madina', requests: 75 }],
            page: { nextCursor: options.params.query.cursor ? null : 'next' },
          },
        },
  );
  render(
    <FluentProvider theme={trotxiLight}>
      <Standby />
    </FluentProvider>,
  );
  fireEvent.click(await screen.findByRole('button', { name: 'Circle to Madina (75)' }));
  await vi.waitFor(() =>
    expect(session.client.GET.mock.lastCall?.[1].params.query.routeId).toBe('route'),
  );
  fireEvent.click(await screen.findByRole('checkbox', { name: 'Select Ama' }));
  fireEvent.click(screen.getByRole('button', { name: 'Next page' }));
  fireEvent.click(await screen.findByRole('checkbox', { name: 'Select Kojo' }));
  expect(screen.getByText(/2 selected/)).toBeInTheDocument();
  fireEvent.change(screen.getByLabelText('Travel day'), { target: { value: '3' } });
  await vi.waitFor(() =>
    expect(session.client.GET.mock.lastCall?.[1].params.query).toMatchObject({
      routeId: 'route',
      day: 3,
      cursor: undefined,
      state: 'submitted',
    }),
  );
  expect(screen.getByText(/0 selected/)).toBeInTheDocument();
  fireEvent.change(screen.getByLabelText('Rider name'), { target: { value: 'Kojo' } });
  fireEvent.click(screen.getByRole('button', { name: 'Search' }));
  await vi.waitFor(() => expect(session.client.GET.mock.lastCall?.[1].params.query.q).toBe('Kojo'));
});

it('stops starting offers when the signed-in account changes during a send', async () => {
  let complete!: (value: unknown) => void;
  session.client.POST.mockImplementation(
    () =>
      new Promise((resolve) => {
        complete = resolve;
      }),
  );
  await showBulk();
  fireEvent.click(screen.getByRole('button', { name: 'Send reviewed offers' }));
  await vi.waitFor(() => expect(session.client.POST).toHaveBeenCalledOnce());
  session.account.id = 'another-admin';
  complete({ data: {} });
  await screen.findByText(/1 of 2 offers sent/);
  expect(session.client.POST).toHaveBeenCalledOnce();
});
