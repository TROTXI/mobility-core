// DESIGN CONTRACT ONLY. Not imported by the application or served on staging.
// Zod is authoritative for these proposed fields; build-contract.mjs emits OpenAPI.
import { z } from '../../../services/api/node_modules/zod/index.js';

export const registry = z.registry();
export const schemas = {};
const named = (name, schema) => {
  registry.add(schema, { id: name });
  schemas[name] = schema;
  return schema;
};
const obj = (properties) => z.strictObject(properties);
const text = (max = 200) => z.string().min(1).max(max);
const id = text(128);
const instant = z.iso.datetime();
const date = z.iso.date();
const time = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/);
const count = z.int().nonnegative();
const money = named('Money', obj({ amountMinor: count, currency: z.literal('GHS') }));
const point = named(
  'Point',
  obj({ latitude: z.number().min(-90).max(90), longitude: z.number().min(-180).max(180) }),
);
const plan = z.enum(['monthly', 'annual']);
const direction = z.enum(['outbound', 'return']);
const periodState = z.enum(['open', 'closed', 'reversed']);
const tripState = z.enum(['scheduled', 'active', 'completed', 'cancelled']);
const role = z.enum(['commuter', 'driver', 'admin']);
const note = z.string().max(2000);
const version = count;
const audit = { createdAt: instant, updatedAt: instant, version };

named(
  'ErrorResponse',
  obj({
    error: obj({
      code: text(100),
      message: text(500),
      requestId: id,
      fieldErrors: z.array(obj({ field: text(), code: text() })).optional(),
    }),
  }),
);
named('Health', obj({ status: z.enum(['ok', 'unavailable']) }));
named('Build', obj({ service: text(), version: text(), commit: text() }));
named('Root', obj({ docs: text(), health: text() }));
named(
  'Bootstrap',
  obj({
    serverTime: instant,
    applications: z.array(
      obj({
        app: z.enum(['commuter', 'driver']),
        platform: z.enum(['ios', 'android']),
        minSupportedBuild: count,
        storeUrl: z.url().nullable(),
        apiMajor: z.literal(1),
      }),
    ),
    operations: obj({
      phone: text().nullable(),
      whatsapp: text().nullable(),
      email: text().nullable(),
      hours: text().nullable(),
    }),
    mapTiles: obj({
      url: z.url().nullable(),
      styleUrl: z.url().nullable(),
      darkStyleUrl: z.url().nullable(),
      attribution: text(1000),
    }),
    flags: z.array(
      obj({ key: text(), enabled: z.boolean(), rolloutPercentage: z.number().min(0).max(100) }),
    ),
  }),
);
named(
  'Account',
  obj({
    id,
    displayName: text(),
    phone: text().nullable(),
    avatarUrl: z.url().nullable(),
    role,
    createdAt: instant,
  }),
);
named('ProfileUpdate', obj({ displayName: text(100) }));
named('Avatar', obj({ url: z.url(), expiresAt: instant }));
named('AvatarUpload', obj({ file: z.string().meta({ format: 'binary' }) }));
named('Session', obj({ id, createdAt: instant, expiresAt: instant, current: z.boolean() }));
named('DeviceInput', obj({ token: text(4096), platform: z.enum(['ios', 'android']) }));
named('Device', obj({ id, platform: z.enum(['ios', 'android']), updatedAt: instant }));
named('GoogleSignIn', obj({ idToken: text(8192) }));
named(
  'AppleSignIn',
  obj({
    idToken: text(8192),
    nonce: text(256).optional(),
    authorizationCode: text(4096).optional(),
    displayName: text(100).optional(),
  }),
);
named(
  'DriverSignIn',
  obj({ code: text(32), pin: z.string().regex(/^\d{6}$/), ownDevice: z.boolean() }),
);
named('RefreshInput', obj({ refreshToken: text(4096) }));
named(
  'Tokens',
  obj({
    accessToken: text(8192),
    refreshToken: text(4096),
    accessExpiresAt: instant,
    refreshExpiresAt: instant,
    account: schemas.Account,
  }),
);
named(
  'DriverTokens',
  schemas.Tokens.extend({ driver: obj({ id, name: text() }), mustChangePin: z.boolean() }),
);
named(
  'PinChange',
  obj({ currentPin: z.string().regex(/^\d{6}$/), newPin: z.string().regex(/^\d{6}$/) }),
);

