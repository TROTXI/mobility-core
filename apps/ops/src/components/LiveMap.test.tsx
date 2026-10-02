import { act, render, screen, waitFor } from '@testing-library/react';
import * as maplibregl from 'maplibre-gl';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { LiveMap } from './LiveMap';

const maps = vi.hoisted(() => {
  const instances: MockMap[] = [];
  const events: string[] = [];
  class MockMap {
    handlers = new Map<string, (() => void)[]>();
    sources = new Map<string, { setData: ReturnType<typeof vi.fn> }>();
    layers = new Set<string>();
    setStyle = vi.fn();
    addControl = vi.fn();
    jumpTo = vi.fn();
    fitBounds = vi.fn();
    remove = vi.fn();
    getCanvas = () => ({ style: { cursor: '' } });
    queryRenderedFeatures = () => [];
    constructor(public options: { style: unknown }) {
      events.push('map');
      instances.push(this);
    }
    on(event: string, layerOrHandler: string | (() => void), handler?: () => void) {
      const callback = typeof layerOrHandler === 'function' ? layerOrHandler : handler!;
      this.handlers.set(event, [...(this.handlers.get(event) ?? []), callback]);
    }
    emit(event: string) {
      for (const handler of this.handlers.get(event) ?? []) handler();
    }
    addSource(id: string) {
      this.sources.set(id, { setData: vi.fn() });
    }
    addLayer(layer: { id: string }) {
      this.layers.add(layer.id);
    }
    getSource(id: string) {
      return this.sources.get(id);
    }
  }
  return { events, instances, MockMap };
});

vi.mock('maplibre-gl', () => ({
  Map: maps.MockMap,
  NavigationControl: class {},
  AttributionControl: class {},
  LngLatBounds: class {
    extend() {}
  },
  addProtocol: vi.fn(),
  setWorkerUrl: vi.fn(() => maps.events.push('worker')),
}));
vi.mock('pmtiles', () => ({
  Protocol: class {
    tile = vi.fn();
  },
}));

describe('live map degradation', () => {
  beforeEach(() => {
    maps.events.length = 0;
    maps.instances.length = 0;
    vi.stubGlobal(
      'fetch',
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ mapTiles: { styleUrl: 'https://tiles.example/style.json' } }),
      }),
    );
  });

  it('configures a bundled worker before creating the map', async () => {
    render(<LiveMap markers={[]} />);
    await waitFor(() => expect(maps.instances).toHaveLength(1));
    expect(maplibregl.setWorkerUrl).toHaveBeenCalledWith(expect.stringContaining('worker'));
    expect(maps.events).toEqual(['worker', 'map']);
  });

  it('keeps position and route overlays when a tile fails after load', async () => {
    render(<LiveMap markers={[{ id: 'bus', latitude: 5.6, longitude: -0.2 }]} />);
    await waitFor(() => expect(maps.instances).toHaveLength(1));
    const map = maps.instances[0];
    act(() => map.emit('style.load'));
    expect(map.sources.has('trotxi-live-vehicles')).toBe(true);
    expect(map.sources.has('trotxi-route-draft')).toBe(true);
    act(() => map.emit('error'));
    expect(screen.getByRole('status')).toHaveTextContent('Basemap unavailable');
    expect(screen.getByLabelText('Live vehicle map')).toBeInTheDocument();
    expect(map.remove).not.toHaveBeenCalled();
  });

  it('uses an overlay-only map when flags cannot supply a basemap', async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('flags unavailable')));
    render(<LiveMap markers={[{ id: 'bus', latitude: 5.6, longitude: -0.2 }]} />);
    await waitFor(() => expect(maps.instances).toHaveLength(1));
    expect(maps.instances[0].options.style).toMatchObject({ version: 8, layers: [] });
    act(() => maps.instances[0].emit('style.load'));
    expect(maps.instances[0].sources.has('trotxi-live-vehicles')).toBe(true);
    expect(screen.getByRole('status')).toHaveTextContent('Basemap unavailable');
  });

  it('switches to overlay-only style if the configured style fails before load', async () => {
    render(<LiveMap markers={[{ id: 'bus', latitude: 5.6, longitude: -0.2 }]} />);
    await waitFor(() => expect(maps.instances).toHaveLength(1));
    const map = maps.instances[0];
    act(() => map.emit('error'));
    expect(map.setStyle).toHaveBeenCalledWith({ version: 8, sources: {}, layers: [] });
    // The original style never emits the map-lifetime `load` event after
    // failing. Its replacement still emits `style.load`.
    act(() => map.emit('style.load'));
    expect(map.sources.has('trotxi-live-vehicles')).toBe(true);
    expect(screen.getByRole('status')).toHaveTextContent('Basemap unavailable');
  });
});
