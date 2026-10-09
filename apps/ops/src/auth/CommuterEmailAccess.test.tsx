import { fireEvent, render, screen } from '@testing-library/react';
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
    target: { value: 'a long testing password' },
  });
  fireEvent.change(screen.getByLabelText('Confirm password'), {
    target: { value: 'a different testing password' },
  });
  fireEvent.click(screen.getByRole('button', { name: 'Save password' }));
  expect(await screen.findByRole('alert')).toHaveTextContent('same password');
  expect(post).not.toHaveBeenCalled();
  post.mockResolvedValue({ response: new Response(null, { status: 204 }) });
  fireEvent.change(screen.getByLabelText('Confirm password'), {
    target: { value: 'a long testing password' },
  });
  fireEvent.click(screen.getByRole('button', { name: 'Save password' }));
  expect(await screen.findByRole('heading', { name: 'Password saved' })).toBeInTheDocument();
  expect(post).toHaveBeenCalledWith('/v1/auth/email/complete', {
    params: { header: { 'X-Trotxi-Client': 'ops', 'X-Trotxi-Build': 1 } },
    body: { token, password: 'a long testing password' },
  });
});