named(
  'Route',
  obj({
    id,
    name: text(),
    description: note.nullable(),
    patternIds: z.array(id),
    acceptsDriverRequests: z.boolean(),
    archived: z.boolean(),
    editToken: text(128),
    ...audit,
  }),
);
named(
  'RouteInput',
  obj({
    name: text(),
    description: note.optional(),
    acceptsDriverRequests: z.boolean().default(false),
  }),
);
named(
  'RouteEdit',
  obj({
    name: text().optional(),
    description: note.nullable().optional(),
    acceptsDriverRequests: z.boolean().optional(),
    archived: z.boolean().optional(),
  }),
);
named(
  'Stop',
  obj({ id, name: text(), location: point, archived: z.boolean(), editToken: text(128), ...audit }),
);
named('StopInput', obj({ name: text(), location: point }));
named(
  'StopEdit',
  obj({ name: text().optional(), location: point.optional(), archived: z.boolean().optional() }),
);
named('Pattern', obj({ id, routeId: id, direction, publishedVersionId: id.nullable(), ...audit }));
named('PatternInput', obj({ routeId: id, direction }));
named('StopOccurrence', obj({ id, stopId: id, ordinal: count, name: text(), location: point }));
named(
  'PatternVersion',
  obj({
    id,
    patternId: id,
    revision: z.int().min(1),
    state: z.enum(['draft', 'published', 'retired']),
    effectiveFrom: instant.nullable(),
    effectiveTo: instant.nullable(),
    stops: z.array(schemas.StopOccurrence).min(2),
    geometryId: id.nullable(),
    editToken: text(128),
    ...audit,
  }),
);
named(
  'PatternVersionInput',
  obj({
    stops: z
      .array(obj({ stopId: id, name: text(), location: point }))
      .min(2)
      .max(500),
    // Configured road geometry, not straight lines guessed between stops. The
    // positional distance array maps to the request's ordered stop occurrences,
    // whose UUIDs do not exist until this atomic command succeeds.
    geometry: obj({
      points: z.array(point).min(2).max(10000),
      stopDistancesMeters: z.array(z.number().nonnegative()).min(2).max(500),
    }),
  }),
);
named('PublishVersionInput', obj({ reason: note, effectiveFrom: instant }));
named(
  'Geometry',
  obj({
    id,
    patternVersionId: id,
    points: z.array(point),
    stopDistances: z.array(obj({ stopOccurrenceId: id, distanceMeters: z.number().nonnegative() })),
    source: z.enum(['observed', 'configured']),
    createdAt: instant,
  }),
);
named(
  'Schedule',
  obj({
    id,
    departureId: id,
    patternId: id,
    patternVersionId: id,
    serviceWindow: z.enum(['morning', 'evening']),
    localDeparture: time,
    timeZone: z.literal('Africa/Accra'),
    weekdays: z.array(z.int().min(1).max(7)),
    effectiveFrom: date,
    effectiveTo: date.nullable(),
    ...audit,
  }),
);
named(
  'ScheduleInput',
  obj({
    departure: z.discriminatedUnion('kind', [
      obj({ kind: z.literal('new') }),
      obj({ kind: z.literal('existing'), departureId: id }),
    ]),
    patternVersionId: id,
    serviceWindow: z.enum(['morning', 'evening']),
    localDeparture: time,
    timeZone: z.literal('Africa/Accra'),
    weekdays: z.array(z.int().min(1).max(7)).min(1).max(7),
    effectiveFrom: date,
    effectiveTo: date.nullable(),
  }),
);
named(
  'CommuteLeg',
  obj({
    direction,
    scheduleId: id,
    patternVersionId: id,
    pickupOccurrenceId: id,
    dropoffOccurrenceId: id,
  }),
);
named(
  'CommuteLegView',
  schemas.CommuteLeg.extend({
    localDeparture: time,
    timeZone: z.literal('Africa/Accra'),
    pickupName: text(),
    dropoffName: text(),
  }),
);
named(
  'CommuteAssignment',
  obj({
    id,
    routeId: id,
    routeName: text(),
    effectiveFrom: date,
    effectiveTo: date.nullable(),
    legs: z.array(schemas.CommuteLegView).length(2),
  }),
);
named(
  'AccessBlock',
  obj({
    kind: z.enum(['paused', 'dispute', 'ops_restriction']),
    scope: z.enum(['period', 'account']),
    periodId: id.nullable(),
  }),
);
named(
  'Coverage',
  obj({
    id,
    startsAt: instant,
    endsAt: instant.nullable(),
    state: periodState,
    paused: z.boolean(),
    renewalMode: z.literal('manual'),
  }),
);
named(
  'Membership',
  obj({
    membership: obj({ id, lifecycle: z.enum(['open', 'ended']) }).nullable(),
    coverage: schemas.Coverage.nullable(),
    lastCoverageEndedAt: instant.nullable(),
    access: obj({ canReserve: z.boolean(), blocks: z.array(schemas.AccessBlock) }),
    commute: schemas.CommuteAssignment.nullable(),
    entitlements: obj({
      remainingRides: count,
      credit: money,
      heldCredit: money,
      availableCredit: money,
    }),
  }),
);
named(
  'BillingPeriod',
  obj({
    id,
    purchaseId: id,
    startsAt: instant,
    originalEndsAt: instant,
    effectiveEndsAt: instant.nullable(),
    state: periodState,
    paused: z.boolean(),
    ridesGranted: count,
    ridesRemaining: count,
    blocks: z.array(schemas.AccessBlock),
  }),
);
named(
  'PurchaseInput',
  obj({ plan, routeId: id, legs: z.array(schemas.CommuteLeg).length(2), useCredit: z.boolean() }),
);
named(
  'Purchase',
  obj({
    id,
    plan,
    state: z.enum([
      'awaiting_payment',
      'processing',
      'fulfilled',
      'failed',
      'cancelled',
      'review_required',
    ]),
    collectionState: z.enum(['pending', 'successful', 'failed', 'unknown']),
    price: money,
    appliedCredit: money,
    cashDue: money,
    checkout: obj({ url: z.url(), expiresAt: instant.nullable() }).nullable(),
    billingPeriodId: id.nullable(),
    failureCode: text().nullable(),
    createdAt: instant,
  }),
);
named(
  'RideEntry',
  obj({
    id,
    deltaRides: z.int(),
    reason: z.enum(['allocation', 'boarding', 'no_show', 'returned', 'refund', 'converted']),
    billingPeriodId: id,
    createdAt: instant,
  }),
);
named(
  'CreditEntry',
  obj({
    id,
    deltaMinor: z.int(),
    currency: z.literal('GHS'),
    reason: z.enum([
      'month_end_conversion',
      'purchase_applied',
      'refund_restored',
      'conversion_reversed',
      'adjustment',
    ]),
    createdAt: instant,
  }),
);
named(
  'CommuteRequestInput',
  obj({
    routeId: id,
    legs: z.array(schemas.CommuteLeg).length(2),
    requestedDate: date,
    pauseIfWaitlisted: z.boolean().default(false),
    note: note.optional(),
  }),
);
named(
  'CommuteRequest',
  obj({
    id,
    status: z.enum(['submitted', 'waitlisted', 'approved', 'applied', 'rejected', 'cancelled']),
    requested: schemas.CommuteRequestInput,
    effectiveDate: date.nullable(),
    paused: z.boolean(),
    decisionNote: note.nullable(),
    ...audit,
  }),
);
named('DecisionEvent', obj({ id, action: text(), note: note.nullable(), occurredAt: instant }));
named(
  'CommuteDecision',
  z.discriminatedUnion('action', [
    obj({ action: z.literal('approve'), slotId: id, effectiveDate: date, note }),
    ...['waitlist', 'pause', 'resume', 'apply', 'cancel', 'reject'].map((action) =>
      obj({ action: z.literal(action), note }),
    ),
  ]),
);
named(
  'CommuteSlotInput',
  obj({ routeId: id, legs: z.array(schemas.CommuteLeg).length(2), availableFrom: date }),
);
named(
  'CommuteSlot',
  schemas.CommuteSlotInput.extend({
    id,
    editToken: text(128),
    state: z.enum(['available', 'held', 'assigned', 'retired']),
    ...audit,
  }),
);
named(
  'Reservation',
  obj({
    id,
    tripId: id.nullable(),
    travelDate: date,
    direction,
    status: z.enum([
      'pending',
      'reserved',
      'declined',
      'unseated',
      'boarded',
      'no_show',
      'operator_cancelled',
    ]),
    pickupOccurrenceId: id.nullable(),
    dropoffOccurrenceId: id.nullable(),
    source: z.enum(['confirmation', 'default']),
    ...audit,
  }),
);
named(
  'ReservationDecision',
  obj({
    travelDate: date,
    direction,
    decision: z.enum(['confirm', 'decline']),
    tripId: id.optional(),
  }),
);
named(
  'Pass',
  obj({
    reservationId: id,
    tripId: id,
    qrToken: text(4096),
    expiresAt: instant,
    boardingCode: z.string().regex(/^[A-Z2-9]{4}$/),
  }),
);
named(
  'ReservationDecisionResult',
  obj({ reservation: schemas.Reservation, pass: schemas.Pass.nullable() }),
);

