# Worked API calls

These are request templates for developers, not a script to run against shared
staging. No calls were sent to create this guide. Use the supported apps for
ordinary operations; raw API calls do not replace UI safeguards.

## Before using the examples

- The host `api.example.invalid` is deliberately non-routable. Replace it only
  with an approved local/test API.
- Tokens, edit tokens, UUIDs, phone, code, geometry and dates below are examples.
  Replace IDs with values returned by **your own** setup. Never use someone
  else's account, live payment details or arbitrary SMS recipients.
- Ops calls require an approved operator session with passkey elevation.
  Driver and commuter tokens must belong to their respective test accounts.
  Client metadata does not grant a role.
- Use the real app build/platform. Build 1 below is illustrative; the server's
  minimum-build policy may refuse it.
- Create a unique idempotency key for each logical command and preserve it for
  an unanswered retry with the same payload. Do not reuse these literal keys
  across test runs. GPS uses `clientFixId` instead.
- Use the resource's exact `editToken` or ETag for `If-Match`, including any
  quotes. A 412 means read/reconcile, not blindly retry.
- Date examples assume an authorized test on **2026-10-04**, service beginning
  **2026-10-05**, and exclusive coverage end **2026-11-02**. Shift the whole
  scenario together when testing later. Offer expiry must be at least a minute
  ahead, within seven days, and no later than coverage start.
- Requests that issue SMS, open checkout, mutate fleet or board riders require
  explicit test authorization. Paystack must be in TEST mode.

The HTTP blocks include all required contract headers. With an HTTP client,
substitute the host and credentials, then submit only the intended step.
For example, the read-only membership request can also be written:

```sh
curl --fail-with-body "$TROTXI_TEST_API/v1/me/membership" \
  -H "Authorization: Bearer $TROTXI_COMMUTER_TOKEN" \
  -H 'X-Trotxi-Client: commuter' \
  -H 'X-Trotxi-Build: 1' \
  -H 'X-Trotxi-Platform: android'
```

Keep credentials out of committed files, verbose logs and screenshots.

## 1. Ops prepares service

The UUIDs show relationships, not pre-seeded records. Save IDs from each
response. The full product flow is in [routes](../features/mobility.md).

### Create a corridor

Operation: `createRoute`.

```http
POST /v1/ops/routes
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-createRoute-01
Content-Type: application/json

{
  "name": "Example A to B",
  "description": "Synthetic development example",
  "acceptsDriverRequests": true
}
```

Save `data.id` as the route ID. This does not publish service or create trips.

### Create stop A

Operation: `createStop`.

```http
POST /v1/ops/stops
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-createStop-01
Content-Type: application/json

{
  "name": "Example stop A",
  "location": {
    "latitude": 5.6,
    "longitude": -0.18
  }
}
```

Save `data.id`. Repeat for stop B at latitude 5.61, longitude -0.17 using a different command key. Stops are physical locations, not ordered occurrences.

### Create the outbound pattern

Operation: `createPattern`.

```http
POST /v1/ops/route-patterns
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-createPattern-01
Content-Type: application/json

{
  "routeId": "10000000-0000-4000-8000-000000000001",
  "direction": "outbound"
}
```

Save the pattern ID. Create a separate return pattern; do not infer direction from morning/evening.

### Draft stops and geometry

Operation: `createPatternVersion`.

```http
POST /v1/ops/route-patterns/10000000-0000-4000-8000-000000000004/versions
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-createPatternVersion-01
Content-Type: application/json

{
  "stops": [
    {
      "stopId": "10000000-0000-4000-8000-000000000002",
      "name": "Example stop A",
      "location": {
        "latitude": 5.6,
        "longitude": -0.18
      }
    },
    {
      "stopId": "10000000-0000-4000-8000-000000000003",
      "name": "Example stop B",
      "location": {
        "latitude": 5.61,
        "longitude": -0.17
      }
    }
  ],
  "geometry": {
    "points": [
      {
        "latitude": 5.6,
        "longitude": -0.18
      },
      {
        "latitude": 5.61,
        "longitude": -0.17
      }
    ],
    "stopDistancesMeters": [
      0,
      1569
    ]
  }
}
```

Save `data.id`, `data.editToken` and the ordered `data.stops[].id` occurrence IDs. The two-point line is illustrative, not a real road route. Use the correct full path and measured stop distances for service.

### Publish the version

Operation: `publishPatternVersion`.

```http
POST /v1/ops/route-patterns/10000000-0000-4000-8000-000000000004/versions/10000000-0000-4000-8000-000000000005/publish
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-publishPatternVersion-01
If-Match: "<CURRENT_RESOURCE_EDIT_TOKEN>"
Content-Type: application/json

{
  "reason": "Publish authorized test service",
  "effectiveFrom": "2026-10-04T00:00:00Z"
}
```

