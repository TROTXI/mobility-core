import { Button, Input } from '@fluentui/react-components';
import { useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import { opsHeaders } from '../api/session';
import { useQuery } from '../hooks/useQuery';
import { Page, Panel, ErrorState, LoadingRows, Empty, when } from '../components/Page';
import { ActionDialog } from '../components/ActionDialog';
import type { components } from '../generated/api';

type Entry = components['schemas']['OpsTeamEntry'];
type Action = 'resend' | 'cancel' | 'delete' | 'make_superadmin' | 'make_admin' | 'reset';
export function Team() {
  const { account } = useAuth();
  if (!account?.isSuperadmin)
    return (
      <Page title="Team & access" description="Only a superadmin can manage administrator access.">
        {null}
      </Page>
    );
  return <TeamDirectory />;
}
function TeamDirectory() {
  const { session, account } = useAuth();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [cursor, setCursor] = useState<string | undefined>();
  const [selected, setSelected] = useState<{ entry: Entry; action: Action } | null>(null);
  const keys = useRef(new Map<string, string>());
  const commandKey = (identity: string) => {
    if (!keys.current.has(identity)) keys.current.set(identity, crypto.randomUUID());
    return keys.current.get(identity)!;
  };
  const query = useQuery(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/team', {
        params: { header: opsHeaders, query: { limit: 50, ...(cursor ? { cursor } : {}) } },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data;
    },
    [session, cursor],
  );
  const invite = async () => {
    setBusy(true);
    setError('');
    setNotice('');
    const identity = JSON.stringify(['invite', name.trim(), email.trim().toLowerCase()]);
    try {
      const response = await session.client.POST('/v1/ops/team/invitations', {
        params: { header: { ...opsHeaders, 'Idempotency-Key': commandKey(identity) } },
        body: { name: name.trim(), email: email.trim().toLowerCase() },
      });
      if (response.error) throw new Error(response.error.error.message);
      keys.current.delete(identity);
      setName('');
      setEmail('');
      setCursor(undefined);
      query.retry();
      setNotice(
        'Invitation saved. Delivery status shows whether the email provider accepted it; access stays pending until setup is complete.',
      );
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Could not invite administrator.');
    } finally {
      setBusy(false);
    }
  };
  const apply = async () => {
    if (!selected) return;
    const { entry, action } = selected;
    const identity = JSON.stringify([action, entry.id]);
    const params = {
      path: { id: entry.id },
      header: { ...opsHeaders, 'Idempotency-Key': commandKey(identity) },
    };
    const response =
      action === 'resend'
        ? await session.client.POST('/v1/ops/team/invitations/{id}/resend', { params })
        : action === 'cancel'
          ? await session.client.POST('/v1/ops/team/invitations/{id}/cancel', { params })
          : action === 'reset'
            ? await session.client.POST('/v1/ops/users/{id}/passkeys/reset', {
                params: { path: { id: entry.id }, header: opsHeaders },
              })
            : await session.client.POST('/v1/ops/team/members/{id}/access', {
                params,
                body: { action },
              });
    if (response.error) throw new Error(response.error.error.message);
    keys.current.delete(identity);
    setSelected(null);
    query.retry();
    setNotice(
      action === 'delete'
        ? 'Account deleted. All sessions have been revoked.'
        : 'Access change saved.',
    );
  };
  const labels: Record<Action, string> = {
    resend: 'Resend invitation',
    cancel: 'Cancel invitation',
    delete: 'Delete account',
    make_superadmin: 'Make superadmin',
    make_admin: 'Make administrator',
    reset: 'Reset passkeys',
  };
  return (
    <Page
      title="Team & access"
      description="Invite administrators and control who can manage this workspace."
      actions={<Link to="/audit">View access history</Link>}
    >
      <Panel title="Invite an administrator">
        <form
          onSubmit={(event) => {
            event.preventDefault();
            void invite();
          }}
          className="team-invite-form"
        >
          <label>
            Name
            <Input
              value={name}
              maxLength={100}
              required
              disabled={busy}
              onChange={(_, data) => setName(data.value)}
            />
          </label>
          <label>
            Google account email
            <Input
              type="email"
              value={email}
              maxLength={320}
              required
              disabled={busy}
              onChange={(_, data) => setEmail(data.value)}
            />
          </label>
          <Button
            type="submit"
            appearance="primary"
            disabled={busy || !name.trim() || !email.trim()}
          >
            {busy ? 'Sending invitation…' : 'Send invitation'}
          </Button>
        </form>
        <p className="muted">
          An invitation expires after 48 hours. Google sign-in and a passkey are required. No
          password is emailed.
        </p>
      </Panel>
      {notice && <p role="status">{notice}</p>}
      {error && <ErrorState message={error} retry={() => void invite()} />}
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      <Panel title="Administrators and invitations">
        {query.loading ? (
          <LoadingRows />
        ) : !query.data?.data.length ? (
          <Empty />
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Person</th>
                  <th>Access</th>
                  <th>Email</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {query.data.data.map((entry) => (
                  <tr key={entry.id}>
                    <td>
                      <strong>{entry.name}</strong>
                      <div className="muted">{entry.email}</div>
                    </td>
                    <td>
                      {entry.kind === 'member'
                        ? entry.isSuperadmin
                          ? 'Superadmin'
                          : 'Administrator'
                        : entry.state === 'claimed'
                          ? entry.expiresAt && Date.parse(entry.expiresAt) <= Date.now()
                            ? 'Setup expired: cancel and invite again'
                            : 'Passkey setup pending'
                          : entry.state}
                      {entry.expiresAt && (
                        <div className="muted">Expires {when(entry.expiresAt)}</div>
                      )}
                    </td>
                    <td>
                      {entry.emailState === 'accepted'
                        ? 'Provider accepted'
                        : (entry.emailState ?? 'Not applicable')}
                    </td>
                    <td>
                      {entry.kind === 'member' ? (
                        entry.id === account?.id ? (
                          <span className="muted">Your account</span>
                        ) : (
                          <>
                            {(
                              [
                                'reset',
                                entry.isSuperadmin ? 'make_admin' : 'make_superadmin',
                                'delete',
                              ] as Action[]
                            ).map((action) => (
                              <Button
                                key={action}
                                appearance="subtle"
                                onClick={() => setSelected({ entry, action })}
                              >
                                {labels[action]}
                              </Button>
                            ))}
                          </>
                        )
                      ) : (
                        <>
                          {entry.state !== 'claimed' && (
                            <Button
                              appearance="subtle"
                              onClick={() => setSelected({ entry, action: 'resend' })}
                            >
                              Resend
                            </Button>
                          )}
                          <Button
                            appearance="subtle"
                            onClick={() => setSelected({ entry, action: 'cancel' })}
                          >
                            Cancel
                          </Button>
                        </>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        <div className="team-pagination">
          <Button disabled={!cursor} onClick={() => setCursor(undefined)}>
            First page
          </Button>
          <Button
            disabled={!query.data?.page.nextCursor}
            onClick={() => setCursor(query.data?.page.nextCursor ?? undefined)}
          >
            Next page
          </Button>
        </div>
      </Panel>
      <ActionDialog
        open={!!selected}
        title={selected ? labels[selected.action] : ''}
        description={
          selected
            ? `${selected.entry.name}: ${selected.action === 'resend' ? 'The old invitation link will stop working.' : selected.action === 'make_superadmin' ? 'This grants authority to invite, delete and manage other administrators.' : selected.action === 'reset' ? 'Existing passkeys and sessions will be revoked. They must sign in with Google and register a new passkey.' : selected.action === 'delete' || (selected.action === 'cancel' && selected.entry.state === 'claimed') ? 'This permanently closes their entire account, including any commuter profile, and signs them out everywhere. Personal details are erased; required financial and audit records are retained. External cleanup is tracked separately. This cannot be undone.' : 'This changes their access immediately and may sign them out.'}`
            : ''
        }
        confirmLabel={selected?.action === 'delete' ? 'Delete account' : 'Confirm'}
        danger={
          selected?.action === 'delete' ||
          selected?.action === 'cancel' ||
          selected?.action === 'reset'
        }
        onClose={() => setSelected(null)}
        onConfirm={apply}
      >
        {null}
      </ActionDialog>
    </Page>
  );
}
