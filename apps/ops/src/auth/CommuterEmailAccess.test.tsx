import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import { expect, it, vi } from 'vitest';
const { post } = vi.hoisted(() => ({ post: vi.fn() }));
vi.mock('openapi-fetch', () => ({ default: () => ({ POST: post }) }));

it('keeps a mail token out of the URL, requires confirmation, and does not start an Ops session', async () => {
  const token = 'a'.repeat(43);
  window.history.replaceState(null, '', `/account-access#token=${token}&purpose=signup`);
  const { CommuterEmailAccess } = await import('./CommuterEmailAccess');
  render(<CommuterEmailAccess />);
  expect(window.location.hash).toBe('');
  expect(post).not.toHaveBeenCalled();
  fireEvent.change(screen.getByLabelText('New password'), {
    target: { value: 'A long testing password1!' },
  });
  fireEvent.change(screen.getByLabelText('Confirm password'), {
    target: { value: 'a different testing password' },
  });
  fireEvent.click(screen.getByRole('button', { name: 'Save password' }));
  expect(await screen.findByRole('alert')).toHaveTextContent('same password');
  expect(post).not.toHaveBeenCalled();
  post.mockResolvedValue({ response: new Response(null, { status: 204 }) });
  fireEvent.change(screen.getByLabelText('Confirm password'), {
    target: { value: 'A long testing password1!' },
  });
  fireEvent.click(screen.getByRole('button', { name: 'Save password' }));
  expect(await screen.findByRole('heading', { name: 'Password saved' })).toBeInTheDocument();
  expect(post).toHaveBeenCalledWith('/v1/auth/email/complete', {
    params: { header: { 'X-Trotxi-Client': 'ops', 'X-Trotxi-Build': 1 } },
    body: { token, password: 'A long testing password1!' },
  });
});

it('explains a used contact link without presenting another verification button', async () => {
  cleanup();
  vi.resetModules();
  post.mockReset();
  const token = 'b'.repeat(43);
  window.history.replaceState(null, '', `/account-access#token=${token}&purpose=contact`);
  post.mockResolvedValue({
    error: {
      error: {
        code: 'invalid_email_link',
        message: 'This link is invalid, expired or already used. Request a new email.',
      },
    },
  });
  const { CommuterEmailAccess } = await import('./CommuterEmailAccess');
  render(<CommuterEmailAccess />);
  expect(window.location.hash).toBe('');
  expect(post).not.toHaveBeenCalled();
  fireEvent.click(screen.getByRole('button', { name: 'Verify email' }));
  expect(
    await screen.findByRole('heading', { name: 'Link already used or expired' }),
  ).toBeInTheDocument();
  expect(screen.getByText(/If you just verified successfully/)).toBeInTheDocument();
  expect(screen.queryByRole('button', { name: 'Verify email' })).not.toBeInTheDocument();
});

it('confirms contact email only after a tap and gives a clear return instruction', async () => {
  cleanup();
  vi.resetModules();
  post.mockReset();
  const token = 'c'.repeat(43);
  window.history.replaceState(null, '', `/account-access#token=${token}&purpose=contact`);
  post.mockResolvedValue({ response: new Response(null, { status: 204 }) });
  const { CommuterEmailAccess } = await import('./CommuterEmailAccess');
  render(<CommuterEmailAccess />);
  expect(window.location.hash).toBe('');
  expect(post).not.toHaveBeenCalled();
  fireEvent.click(screen.getByRole('button', { name: 'Verify email' }));
  expect(await screen.findByRole('heading', { name: 'Email verified' })).toBeInTheDocument();
  expect(screen.getByRole('status')).toHaveTextContent(
    'Close this tab and return to the Trotxi app',
  );
  expect(post).toHaveBeenCalledWith('/v1/auth/email/verify', {
    params: { header: { 'X-Trotxi-Client': 'ops', 'X-Trotxi-Build': 1 } },
    body: { token },
  });
});
