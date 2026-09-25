import { render, screen } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it, vi } from 'vitest';
import type { components } from '../generated/api';
import { trotxiLight } from '../theme';
import { Overview } from './Overview';

type OverviewData = components['schemas']['OpsOverview'];
const query = vi.hoisted(() => ({ current: {} as object }));

vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session: {} }) }));
vi.mock('../hooks/useQuery', () => ({ useQuery: () => query.current }));
vi.mock('../components/LiveMap', () => ({ LiveMap: () => <div>Map mounted</div> }));

function data(status: 'scheduled' | 'active', positioned: boolean): OverviewData {
  return {
    generatedAt: '2026-09-25T06:00:00Z',
    window: 'morning',
    serviceDate: '2026-09-25',
    staleFixAfterSeconds: 300,
    tiles: {
      trips: 1,
      inProgress: status === 'active' ? 1 : 0,
      completed: 0,
      cancelled: 0,
      seatCapacity: 18,
      seatsConfirmed: 0,
      boarded: 0,
      noShows: 0,
      awaitingResolution: 0,
      staleGps: 0,
      unassigned: 0,
    },
    trips: [
      {
        tripId: 'test-trip',
        scheduledAt: '2026-09-25T06:30:00Z',
        status,
        routeName: 'Circle - Madina',
        driverId: 'test-driver',
        driverName: 'Test Driver',
        vehicleId: 'test-vehicle',
        vehicleLabel: 'Test Bus',
        vehiclePlate: 'GT-1234',
        capacity: 18,
        confirmed: 0,
        boarded: 0,
        noShow: 0,
        reserved: 0,
        lastFixAt: positioned ? '2026-09-25T06:32:00Z' : null,
        fixAgeSeconds: positioned ? 0 : null,
        lastPosition: positioned ? { latitude: 5.6, longitude: -0.2 } : null,
        badge: 'on_time',
      },
    ],
  };
}

function show(overview: OverviewData) {
  query.current = { data: overview, loading: false, error: null, retry: vi.fn() };
  return render(
    <FluentProvider theme={trotxiLight} data-theme="light">
      <MemoryRouter>
        <Overview />
      </MemoryRouter>
    </FluentProvider>,
  );
}

describe('live operations density', () => {
  it('moves healthy scheduled departures to Dispatch and hides an empty map', () => {
    show(data('scheduled', false));
    expect(screen.getByText(/No buses are running or need attention/)).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /View scheduled departures/ })).toHaveAttribute(
      'href',
      '/trips',
    );
    expect(screen.queryByText('Map mounted')).not.toBeInTheDocument();
    expect(
      screen.queryByRole('textbox', { name: 'Find a trip or driver' }),
    ).not.toBeInTheDocument();
  });

  it('shows the map and Ghana time once a driver reports on an active run', () => {
    show(data('active', true));
    expect(screen.getByText('Map mounted')).toBeInTheDocument();
    expect(screen.getByText(/06:30 am GMT/)).toBeInTheDocument();
    expect(screen.getAllByText('Circle - Madina')).toHaveLength(2);
  });
});
