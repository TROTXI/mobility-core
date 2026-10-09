import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { opsHeaders } from '../api/session';
import { useQuery } from '../hooks/useQuery';
import { ErrorState } from '../components/Page';

export type FareJourney = {
  patternVersionId: string;
  pickupOccurrenceId: string;
  dropoffOccurrenceId: string;
};
type Pattern = components['schemas']['Pattern'];
type Version = components['schemas']['PatternVersion'];

/** Occurrences, not stop IDs: a route may visit the same physical stop twice. */
export function FareJourneyFields({
  patterns,
  value,
  onChange,
}: {
  patterns: Pattern[];
  value: FareJourney | null;
  onChange: (value: FareJourney | null) => void;
}) {
  const { session } = useAuth();
  const [patternId, setPatternId] = useState('');
  const versions = useQuery<Version[]>(
    async (signal) => {
      if (!patternId) return [];
      const response = await session.client.GET('/v1/ops/route-patterns/{id}/versions', {
        params: { path: { id: patternId }, query: { limit: 200 }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data.filter((version) => version.state === 'published');
    },
    [session, patternId],
  );
  const detail = useQuery<Version | null>(
    async (signal) => {
      if (!patternId || !value?.patternVersionId) return null;
      const response = await session.client.GET(
        '/v1/ops/route-patterns/{id}/versions/{versionId}',
        {
          params: {
            path: { id: patternId, versionId: value.patternVersionId },
            header: opsHeaders,
          },
          signal,
        },
      );
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session, patternId, value?.patternVersionId],
  );
  const stops = detail.data?.id === value?.patternVersionId ? (detail.data?.stops ?? []) : [];
  const pickupIndex = stops.findIndex((stop) => stop.id === value?.pickupOccurrenceId);
  return (
    <>
      <label>
        Direction
        <select
          required
          value={patternId}
          onChange={(event) => {
            setPatternId(event.target.value);
            onChange(null);
          }}
        >
          <option value="">Choose direction</option>
          {patterns.map((pattern) => (
            <option key={pattern.id} value={pattern.id}>
              {pattern.direction}
            </option>
          ))}
        </select>
      </label>
      {versions.error && <ErrorState message={versions.error} retry={versions.retry} />}
      <label>
        Published route version
        <select
          required
          disabled={versions.loading || !patternId}
          value={value?.patternVersionId ?? ''}
          onChange={(event) =>
            onChange({
              patternVersionId: event.target.value,
              pickupOccurrenceId: '',
              dropoffOccurrenceId: '',
            })
          }
        >
          <option value="">Choose version</option>
          {versions.data?.map((version) => (
            <option key={version.id} value={version.id}>
              {version.id.slice(0, 8)} ({version.stops.length} stops)
            </option>
          ))}
        </select>
      </label>
      {detail.error && <ErrorState message={detail.error} retry={detail.retry} />}
      <label>
        Pickup
        <select
          required
          disabled={detail.loading || !stops.length}
          value={value?.pickupOccurrenceId ?? ''}
          onChange={(event) =>
            value &&
            onChange({ ...value, pickupOccurrenceId: event.target.value, dropoffOccurrenceId: '' })
          }
        >
          <option value="">Choose pickup</option>
          {stops.slice(0, -1).map((stop, index) => (
            <option key={stop.id} value={stop.id}>
              {index + 1}. {stop.name}
            </option>
          ))}
        </select>
      </label>
      <label>
        Drop-off
        <select
          required
          disabled={detail.loading || pickupIndex < 0}
          value={value?.dropoffOccurrenceId ?? ''}
          onChange={(event) =>
            value && onChange({ ...value, dropoffOccurrenceId: event.target.value })
          }
        >
          <option value="">Choose drop-off</option>
          {pickupIndex >= 0 &&
            stops.slice(pickupIndex + 1).map((stop, index) => (
              <option key={stop.id} value={stop.id}>
                {pickupIndex + index + 2}. {stop.name}
              </option>
            ))}
        </select>
      </label>
      <p className="dialog-note">
        This is the fare for the complete selected journey, not an individual segment to add to
        other fares. Return fares are configured separately.
      </p>
    </>
  );
}
