import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter } from 'react-router-dom';
import { beforeEach, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Team } from './Team';
const { client, account } = vi.hoisted(() => ({
  client: { GET: vi.fn(), POST: vi.fn() },
  account: { id: 'owner', isSuperadmin: true },
}));
vi.mock('../auth/AuthContext', () => ({
  useAuth: () => ({ account, session: { client, account } }),
}));
beforeEach(() => {
  vi.clearAllMocks();
  account.isSuperadmin = true;
  client.GET.mockResolvedValue({ data: { data: [], page: { nextCursor: null } } });
});
const show = () =>
  render(
    <FluentProvider theme={trotxiLight}>
      <MemoryRouter>
        <Team />
      </MemoryRouter>
    </FluentProvider>,
  );
it('does not load access data for a regular administrator', () => {
  account.isSuperadmin = false;
  show();
  expect(screen.getByText(/Only a superadmin/)).toBeInTheDocument();
  expect(client.GET).not.toHaveBeenCalled();
});
it('reuses an invitation key after an uncertain response and shows queued rather than delivered', async () => {
  client.POST.mockRejectedValueOnce(new Error('Connection lost')).mockResolvedValueOnce({
    data: { data: { id: 'invitation' } },
  });
  show();
  fireEvent.change(screen.getByLabelText('Name'), { target: { value: 'Adom' } });
  fireEvent.change(screen.getByLabelText('Google account email'), {
    target: { value: 'adom@example.invalid' },
  });
  expect(screen.getByRole('button', { name: 'Send invitation' })).toBeDisabled();
  fireEvent.change(screen.getByLabelText('Reason'), { target: { value: 'Joins dispatch' } });
  fireEvent.click(screen.getByRole('button', { name: 'Send invitation' }));
  await screen.findByText('Connection lost');
  fireEvent.click(screen.getByRole('button', { name: 'Send invitation' }));
  await screen.findByText(/Invitation saved/);
  expect(client.POST).toHaveBeenCalledTimes(2);
  const first = client.POST.mock.calls[0]!,
    second = client.POST.mock.calls[1]!;
  expect(first[0]).toBe('/v1/ops/team/invitations');
  expect(first[1].params.header['Idempotency-Key']).toBe(
    second[1].params.header['Idempotency-Key'],
  );
  expect(first[1].body).toEqual({
    name: 'Adom',
    email: 'adom@example.invalid',
    reason: 'Joins dispatch',
  });
});
it('confirms whole-account deletion, and never offers self-deletion', async () => {
  client.GET.mockResolvedValue({
    data: {
      data: [
        {
          id: 'owner',
          name: 'Owner',
          email: 'owner@example.invalid',
          kind: 'member',
          state: 'active',
          isSuperadmin: true,
          expiresAt: null,
          emailState: null,
        },
        {
          id: 'other',
          name: 'Operator',
          email: 'operator@example.invalid',
          kind: 'member',
          state: 'active',
          isSuperadmin: false,
          expiresAt: null,
          emailState: null,
        },
      ],
      page: { nextCursor: null },
    },
  });
  client.POST.mockResolvedValue({ data: { data: { id: 'other' } } });
  show();
  const remove = await screen.findAllByRole('button', { name: 'Delete account' });
  expect(remove).toHaveLength(1);
  fireEvent.click(remove[0]!);
  expect(client.POST).not.toHaveBeenCalled();
  expect(screen.getByText(/permanently closes their entire account/)).toBeInTheDocument();
  const confirm = within(screen.getByRole('dialog')).getByRole('button', {
    name: 'Delete account',
  });
  expect(confirm).toBeDisabled();
  fireEvent.change(within(screen.getByRole('dialog')).getByLabelText('Reason'), {
    target: { value: 'Left the company' },
  });
  fireEvent.click(
    within(screen.getByRole('dialog')).getByRole('button', { name: 'Delete account' }),
  );
  await waitFor(() =>
    expect(client.POST).toHaveBeenCalledWith(
      '/v1/ops/team/members/{id}/access',
      expect.objectContaining({
        body: { action: 'delete', reason: 'Left the company' },
        params: expect.objectContaining({ path: { id: 'other' } }),
      }),
    ),
  );
});
