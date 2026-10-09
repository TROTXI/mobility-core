import { fireEvent, render, screen, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { FluentProvider } from '@fluentui/react-components';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { components } from '../generated/api';
import { trotxiLight } from '../theme';
import { Payments } from './Payments';

type Purchase = components['schemas']['OpsPurchase'];
const { get, session } = vi.hoisted(() => {
  const get = vi.fn();
  return { get, session: { client: { GET: get } } };
});

vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));

function show() {
  return render(
    <MemoryRouter>
      <FluentProvider theme={trotxiLight} data-theme="light">
        <Payments />
      </FluentProvider>
    </MemoryRouter>,
  );
}

describe('Payments lists', () => {
  beforeEach(() => vi.clearAllMocks());

  it('keeps purchases visible when the review queue fails', async () => {
    const purchase = {
      id: 'purchase-1',
      riderId: 'rider-12345678',
      plan: 'monthly',
      cashDue: { amountMinor: 26400, currency: 'GHS' },
      collectionState: 'successful',
      state: 'fulfilled',
      createdAt: '2026-09-25T12:00:00Z',
    } as Purchase;
    get.mockImplementation(async (path: string) =>
      path === '/v1/ops/purchases'
        ? { data: { data: [purchase] } }
        : { error: { error: { message: 'Review queue unavailable' } } },
    );

    show();
    expect(await screen.findByText('monthly')).toBeInTheDocument();
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
    expect(get).toHaveBeenCalledWith(
      '/v1/ops/payments/reviews',
      expect.objectContaining({ params: expect.objectContaining({ query: { limit: 200 } }) }),
    );

    fireEvent.click(screen.getByRole('tab', { name: 'Manual reviews' }));
    expect(await screen.findByRole('alert')).toHaveTextContent('Review queue unavailable');
    expect(screen.queryByText('No payment reviews need a decision.')).not.toBeInTheDocument();
  });

  it('keeps the review queue visible when purchases fail', async () => {
    get.mockImplementation(async (path: string) =>
      path === '/v1/ops/purchases'
        ? { error: { error: { message: 'Purchases unavailable' } } }
        : { data: { data: [] } },
    );

    show();
    fireEvent.click(screen.getByRole('tab', { name: 'Manual reviews' }));
    expect(await screen.findByText('No payment reviews need a decision.')).toBeInTheDocument();
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
  });

  it('shows card renewals that need attention, in plain words, with a way to a new offer', async () => {
    const renewals = [
      {
        id: 'renewal-1',
        riderId: 'rider-1',
        riderName: 'Ama Mensah',
        state: 'needs_offer',
        failureCode: 'fare_changed',
        attempts: 0,
        periodEndsAt: '2026-11-01T00:00:00Z',
        nextAttemptAt: null,
        price: { amountMinor: 7000, currency: 'GHS' },
        card: { brand: 'visa', last4: '4081' },
        renewalPurchaseId: null,
        updatedAt: '2026-10-29T01:30:00Z',
      },
      {
        id: 'renewal-2',
        riderId: 'rider-2',
        riderName: null,
        state: 'failed',
        failureCode: 'card_declined',
        attempts: 2,
        periodEndsAt: '2026-11-02T00:00:00Z',
        nextAttemptAt: '2026-10-31T00:30:00Z',
        price: { amountMinor: 9000, currency: 'GHS' },
        card: null,
        renewalPurchaseId: 'purchase-9',
        updatedAt: '2026-10-30T01:30:00Z',
      },
    ];
    get.mockImplementation(
      async (path: string, init: { params: { query: { filter?: string } } }) =>
        path === '/v1/ops/auto-renewals'
          ? { data: { data: init.params.query.filter === 'attention' ? renewals : [] } }
          : { data: { data: [] } },
    );

    show();
    fireEvent.click(screen.getByRole('tab', { name: 'Card renewals' }));
    const table = await screen.findByRole('table');
    expect(within(table).getByText('Ama Mensah')).toBeInTheDocument();
    expect(within(table).getByText('Fare changed. Send a new offer.')).toBeInTheDocument();
    expect(within(table).getByRole('link', { name: 'Open Standby' })).toHaveAttribute(
      'href',
      '/standby',
    );
    expect(within(table).getByText('visa •••• 4081')).toBeInTheDocument();
    // A rider with no name is identified, and a missing card is said plainly.
    expect(within(table).getByText('rider-2')).toBeInTheDocument();
    expect(within(table).getByText('None')).toBeInTheDocument();
    expect(within(table).getByText('Card declined. Retrying daily.')).toBeInTheDocument();

    fireEvent.change(screen.getByRole('combobox'), { target: { value: 'all' } });
    expect(await screen.findByText('No card renewals match this view.')).toBeInTheDocument();
    expect(get).toHaveBeenCalledWith(
      '/v1/ops/auto-renewals',
      expect.objectContaining({
        params: expect.objectContaining({ query: { limit: 200, filter: 'all' } }),
      }),
    );
  });
});