named(
  'Trip',
  obj({
    id,
    departureId: id,
    serviceDate: date,
    runNumber: z.literal(1),
    routeId: id,
    patternId: id,
    patternVersionId: id,
    direction,
    scheduledAt: instant,
    status: tripState,
    vehicleLabel: text().nullable(),
  }),
);
named(
  'DriverTrip',
  schemas.Trip.extend({
    startedAt: instant.nullable(),
    completedAt: instant.nullable(),
    currentStopOccurrenceId: id.nullable(),
    stops: z.array(schemas.StopOccurrence),
    version,
    editToken: text(128),
  }),
);
named(
  'OpsTrip',
  schemas.DriverTrip.extend({
    scheduleId: id,
    assignedDriverId: id.nullable(),
    vehicleId: id.nullable(),
  }),
);
named(
  'TripInput',
  obj({
    scheduleId: id,
    serviceDate: date,
    // Optional on the wire as well as at runtime; emitted OpenAPI must not
    // require a property whose omission is deliberately defaulted by Zod.
    runNumber: z.literal(1).default(1).optional(),
    scheduledAt: instant,
  }),
);
named('TripEdit', obj({ scheduledAt: instant }));
named('TripAssignment', obj({ driverId: id.nullable(), vehicleId: id.nullable() }));
named('ReasonInput', obj({ reason: note }));
named('ArrivalInput', obj({ stopOccurrenceId: id, correction: z.boolean().default(false) }));
named(
  'PositionInput',
  obj({
    clientFixId: z.uuid(),
    capturedAt: instant,
    latitude: point.shape.latitude,
    longitude: point.shape.longitude,
    accuracyMeters: z.number().nonnegative().optional(),
  }),
);
named(
  'PositionReceipt',
  obj({
    clientFixId: z.uuid(),
    receivedAt: instant,
    capturedAt: instant,
    effectiveCapturedAt: instant,
    acceptedForLive: z.boolean(),
    clockAdjusted: z.boolean(),
  }),
);
named(
  'StopEta',
  obj({
    stopOccurrenceId: id,
    durationSeconds: count,
    distanceMeters: z.number().nonnegative(),
    basis: z.enum(['observed', 'fallback']),
  }),
);
named(
  'LiveTrip',
  obj({
    tripId: id,
    patternVersionId: id,
    geometryId: id.nullable(),
    riderPickupOccurrenceId: id.nullable(),
    state: z.enum(['not_started', 'awaiting_fix', 'live', 'stale', 'ended']),
    position: obj({
      location: point,
      capturedAt: instant,
      receivedAt: instant,
      ageSeconds: count,
    }).nullable(),
    etas: z.array(schemas.StopEta),
    serverTime: instant,
  }),
);
named(
  'ManifestRider',
  obj({
    reservationId: id,
    displayName: text(),
    avatarUrl: z.url().nullable(),
    status: schemas.Reservation.shape.status,
    pickupOccurrenceId: id,
    dropoffOccurrenceId: id,
  }),
);
named(
  'Manifest',
  obj({
    tripId: id,
    revision: id,
    generatedAt: instant,
    expiresAt: instant,
    complete: z.literal(true),
    riders: z.array(schemas.ManifestRider).max(500),
  }),
);
named(
  'BoardingInput',
  z.discriminatedUnion('kind', [
    obj({ kind: z.literal('qr'), token: text(4096) }),
    obj({ kind: z.literal('code'), code: z.string().regex(/^[A-Za-z2-9]{4}$/) }),
    obj({ kind: z.literal('photo'), reservationId: id }),
  ]),
);
named(
  'BoardingResult',
  obj({
    reservationId: id,
    status: z.enum(['boarded', 'no_show']),
    alreadyApplied: z.boolean(),
    chargedRides: z.int().min(0).max(1),
  }),
);
named(
  'TripSummary',
  obj({
    tripId: id,
    status: tripState,
    boarded: count,
    noShows: count,
    unseated: count,
    scanned: count,
    codeVerified: count,
    photoVerified: count,
  }),
);
named(
  'IncidentInput',
  obj({
    tripId: id.optional(),
    category: z.enum(['vehicle', 'collision', 'passenger_safety', 'route_blocked', 'other']),
    note: note.optional(),
    location: point.optional(),
  }),
);
named(
  'Incident',
  obj({
    id,
    tripId: id.nullable(),
    vehicleId: id.nullable(),
    category: schemas.IncidentInput.shape.category,
    note: note.nullable(),
    location: point.nullable(),
    status: z.enum(['open', 'acknowledged', 'resolved']),
    resolution: note.nullable(),
    createdAt: instant,
  }),
);
named('IncidentDecision', obj({ status: z.enum(['acknowledged', 'resolved']), resolution: note }));
named(
  'WorkRequestInput',
  z.discriminatedUnion('kind', [
    obj({
      kind: z.literal('route_change'),
      routeId: id,
      fromDate: date.optional(),
      note: note.optional(),
    }),
    obj({ kind: z.literal('leave'), fromDate: date, toDate: date, note: note.optional() }),
  ]),
);
named(
  'WorkRequest',
  obj({
    id,
    request: schemas.WorkRequestInput,
    status: z.enum(['pending', 'approved', 'declined', 'withdrawn']),
    decisionNote: note.nullable(),
    ...audit,
  }),
);
named('WorkDecision', obj({ status: z.enum(['approved', 'declined']), decisionNote: note }));
named(
  'DriverInput',
  obj({
    name: text(),
    phone: text().optional(),
    licenseNumber: text().optional(),
    userId: id.optional(),
  }),
);
named(
  'Driver',
  obj({
    id,
    name: text(),
    phone: text().nullable(),
    licenseNumber: text().nullable(),
    userId: id.nullable(),
    archived: z.boolean(),
    editToken: text(128),
    ...audit,
  }),
);
named(
  'DriverEdit',
  obj({
    name: text().optional(),
    phone: text().nullable().optional(),
    licenseNumber: text().nullable().optional(),
    userId: id.nullable().optional(),
    archived: z.boolean().optional(),
  }),
);
named(
  'VehicleInput',
  obj({
    plate: text(32),
    label: text().nullable(),
    make: text().nullable(),
    colour: text().nullable(),
    capacity: z.int().min(1).max(500),
  }),
);
// Route and Stop expose editToken because their single-resource GETs are
// deferred and a collection ETag cannot supply a per-row If-Match value.
// getOpsVehicle is deferred for the same reason, so Vehicle needs it too:
// without it an ops client can only edit a bus it just created.
named(
  'Vehicle',
  schemas.VehicleInput.extend({ id, archived: z.boolean(), editToken: text(128), ...audit }),
);
named(
  'VehicleEdit',
  obj({
    plate: text(32).optional(),
    label: text().nullable().optional(),
    make: text().nullable().optional(),
    colour: text().nullable().optional(),
    capacity: z.int().min(1).max(500).optional(),
    archived: z.boolean().optional(),
  }),
);
named('RoleEdit', obj({ role, reason: note }));
// Preserve existing ops-generated codes when omitted; an explicit code is optional.
named('CredentialIssue', obj({ code: text(32).optional() }));
named('CredentialSecret', obj({ code: text(32), pin: z.string().regex(/^\d{6}$/) }));
named('CredentialAction', obj({ action: z.enum(['suspend', 'activate', 'unlock']), reason: note }));
named('FareInput', obj({ amount: money, effectiveFrom: instant, note: note.optional() }));
named('Fare', schemas.FareInput.extend({ id, routeId: id, effectiveTo: instant.nullable() }));
named(
  'PlanPricing',
  obj({
    plan,
    ridesPerPeriod: z.int().positive(),
    priceMultiplierBp: z.int().positive(),
    takeRateBp: z.int().min(0).max(10000),
    creditPerRide: money,
    version,
  }),
);
named(
  'PricingEdit',
  obj({
    ridesPerPeriod: z.int().positive().optional(),
    priceMultiplierBp: z.int().positive().optional(),
    takeRateBp: z.int().min(0).max(10000).optional(),
    creditPerRide: money.optional(),
  }),
);
named(
  'Flag',
  obj({
    key: text(),
    enabled: z.boolean(),
    rolloutPercentage: z.number().min(0).max(100),
    description: note,
    version,
  }),
);
named(
  'FlagEdit',
  obj({ enabled: z.boolean(), rolloutPercentage: z.number().min(0).max(100), description: note }),
);
named(
  'MinimumVersion',
  obj({
    app: z.enum(['commuter', 'driver']),
    platform: z.enum(['ios', 'android']),
    minSupportedBuild: count,
    apiMajor: z.literal(1),
    storeUrl: z.url(),
    version,
  }),
);
named(
  'MinimumVersionEdit',
  obj({ minSupportedBuild: count, apiMajor: z.literal(1), storeUrl: z.url() }),
);
named(
  'PaymentReview',
  obj({
    id,
    kind: z.enum(['refund', 'dispute', 'manual_review']),
    editToken: text(128),
    purchaseId: id,
    status: text(50),
    amount: money,
    reason: text().nullable(),
    updatedAt: instant,
  }),
);
named('ReviewDecision', obj({ decision: z.enum(['resolved', 'waived']), reason: note }));
named('RestrictionInput', obj({ reason: note, reviewAt: instant }));
named(
  'Restriction',
  obj({
    id,
    userId: id,
    reason: note,
    reviewAt: instant,
    active: z.boolean(),
    editToken: text(128),
    ...audit,
  }),
);
named(
  'TraceHoldInput',
  obj({
    incidentId: id,
    tripId: id,
    receivedFrom: instant,
    receivedTo: instant,
    reason: note,
    reviewAt: instant,
  }),
);
// Release requires If-Match and there is no single-hold GET, so the list and
// the create response are the only places a client can learn the token.
named(
  'TraceHold',
  schemas.TraceHoldInput.extend({
    id,
    state: z.enum(['active', 'released']),
    editToken: text(128),
    ...audit,
  }),
);
named('MaintenanceInput', obj({ limit: z.int().min(1).max(100).default(100) }));
named(
  'ServiceDayInput',
  obj({
    travelDate: date,
    direction,
    limit: z.int().min(1).max(100).default(100),
    routeId: id.optional(),
  }),
);
named(
  'MaintenanceResult',
  obj({
    considered: count,
    succeeded: count,
    blocked: count,
    failed: count,
    failures: z.array(obj({ resourceId: id, reason: text(100) })).max(100),
  }),
);
named(
  'PaymentMaintenanceResult',
  obj({
    inbox: schemas.MaintenanceResult,
    reconciliation: schemas.MaintenanceResult,
    periods: schemas.MaintenanceResult,
  }),
);
named('WebhookAck', obj({ received: z.literal(true) }));
// decideIncident requires If-Match and getOpsIncident is not offered, so the
// ops row carries its own edit token: a collection ETag cannot supply a
// per-row precondition value.
named(
  'OpsIncident',
  schemas.Incident.extend({
    driverId: id,
    handledBy: id.nullable(),
    handledAt: instant.nullable(),
    version,
    editToken: text(128),
  }),
);
named(
  'OpsCommuteRequest',
  schemas.CommuteRequest.extend({
    riderId: id,
    slotId: id.nullable(),
    decidedBy: id.nullable(),
    editToken: text(128),
  }),
);
// The decide operations require If-Match and the single-resource reads are
// deferred, so the ops rows must carry their own edit token: a collection
// ETag cannot supply a per-row precondition value.
named(
  'OpsWorkRequest',
  schemas.WorkRequest.extend({ driverId: id, decidedBy: id.nullable(), editToken: text(128) }),
);
named(
  'OpsPurchase',
  schemas.Purchase.extend({
    riderId: id,
    attempts: z.array(
      obj({
        id,
        providerReference: text(),
        providerTransactionId: text().nullable(),
        environment: z.enum(['test', 'live']),
        status: z.enum(['pending', 'successful', 'failed', 'unknown']),
        receivedAmount: money.nullable(),
      }),
    ),
  }),
);