Use the draft's exact edit token in If-Match. Publication freezes the version. If it conflicts with existing service, resolve that conflict instead of editing history.

### Add a recurring departure

Operation: `createSchedule`.

```http
POST /v1/ops/service-schedules
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-createSchedule-01
Content-Type: application/json

{
  "departure": {
    "kind": "new"
  },
  "patternVersionId": "10000000-0000-4000-8000-000000000005",
  "serviceWindow": "morning",
  "localDeparture": "06:30",
  "timeZone": "Africa/Accra",
  "weekdays": [
    1,
    2,
    3,
    4,
    5
  ],
  "effectiveFrom": "2026-10-04",
  "effectiveTo": null
}
```

Save the schedule ID. Create/publish the return version with reversed stop order and a separate schedule, such as 17:30 evening. Both schedules must cover the offered dates.

### Publish the exact journey fare

Operation: `createFare`.

```http
POST /v1/ops/routes/10000000-0000-4000-8000-000000000001/fares
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-createFare-01
Content-Type: application/json

{
  "amount": {
    "amountMinor": 1000,
    "currency": "GHS"
  },
  "effectiveFrom": "2026-10-04T00:00:00Z",
  "note": "Illustrative GHS 10 journey",
  "patternVersionId": "10000000-0000-4000-8000-000000000005",
  "pickupOccurrenceId": "10000000-0000-4000-8000-000000000006",
  "dropoffOccurrenceId": "10000000-0000-4000-8000-000000000007"
}
```

This is GHS 10, not GHS 1,000. Also publish the return journey's fare. Every offered stop pair needs its own effective fare.

### Create a departure

Operation: `createTrip`.

```http
POST /v1/ops/trips
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-createTrip-01
Content-Type: application/json

{
  "scheduleId": "10000000-0000-4000-8000-000000000008",
  "serviceDate": "2026-10-05",
  "runNumber": 1,
  "scheduledAt": "2026-10-05T06:30:00Z"
}
```

Save `data.id` and `data.editToken`. The date must match the schedule's service day and the trip must be in the future. Bulk generation is a separate maintenance operation.

### Assign fleet to the trip

Operation: `assignTrip`.

```http
PUT /v1/ops/trips/10000000-0000-4000-8000-00000000000d/assignment
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-assignTrip-01
If-Match: "<CURRENT_RESOURCE_EDIT_TOKEN>"
Content-Type: application/json

{
  "driverId": "10000000-0000-4000-8000-00000000000e",
  "vehicleId": "10000000-0000-4000-8000-00000000000f"
}
```

Use existing active test driver/vehicle IDs and the trip's current edit token. Creating a trip alone does not provide seat capacity.

## 2. Establish commuter eligibility

Choose **one** auth path. Steps for social-account phone verification are an
alternative to public phone sign-in, not a second OTP after successful phone login.
Use [authentication](../features/authentication.md) for failures and session rules.

### Request a login OTP

Operation: `requestPhoneSignIn`.

```http
POST /v1/auth/phone/request
Host: api.example.invalid
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Content-Type: application/json

{
  "phone": "+233200000000"
}
```

This request sends SMS when configured. Replace the illustrative number only with an authorized recipient. Save `data.challengeId`; successful submission is not proof of handset receipt.

### Verify the login OTP

Operation: `verifyPhoneSignIn`.

```http
POST /v1/auth/phone/verify
Host: api.example.invalid
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Content-Type: application/json

{
  "challengeId": "20000000-0000-4000-8000-000000000001",
  "code": "123456"
}
```

Replace both values with the returned challenge ID and received code. Save the returned tokens through the shared session client. Complete the rider name if prompted; phone login already establishes verification.

### Verify a social-login account's phone

Operation: `startPhoneVerification`.

```http
POST /v1/me/phone-verification/start
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Content-Type: application/json

{
  "phone": "+233200000000"
}
```

For an already authenticated Google/configured Apple account only. Save its challenge ID. Do not use public phone sign-in to silently link or merge another account.

### Confirm the account-bound challenge

Operation: `confirmPhoneVerification`.

```http
POST /v1/me/phone-verification/confirm
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Content-Type: application/json

{
  "challengeId": "20000000-0000-4000-8000-000000000002",
  "code": "123456"
}
```

Use this flow instead of repeating login OTP for an already phone-verified account. Re-read `/v1/me/verification` for eligibility.

## 3. Request, offer and pay

