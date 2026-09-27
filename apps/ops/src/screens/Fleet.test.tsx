import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { MemoryRouter } from 'react-router-dom';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { components } from '../generated/api';
import { trotxiLight } from '../theme';
import { EMAIL_STATE, Fleet, pinState } from './Fleet';

type Driver = components['schemas']['Driver'];

const { client, session } = vi.hoisted(() => {
  const client = { GET: vi.fn(), POST: vi.fn(), PATCH: vi.fn() };
  return { client, session: { client } };
});
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));
// jsdom has no ResizeObserver; Fluent's MessageBar measures itself with one.
globalThis.ResizeObserver ??= class {
  observe() {}
  unobserve() {}
  disconnect() {}
} as unknown as typeof ResizeObserver;

const driver = (overrides: Partial<Driver> = {}): Driver => ({
  id: 'driver-1',
  name: 'Ama Mensah',
  phone: '+233200000001',
  email: 'ama.driver@example.test',
  licenseNumber: null,
  userId: null,
  archived: false,
  credential: null,
  credentialEmail: null,
  editToken: '"driver:driver-1:1"',
  version: 1,
  createdAt: '2026-09-26T08:00:00Z',
  updatedAt: '2026-09-26T08:00:00Z',
  ...overrides,
});
const secret = {
  code: 'DR-7K9Q',
  pin: '481205',
  temporaryPinExpiresAt: '2026-09-29T08:00:00Z',
  email: { id: 'mail-1', to: 'ama.driver@example.test', state: 'queued' as const },
};

let register: Driver[] = [];
function show() {
  client.GET.mockImplementation(async (path: string) => ({
    data: { data: path === '/v1/ops/drivers' ? register : [], page: { nextCursor: null } },
  }));
  return render(
    <FluentProvider theme={trotxiLight} data-theme="light">
      <MemoryRouter>
        <Fleet view="drivers" />
      </MemoryRouter>
    </FluentProvider>,
  );
}
const dialog = () => screen.getByRole('dialog');
const field = (label: RegExp) => within(dialog()).getByLabelText(label);

