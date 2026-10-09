import { afterEach, expect, it, vi } from 'vitest';

afterEach(() => {
  window.history.replaceState(null, '', '/');
  sessionStorage.clear();
  vi.resetModules();
});

it('keeps invitation secrets out of the URL and storage, preserves them on rejection, then consumes them', async () => {
  const invitationToken = 'a'.repeat(43);
  window.history.replaceState(null, '', `/#invite=${invitationToken}`);
  sessionStorage.setItem('trotxi.ops.refresh', 'previous-account');
  vi.resetModules();
  const { OpsSession } = await import('./session');
  expect(window.location.hash).toBe('');
  const response = {
    data: {
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
      accessExpiresAt: '2026-10-05T00:00:00Z',
      refreshExpiresAt: '2026-11-05T00:00:00Z',
      account: {
        id: 'invited',
        role: 'admin',
        isSuperadmin: false,
        displayName: 'Invited operator',
        email: 'invited@example.test',
        phone: null,
        avatarUrl: null,
        createdAt: '2026-10-04T00:00:00Z',
      },
    },
  };
  const transport = vi
    .fn()
    .mockResolvedValueOnce(
      Response.json(
        { error: { code: 'invitation_invalid', message: 'Use the invited account.' } },
        { status: 403 },
      ),
    )
    .mockImplementation(() => Promise.resolve(Response.json(response)));
  const session = new OpsSession('https://api.example.test', transport, sessionStorage);
  await session.restore();
  expect(transport).not.toHaveBeenCalled();
  await expect(session.signInGoogle('wrong-account')).rejects.toMatchObject({
    code: 'invitation_invalid',
  });
  await session.signInGoogle('invited-account');
  const bodies = transport.mock.calls.map(([, options]) => JSON.parse(options.body));
  expect(bodies).toEqual([
    { idToken: 'wrong-account', invitationToken },
    { idToken: 'invited-account', invitationToken },
  ]);
  expect(JSON.stringify(sessionStorage)).not.toContain(invitationToken);
  await session.signInGoogle('later-login');
  expect(JSON.parse(transport.mock.calls[2]![1].body)).toEqual({ idToken: 'later-login' });
});
