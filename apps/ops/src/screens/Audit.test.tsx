import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Audit } from './Audit';

const { client, session } = vi.hoisted(() => {
  const client = { GET: vi.fn() };
  return { client, session: { client } };
});
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));
globalThis.ResizeObserver ??= class {
  observe() {}
  unobserve() {}
  disconnect() {}
} as unknown as typeof ResizeObserver;

describe('Ops audit', () => {
  beforeEach(() => vi.clearAllMocks());

  it('searches by domain and target, and keeps pagination bound to the search', async () => {
    client.GET.mockImplementation(
      async (_path: string, request: { params: { query: Record<string, string> } }) => ({
        data: {
          data: [
            {
              id: request.params.query.cursor ? 'older' : 'newer',
              area: 'payments',
              action: 'initiateRefund',
              actorId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
              actorName: 'Pilot Operator',
              targetId: 'purchase-1',
              reason: 'Duplicate payment',
              occurredAt: '2026-09-29T09:00:00Z',
            },
          ],
          page: { nextCursor: request.params.query.cursor ? null : 'older-cursor' },
        },
      }),
    );
    render(
      <FluentProvider theme={trotxiLight} data-theme="light">
        <Audit />
      </FluentProvider>,
    );
    await screen.findByText('Pilot Operator');
    fireEvent.change(screen.getByLabelText('Area'), { target: { value: 'payments' } });
    fireEvent.click(screen.getByText('Find a specific event'));
    fireEvent.change(screen.getByLabelText('Target ID'), { target: { value: 'purchase-1' } });
    fireEvent.click(screen.getByRole('button', { name: 'Search' }));
    await waitFor(() =>
      expect(client.GET).toHaveBeenLastCalledWith(
        '/v1/ops/audit-events',
        expect.objectContaining({
          params: expect.objectContaining({
            query: expect.objectContaining({ area: 'payments', targetId: 'purchase-1' }),
          }),
        }),
      ),
    );
    fireEvent.click(screen.getByRole('button', { name: 'Older' }));
    await waitFor(() =>
      expect(client.GET).toHaveBeenLastCalledWith(
        '/v1/ops/audit-events',
        expect.objectContaining({
          params: expect.objectContaining({
            query: expect.objectContaining({
              area: 'payments',
              targetId: 'purchase-1',
              cursor: 'older-cursor',
            }),
          }),
        }),
      ),
    );
    fireEvent.click(screen.getByRole('button', { name: 'Newer' }));
    await waitFor(() =>
      expect(client.GET).toHaveBeenLastCalledWith(
        '/v1/ops/audit-events',
        expect.objectContaining({
          params: expect.objectContaining({
            query: expect.not.objectContaining({ cursor: expect.anything() }),
          }),
        }),
      ),
    );
  });
});
