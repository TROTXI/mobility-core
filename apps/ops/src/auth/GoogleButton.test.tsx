import { StrictMode } from 'react';
import { act, fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { GoogleButton } from './GoogleButton';

const { auth, initialize, renderButton } = vi.hoisted(() => ({
  auth: { session: { signInGoogle: vi.fn() } },
  initialize: vi.fn(),
  renderButton: vi.fn((host: HTMLElement) => {
    const button = document.createElement('button');
    button.textContent = 'Continue with Google';
    host.append(button);
  }),
}));

vi.mock('./AuthContext', () => ({ useAuth: () => auth }));

describe('GoogleButton', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    vi.stubEnv('VITE_GOOGLE_CLIENT_ID', 'public-client.apps.googleusercontent.com');
    const script = document.createElement('script');
    script.dataset.trotxiGoogle = 'true';
    document.head.append(script);
    window.google = {
      accounts: { id: { initialize, renderButton, cancel: vi.fn() } },
    };
  });

  it('keeps the provider-owned button outside React reconciliation during a strict remount', async () => {
    render(
      <StrictMode>
        <GoogleButton />
      </StrictMode>,
    );

    expect(await screen.findByRole('button', { name: 'Continue with Google' })).toBeInTheDocument();
    expect(initialize).toHaveBeenCalled();
    expect(renderButton).toHaveBeenCalled();
  });

  it('retries a rejected account without reloading and losing the invitation', async () => {
    auth.session.signInGoogle.mockRejectedValueOnce(new Error('Use the invited account.'));
    render(<GoogleButton />);
    await act(async () =>
      initialize.mock.calls.at(-1)![0].callback({ credential: 'wrong-account' }),
    );
    expect(await screen.findByText('Use the invited account.')).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Try again' }));
    expect(await screen.findByRole('button', { name: 'Continue with Google' })).toBeInTheDocument();
    expect(initialize).toHaveBeenCalledTimes(2);
  });
});
