import type { PoolClient } from 'pg';
import type { Actor } from '../transport/service.js';
import { fail } from '../transport/errors.js';

/** Supplied by server handlers, never by request bodies or client headers. */
export interface AuthorizationContext {
  operation?: string;
}
export type SessionAuthorizer = (
  client: PoolClient,
  actor: Actor,
  context?: AuthorizationContext,
) => Promise<void>;

export const maintenanceOperations: ReadonlySet<string> = new Set([
  'runPersonalPauseResumes',
  'runTripGeneration',
  'runPayments',
  'runPaymentInbox',
  'runPaymentReconciliation',
  'runPeriodClose',
  'runAskDispatch',
  'runReservationDefaults',
  'runNoShows',
  'runRouteLearning',
  'runGpsRetention',
  'runAutoRenewals',
]);
export const financeOperations: ReadonlySet<string> = new Set([
  'initiateRefund',
  'resolvePaymentReview',
  'createFare',
  'updatePlanPricing',
]);

/** Call only with current DB facts locked by the session authorizer. */
export function checkOpsPermission(
  user: { role: string; is_superadmin?: boolean },
  issuedFor: string,
  operation?: string,
) {
  const maintenance = !!operation && maintenanceOperations.has(operation);
  if (issuedFor === 'maintenance') {
    if (user.role !== 'admin' || !maintenance)
      fail(403, 'worker_scope_required', 'Worker sessions can only run maintenance.');
    return;
  }
  if (maintenance || (!!operation && financeOperations.has(operation))) {
    if (user.role !== 'admin' || !user.is_superadmin)
      fail(403, 'superadmin_required', 'Only a superadmin can perform this action.');
  }
}
