import { fireEvent, render, screen } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Delivery } from './Delivery';
const { session } = vi.hoisted(() => ({ session: { client: { GET: vi.fn() } } }));
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));

it('loads only delivery evidence and resets pagination when channel changes', async () => {
  session.client.GET.mockImplementation(async (_path, options) => ({
    data: {
      data: [
        {
          id: 'delivery',
          createdAt: '2026-01-01T00:00:00Z',
          channel: options.params.query.channel || 'email',
          kind: 'standby_offered',
          state: 'queued',
          attempts: 0,
          failureCode: null,
        },
      ],
      page: { nextCursor: options.params.query.cursor ? null : 'next' },
    },
  }));
  render(
    <FluentProvider theme={trotxiLight}>
      <Delivery />
    </FluentProvider>,
  );
  await screen.findByText('standby offered');
  fireEvent.click(screen.getByRole('button', { name: 'Next page' }));
  await vi.waitFor(() =>
    expect(session.client.GET.mock.lastCall?.[1].params.query.cursor).toBe('next'),
  );
  fireEvent.change(screen.getByLabelText('Channel'), { target: { value: 'push' } });
  await vi.waitFor(() =>
    expect(session.client.GET.mock.lastCall?.[1].params.query).toMatchObject({
      cursor: undefined,
      channel: 'push',
    }),
  );
  expect(session.client.GET.mock.calls.every(([path]) => path === '/v1/ops/deliveries')).toBe(true);
  expect(screen.queryByRole('button', { name: /Reset passkeys/ })).not.toBeInTheDocument();
});