export const operations = [];
const op = (method, path, operationId, response, options = {}) => {
  const access =
    options.access ??
    (path.startsWith('/v1/ops/')
      ? 'ops'
      : path.startsWith('/v1/driver/')
        ? 'driver_assigned_or_own'
        : path.startsWith('/v1/me/')
          ? 'self'
          : 'public');
  operations.push({ method, path, operationId, response, access, ...options });
};
const get = (path, name, response, options) => op('get', path, name, response, options);
const post = (path, name, input, response, options) =>
  op('post', path, name, response, { input, ...options });
const edit = (method, path, name, input, response, options) =>
  op(method, path, name, response, { input, etag: true, ...options });
const del = (path, name, options) => op('delete', path, name, null, { status: 204, ...options });
const list = (path, name, response, options) =>
  get(path, name, response, { list: true, ...options });
get('/', 'getRoot', 'Root', { stable: true });
get('/healthz', 'getHealth', 'Health', { stable: true });
get('/readyz', 'getReadiness', 'Health', { stable: true });
get('/version', 'getBuild', 'Build', { stable: true });
get('/flags', 'getBootstrap', 'Bootstrap', { stable: true });
for (const provider of ['google', 'apple', 'driver'])
  post(
    `/v1/auth/${provider}`,
    `signIn${provider[0].toUpperCase() + provider.slice(1)}`,
    `${provider[0].toUpperCase() + provider.slice(1)}SignIn`,
    provider === 'driver' ? 'DriverTokens' : 'Tokens',
    { retry: 'credential', sensitive: true },
  );
