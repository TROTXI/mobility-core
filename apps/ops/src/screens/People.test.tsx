import { fireEvent, render, screen, within } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter } from 'react-router-dom';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { components } from '../generated/api';
import { trotxiLight } from '../theme';
import { People } from './People';

type Operator = components['schemas']['OpsOperator'];

const { client, session } = vi.hoisted(() => {
  const client = { GET: vi.fn(), POST: vi.fn(), PATCH: vi.fn() };
  return { client, session: { client, account: { id: 'admin-me', isSuperadmin: true } } };
});
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));
// jsdom has no ResizeObserver; Fluent's MessageBar measures itself with one.
globalThis.ResizeObserver ??= class {
  observe() {}
  unobserve() {}
  disconnect() {}
} as unknown as typeof ResizeObserver;

const operator = (id: string, name: string): Operator => ({
  id,
  displayName: name,
  email: `${id}@example.test`,
  passkeyCount: 1,
  activeSessions: 1,
  lastPasskeyUsedAt: null,
  joinedAt: '2026-09-20T08:00:00Z',
  editToken: `"user:${id}:3"`,
});

function show() {
  client.GET.mockImplementation(async (path: string) => ({
    data: {
      data:
        path === '/v1/ops/operators'
          ? [operator('admin-me', 'Me'), operator('admin-fosu', 'K. Fosu')]
          : [],
      page: { nextCursor: null },
    },
  }));
  return render(
    <FluentProvider theme={trotxiLight} data-theme="light">
      <MemoryRouter>
        <People />
      </MemoryRouter>
    </FluentProvider>,
  );
}
const dialog = () => screen.getByRole('dialog');

describe('Administrator account management', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    session.account.isSuperadmin = true;
  });

  it('routes account changes to Team instead of offering commuter demotion', async () => {
    show();
    const mine = (await screen.findByText('Me')).closest('tr')!;
    expect(within(mine).getByRole('button', { name: 'Reset passkeys' })).toBeDisabled();
    const theirs = screen.getByText('K. Fosu').closest('tr')!;
    expect(within(theirs).getByRole('button', { name: 'Reset passkeys' })).toBeEnabled();
    expect(screen.queryByRole('button', { name: 'Change role' })).not.toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Manage team accounts' })).toHaveAttribute(
      'href',
      '/team',
    );
  });

  it('does not offer account management to regular admins', async () => {
    session.account.isSuperadmin = false;
    show();
    const theirs = (await screen.findByText('K. Fosu')).closest('tr')!;
    expect(within(theirs).getByRole('button', { name: 'Reset passkeys' })).toBeDisabled();
    expect(screen.queryByRole('link', { name: 'Manage team accounts' })).not.toBeInTheDocument();
    expect(client.PATCH).not.toHaveBeenCalled();
  });

  it('shows a passkey reset refusal without changing account roles', async () => {
    client.POST.mockResolvedValue({
      error: {
        error: {
          code: 'superadmin_required',
          message: 'Only a superadmin can manage operator access.',
        },
      },
    });
    show();
    const theirs = (await screen.findByText('K. Fosu')).closest('tr')!;
    fireEvent.click(within(theirs).getByRole('button', { name: 'Reset passkeys' }));
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Reset access' }));
    expect(await within(dialog()).findByText(/Only a superadmin/)).toBeInTheDocument();
    expect(client.PATCH).not.toHaveBeenCalled();
  });
});
