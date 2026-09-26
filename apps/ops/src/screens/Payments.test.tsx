import { fireEvent, render, screen } from '@testing-library/react';
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
    <FluentProvider theme={trotxiLight} data-theme="light">
      <Payments />
    </FluentProvider>,
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
});
