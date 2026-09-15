// Schema-independent actions and fixed expectations. Never import a database adapter here.
const terms = { plan: 'monthly', price: 26400, rides: 44, fare: 600, conversionRate: 45 };
const firstAt = '2026-01-01T00:00:00.000Z';
const renewalAt = '2026-02-02T00:00:00.000Z';
const action = (kind, args = {}) => ({ action: kind, ...args });
const check = (label, expected) => ({ checkpoint: label, expected });
const rider = (name = 'riderA', credit = 0) => action('rider', { name, credit });
const buy = (purchase = 'first', owner = 'riderA', at = firstAt) =>
  action('checkout', { purchase, owner, at, terms });
const fulfill = (purchase = 'first', at = firstAt) => action('fulfill', { purchase, at });
const paid = () => [rider(), buy(), fulfill()];
const close = () => action('close', { at: renewalAt });
const refund = (status = 'processed', amount = 'full') =>
  action('refund', { purchase: 'first', identity: 'refundA', amount, status });
const dispute = (status, resolution = null) =>
  action('dispute', { purchase: 'first', identity: 'disputeA', amount: 1000, status, resolution });
const state = (periodStatus, membership, purchaseStatus = 'fulfilled') => ({
  riders: { riderA: { membership } },
  purchases: {
    first: {
      status: purchaseStatus,
      period: { status: periodStatus, owner: 'riderA', purchase: 'first' },
    },
  },
});
const once = {
  riders: { riderA: { membership: 'active', currentPurchase: 'first', rides: 44 } },
  purchases: {
    first: {
      status: 'fulfilled',
      cash: 26400,
      gross: 26400,
      creditApplied: 0,
      period: {
        purchase: 'first',
        owner: 'riderA',
        status: 'open',
        rides: 44,
        allocated: 44,
        allocations: 1,
      },
    },
  },
  totals: { purchases: 1, periods: 1, allocations: 1 },
};
const converted = {
  purchases: {
    first: {
      period: {
        status: 'closed',
        rides: 0,
        convertedRides: 44,
        conversionEffects: 1,
        conversionCredit: 1980,
      },
    },
  },
};
export const scenarios = [
  {
    id: 'PAY-01',
    category: 'storage',
    title: 'Monetary units are explicit',
    steps: [
      action('moneyMetadata'),
      check('units', {
        result: {
          cash: 'pesewas',
          gross: 'pesewas',
          appliedCredit: 'pesewas',
          fare: 'pesewas',
          conversionRate: 'pesewas',
          fees: 'pesewas',
          refunded: 'pesewas',
        },
      }),
    ],
  },
  {
    id: 'PAY-02',
    title: 'Concurrent checkouts cannot promise the same credit',
    steps: [
      rider('riderA', 1000),
      action('contend', { owner: 'riderA', actions: [buy('attemptA'), buy('attemptB')] }),
      check('one-hold', {
        result: { fulfilled: 1, rejected: 1, errors: ['pending_checkout'] },
        totals: { purchases: 1, periods: 0, heldPayments: 1 },
        riders: { riderA: { credit: 1000, held: 1000, available: 0, rides: 0 } },
      }),
    ],
  },
  {
    id: 'PAY-03',
    title: 'Duplicate successful delivery fulfils once',
    steps: [
      rider(),
      buy(),
      action('acceptSuccess', { purchase: 'first', at: firstAt, copies: 2 }),
      check('durable-before-work', {
        totals: { periods: 0, allocations: 0 },
        inbox: { received: 1, processed: 0 },
      }),
      action('raceInbox'),
      check('one-fulfilment', {
        ...once,
        result: { processed: 1, failed: 0 },
        inbox: { processed: 1, total: 1 },
      }),
    ],
  },
  {
    id: 'PAY-04',
    title: 'Renewal and scheduled close agree on conversion',
    steps: [
      ...paid(),
      action('contend', {
        owner: 'riderA',
        actions: [close(), buy('renewal', 'riderA', renewalAt)],
      }),
      check('conversion-and-hold', {
        ...converted,
        result: { fulfilled: 2, rejected: 0, errors: [] },
        purchases: {
          ...converted.purchases,
          renewal: { status: 'pending', creditApplied: 1980, cash: 24420 },
        },
        riders: { riderA: { held: 1980, available: 0 } },
        totals: { purchases: 2, periods: 1, allocations: 1 },
      }),
    ],
  },
  {
    id: 'PAY-05',
    title: 'Renewed purchase is distinct and current',
    steps: [
      ...paid(),
      buy('renewal', 'riderA', renewalAt),
      fulfill('renewal', renewalAt),
      fulfill('renewal', renewalAt),
      check('renewal-identity', {
        result: 'already_fulfilled',
        ...converted,
        riders: {
          riderA: {
            membership: 'active',
            currentPurchase: 'renewal',
            rides: 44,
            credit: 0,
            held: 0,
          },
        },
        purchases: {
          ...converted.purchases,
          renewal: {
            status: 'fulfilled',
            creditApplied: 1980,
            period: {
              purchase: 'renewal',
              owner: 'riderA',
              status: 'open',
              allocated: 44,
              allocations: 1,
              rides: 44,
            },
          },
        },
        totals: { purchases: 2, periods: 2, distinctLinkedPeriods: 2, allocations: 2 },
      }),
    ],
  },
  {
    id: 'PAY-06',
    title: 'Concurrent close workers convert once',
    steps: [
      ...paid(),
      action('contend', { owner: 'riderA', actions: [close(), close()] }),
      check('one-conversion', {
        ...converted,
        result: { fulfilled: 2, rejected: 0, errors: [] },
        riders: { riderA: { credit: 1980, rides: 0 } },
      }),
    ],
  },
  {
    id: 'PAY-07',
    title: 'Inclusive end boundary; no rides means no credit',
    steps: [
      ...paid(),
      action('consume', { purchase: 'first', rides: 44 }),
      action('closeAtBoundary', { purchase: 'first', offsetMs: -1 }),
      check('before-end', state('open', 'active')),
      action('closeAtBoundary', { purchase: 'first', offsetMs: 0 }),
      check('at-end', {
        ...state('closed', 'expired'),
        riders: { riderA: { credit: 0, rides: 0 } },
        purchases: {
          first: {
            period: {
              status: 'closed',
              convertedRides: 0,
              conversionCredit: 0,
              conversionEffects: 0,
              closeRides: 0,
              closeCredit: 0,
            },
          },
        },
      }),
    ],
  },
  {
    id: 'PAY-08',
    title: 'Malformed period rolls back; later valid period still closes',
    steps: [
      ...paid(),
      rider('riderB'),
      buy('valid', 'riderB', '2026-01-02T00:00:00.000Z'),
      fulfill('valid', '2026-01-02T00:00:00.000Z'),
      action('malformRate', { purchase: 'first' }),
      close(),
      check('isolated-failure', {
        result: {
          considered: 2,
          closed: 1,
          blocked: 0,
          failed: 1,
          failures: [{ purchase: 'first', reason: 'missing_conversion_rate' }],
        },
        riders: {
          riderA: { membership: 'active', credit: 0, rides: 44 },
          riderB: { membership: 'expired', credit: 1980 },
        },
        purchases: {
          first: {
            period: { status: 'open', closeRides: null, closeCredit: null, conversionEffects: 0 },
          },
          valid: {
            period: { status: 'closed', closeRides: 44, closeCredit: 1980, conversionEffects: 1 },
          },
        },
      }),
    ],
  },
  {
    id: 'PAY-09',
    title: 'Unsettled funded reservations block close and renewal',
    steps: [
      ...paid(),
      action('reserve', { purchase: 'first' }),
      close(),
      check('blocked-close', {
        ...state('open', 'active'),
        result: { blocked: 1, closed: 0 },
        riders: { riderA: { credit: 0, rides: 44 } },
      }),
      action('expectRejection', { operation: buy('renewal', 'riderA', renewalAt) }),
      check('blocked-renewal', {
        result: 'period_close_blocked',
        totals: { purchases: 1, periods: 1 },
      }),
    ],
  },
  {
    id: 'PAY-10',
    title: 'Verification recovers a missing callback',
    steps: [
      rider(),
      buy(),
      action('reconcile', { purchase: 'first', at: firstAt }),
      check('verified', {
        ...once,
        result: { considered: 1, fulfilled: 1, failed: 0, errors: 0 },
        inbox: { total: 0 },
      }),
    ],
  },
  {
    id: 'PAY-11',
    title: 'Concurrent full refund reverses once and restores captured credit',
    steps: [
      rider('riderA', 1000),
      buy(),
      fulfill(),
      action('contend', { owner: 'riderA', actions: [refund(), refund()] }),
      check('refunded-once', {
        ...state('reversed', 'expired', 'refunded'),
        riders: { riderA: { rides: 0, credit: 1000, held: 0 } },
        purchases: {
          first: {
            status: 'refunded',
            refunded: 25400,
            refundEffects: 1,
            creditApplied: 1000,
            period: { status: 'reversed', rides: 0 },
          },
        },
        totals: { reviews: 0 },
      }),
    ],
  },
  {
    id: 'PAY-12',
    title: 'Declined dispute removes its freeze',
    steps: [
      ...paid(),
      dispute('created'),
      check('frozen', state('frozen', 'suspended', 'disputed')),
      dispute('resolved', 'declined'),
      dispute('resolved', 'declined'),
      check('restored', {
        ...once,
        purchases: {
          first: { status: 'fulfilled', disputeEffects: 1, period: { status: 'open', rides: 44 } },
        },
      }),
    ],
  },
  {
    id: 'PAY-13',
    title: 'Accepted partial dispute waits for covering refund',
    steps: [
      ...paid(),
      dispute('resolved', 'merchant-accepted'),
      check('await-refund', {
        ...state('frozen', 'suspended', 'disputed'),
        purchases: { first: { refunded: 0, period: { status: 'frozen', rides: 44 } } },
      }),
      refund('processed', 1000),
      check('partial-restored', {
        ...state('open', 'active'),
        purchases: {
          first: { status: 'fulfilled', refunded: 1000, period: { status: 'open', rides: 44 } },
        },
      }),
    ],
  },
  {
    id: 'PAY-14',
    title: 'Consumed value requires review without negative rides',
    steps: [
      ...paid(),
      action('consume', { purchase: 'first', rides: 10 }),
      refund(),
      check('consumed-review', {
        ...state('reversed', 'expired', 'refunded'),
        purchases: {
          first: {
            refunded: 26400,
            period: { rides: 0, consumed: 10 },
            review: { consumed: 10, unrecoveredCredit: 0, estimate: 6000 },
          },
        },
        totals: { reviews: 1 },
        opsReviews: [{ purchase: 'first', kind: 'manual_review', status: 'open', amount: 6000 }],
      }),
    ],
  },
  {
    id: 'PAY-15',
    title: 'Conversion is not consumption; available conversion credit is recovered',
    steps: [
      ...paid(),
      close(),
      check('converted', converted),
      refund(),
      check('clawed-back', {
        ...state('reversed', 'expired', 'refunded'),
        riders: { riderA: { rides: 0, credit: 0 } },
        purchases: { first: { period: { rides: 0, consumed: 0 }, review: null } },
        totals: { reviews: 0 },
      }),
    ],
  },
  {
    id: 'PAY-16',
    title: 'Older provider events do not regress known states',
    steps: [
      ...paid(),
      refund('failed', 1000),
      refund('pending', 1000),
      dispute('reminded'),
      dispute('created'),
      check('monotonic', {
        purchases: { first: { refundEffects: 1, disputeEffects: 1, refunded: 0 } },
        opsReviews: [
          { purchase: 'first', kind: 'dispute', status: 'reminded', amount: 1000 },
          { purchase: 'first', kind: 'refund', status: 'failed', amount: 1000 },
        ],
      }),
    ],
  },
];

