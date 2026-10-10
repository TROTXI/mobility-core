import { test } from 'node:test';
import assert from 'node:assert/strict';
import contract from '../src/http/contract.json' with { type: 'json' };
import { JOBS } from '../src/runtime/maintenance.js';

// A new privileged mutation must name its existing durable evidence here.
// Domain receipts remain in their own tables; maintenance is the only new
// cross-domain run record. See docs/design/ops-audit-coverage.md.
const evidence = {
  ops_team_events: [
    'inviteOperator',
    'resendOperatorInvitation',
    'cancelOperatorInvitation',
    'updateOperatorAccess',
    'eraseCommuter',
  ],
  admin_passkey_events: ['resetOperatorPasskeys'],
  refund_initiations: ['initiateRefund'],
  catalog_events: [
    'createRoute',
    'updateRoute',
    'createStop',
    'updateStop',
    'createPattern',
    'createPatternVersion',
    'publishPatternVersion',
  ],
  fleet_events: ['createVehicle', 'updateVehicle', 'decideIncident', 'decideDriverRequest'],
  driver_events: [
    'createDriver',
    'updateDriver',
    'issueDriverCredential',
    'resetDriverPin',
    'changeCredentialState',
  ],
  trip_events: ['createTrip', 'rescheduleTrip', 'assignTrip', 'cancelTrip'],
  schedule_events: ['createSchedule'],
  membership_events: [
    'createCommuteSlot',
    'retireCommuteSlot',
    'decideCommuteRequest',
    'createAccountRestriction',
    'releaseAccountRestriction',
  ],
  pricing_events: ['createFare', 'updatePlanPricing'],
  config_events: ['changeRole', 'setFlag', 'setMinimumVersion'],
  payment_review_commands: ['resolvePaymentReview'],
  standby_events: ['offerStandby'],
  gps_events: ['createTraceHold', 'releaseTraceHold'],
  maintenance_run_starts: [
    'runPersonalPauseResumes',
    'runPayments',
    'runPaymentInbox',
    'runPaymentReconciliation',
    'runPeriodClose',
    'runAskDispatch',
    'runReservationDefaults',
    'runNoShows',
    'runRouteLearning',
    'runGpsRetention',
    'runTripGeneration',
    'runAutoRenewals',
  ],
} as const;

test('every published Ops mutation has a named durable audit source', () => {
  const published = Object.entries(contract.paths).flatMap(([path, methods]) =>
    path.startsWith('/v1/ops/')
      ? Object.entries(methods)
          .filter(([method]) => ['post', 'put', 'patch', 'delete'].includes(method))
          .map(([, operation]) => operation.operationId)
      : [],
  );
  const registered = Object.values(evidence).flat();
  assert.equal(new Set(registered).size, registered.length, 'duplicate audit registration');
  assert.deepEqual(registered.sort(), published.sort());
});

test('every scheduler job is covered by the worker run recorder', () => {
  assert.deepEqual(
    [...JOBS].sort(),
    [
      'admission',
      'ask-dispatch',
      'auto-renewals',
      'driver-secrets',
      'emails',
      'erasures',
      'gps-retention',
      'incident-retention',
      'no-shows',
      'payments',
      'payment-evidence-retention',
      'personal-pause-resumes',
      'push',
      'reservation-defaults',
      'route-learning',
      'trip-generation',
    ].sort(),
  );
});
