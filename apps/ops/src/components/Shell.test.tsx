import { fireEvent, render, screen } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { describe, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Shell } from './Shell';

vi.mock('../auth/AuthContext', () => ({
  useAuth: () => ({
    account: { displayName: 'Test Operator', avatarUrl: null },
    session: { logout: vi.fn() },
  }),
}));

describe('Ops navigation', () => {
  it('keeps secondary sections reachable without filling the icon rail', async () => {
    render(
      <FluentProvider theme={trotxiLight} data-theme="light">
        <MemoryRouter initialEntries={['/']}>
          <Routes>
            <Route element={<Shell appearance="light" toggleAppearance={vi.fn()} />}>
              <Route index element={<div>Home screen</div>} />
              <Route path="payments" element={<div>Payments screen</div>} />
            </Route>
          </Routes>
        </MemoryRouter>
      </FluentProvider>,
    );
    expect(screen.getByText('Home screen')).toBeInTheDocument();
    expect(screen.queryByRole('link', { name: 'Payments' })).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'More sections' }));
    fireEvent.click(await screen.findByRole('menuitem', { name: 'Payments' }));
    expect(await screen.findByText('Payments screen')).toBeInTheDocument();
  });
});