post('/v1/auth/refresh', 'refreshSession', 'RefreshInput', 'Tokens', {
  retry: 'credential',
  sensitive: true,
});
post('/v1/auth/logout', 'logoutSession', 'RefreshInput', null, {
  status: 204,
  retry: 'credential',
  sensitive: true,
});
post('/v1/auth/driver/pin', 'changeDriverPin', 'PinChange', null, {
  access: 'driver_own',
  status: 204,
  sensitive: true,
});
get('/v1/me', 'getAccount', 'Account', { access: 'self' });
edit('patch', '/v1/me', 'updateAccount', 'ProfileUpdate', 'Account', {
  access: 'self',
  etag: false,
});
del('/v1/me', 'eraseAccount', { access: 'self', retry: 'erasure' });
get('/v1/me/avatar', 'getAvatar', 'Avatar');
op('put', '/v1/me/avatar', 'uploadAvatar', 'Avatar', {
  input: 'AvatarUpload',
  contentType: 'multipart/form-data',
  sensitive: true,
});
del('/v1/me/avatar', 'deleteAvatar');
list('/v1/me/sessions', 'listSessions', 'Session');
del('/v1/me/sessions/{id}', 'revokeSession');
post('/v1/me/devices', 'registerDevice', 'DeviceInput', 'Device');
get('/v1/me/membership', 'getMembership', 'Membership', { access: 'rider_own' });
for (const [path, name, type] of [
  ['billing-periods', 'BillingPeriods', 'BillingPeriod'],
  ['purchases', 'Purchases', 'Purchase'],
  ['commute-requests', 'CommuteRequests', 'CommuteRequest'],
  ['reservations', 'Reservations', 'Reservation'],
]) {
  list(`/v1/me/${path}`, `list${name}`, type, { access: 'rider_own' });
  get(`/v1/me/${path}/{id}`, `get${type}`, type, { access: 'rider_own' });
}
for (const [path, name, type] of [
  ['ride-entries', 'RideEntries', 'RideEntry'],
  ['credit-entries', 'CreditEntries', 'CreditEntry'],
  ['commute-assignments', 'CommuteAssignments', 'CommuteAssignment'],
])
  list(`/v1/me/${path}`, `list${name}`, type, { access: 'rider_own' });
