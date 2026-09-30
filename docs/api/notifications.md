# Rider notification inbox

The commuter app's bell opens an account-owned inbox. These records are durable
facts about a ride, not a claim that Firebase displayed a push on a handset.
The API records only a kind, first-party target, timestamp and read state; it
does not copy passenger names, phone numbers, route labels, provider responses
or device tokens into notification records.

`GET /v1/me/notifications?limit=30&unreadOnly=false` returns newest first:

```json
{
  "data": [
    {
      "id": "26a51489-63b5-4c24-9d6f-e3f16d72d807",
      "kind": "seat_ask",
      "target": {
        "type": "reservation",
        "id": "08ed1605-1cd0-4571-af5b-c33b1c3c719e"
      },
      "createdAt": "2026-09-30T17:00:00.000Z",
      "readAt": null
    }
  ],
  "page": { "nextCursor": null }
}
```

This is a schema-valid _illustrative_ response, not a captured staging record.
Follow `nextCursor` unchanged and keep the same `unreadOnly` filter. The page
size is 1–100 (default 30). A cursor belongs to the current account and filter.
`POST /v1/me/notifications/{id}/read` returns the same notification with a
non-null `readAt`. It is idempotent; a different rider's ID returns 404.
`POST /v1/me/notifications/read` marks all unread rows and returns
`{ "data": { "readCount": 1 } }`. Neither mark-read call needs a request body.

The supported kinds are `seat_ask`, `seat_held`, `seat_unseated`, `ride_used`,
`credit_converted`, `trip_changed` and `trip_cancelled`. They come from committed
reservation prompts, status changes, credit conversions and trip events. A
unique `(rider, kind, source)` key prevents a replay from creating a duplicate.
Opening a reservation target fetches the current trip detail; a credit target
opens the wallet. The inbox never treats an old event as current trip state.

`GET /v1/me/notification-preferences` returns `data.dailyAskTime` (24-hour
Ghana local clock, 06:00–21:00), `data.optionalUpdatesEnabled`, `updatedAt`
and `version`, plus an `ETag` header. `PATCH` takes both settings and that
ETag in `If-Match`; missing is 428 and stale is 412. There is no global mute:
seat asks, seat results, boarding/credit receipts and trip changes remain
service notifications. `optionalUpdatesEnabled` defaults off; no optional
campaigns currently exist.

The pilot's ask/default workers are still **manually run**. The preferred
`dailyAskTime` is recorded for the future scheduled dispatcher, but it does
not schedule a worker or guarantee delivery at that hour today. The app says
this explicitly. Proximity alerts are deferred until product approval and a
bounded once-per-trip design. Missing Firebase credentials do not block API
startup, the inbox, or tests; only the push worker requires them. No new push
delivery path was added by this inbox work.
