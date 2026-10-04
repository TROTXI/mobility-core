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

it('requires explicit price and two credit rates and retries unchanged terms with one key', async () => {
  const legs = ['outbound', 'return'].map((direction) => ({
    direction,
    scheduleId: direction,
    patternVersionId: direction,
    pickupOccurrenceId: `${direction}-a`,
    dropoffOccurrenceId: `${direction}-b`,
  }));
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
            : legs.map((l, i) => ({
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
  session.client.POST.mockResolvedValue({
    error: { error: { message: 'Response unavailable; retry safely.' } },
  });
  render(
    <FluentProvider theme={trotxiLight}>
      <Standby />
    </FluentProvider>,
  );
  fireEvent.click(await screen.findByRole('button', { name: 'Send offer' }));
  const dialog = within(screen.getByRole('dialog'));
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
  fireEvent.click(dialog.getByRole('button', { name: 'Send offer' }));
  await dialog.findByText('Response unavailable; retry safely.');
  expect(dialog.getByLabelText('Agreed package price (GHS)')).toBeDisabled();
  fireEvent.click(dialog.getByRole('button', { name: 'Send offer' }));
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
});
