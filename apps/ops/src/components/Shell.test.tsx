import { fireEvent, render, screen } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { describe, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Shell } from './Shell';

vi.mock('../auth/AuthContext', () => ({
  useAuth: () => ({
    account: { displayName: 'Test Operator', avatarUrl: null, isSuperadmin: true },
    session: { logout: vi.fn() },
  }),
}));

describe('Ops navigation', () => {
  it('groups work without hiding payment or access pages in More', async () => {
    const toggleAppearance = vi.fn();
    render(
      <FluentProvider theme={trotxiLight} data-theme="light">
        <MemoryRouter initialEntries={['/']}>
          <Routes>
            <Route element={<Shell appearance="light" toggleAppearance={toggleAppearance} />}>
              <Route index element={<div>Home screen</div>} />
              <Route path="payments" element={<div>Payments screen</div>} />
            </Route>
          </Routes>
        </MemoryRouter>
      </FluentProvider>,
    );
    expect(screen.getByText('Home screen')).toBeInTheDocument();
    const home = screen.getByRole('link', { name: 'Trotxi operations home' });
    expect(home.querySelector('img')).toHaveAttribute('src', '/trotxi-wordmark-light.png');
    expect(home.querySelector('img')).toHaveAttribute('alt', '');
    expect(screen.getByRole('link', { name: 'Live operations' })).toBeInTheDocument();
    expect(screen.queryByRole('search')).not.toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Payments' })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Team & access' })).toBeInTheDocument();
    expect(screen.getAllByRole('link', { name: 'Fleet & drivers' })).toHaveLength(1);
    expect(screen.queryByRole('link', { name: 'Drivers' })).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Account menu for Test Operator' }));
    fireEvent.click(await screen.findByRole('menuitem', { name: 'Dark appearance' }));
    expect(toggleAppearance).toHaveBeenCalledOnce();
    fireEvent.click(screen.getByRole('link', { name: 'Payments' }));
    expect(await screen.findByText('Payments screen')).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Open navigation' }));
    expect(screen.getByRole('button', { name: 'Open navigation' })).toHaveAttribute(
      'aria-expanded',
      'true',
    );
    fireEvent.click(screen.getAllByRole('button', { name: 'Close navigation' })[0]);
    expect(screen.getByRole('button', { name: 'Open navigation' })).toHaveAttribute(
      'aria-expanded',
      'false',
    );
  });
});
