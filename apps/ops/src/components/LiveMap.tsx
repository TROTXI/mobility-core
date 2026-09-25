import * as maplibregl from 'maplibre-gl';
import type { GeoJSONSource, Map as MapLibreMap, MapLayerMouseEvent } from 'maplibre-gl';
import { Protocol } from 'pmtiles';
import { useEffect, useRef, useState } from 'react';
import 'maplibre-gl/dist/maplibre-gl.css';
import { mapStyleFromBootstrap } from '../api/map-config';

type Marker = {
  id: string;
  latitude: number;
  longitude: number;
  label?: string;
  state?: string;
};
type Point = { latitude: number; longitude: number };

const sourceId = 'trotxi-live-vehicles';
const routeSourceId = 'trotxi-route-draft';
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

function asLineGeoJson(points: Point[]) {
  return {
    type: 'FeatureCollection',
    features:
      points.length < 2
        ? []
        : [
            {
              type: 'Feature',
              geometry: {
                type: 'LineString',
                coordinates: points.map((point) => [point.longitude, point.latitude]),
              },
              properties: {},
            },
          ],
  };
}

function frameLine(instance: MapLibreMap, points: Point[]) {
  if (points.length === 1) {
    instance.jumpTo({ center: [points[0].longitude, points[0].latitude], zoom: 14 });
  } else if (points.length > 1) {
    const bounds = new maplibregl.LngLatBounds();
    for (const point of points) bounds.extend([point.longitude, point.latitude]);
    instance.fitBounds(bounds, { padding: 48, maxZoom: 15, duration: 0 });
  }
}

export function LiveMap({
  markers,
  line = [],
  onMapClick,
}: {
  markers: Marker[];
  line?: Point[];
  onMapClick?: (point: Point) => void;
}) {
  const container = useRef<HTMLDivElement>(null);
  const map = useRef<MapLibreMap | null>(null);
  const clickHandler = useRef(onMapClick);
  clickHandler.current = onMapClick;
  const currentMarkers = useRef(markers);
  currentMarkers.current = markers;
  const currentLine = useRef(line);
  currentLine.current = line;
  const [bootstrap, setBootstrap] = useState<unknown>(null);
  const [appearance, setAppearance] = useState<'dark' | 'light'>(() =>
    document.querySelector('[data-theme]')?.getAttribute('data-theme') === 'dark'
      ? 'dark'
      : 'light',
  );
  const [failed, setFailed] = useState(false);
  const styleUrl = mapStyleFromBootstrap(bootstrap, appearance);

  useEffect(() => {
    const root = document.querySelector('[data-theme]');
    if (!root) return;
    const observer = new MutationObserver(() => {
      setAppearance(root.getAttribute('data-theme') === 'dark' ? 'dark' : 'light');
    });
    observer.observe(root, { attributes: true, attributeFilter: ['data-theme'] });
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    const controller = new AbortController();
    void fetch(
      `${String(import.meta.env.VITE_API_BASE_URL ?? 'https://trotxi-api-staging.onrender.com').replace(/\/$/, '')}/flags`,
      { signal: controller.signal },
    )
      .then((response) =>
        response.ok ? response.json() : Promise.reject(new Error('map_config_unavailable')),
      )
      .then((body: unknown) => {
        // GET /flags is a public Bootstrap object, not a {data: ...} envelope.
        const style = mapStyleFromBootstrap(body, appearance);
        if (!style) throw new Error('map_style_unavailable');
        setBootstrap(body);
      })
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
      instance.addSource(routeSourceId, {
        type: 'geojson',
        data: asLineGeoJson(currentLine.current),
      });
      instance.addLayer({
        id: routeSourceId,
        type: 'line',
        source: routeSourceId,
        paint: { 'line-color': '#bc783c', 'line-width': 5, 'line-opacity': 0.9 },
      });
      instance.addSource(sourceId, { type: 'geojson', data: asGeoJson(currentMarkers.current) });
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
      instance.on('click', (event) => {
        if (instance.queryRenderedFeatures(event.point, { layers: [sourceId] }).length) return;
        clickHandler.current?.({ latitude: event.lngLat.lat, longitude: event.lngLat.lng });
      });
      frameLine(instance, currentLine.current);
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

  useEffect(() => {
    const source = map.current?.getSource(routeSourceId) as GeoJSONSource | undefined;
    source?.setData(asLineGeoJson(line));
    if (source && map.current) frameLine(map.current, line);
  }, [line]);

  if (!styleUrl || failed) return <MapFallback markers={markers} failed={failed} />;
  return (
    <div
      className="live-map"
      ref={container}
      aria-label={onMapClick ? 'Route drawing map' : 'Live vehicle map'}
    />
  );
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