describe('Driver onboarding in Fleet', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    register = [];
    window.sessionStorage.clear();
    window.localStorage.clear();
  });

  it('creates a driver, issues sign-in details and emails them without keeping the PIN', async () => {
    const created = driver();
    client.POST.mockImplementation(async (path: string) =>
      path === '/v1/ops/drivers' ? { data: { data: created } } : { data: { data: secret } },
    );
    show();
    fireEvent.click(await screen.findByRole('button', { name: /Add driver/ }));
    fireEvent.change(field(/^Name/), { target: { value: 'Ama Mensah' } });
    fireEvent.change(field(/Email for sign-in/), { target: { value: 'ama.driver@example.test' } });
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Create and issue' }));

    expect(
      await screen.findByText(/queued for email to ama.driver@example.test/),
    ).toBeInTheDocument();
    const [createCall, issueCall] = client.POST.mock.calls;
    expect(createCall![0]).toBe('/v1/ops/drivers');
    expect(createCall![1].body).toMatchObject({
      name: 'Ama Mensah',
      email: 'ama.driver@example.test',
    });
    expect(issueCall![0]).toBe('/v1/ops/drivers/{id}/credentials');
    expect(issueCall![1].body).toEqual({ emailInstructions: true });
    // Emailed PINs are never put on screen or in storage.
    expect(document.body.textContent).not.toContain(secret.pin);
    expect(JSON.stringify({ ...window.sessionStorage, ...window.localStorage })).not.toContain(
      secret.pin,
    );
  });

  it('retries only the failed onboarding step, with the same keys, never a second driver', async () => {
    const created = driver();
    let issueAttempts = 0;
    client.POST.mockImplementation(async (path: string) => {
      if (path === '/v1/ops/drivers') return { data: { data: created } };
      issueAttempts++;
      return issueAttempts === 1
        ? { error: { error: { message: 'Email delivery is not configured here.' } } }
        : { data: { data: secret } };
    });
    show();
    fireEvent.click(await screen.findByRole('button', { name: /Add driver/ }));
    fireEvent.change(field(/^Name/), { target: { value: 'Ama Mensah' } });
    fireEvent.change(field(/Email for sign-in/), { target: { value: 'ama.driver@example.test' } });
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Create and issue' }));

    expect(
      await within(dialog()).findByText(/was created, but issuing sign-in details failed/),
    ).toBeInTheDocument();
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Retry sign-in details' }));
    await screen.findByText(/queued for email/);

    const paths = client.POST.mock.calls.map((call) => call[0]);
    expect(paths.filter((path) => path === '/v1/ops/drivers')).toHaveLength(1);
    const issueKeys = client.POST.mock.calls
      .filter((call) => call[0] === '/v1/ops/drivers/{id}/credentials')
      .map((call) => call[1].params.header['Idempotency-Key']);
    expect(issueKeys).toHaveLength(2);
    expect(issueKeys[0]).toBe(issueKeys[1]);
  });

  it('resets with an audit reason and emails the new PIN to the driver on file', async () => {
    register = [
      driver({
        userId: 'user-1',
        credential: {
          driverCode: 'DR-7K9Q',
          status: 'active',
          mustChangePin: false,
          temporaryPinExpiresAt: null,
          lockedUntil: null,
        },
      }),
    ];
    client.POST.mockResolvedValue({ data: { data: { ...secret, pin: '905113' } } });
    show();
    fireEvent.click(await screen.findByRole('button', { name: 'Manage' }));
    fireEvent.click(screen.getByRole('button', { name: 'Reset PIN and email instructions' }));
    expect(
      within(dialog()).getByText(/any earlier sign-in email still waiting is cancelled/),
    ).toBeInTheDocument();
    fireEvent.change(field(/Reason/), {
      target: { value: 'Driver forgot PIN, confirmed by phone' },
    });
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Apply' }));
    await screen.findByText(/queued for email/);
    const [path, request] = client.POST.mock.calls[0]!;
    expect(path).toBe('/v1/ops/drivers/{id}/credentials/reset-pin');
    expect(request.body).toEqual({
      reason: 'Driver forgot PIN, confirmed by phone',
      emailInstructions: true,
    });
    expect(document.body.textContent).not.toContain('905113');
  });

  it('shows a PIN given out by hand once, with its expiry, when there is no email', async () => {
    register = [driver({ email: null })];
    client.POST.mockResolvedValue({ data: { data: { ...secret, email: null } } });
    show();
    fireEvent.click(await screen.findByRole('button', { name: 'Manage' }));
    fireEvent.click(screen.getByRole('button', { name: 'Issue sign-in details' }));
    expect(within(dialog()).getByText(/has no email address/)).toBeInTheDocument();
    fireEvent.click(within(dialog()).getByRole('button', { name: 'Apply' }));
    expect(await screen.findByText(`Temporary PIN ${secret.pin}`)).toBeInTheDocument();
    expect(client.POST.mock.calls[0]![1].body).toEqual({});
    fireEvent.click(screen.getByRole('button', { name: 'Dismiss' }));
    await waitFor(() => expect(document.body.textContent).not.toContain(secret.pin));
  });

  it('describes delivery honestly: queued is not sent, accepted is not delivered', () => {
    expect(EMAIL_STATE.queued).toMatch(/not sent yet/);
    expect(EMAIL_STATE.provider_accepted).toMatch(/not confirmed/);
    const base = driver({
      credential: {
        driverCode: 'DR-7K9Q',
        status: 'active',
        mustChangePin: true,
        temporaryPinExpiresAt: '2000-01-01T00:00:00Z',
        lockedUntil: null,
      },
    });
    expect(pinState(base)).toBe('Temporary PIN expired');
    expect(pinState({ ...base, credential: { ...base.credential!, mustChangePin: false } })).toBe(
      'Private PIN set',
    );
    expect(pinState(driver())).toBe('Not issued');
  });
});
