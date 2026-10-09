import { fireEvent, render, screen } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { beforeEach, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Support } from './Support';

const { client, session } = vi.hoisted(() => {
  const client = { GET: vi.fn(), POST: vi.fn() };
  return { client, session: { client } };
});
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));

beforeEach(() => {
  vi.clearAllMocks();
  client.GET.mockImplementation(async (path: string) => ({
    data: {
      data:
        path === '/v1/ops/account-erasures'
          ? [
              {
                userId: '00000000-0000-4000-8000-000000000001',
                erasedAt: '2026-09-30T08:00:00Z',
                sessionsRevoked: 1,
                devicesRevoked: 0,
                identitiesScrubbed: 1,
                trackedTasks: 1,
                trackedDone: 1,
                trackedCancelled: 0,
                trackedPending: 0,
                trackedUnavailable: 0,
                trackedCleanupState: 'tracked_complete',
              },
            ]
          : [],
      page: { nextCursor: null },
    },
  }));
});

it('labels deletion status as local only and does not present provider erasure as complete', async () => {
  render(
    <FluentProvider theme={trotxiLight}>
      <Support />
    </FluentProvider>,
  );
  fireEvent.click(screen.getByRole('tab', { name: 'Account deletions' }));
  expect(await screen.findByText('Tracked tasks complete')).toBeInTheDocument();
  expect(screen.getByText(/does not certify deletion from payment/)).toBeInTheDocument();
  expect(client.GET).toHaveBeenCalledWith('/v1/ops/account-erasures', expect.anything());
});
