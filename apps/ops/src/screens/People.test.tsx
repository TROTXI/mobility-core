import { fireEvent, render, screen, within } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { components } from '../generated/api';
import { trotxiLight } from '../theme';
import { People } from './People';

type Operator = components['schemas']['OpsOperator'];

const { client, session } = vi.hoisted(() => {
  const client = { GET: vi.fn(), POST: vi.fn(), PATCH: vi.fn() };
  return { client, session: { client, account: { id: 'admin-me' } } };
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
      <People />
    </FluentProvider>,
  );
}
const dialog = () => screen.getByRole('dialog');

describe('Changing an administrator role', () => {
  beforeEach(() => vi.clearAllMocks());

  it('is not offered on your own row', async () => {
    show();
    const mine = (await screen.findByText('Me')).closest('tr')!;
    expect(within(mine).getByRole('button', { name: 'Change role' })).toBeDisabled();
    const theirs = screen.getByText('K. Fosu').closest('tr')!;
    expect(within(theirs).getByRole('button', { name: 'Change role' })).toBeEnabled();
  });

  it('demotes another administrator to commuter with a reason and their edit token', async () => {
    client.PATCH.mockResolvedValue({ data: { data: { id: 'admin-fosu', role: 'commuter' } } });
    show();
    const theirs = (await screen.findByText('K. Fosu')).closest('tr')!;
    fireEvent.click(within(theirs).getByRole('button', { name: 'Change role' }));

    fireEvent.click(within(dialog()).getByRole('button', { name: 'Change role' }));
    expect(await within(dialog()).findByText(/Give a reason/)).toBeInTheDocument();
    expect(client.PATCH).not.toHaveBeenCalled();

    fireEvent.change(within(dialog()).getByLabelText(/Reason/), {
      target: { value: 'Rider app testing account' },
    });
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Change role' }));
    await vi.waitFor(() => expect(client.PATCH).toHaveBeenCalledTimes(1));
    const [path, request] = client.PATCH.mock.calls[0]!;
    expect(path).toBe('/v1/ops/users/{id}/role');
    expect(request.params.path).toEqual({ id: 'admin-fosu' });
    expect(request.params.header['If-Match']).toBe('"user:admin-fosu:3"');
    expect(request.body).toEqual({ role: 'commuter', reason: 'Rider app testing account' });
  });

  it('keeps one key for a retry and shows the server refusal', async () => {
    client.PATCH.mockResolvedValue({
      error: {
        error: {
          code: 'last_administrator',
          message: 'This is the last administrator. Make someone else an administrator first.',
        },
      },
    });
    show();
    const theirs = (await screen.findByText('K. Fosu')).closest('tr')!;
    fireEvent.click(within(theirs).getByRole('button', { name: 'Change role' }));
    fireEvent.change(within(dialog()).getByLabelText(/Reason/), {
      target: { value: 'Testing' },
    });
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Change role' }));
    expect(await within(dialog()).findByText(/last administrator/)).toBeInTheDocument();
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Change role' }));
    await vi.waitFor(() => expect(client.PATCH).toHaveBeenCalledTimes(2));
    const keys = client.PATCH.mock.calls.map((call) => call[1].params.header['Idempotency-Key']);
    expect(keys[0]).toBe(keys[1]);
  });
});
