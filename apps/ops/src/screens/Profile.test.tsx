import { fireEvent, render, screen } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter } from 'react-router-dom';
import { describe, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Profile } from './Profile';

const query = vi.hoisted(() => ({ current: {} as object }));

vi.mock('../auth/AuthContext', () => ({
  useAuth: () => ({
    account: {
      id: 'operator-123',
      displayName: 'Test Operator',
      email: 'operator@example.com',
      avatarUrl: null,
      createdAt: '2026-09-25T07:00:00Z',
    },
    session: {},
  }),
}));
vi.mock('../hooks/useQuery', () => ({ useQuery: () => query.current }));

describe('operator profile', () => {
  it('shows identity and security first, with technical details on request', () => {
    query.current = { data: [], loading: false, error: null, retry: vi.fn() };
    render(
      <FluentProvider theme={trotxiLight} data-theme="light">
        <MemoryRouter>
          <Profile />
        </MemoryRouter>
      </FluentProvider>,
    );

    expect(screen.getByRole('heading', { name: 'My profile' })).toBeInTheDocument();
    expect(screen.getByText('Test Operator')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Manage passkeys' })).toHaveAttribute(
      'href',
      '/platform',
    );
    const details = screen.getByText('Account details').closest('details');
    expect(details).not.toHaveAttribute('open');
    fireEvent.click(screen.getByText('Account details'));
    expect(details).toHaveAttribute('open');
    expect(screen.getByText('operator-123')).toBeInTheDocument();
  });

  it('shows a failed session read as an error, not an empty account', () => {
    query.current = { data: null, loading: false, error: 'Sessions unavailable', retry: vi.fn() };
    render(
      <FluentProvider theme={trotxiLight} data-theme="light">
        <MemoryRouter>
          <Profile />
        </MemoryRouter>
      </FluentProvider>,
    );

    expect(screen.getByRole('alert')).toHaveTextContent('Sessions unavailable');
    expect(screen.queryByText('No active sessions.')).not.toBeInTheDocument();
  });
});
