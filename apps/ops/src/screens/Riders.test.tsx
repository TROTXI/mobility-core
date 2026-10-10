import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter } from 'react-router-dom';
import { beforeEach, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Riders } from './Riders';

const { client, account, session } = vi.hoisted(() => {
  const client = { GET: vi.fn(), POST: vi.fn(), PATCH: vi.fn() };
  const account = { id: 'operator', isSuperadmin: true };
  return { client, account, session: { client, account } };
});
vi.mock('../auth/AuthContext', () => ({
  useAuth: () => ({ account, session }),
}));

const riderId = '11111111-1111-4111-8111-111111111111';
const rider = {
  id: riderId,
  displayName: 'Test Rider',
  email: 'rider@example.invalid',
  phone: null,
  status: 'active',
  plan: null,
  routeName: null,
  ridesLeft: 0,
  availableCredit: { amountMinor: 0, currency: 'GHS' },
  role: 'commuter',
  editToken: 'edit-token',
};

beforeEach(() => {
  vi.clearAllMocks();
  account.isSuperadmin = true;
  client.GET.mockImplementation(async (path: string) => {
    if (path === '/v1/ops/riders/summary')
      return {
        data: {
          data: {
            active: 1,
            paused: 0,
            monthly: 0,
            annual: 0,
            creditOutstanding: rider.availableCredit,
          },
        },
      };
    if (path === '/v1/ops/riders/{id}')
      return {
        data: {
          data: { rider, membership: null, restrictions: [], purchases: [], reservations: [] },
        },
      };
    return { data: { data: [rider], page: { nextCursor: null } } };
  });
  client.POST.mockResolvedValue({ data: { data: { id: riderId } } });
});

const show = () =>
  render(
    <FluentProvider theme={trotxiLight}>
      <MemoryRouter>
        <Riders />
      </MemoryRouter>
    </FluentProvider>,
  );

it('only offers commuter erasure to a superadmin and requires exact account confirmation', async () => {
  account.isSuperadmin = false;
  const page = show();
  fireEvent.click(await screen.findByRole('button', { name: 'Manage' }));
  expect(screen.queryByRole('button', { name: 'Delete account' })).not.toBeInTheDocument();
  page.unmount();

  account.isSuperadmin = true;
  show();
  fireEvent.click(await screen.findByRole('button', { name: 'Manage' }));
  fireEvent.click(await screen.findByRole('button', { name: 'Delete account' }));
  const dialog = screen.getByRole('dialog');
  const confirm = within(dialog).getByRole('button', { name: 'Delete account' });
  expect(confirm).toBeDisabled();
  fireEvent.change(within(dialog).getByRole('textbox', { name: /Type this account ID/ }), {
    target: { value: riderId },
  });
  fireEvent.change(within(dialog).getByRole('textbox', { name: /Verified request reference/ }), {
    target: { value: 'Verified support case CASE-42' },
  });
  expect(confirm).toBeEnabled();
  fireEvent.click(confirm);
  await waitFor(() =>
    expect(client.POST).toHaveBeenCalledWith(
      '/v1/ops/riders/{id}/erase',
      expect.objectContaining({
        body: { confirmAccountId: riderId, reason: 'Verified support case CASE-42' },
        params: expect.objectContaining({ path: { id: riderId } }),
      }),
    ),
  );
});