Both directional schedules, versions, ordered stop occurrences and fares must
exist. The rider must have a completed name and verified phone.
See [payments](../features/payments-and-wallet.md) for immutable terms and renewal.

### Submit the subscription request

Operation: `joinStandby`.

```http
POST /v1/me/standby
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Idempotency-Key: example-joinStandby-01
Content-Type: application/json

{
  "selection": {
    "plan": "monthly",
    "routeId": "10000000-0000-4000-8000-000000000001",
    "legs": [
      {
        "direction": "outbound",
        "scheduleId": "10000000-0000-4000-8000-000000000008",
        "patternVersionId": "10000000-0000-4000-8000-000000000005",
        "pickupOccurrenceId": "10000000-0000-4000-8000-000000000006",
        "dropoffOccurrenceId": "10000000-0000-4000-8000-000000000007"
      },
      {
        "direction": "return",
        "scheduleId": "10000000-0000-4000-8000-00000000000c",
        "patternVersionId": "10000000-0000-4000-8000-000000000009",
        "pickupOccurrenceId": "10000000-0000-4000-8000-00000000000a",
        "dropoffOccurrenceId": "10000000-0000-4000-8000-00000000000b"
      }
    ],
    "useCredit": true
  },
  "travelDays": [
    1,
    2,
    3,
    4,
    5
  ]
}
```

Save `data.id` as the application ID. Use a completed rider name and verified phone. A successful request is free and grants no coverage or guaranteed seat. `annual` is also a supported request preference.

### Find the request in Ops

Operation: `listOpsStandby`.

```http
GET /v1/ops/standby?limit=30
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
```

Follow `page.nextCursor` unchanged until the request is found. Keep the same page/filter context; do not assume the first page contains all requests.

### Send the priced offer

Operation: `offerStandby`.

```http
POST /v1/ops/standby/10000000-0000-4000-8000-000000000010/offers
Host: api.example.invalid
Authorization: Bearer <OPS_ACCESS_TOKEN>
X-Trotxi-Client: ops
X-Trotxi-Build: 1
Idempotency-Key: example-offerStandby-01
Content-Type: application/json

{
  "expiresAt": "2026-10-04T23:00:00Z",
  "coverageStart": "2026-10-05",
  "coverageEnd": "2026-11-02",
  "price": {
    "amountMinor": 40000,
    "currency": "GHS"
  },
  "credits": [
    {
      "direction": "outbound",
      "creditPerUnusedRide": {
        "amountMinor": 500,
        "currency": "GHS"
      }
    },
    {
      "direction": "return",
      "creditPerUnusedRide": {
        "amountMinor": 500,
        "currency": "GHS"
      }
    }
  ]
}
```

Illustration: four Mon-Fri weeks give 20 outbound and 20 return rides. The package is GHS 400; each unused ride credits GHS 5. Maximum credit is GHS 200, below the price, and each credit is below its GHS 10 fare. Use the server's computed terms in the UI, not these example counts.

### Read the offered terms

Operation: `listMyStandby`.

```http
GET /v1/me/standby?limit=30
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
```

Find the application and display `offer.terms`, `offer.expiresAt` and current state. Show dates, journeys, weekdays, allowances, total and unused-ride credit before accepting.

### Accept and open checkout

Operation: `acceptStandbyOffer`.

```http
POST /v1/me/standby/10000000-0000-4000-8000-000000000010/accept
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Idempotency-Key: example-acceptStandbyOffer-01
```

Returns a purchase, not another standby application. Save its `data.id` and follow the returned payment instructions. Retain this acceptance key across an unanswered retry; do not start an unrelated purchase.

### Recover payment status

Operation: `getPurchase`.

```http
GET /v1/me/purchases/10000000-0000-4000-8000-000000000011
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
```

Re-read the same purchase after checkout or network loss. Only `fulfilled` establishes successful fulfilment. `processing` or `review_required` is not permission to pay again.

### Read current and upcoming coverage

Operation: `getMembership`.

```http
GET /v1/me/membership
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
```

Read `data.coverage`, `data.upcomingCoverage` and entitlements. Paid future coverage is upcoming until its start, even when the rider can confirm a covered future departure.

## 4. Reserve and operate the trip

Coverage must be paid and the chosen departure funded. The driver is a separate
account, assigned to that trip. The trip must have capacity and be eligible for
the requested lifecycle action. See [boarding](../features/boarding.md).

### Confirm the funded departure

Operation: `decideReservation`.

```http
POST /v1/me/reservation-decisions
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Idempotency-Key: example-decideReservation-01
Content-Type: application/json

{
  "travelDate": "2026-10-05",
  "direction": "outbound",
  "decision": "confirm",
  "tripId": "10000000-0000-4000-8000-00000000000d"
}
```

