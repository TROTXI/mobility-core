import { act, render, screen, waitFor } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter } from 'react-router-dom';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { components } from '../generated/api';
import { trotxiLight } from '../theme';
import { Overview } from './Overview';

type OverviewData = components['schemas']['OpsOverview'];
const query = vi.hoisted(() => ({ current: {} as object }));
const api = vi.hoisted(() => ({ GET: vi.fn() }));
const session = vi.hoisted(() => ({ client: api }));

vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));
vi.mock('../hooks/useQuery', () => ({ useQuery: () => query.current }));
vi.mock('../components/LiveMap', () => ({
  LiveMap: ({ line }: { line: unknown[] }) => (
    <div>
      Map mounted <span>Line points {line.length}</span>
    </div>
  ),
}));

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
        patternId: 'test-pattern',
        patternVersionId: 'test-version',
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

function show(overview: OverviewData, error = '') {
  query.current = { data: overview, loading: false, error, retry: vi.fn() };
  return render(
    <FluentProvider theme={trotxiLight} data-theme="light">
      <MemoryRouter>
        <Overview />
      </MemoryRouter>
    </FluentProvider>,
  );
}

describe('live operations density', () => {
  beforeEach(() => {
    api.GET.mockReset();
    api.GET.mockResolvedValue({
      data: {
        data: {
          geometryId: null,
          stops: [
            { ordinal: 1, location: { latitude: 5.6, longitude: -0.2 } },
            { ordinal: 2, location: { latitude: 5.7, longitude: -0.21 } },
          ],
        },
      },
    });
  });
  it('moves healthy scheduled departures to Dispatch and hides an empty map', () => {
    show(data('scheduled', false));
    expect(screen.getByText(/No buses are running or need attention/)).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /View scheduled departures/ })).toHaveAttribute(
      'href',
      '/trips?date=2026-09-25',
    );
    expect(screen.queryByText('Map mounted')).not.toBeInTheDocument();
    expect(
      screen.queryByRole('textbox', { name: 'Find a trip or driver' }),
    ).not.toBeInTheDocument();
  });

  it('shows the map and Ghana time once a driver reports on an active run', () => {
    show(data('active', true));
    expect(screen.getByText('Map mounted')).toBeInTheDocument();
    expect(screen.getByText('Boarded / confirmed')).toBeInTheDocument();
    expect(screen.queryByText('Seats confirmed')).not.toBeInTheDocument();
    expect(screen.getByText(/06:30 am GMT/)).toBeInTheDocument();
    expect(screen.getAllByText('Circle - Madina')).toHaveLength(2);
    expect(screen.getByLabelText('Service date')).toHaveValue('2026-09-25');
    expect(screen.getByRole('link', { name: 'Open dispatch' })).toHaveAttribute(
      'href',
      '/trips?date=2026-09-25&search=test-trip',
    );
  });

  it('keeps a map and explicit no-fix state for an active bus with no position', async () => {
    show(data('active', false));
    expect(screen.getByText('Map mounted')).toBeInTheDocument();
    expect(screen.getAllByText('No GPS fix')).toHaveLength(2);
    await waitFor(() => expect(screen.getByText('Line points 2')).toBeInTheDocument());
    expect(screen.getByText(/Showing the ordered stops/)).toBeInTheDocument();
  });

  it('loads the selected published geometry and falls back to stops if it fails', async () => {
    api.GET.mockImplementation(async (path: string) =>
      path === '/v1/route-geometries/{id}'
        ? {
            data: {
              data: {
                points: [
                  { latitude: 5.6, longitude: -0.2 },
                  { latitude: 5.65, longitude: -0.205 },
                  { latitude: 5.7, longitude: -0.21 },
                ],
              },
            },
          }
        : { data: { data: { geometryId: 'geometry', stops: [] } } },
    );
    const view = show(data('active', true));
    await waitFor(() => expect(screen.getByText('Line points 3')).toBeInTheDocument());
    expect(api.GET).toHaveBeenCalledTimes(2);
    view.unmount();

    api.GET.mockImplementation(async (path: string) =>
      path === '/v1/route-geometries/{id}'
        ? { error: { error: { message: 'geometry_unavailable' } } }
        : {
            data: {
              data: {
                geometryId: 'geometry',
                stops: [
                  { ordinal: 2, location: { latitude: 5.7, longitude: -0.21 } },
                  { ordinal: 1, location: { latitude: 5.6, longitude: -0.2 } },
                ],
              },
            },
          },
    );
    show(data('active', true));
    await waitFor(() => expect(screen.getByText('Line points 2')).toBeInTheDocument());
    expect(screen.getByText(/Showing the ordered stops/)).toBeInTheDocument();
  });

  it('polls the one overview read every ten seconds', () => {
    vi.useFakeTimers();
    try {
      show(data('scheduled', false));
      const retry = (query.current as { retry: ReturnType<typeof vi.fn> }).retry;
      act(() => vi.advanceTimersByTime(10_000));
      expect(retry).toHaveBeenCalledTimes(1);
    } finally {
      vi.useRealTimers();
    }
  });

  it('keeps the last map visible if a later overview refresh fails', () => {
    show(data('active', true), 'Temporarily unavailable');
    expect(screen.getByText('Temporarily unavailable')).toBeInTheDocument();
    expect(screen.getByText('Map mounted')).toBeInTheDocument();
  });
});
