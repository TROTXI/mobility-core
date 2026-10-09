# API response examples

These illustrative responses are checked against the executable contract by
`docs/design/scripts/contract.test.mjs`. They are shapes for integration, not
live account data, package defaults or proof of deployed provider setup.
Money is integer pesewas. Use [API integration](README.md) for the current flow.

## Error

```json
{
  "error": {
    "code": "period_settlement_pending",
    "message": "Your previous period still has a trip awaiting settlement.",
    "requestId": "request-example",
    "fieldErrors": []
  }
}
```

## Membership

```json
{
  "data": {
    "membership": { "id": "membership-example", "lifecycle": "open" },
    "access": { "canReserve": true, "blocks": [] },
    "coverage": {
      "id": "period-example",
      "startsAt": "2026-09-01T00:00:00Z",
      "endsAt": "2026-10-01T00:00:00Z",
      "state": "open",
      "paused": false,
      "renewalMode": "manual"
    },
    "lastCoverageEndedAt": null,
    "entitlements": {
      "remainingRides": 24,
      "credit": { "amountMinor": 1980, "currency": "GHS" },
      "availableCredit": { "amountMinor": 1980, "currency": "GHS" },
      "heldCredit": { "amountMinor": 0, "currency": "GHS" }
    },
    "commute": {
      "id": "assignment-example",
      "routeId": "route-example",
      "routeName": "Adenta - Circle",
      "effectiveFrom": "2026-09-01",
      "effectiveTo": null,
      "legs": [
        {
          "direction": "outbound",
          "scheduleId": "outbound-schedule-example",
          "patternVersionId": "outbound-version-example",
          "pickupOccurrenceId": "outbound-pickup-example",
          "dropoffOccurrenceId": "outbound-dropoff-example",
          "localDeparture": "06:30",
          "pickupName": "Adenta",
          "dropoffName": "Circle",
          "timeZone": "Africa/Accra"
        },
        {
          "direction": "return",
          "scheduleId": "return-schedule-example",
          "patternVersionId": "return-version-example",
          "pickupOccurrenceId": "return-pickup-example",
          "dropoffOccurrenceId": "return-dropoff-example",
          "localDeparture": "17:30",
          "pickupName": "Circle",
          "dropoffName": "Adenta",
          "timeZone": "Africa/Accra"
        }
      ]
    }
  }
}
```

## Live trip

```json
{
  "data": {
    "tripId": "trip-example",
    "state": "live",
    "patternVersionId": "outbound-version-example",
    "geometryId": "geometry-example",
    "position": {
      "location": { "latitude": 5.6037, "longitude": -0.187 },
      "capturedAt": "2026-09-14T06:45:00Z",
      "receivedAt": "2026-09-14T06:45:02Z",
      "ageSeconds": 4
    },
    "etas": [
      {
        "stopOccurrenceId": "outbound-dropoff-example",
        "durationSeconds": 360,
        "distanceMeters": 1800,
        "basis": "observed"
      }
    ],
    "riderPickupOccurrenceId": "outbound-pickup-example",
    "serverTime": "2026-09-14T06:45:04Z"
  }
}
```
