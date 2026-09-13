# Driver operations

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Live on the API and consumed by the current driver-app branch.

Driver operations covers assigned-run lifecycle, incident reporting, work
requests and assignment-change notifications. Authentication and boarding are
documented separately.

## Assigned-run lifecycle

All endpoints require role `driver` and a `users.id → drivers.user_id` link.
Trip-specific operations additionally require the caller to be that trip's
assigned driver.

| Endpoint                   | Purpose                                                                 |
| -------------------------- | ----------------------------------------------------------------------- |
| `GET /me/trips`            | Assigned runs for one UTC day or an inclusive date range                |
| `POST /trips/:id/start`    | `scheduled → active`; retrying an active run succeeds                   |
| `POST /trips/:id/arrive`   | Record the current route-stop sequence; correction backwards is allowed |
| `POST /trips/:id/complete` | `active → completed`; an unstarted run is rejected                      |
| `GET /trips/:id/summary`   | Boarded/not-boarded counts, verification methods and timing             |

Completed and cancelled trips are terminal. Stop progress is driver-reported,
not inferred from GPS.

### Driver device readiness (#239, page 06)

Both Today → Start trip and the run screen route through pre-trip. Before the
driver app calls the start endpoint, it requires foreground location permission
and enabled device location services. The readiness page checks again on resume
and immediately before continuing; unknown/error states keep Start disabled.
This is a device-side gate, not a new server-side permission assertion.

Camera access is optional: drivers can use **Board by code** without it. Only
camera and while-in-use location can be requested, after an explicit tap.
Permanent denial links to app settings, disabled location services link to
location settings, and restricted permissions explain the device-policy limit.
Profile → Check camera & location opens the same checks without starting a trip.

The checks make no network requests, open no camera and start no GPS stream.
The existing position publisher starts when the active run screen is open and
stops when that screen is disposed or the run ends; it no longer prompts for
permission as a side effect. Cancelling during a native check cannot start a
late stream. This PR does not add background tracking or an offline location
queue. Permission success is not proof of a GPS fix or successful server delivery.

The layout uses the page-06 Figma readiness/denial structure and existing theme
tokens, with camera optional per product decision. Notification setup, GPS/network
health indicators, splash/onboarding and full offline queueing remain separate.

## Incident reporting

| Endpoint                     | Role   | Purpose                                            |
| ---------------------------- | ------ | -------------------------------------------------- |
| `POST /me/incidents`         | driver | File category, note, optional trip and coordinates |
| `GET /me/incidents`          | driver | List the caller's reports and ops outcomes         |
| `GET /admin/incidents`       | admin  | Filterable incident queue, newest first            |
| `PATCH /admin/incidents/:id` | admin  | Acknowledge or resolve a report                    |

When a trip is supplied, the server derives the vehicle and verifies assignment;
the app cannot attribute an incident to another driver's run. Emergency help is
not queued here: the driver app uses the operations contact from `GET /flags`.

## Work requests

| Endpoint                              | Role   | Purpose                                           |
| ------------------------------------- | ------ | ------------------------------------------------- |
| `GET /me/work/routes`                 | driver | Corridors currently open to reassignment requests |
| `POST /me/work/requests`              | driver | Submit a route-change or leave request            |
| `GET /me/work/requests`               | driver | List the caller's requests and decisions          |
| `POST /me/work/requests/:id/withdraw` | driver | Withdraw the caller's still-pending request       |
| `GET /admin/driver-requests`          | admin  | Operations request queue                          |
| `PATCH /admin/driver-requests/:id`    | admin  | Approve or decline a pending request              |

Approval records a decision only. It never mutates trip assignments; operations
must use `PUT /admin/trips/:id/assignment`, where assignment checks live.

## Driver notifications

`DriverNotifier` sends FCM notifications after an admin persists an assignment,
unassignment, vehicle change or departure-time change. Notifications are a
delivery mechanism, not the source of truth; `GET /me/trips` remains authoritative.

## Code

- `services/api/src/modules/mobility/trip-lifecycle.*`
- `services/api/src/modules/incidents/*`
- `services/api/src/modules/work/*`
- `services/api/src/modules/notifications/driver-notifier.service.ts`
- migrations `028`, `036`, `037` and `038`
