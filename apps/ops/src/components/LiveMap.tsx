import * as maplibregl from 'maplibre-gl';
import type { GeoJSONSource, Map as MapLibreMap, MapLayerMouseEvent } from 'maplibre-gl';
import { Protocol } from 'pmtiles';
import { useEffect, useRef, useState } from 'react';
import 'maplibre-gl/dist/maplibre-gl.css';

type Marker = {
  id: string;
  latitude: number;
  longitude: number;
  label?: string;
  state?: string;
};

const sourceId = 'trotxi-live-vehicles';
let protocolReady = false;

function asGeoJson(markers: Marker[]) {
  return {
    type: 'FeatureCollection',
    features: markers.map((marker) => ({
      type: 'Feature',
      id: marker.id,
      geometry: { type: 'Point', coordinates: [marker.longitude, marker.latitude] },
      properties: { label: marker.label ?? 'Vehicle', state: marker.state ?? 'live' },
    })),
  };
}

export function LiveMap({ markers }: { markers: Marker[] }) {
  const container = useRef<HTMLDivElement>(null);
  const map = useRef<MapLibreMap | null>(null);
  const [styleUrl, setStyleUrl] = useState<string | null>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    const controller = new AbortController();
    void fetch(
      `${String(import.meta.env.VITE_API_BASE_URL ?? 'https://trotxi-api-staging.onrender.com').replace(/\/$/, '')}/flags`,
      { signal: controller.signal },
    )
      .then((response) =>
        response.ok ? response.json() : Promise.reject(new Error('map_config_unavailable')),
      )
      .then((body: { data?: { mapTiles?: { styleUrl?: string | null } } }) =>
        setStyleUrl(body.data?.mapTiles?.styleUrl ?? null),
      )
      .catch((error: unknown) => {
        if (!(error instanceof DOMException && error.name === 'AbortError')) setFailed(true);
      });
    return () => controller.abort();
  }, []);

  useEffect(() => {
    if (!container.current || !styleUrl) return;
    if (!protocolReady) {
      const protocol = new Protocol();
      maplibregl.addProtocol('pmtiles', protocol.tile);
      protocolReady = true;
    }
    const instance = new maplibregl.Map({
      container: container.current,
      style: styleUrl,
      center: [-0.187, 5.6037],
      zoom: 11,
      attributionControl: false,
    });
    instance.addControl(new maplibregl.NavigationControl({ showCompass: false }), 'top-right');
    instance.addControl(new maplibregl.AttributionControl({ compact: true }), 'bottom-right');
    instance.on('load', () => {
      instance.addSource(sourceId, { type: 'geojson', data: asGeoJson(markers) });
      instance.addLayer({
        id: `${sourceId}-halo`,
        type: 'circle',
        source: sourceId,
        paint: { 'circle-radius': 12, 'circle-color': '#ffffff', 'circle-opacity': 0.9 },
      });
      instance.addLayer({
        id: sourceId,
        type: 'circle',
        source: sourceId,
        paint: {
          'circle-radius': 7,
          'circle-color': [
            'match',
            ['get', 'state'],
            'stale_gps',
            '#c2513d',
            'unassigned',
            '#c98518',
            '#3d6751',
          ],
          'circle-stroke-width': 2,
          'circle-stroke-color': '#17151b',
        },
      });
      instance.on('click', sourceId, (event: MapLayerMouseEvent) => {
        const feature = event.features?.[0];
        if (!feature || feature.geometry.type !== 'Point') return;
        new maplibregl.Popup({ offset: 12 })
          .setLngLat(feature.geometry.coordinates as [number, number])
          .setText(String(feature.properties?.label ?? 'Vehicle'))
          .addTo(instance);
      });
      instance.on('mouseenter', sourceId, () => {
        instance.getCanvas().style.cursor = 'pointer';
      });
      instance.on('mouseleave', sourceId, () => {
        instance.getCanvas().style.cursor = '';
      });
    });
    instance.on('error', () => setFailed(true));
    map.current = instance;
    return () => {
      instance.remove();
      map.current = null;
    };
  }, [styleUrl]);

  useEffect(() => {
    const source = map.current?.getSource(sourceId) as GeoJSONSource | undefined;
    source?.setData(asGeoJson(markers));
  }, [markers]);

  if (!styleUrl || failed) return <MapFallback markers={markers} failed={failed} />;
  return <div className="live-map" ref={container} aria-label="Live vehicle map" />;
}

function MapFallback({ markers, failed }: { markers: Marker[]; failed: boolean }) {
  return (
    <div className="map-placeholder">
      <div className="map-copy">
        <strong>{markers.length} buses reporting</strong>
        <div className="muted">
          {failed
            ? 'The map style could not be loaded. Live trip data remains available in the table.'
            : 'Loading the Ghana basemap…'}
        </div>
      </div>
    </div>
  );
}
