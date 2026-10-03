import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter, useNavigate } from 'react-router-dom';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Trips } from './Trips';
import { dispatchDate, dispatchLink } from './dispatch-context';

const { get, session } = vi.hoisted(() => {
  const get = vi.fn();
  return { get, session: { client: { GET: get } } };
});
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));
vi.mock('../components/LiveMap', () => ({ LiveMap: () => <div>Map</div> }));

function NavigateAgain() {
  const navigate = useNavigate();
  return (
    <button onClick={() => navigate('/trips?date=2026-09-24&direction=outbound')}>
      Another window
    </button>
  );
}

function show(url: string) {
  return render(
    <FluentProvider theme={trotxiLight}>
      <MemoryRouter initialEntries={[url]}>
        <NavigateAgain />
        <Trips />
      </MemoryRouter>
    </FluentProvider>,
  );
}

describe('dispatch navigation context', () => {
  beforeEach(() => {
    get.mockReset();
    get.mockImplementation(async (path: string) => ({
      data: { data: path === '/v1/ops/overview' ? { trips: [] } : [] },
    }));
  });

  it('honors an explicit direction, including another date without remounting', async () => {
    show('/trips?date=2026-09-25&direction=return&search=old-trip');
    expect(screen.getByLabelText('From')).toHaveValue('2026-09-25');
    expect(screen.getByLabelText('To')).toHaveValue('2026-09-25');
    expect(screen.getByRole('tab', { name: 'Return' })).toHaveAttribute('aria-selected', 'true');
    expect(screen.getByRole('textbox', { name: 'Search trips' })).toHaveValue('old-trip');
    await waitFor(() =>
      expect(get).toHaveBeenCalledWith(
        '/v1/ops/trips',
        expect.objectContaining({
          params: expect.objectContaining({
            query: { fromDate: '2026-09-25', toDate: '2026-09-25', limit: 200 },
          }),
        }),
      ),
    );
    fireEvent.click(screen.getByRole('button', { name: 'Another window' }));
    await waitFor(() => expect(screen.getByLabelText('From')).toHaveValue('2026-09-24'));
    expect(screen.getByLabelText('To')).toHaveValue('2026-09-24');
    expect(screen.getByRole('tab', { name: 'Outbound' })).toHaveAttribute('aria-selected', 'true');
    expect(screen.getByRole('textbox', { name: 'Search trips' })).toHaveValue('');
  });

  it('ignores malformed URL filters and preserves the normal dispatch defaults', async () => {
    show('/trips?date=2026-02-30&direction=wrong');
    const today = new Date().toISOString().slice(0, 10);
    expect(screen.getByLabelText('From')).toHaveValue(today);
    expect(screen.getByRole('tab', { name: 'All' })).toHaveAttribute('aria-selected', 'true');
    await waitFor(() =>
      expect(get).toHaveBeenCalledWith(
        '/v1/ops/trips',
        expect.objectContaining({
          params: expect.objectContaining({ query: expect.objectContaining({ fromDate: today }) }),
        }),
      ),
    );
  });

  it.each([
    { direction: 'return', time: '06:30', status: 'active' },
    { direction: 'outbound', time: '17:30', status: 'scheduled' },
  ])('keeps $time $direction trips visible from Overview links', async (trip) => {
    get.mockImplementation(async (path: string) => ({
      data: {
        data:
          path === '/v1/ops/overview'
            ? { trips: [] }
            : path === '/v1/ops/trips'
              ? [
                  {
                    id: 'cross-direction-trip',
                    serviceDate: '2026-09-25',
                    scheduledAt: `2026-09-25T${trip.time}:00Z`,
                    direction: trip.direction,
                    status: trip.status,
                    assignedDriverId: 'driver',
                    vehicleId: 'vehicle',
                    vehiclePlate: 'TEST-CROSS-DIRECTION',
                    stops: [],
                  },
                ]
              : [],
      },
    }));
    const view = show(dispatchLink('2026-09-25', 'cross-direction-trip'));
    expect(screen.getByRole('tab', { name: 'All' })).toHaveAttribute('aria-selected', 'true');
    expect(await screen.findByText('TEST-CROSS-DIRECTION')).toBeInTheDocument();
    expect(screen.getByRole('textbox', { name: 'Search trips' })).toHaveValue(
      'cross-direction-trip',
    );
    view.unmount();
    show(dispatchLink('2026-09-25'));
    expect(screen.getByRole('tab', { name: 'All' })).toHaveAttribute('aria-selected', 'true');
    expect(await screen.findByText('TEST-CROSS-DIRECTION')).toBeInTheDocument();
  });

  it('validates calendar dates and safely encodes the trip link without a direction', () => {
    expect(dispatchDate('2026-02-30')).toBeNull();
    expect(dispatchDate('2026-9-2')).toBeNull();
    expect(dispatchDate('2028-02-29')).toBe('2028-02-29');
    expect(dispatchLink('2026-09-25', 'trip&other')).toBe(
      '/trips?date=2026-09-25&search=trip%26other',
    );
  });
});