Use the actual trip ID and read the resulting reservation state. Eligibility, offered journey/day, pause/restrictions and capacity are checked. Confirmation is not boarding.

### Issue the rider's boarding pass

Operation: `issuePass`.

```http
POST /v1/me/reservations/10000000-0000-4000-8000-000000000012/pass
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Idempotency-Key: example-issuePass-01
```

Use the rider's own confirmed reservation. The pass is short-lived and private. Never log or share the QR proof; a screenshot does not override current eligibility.

### Driver starts the assigned run

Operation: `startTrip`.

```http
POST /v1/driver/trips/10000000-0000-4000-8000-00000000000d/start
Host: api.example.invalid
Authorization: Bearer <DRIVER_ACCESS_TOKEN>
X-Trotxi-Client: driver
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Idempotency-Key: example-startTrip-01
```

The app first performs its readiness/location checks. The API rechecks assignment and lifecycle. Start native collection from the foreground, not via a background service launch.

### Upload one captured GPS fix

Operation: `recordPosition`.

```http
POST /v1/driver/trips/10000000-0000-4000-8000-00000000000d/positions
Host: api.example.invalid
Authorization: Bearer <DRIVER_ACCESS_TOKEN>
X-Trotxi-Client: driver
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Content-Type: application/json

{
  "clientFixId": "30000000-0000-4000-8000-000000000001",
  "capturedAt": "2026-10-05T06:30:05Z",
  "latitude": 5.6,
  "longitude": -0.18,
  "accuracyMeters": 8
}
```

Use the real capture timestamp and a stable fix UUID. Retry that exact fix, not a re-timestamped copy. Match the receipt before removing the queued fix. Old history is not necessarily accepted for live display.

### Board by code

Operation: `boardRider`.

```http
POST /v1/driver/trips/10000000-0000-4000-8000-00000000000d/boardings
Host: api.example.invalid
Authorization: Bearer <DRIVER_ACCESS_TOKEN>
X-Trotxi-Client: driver
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Idempotency-Key: example-boardRider-01
Content-Type: application/json

{
  "kind": "code",
  "code": "AB23"
}
```

Replace the code with the rider's current pass code. QR uses `{kind: 'qr', token: ...}` and photo uses `{kind: 'photo', reservationId: ...}` instead. All paths need online authorization and commit the same reservation charge.

### Finish the driver run

Operation: `completeTrip`.

```http
POST /v1/driver/trips/10000000-0000-4000-8000-00000000000d/complete
Host: api.example.invalid
Authorization: Bearer <DRIVER_ACCESS_TOKEN>
X-Trotxi-Client: driver
X-Trotxi-Build: 1
X-Trotxi-Platform: android
Idempotency-Key: example-completeTrip-01
```

Use the app's completion workflow: freeze capture and flush the durable queue first. Unresolved uploads keep the trip active for recovery; do not bypass that safeguard with this raw call.

## 5. Update preferences safely

This read-then-write pattern demonstrates optimistic concurrency. Preferences
are account-owned; use the same commuter account for both calls.

### Read settings and their ETag

Operation: `getNotificationPreferences`.

```http
GET /v1/me/notification-preferences
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
```

Save the ETag response header including its quotes. Do not fabricate it or use an ETag from another resource.

### Save notification settings

Operation: `updateNotificationPreferences`.

```http
PATCH /v1/me/notification-preferences
Host: api.example.invalid
Authorization: Bearer <COMMUTER_ACCESS_TOKEN>
X-Trotxi-Client: commuter
X-Trotxi-Build: 1
X-Trotxi-Platform: android
If-Match: "<CURRENT_RESOURCE_EDIT_TOKEN>"
Content-Type: application/json

{
  "dailyAskTime": "18:30",
  "optionalUpdatesEnabled": true
}
```

Send the previously read ETag. On 412, refresh and let the user reconcile the newer values; do not silently overwrite them. The setting is not a promise of a scheduled campaign.

## What these examples prove

CI validates the method/path, required metadata, authorization presence and
JSON bodies against the current implemented contract. This catches documentation
drift. Schema validity does not prove the referenced resources exist, dates
are eligible, a session is elevated, capacity is available or a provider delivered.

A successful route setup does not automatically send an offer, generate all
departures or run maintenance. A checkout response is not payment success.
Use each feature's failure table and tests when implementing recovery.

Account deletion is intentionally not included as a copy-and-paste command.
See [account lifecycle](../features/profile-avatars.md) for its irreversible
boundary, confirmation and cleanup behavior.
