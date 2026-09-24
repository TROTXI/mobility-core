import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { PasskeyGate } from './PasskeyGate';

const { get, post, startRegistration, startAuthentication, auth } = vi.hoisted(() => {
  const get = vi.fn();
  const post = vi.fn();
  return {
    get,
    post,
    startRegistration: vi.fn(),
    startAuthentication: vi.fn(),
    auth: { session: { client: { GET: get, POST: post } } },
  };
});

vi.mock('./AuthContext', () => ({ useAuth: () => auth }));
vi.mock('@simplewebauthn/browser', () => ({ startRegistration, startAuthentication }));

describe('PasskeyGate', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });
  it('requires a first passkey before exposing Ops data', async () => {
    get
      .mockResolvedValueOnce({
        data: {
          data: { registered: false, passkeyCount: 0, registrationPending: false, verified: false },
        },
      })
      .mockResolvedValueOnce({
        data: {
          data: { registered: true, passkeyCount: 1, registrationPending: false, verified: true },
        },
      });
    post
      .mockResolvedValueOnce({ data: { data: { challenge: 'challenge' } } })
      .mockResolvedValueOnce({ data: { data: { verified: true } } });
    startRegistration.mockResolvedValue({ id: 'credential' });
    render(
      <PasskeyGate>
        <div>Private operations</div>
      </PasskeyGate>,
    );
    expect(await screen.findByText('Create secure access')).toBeInTheDocument();
    expect(screen.queryByText('Private operations')).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Create passkey' }));
    await waitFor(() => expect(screen.getByText('Private operations')).toBeInTheDocument());
    expect(startRegistration).toHaveBeenCalledOnce();
  });
  it('uses assertion, not registration, for a returning administrator', async () => {
    get
      .mockResolvedValueOnce({
        data: {
          data: { registered: true, passkeyCount: 2, registrationPending: false, verified: false },
        },
      })
      .mockResolvedValueOnce({
        data: {
          data: { registered: true, passkeyCount: 2, registrationPending: false, verified: true },
        },
      });
    post
      .mockResolvedValueOnce({ data: { data: { challenge: 'challenge' } } })
      .mockResolvedValueOnce({ data: { data: { verified: true } } });
    startAuthentication.mockResolvedValue({ id: 'assertion' });
    render(
      <PasskeyGate>
        <div>Private operations</div>
      </PasskeyGate>,
    );
    fireEvent.click(await screen.findByRole('button', { name: 'Verify with passkey' }));
    await waitFor(() => expect(screen.getByText('Private operations')).toBeInTheDocument());
    expect(startAuthentication).toHaveBeenCalledOnce();
    expect(startRegistration).not.toHaveBeenCalled();
  });
});
