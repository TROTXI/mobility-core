import { fireEvent, render, screen, waitFor, within } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Platform } from './Platform';

const { get, post, session } = vi.hoisted(() => {
  const get = vi.fn();
  const post = vi.fn();
  return { get, post, session: { client: { GET: get, POST: post } } };
});

vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));

describe('Manual maintenance', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    get.mockResolvedValue({ data: { data: [] } });
    post.mockResolvedValue({
      data: { data: { considered: 0, succeeded: 0, blocked: 0, failed: 0, failures: [] } },
    });
  });

  it('shows the job scope and waits for confirmation before dispatching rider asks', async () => {
    render(
      <FluentProvider theme={trotxiLight} data-theme="light">
        <Platform />
      </FluentProvider>,
    );
    fireEvent.click(screen.getByRole('tab', { name: 'Manual jobs' }));
    expect(screen.getByText('System upkeep and individual recovery steps')).toBeInTheDocument();
    const askRow = screen.getByText('Ask riders').closest('.maintenance-job');
    expect(askRow).not.toBeNull();
    fireEvent.click(within(askRow as HTMLElement).getByRole('button', { name: 'Run' }));
    expect(post).not.toHaveBeenCalled();
    const dialog = screen.getByRole('dialog');
    expect(within(dialog).getByText(/outbound/)).toBeInTheDocument();
    fireEvent.click(within(dialog).getByRole('button', { name: 'Run job' }));
    await waitFor(() =>
      expect(post).toHaveBeenCalledWith(
        '/v1/ops/maintenance/ask-dispatch',
        expect.objectContaining({ body: expect.objectContaining({ direction: 'outbound' }) }),
      ),
    );
    expect(await screen.findByRole('status')).toHaveTextContent('considered: 0');
    expect(screen.getByRole('status')).not.toHaveTextContent('/v1/ops/maintenance/');
  });
});