post('/v1/me/purchases', 'createPurchase', 'PurchaseInput', 'Purchase', {
  access: 'rider_own',
  status: 201,
});
post('/v1/me/commute-requests', 'createCommuteRequest', 'CommuteRequestInput', 'CommuteRequest', {
  access: 'rider_own',
  status: 201,
});
post('/v1/me/commute-requests/{id}/withdraw', 'withdrawCommuteRequest', null, 'CommuteRequest', {
  access: 'rider_own',
});
post(
  '/v1/me/reservation-decisions',
  'decideReservation',
  'ReservationDecision',
  'ReservationDecisionResult',
  { access: 'rider_own', sensitive: true },
);
post('/v1/me/reservations/{id}/pass', 'issuePass', null, 'Pass', {
  access: 'rider_own',
  sensitive: true,
  retry: 'short_lived',
});
list('/v1/routes', 'listRoutes', 'Route');
get('/v1/routes/{id}', 'getRoute', 'Route');
list('/v1/routes/{id}/schedules', 'listRouteSchedules', 'Schedule');
get('/v1/route-patterns/{id}', 'getPattern', 'Pattern');
get('/v1/route-patterns/{id}/versions/{versionId}', 'getPatternVersion', 'PatternVersion');
get('/v1/route-geometries/{id}', 'getGeometry', 'Geometry');
list('/v1/trips', 'listTrips', 'Trip', { access: 'signed_in_catalog' });
get('/v1/trips/{id}', 'getTrip', 'Trip', { access: 'signed_in_catalog' });
get('/v1/trips/{id}/live', 'getLiveTrip', 'LiveTrip', { access: 'live_eligible' });
list('/v1/driver/trips', 'listDriverTrips', 'DriverTrip');
get('/v1/driver/trips/{id}', 'getDriverTrip', 'DriverTrip');
get('/v1/driver/trips/{id}/manifest', 'getManifest', 'Manifest');
get('/v1/driver/trips/{id}/summary', 'getTripSummary', 'TripSummary');
for (const action of ['start', 'complete'])
  post(`/v1/driver/trips/{id}/${action}`, `${action}Trip`, null, 'DriverTrip');
