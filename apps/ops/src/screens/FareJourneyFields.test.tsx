import { useState } from 'react';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { expect, it, vi } from 'vitest';
import { FareJourneyFields, type FareJourney } from './FareJourneyFields';

const { session } = vi.hoisted(() => ({ session: { client: { GET: vi.fn() } } }));
vi.mock('../auth/AuthContext', () => ({ useAuth: () => ({ session }) }));

it('prices ordered occurrences independently and clears the pair when direction changes', async () => {
  const version = {
    id: 'version',
    revision: 2,
    state: 'published',
    stops: [
      { id: 'a', name: 'A', stopId: 'same-stop' },
      { id: 'b', name: 'B', stopId: 'same-stop' },
      { id: 'c', name: 'C', stopId: 'same-stop' },
    ],
  };
  session.client.GET.mockImplementation(async (path: string) => ({
    data: { data: path.endsWith('{versionId}') ? version : [version] },
  }));
  function Form() {
    const [value, setValue] = useState<FareJourney | null>(null);
    return (
      <>
        <FareJourneyFields
          patterns={[
            {
              id: 'out',
              routeId: 'route',
              direction: 'outbound',
              publishedVersionId: 'version',
              createdAt: '2026-01-01T00:00:00Z',
              updatedAt: '2026-01-01T00:00:00Z',
              version: 1,
            },
            {
              id: 'back',
              routeId: 'route',
              direction: 'return',
              publishedVersionId: 'version',
              createdAt: '2026-01-01T00:00:00Z',
              updatedAt: '2026-01-01T00:00:00Z',
              version: 1,
            },
          ]}
          value={value}
          onChange={setValue}
        />
        <output>{JSON.stringify(value)}</output>
      </>
    );
  }
  render(<Form />);
  fireEvent.change(screen.getByLabelText('Direction'), { target: { value: 'out' } });
  await screen.findByText('Revision 2, published (3 stops)');
  fireEvent.change(screen.getByLabelText('Published route version'), {
    target: { value: 'version' },
  });
  await screen.findByRole('option', { name: '2. B' });
  fireEvent.change(screen.getByLabelText('Pickup'), { target: { value: 'b' } });
  const dropoff = screen.getByLabelText('Drop-off');
  expect(within(dropoff).queryByRole('option', { name: '1. A' })).not.toBeInTheDocument();
  expect(within(dropoff).queryByRole('option', { name: '2. B' })).not.toBeInTheDocument();
  fireEvent.change(dropoff, { target: { value: 'c' } });
  expect(screen.getByRole('status')).toHaveTextContent(
    '"pickupOccurrenceId":"b","dropoffOccurrenceId":"c"',
  );
  fireEvent.change(screen.getByLabelText('Direction'), { target: { value: 'back' } });
  expect(screen.getByRole('status')).toHaveTextContent('null');
});
