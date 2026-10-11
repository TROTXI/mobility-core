import { fireEvent, render, screen } from '@testing-library/react';
import { FluentProvider } from '@fluentui/react-components';
import { describe, expect, it, vi } from 'vitest';
import { trotxiLight } from '../theme';
import { Network } from './Network';

const { get, session } = vi.hoisted(() => {
  const get = vi.fn().mockResolvedValue({ data: { data: [] } });
  return { get, session: { client: { GET: get } } };
});

vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));
vi.mock('../components/LiveMap', () => ({ LiveMap: () => <div>Map mounted</div> }));

describe('Route setup', () => {
  it('groups the setup steps and opens the heavy map only on request', async () => {
    render(
      <FluentProvider theme={trotxiLight} data-theme="light">
        <Network />
      </FluentProvider>,
    );
    expect(screen.getByText('Build the route')).toBeInTheDocument();
    expect(screen.getByText('Set the offer')).toBeInTheDocument();
    expect(screen.queryByText('Map mounted')).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: 'Show map' }));
    expect(await screen.findByText('Map mounted')).toBeInTheDocument();
    expect(get).toHaveBeenCalledWith('/v1/ops/routes', expect.anything());
  });
});
