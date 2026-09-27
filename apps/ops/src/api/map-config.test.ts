import { describe, expect, it } from 'vitest';
import { mapStyleFromBootstrap } from './map-config';

describe('public map configuration', () => {
  it('reads the top-level /flags Bootstrap response', () => {
    expect(
      mapStyleFromBootstrap(
        {
          mapTiles: {
            styleUrl: 'https://tiles.trotxi.com/style.light.json',
            darkStyleUrl: 'https://tiles.trotxi.com/style.dark.json',
          },
        },
        'light',
      ),
    ).toBe('https://tiles.trotxi.com/style.light.json');
    expect(mapStyleFromBootstrap({ mapTiles: { darkStyleUrl: 'dark' } }, 'dark')).toBe('dark');
  });

  it('does not mistake a missing style for a map that is still loading', () => {
    expect(mapStyleFromBootstrap({ mapTiles: { styleUrl: null } }, 'light')).toBeNull();
    expect(
      mapStyleFromBootstrap({ data: { mapTiles: { styleUrl: 'wrong shape' } } }, 'light'),
    ).toBeNull();
  });
});
