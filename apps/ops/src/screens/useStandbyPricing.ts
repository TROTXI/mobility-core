import { useAuth } from '../auth/AuthContext';
import { opsHeaders } from '../api/session';
import { useQuery } from '../hooks/useQuery';
import { pricingPages } from './standby-offers';

export function useStandbyPricing(routeId?: string) {
  const { session } = useAuth();
  return useQuery(
    async (signal) => {
      if (!routeId) return null;
      const [fares, schedules] = await Promise.all([
        pricingPages(async (cursor) => {
          const r = await session.client.GET('/v1/ops/routes/{id}/fares', {
            params: { path: { id: routeId }, header: opsHeaders, query: { limit: 200, cursor } },
            signal,
          });
          if (r.error) throw new Error(r.error.error.message);
          return r.data;
        }),
        pricingPages(async (cursor) => {
          const r = await session.client.GET('/v1/ops/service-schedules', {
            params: { header: opsHeaders, query: { routeId, limit: 200, cursor } },
            signal,
          });
          if (r.error) throw new Error(r.error.error.message);
          return r.data;
        }),
      ]);
      return { routeId, fares, schedules };
    },
    [session, routeId],
  );
}