export const supplemental = [
  {
    id: 'REC-01',
    title: 'Interrupted fulfilment after allocation rolls back and inbox retries',
    steps: [
      rider('riderA', 1000),
      buy(),
      action('acceptSuccess', { purchase: 'first', at: firstAt }),
      action('terminateAfterAllocation'),
      action('processInbox'),
      check('rollback', {
        result: { processed: 0, failed: 1 },
        totals: { periods: 0, allocations: 0 },
        riders: { riderA: { credit: 1000, held: 1000, rides: 0 } },
        purchases: { first: { status: 'pending' } },
        inbox: { failed: 1 },
      }),
      action('restartWorker'),
      action('processInbox'),
      check('recovered', {
        result: { processed: 1, failed: 0 },
        totals: { periods: 1, allocations: 1 },
        riders: { riderA: { credit: 0, held: 0, rides: 44 } },
        inbox: { processed: 1 },
      }),
    ],
  },
  {
    id: 'REC-02',
    title: 'Committed fulfilment survives missing acknowledgement',
    steps: [
      rider(),
      buy(),
      action('acceptSuccess', { purchase: 'first', at: firstAt }),
      action('failAcknowledgement'),
      action('processInbox'),
      check('committed-before-ack', {
        ...once,
        inbox: { failed: 1 },
        result: { failed: 1, processed: 0 },
      }),
      action('restartWorker'),
      action('processInbox'),
      check('replayed-without-value', {
        ...once,
        inbox: { processed: 1 },
        result: { failed: 0, processed: 1 },
      }),
    ],
  },
  {
    id: 'REC-03',
    title: 'Durable claimed inbox waits for lease expiry then recovers',
    steps: [
      rider(),
      buy(),
      action('acceptSuccess', { purchase: 'first', at: firstAt }),
      action('claimOnly'),
      action('restartWorker'),
      action('processInbox'),
      check('lease-live', {
        inbox: { processing: 1 },
        totals: { periods: 0, allocations: 0 },
        result: { processed: 0, failed: 0 },
      }),
      action('expireLease'),
      action('processInbox'),
      check('lease-recovered', {
        ...once,
        inbox: { processed: 1 },
        result: { processed: 1, failed: 0 },
      }),
    ],
  },
  {
    id: 'REC-04',
    title: 'Refund cannot steal conversion credit held by renewal',
    steps: [
      ...paid(),
      buy('renewal', 'riderA', renewalAt),
      refund(),
      check('hold-preserved', {
        riders: { riderA: { credit: 1980, held: 1980, available: 0 } },
        purchases: {
          first: {
            period: { status: 'reversed', consumed: 0 },
            review: { consumed: 0, unrecoveredCredit: 1980, estimate: 1980 },
          },
          renewal: { status: 'pending', creditApplied: 1980 },
        },
      }),
      fulfill('renewal', renewalAt),
      check('renewal-not-shortchanged', {
        riders: {
          riderA: {
            credit: 0,
            held: 0,
            rides: 44,
            membership: 'active',
            currentPurchase: 'renewal',
          },
        },
        totals: { allocations: 2, periods: 2 },
      }),
    ],
  },
];

export const negativeControls = [
  {
    id: 'NEG-ARITHMETIC',
    scenario: 'PAY-03',
    checkpoint: 'one-fulfilment',
    mutation: 'double_allocation',
    expectedPath: '$.riders.riderA.rides',
  },
  {
    id: 'NEG-ATTRIBUTION',
    scenario: 'PAY-05',
    checkpoint: 'renewal-identity',
    mutation: 'wrong_current_purchase',
    expectedPath: '$.riders.riderA.currentPurchase',
  },
];