post('/v1/driver/trips/{id}/arrivals', 'recordArrival', 'ArrivalInput', 'DriverTrip', {
  etag: true,
});
post('/v1/driver/trips/{id}/positions', 'recordPosition', 'PositionInput', 'PositionReceipt', {
  retry: 'fix_id',
});
post('/v1/driver/trips/{id}/boardings', 'boardRider', 'BoardingInput', 'BoardingResult', {
  sensitive: true,
});
post(
  '/v1/driver/trips/{id}/reservations/{reservationId}/no-show',
  'markNoShow',
  null,
  'BoardingResult',
);
list('/v1/driver/incidents', 'listDriverIncidents', 'Incident', { access: 'driver_own' });
post('/v1/driver/incidents', 'reportIncident', 'IncidentInput', 'Incident', {
  access: 'driver_own',
  status: 201,
});
list('/v1/driver/requests', 'listDriverRequests', 'WorkRequest', { access: 'driver_own' });
post('/v1/driver/requests', 'createDriverRequest', 'WorkRequestInput', 'WorkRequest', {
  access: 'driver_own',
  status: 201,
});
post('/v1/driver/requests/{id}/withdraw', 'withdrawDriverRequest', null, 'WorkRequest', {
  access: 'driver_own',
});
list('/v1/driver/available-routes', 'listDriverAvailableRoutes', 'Route', { access: 'driver_own' });
for (const [path, type, input] of [
  ['routes', 'Route', 'RouteInput'],
  ['stops', 'Stop', 'StopInput'],
  ['vehicles', 'Vehicle', 'VehicleInput'],
  ['drivers', 'Driver', 'DriverInput'],
]) {
  list(`/v1/ops/${path}`, `listOps${type}s`, type);
  get(`/v1/ops/${path}/{id}`, `getOps${type}`, type);
  post(`/v1/ops/${path}`, `create${type}`, input, type, { status: 201 });
  edit('patch', `/v1/ops/${path}/{id}`, `update${type}`, `${type}Edit`, type);
}
list('/v1/ops/trips', 'listOpsTrips', 'OpsTrip');
post('/v1/ops/trips', 'createTrip', 'TripInput', 'OpsTrip', { status: 201 });
edit('patch', '/v1/ops/trips/{id}', 'rescheduleTrip', 'TripEdit', 'OpsTrip');
edit('put', '/v1/ops/trips/{id}/assignment', 'assignTrip', 'TripAssignment', 'OpsTrip');
post('/v1/ops/trips/{id}/cancel', 'cancelTrip', 'ReasonInput', 'OpsTrip', { etag: true });
for (const [path, name, type, input] of [
  ['route-patterns', 'Pattern', 'Pattern', 'PatternInput'],
  ['service-schedules', 'Schedule', 'Schedule', 'ScheduleInput'],
  ['commute-slots', 'CommuteSlot', 'CommuteSlot', 'CommuteSlotInput'],
]) {
  list(`/v1/ops/${path}`, `list${name}s`, type);
  post(`/v1/ops/${path}`, `create${name}`, input, type, { status: 201 });
}
post(
  '/v1/ops/route-patterns/{id}/versions',
  'createPatternVersion',
  'PatternVersionInput',
  'PatternVersion',
  { status: 201 },
);
list('/v1/ops/route-patterns/{id}/versions', 'listPatternVersions', 'PatternVersion');
get('/v1/ops/route-patterns/{id}/versions/{versionId}', 'getOpsPatternVersion', 'PatternVersion');
post(
  '/v1/ops/route-patterns/{id}/versions/{versionId}/publish',
  'publishPatternVersion',
  'PublishVersionInput',
  'PatternVersion',
  { etag: true },
);
post('/v1/ops/commute-slots/{id}/retire', 'retireCommuteSlot', 'ReasonInput', 'CommuteSlot', {
  etag: true,
});
list('/v1/ops/commute-requests', 'listOpsCommuteRequests', 'OpsCommuteRequest');
post(
  '/v1/ops/commute-requests/{id}/decisions',
  'decideCommuteRequest',
  'CommuteDecision',
  'OpsCommuteRequest',
  { etag: true },
);
list('/v1/ops/commute-requests/{id}/events', 'listCommuteEvents', 'DecisionEvent');
list('/v1/ops/incidents', 'listOpsIncidents', 'OpsIncident');
post('/v1/ops/incidents/{id}/decisions', 'decideIncident', 'IncidentDecision', 'OpsIncident', {
  etag: true,
});
list('/v1/ops/driver-requests', 'listOpsDriverRequests', 'OpsWorkRequest');
post(
  '/v1/ops/driver-requests/{id}/decisions',
  'decideDriverRequest',
  'WorkDecision',
  'OpsWorkRequest',
  { etag: true },
);
edit('patch', '/v1/ops/users/{id}/role', 'changeRole', 'RoleEdit', 'Account');
post(
  '/v1/ops/drivers/{id}/credentials',
  'issueDriverCredential',
  'CredentialIssue',
  'CredentialSecret',
  { status: 201, sensitive: true },
);
post(
  '/v1/ops/drivers/{id}/credentials/reset-pin',
  'resetDriverPin',
  'ReasonInput',
  'CredentialSecret',
  { sensitive: true },
);
post(
  '/v1/ops/drivers/{id}/credentials/actions',
  'changeCredentialState',
  'CredentialAction',
  null,
  { status: 204 },
);
list('/v1/ops/routes/{id}/fares', 'listFares', 'Fare');
post('/v1/ops/routes/{id}/fares', 'createFare', 'FareInput', 'Fare', { status: 201 });
list('/v1/ops/plan-pricing', 'listPlanPricing', 'PlanPricing');
edit('patch', '/v1/ops/plan-pricing/{plan}', 'updatePlanPricing', 'PricingEdit', 'PlanPricing');
list('/v1/ops/flags', 'listFlags', 'Flag');
edit('put', '/v1/ops/flags/{key}', 'setFlag', 'FlagEdit', 'Flag');
list('/v1/ops/min-versions', 'listMinimumVersions', 'MinimumVersion');
edit(
  'put',
  '/v1/ops/min-versions/{app}/{platform}',
  'setMinimumVersion',
  'MinimumVersionEdit',
  'MinimumVersion',
);
list('/v1/ops/payments/reviews', 'listPaymentReviews', 'PaymentReview');
list('/v1/ops/purchases', 'listOpsPurchases', 'OpsPurchase');
get('/v1/ops/purchases/{id}', 'getOpsPurchase', 'OpsPurchase');
post(
  '/v1/ops/payments/reviews/{id}/decisions',
  'resolvePaymentReview',
  'ReviewDecision',
  'PaymentReview',
  { etag: true },
);
post(
  '/v1/ops/users/{id}/restrictions',
  'createAccountRestriction',
  'RestrictionInput',
  'Restriction',
  { status: 201 },
);
post(
  '/v1/ops/users/{id}/restrictions/{restrictionId}/release',
  'releaseAccountRestriction',
  'ReasonInput',
  'Restriction',
  { etag: true },
);
post('/v1/ops/trace-holds', 'createTraceHold', 'TraceHoldInput', 'TraceHold', { status: 201 });
list('/v1/ops/trace-holds', 'listTraceHolds', 'TraceHold');
post('/v1/ops/trace-holds/{id}/release', 'releaseTraceHold', 'ReasonInput', 'TraceHold', {
  etag: true,
});
for (const task of [
  'payments',
  'payment-inbox',
  'payment-reconciliation',
  'period-close',
  'ask-dispatch',
  'reservation-defaults',
  'no-shows',
  'route-learning',
  'gps-retention',
])
  post(
    `/v1/ops/maintenance/${task}`,
    `run${task
      .split('-')
      .map((s) => s[0].toUpperCase() + s.slice(1))
      .join('')}`,
    ['ask-dispatch', 'reservation-defaults', 'no-shows'].includes(task)
      ? 'ServiceDayInput'
      : 'MaintenanceInput',
    task === 'payments' ? 'PaymentMaintenanceResult' : 'MaintenanceResult',
    { access: 'ops_or_scoped_worker', retry: 'safe_batch' },
  );
post('/webhooks/paystack', 'receivePaystackWebhook', null, 'WebhookAck', {
  access: 'provider_signature',
  stable: true,
  retry: 'provider_event',
});

// Named envelopes are emitted once and referenced by operations.
for (const operation of operations) {
  if (!operation.response) continue;
  if (operation.stable) {
    operation.responseSchema = operation.response;
    continue;
  }
  const model = schemas[operation.response];
  if (!model) throw new Error(`Missing response ${operation.response}`);
  const name = operation.response + (operation.list ? 'Page' : 'Response');
  if (!schemas[name])
    named(
      name,
      operation.list
        ? obj({ data: z.array(model), page: obj({ nextCursor: id.nullable() }) })
        : obj({ data: model }),
    );
  operation.responseSchema = name;
}

export const exampleCases = [
  {
    name: 'never-subscribed',
    schema: 'MembershipResponse',
    value: {
      data: {
        membership: null,
        coverage: null,
        lastCoverageEndedAt: null,
        access: { canReserve: false, blocks: [] },
        commute: null,
        entitlements: {
          remainingRides: 0,
          credit: { amountMinor: 0, currency: 'GHS' },
          heldCredit: { amountMinor: 0, currency: 'GHS' },
          availableCredit: { amountMinor: 0, currency: 'GHS' },
        },
      },
    },
  },
  {
    name: 'awaiting-fix',
    schema: 'LiveTripResponse',
    value: {
      data: {
        tripId: 'trip-demo',
        patternVersionId: 'pattern-version-demo',
        geometryId: null,
        riderPickupOccurrenceId: null,
        state: 'awaiting_fix',
        position: null,
        etas: [],
        serverTime: '2026-09-14T10:00:00Z',
      },
    },
  },
  {
    name: 'boarded',
    schema: 'BoardingResultResponse',
    value: {
      data: {
        reservationId: 'reservation-demo',
        status: 'boarded',
        alreadyApplied: false,
        chargedRides: 1,
      },
    },
  },
  {
    name: 'paused-and-disputed',
    schema: 'MembershipResponse',
    value: {
      data: {
        membership: { id: 'membership-demo', lifecycle: 'open' },
        coverage: {
          id: 'period-demo',
          startsAt: '2026-09-01T00:00:00Z',
          endsAt: null,
          state: 'open',
          paused: true,
          renewalMode: 'manual',
        },
        lastCoverageEndedAt: null,
        access: {
          canReserve: false,
          blocks: [
            { kind: 'paused', scope: 'period', periodId: 'period-demo' },
            { kind: 'dispute', scope: 'period', periodId: 'period-demo' },
          ],
        },
        commute: null,
        entitlements: {
          remainingRides: 20,
          credit: { amountMinor: 0, currency: 'GHS' },
          heldCredit: { amountMinor: 0, currency: 'GHS' },
          availableCredit: { amountMinor: 0, currency: 'GHS' },
        },
      },
    },
  },
  {
    name: 'stale-state',
    schema: 'ErrorResponse',
    value: {
      error: {
        code: 'version_conflict',
        message: 'Reload this resource before retrying.',
        requestId: 'request-demo',
      },
    },
  },
];
