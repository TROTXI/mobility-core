# Ops workflows

Source audit: 2026-10-08. Sign in with an invited or existing approved Google account, then complete
the passkey check. Role checks are enforced by the server, not only navigation.

| Navigation                 | Implemented work                                                                                                    |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Live operations            | Aggregate trip/boarding counts, attention states, map and dispatch links                                            |
| Trips                      | Create/generate, inspect manifests, assign drivers/vehicles, reschedule, cancel                                     |
| Routes & stops             | Routes, physical stops, directional patterns/versions, geometry, schedules, fares, plan settings and transfer slots |
| Fleet / Drivers            | Fleet records, driver provisioning, credential issue/reset/status and delivery choice                               |
| Riders                     | Membership, reservations, financial history, restrictions and support context                                       |
| Support                    | Commute requests, driver requests, incidents and decisions                                                          |
| More → Payments            | Purchases, recovery/review, TEST refund initiation and card-renewal status/attention list                           |
| More → People & messages   | Operators, access controls, delivery and erasure visibility                                                         |
| Standby                    | Group route demand, filter requests and send individually priced offers in batches                                  |
| More → Delivery status     | Paginated email and push delivery evidence                                                                          |
| More → Team & access       | Superadmin-only invitations, administrator account deletion, superadmin capability and passkey recovery             |
| More → Audit log / Reports | Attributable events and operational summaries                                                                       |
| More → Platform            | Flags, minimum builds and exposed manual maintenance controls                                                       |

## Route to offer

Create the route and stops, publish both directional versions and schedules,
then publish exact pickup/drop-off fares. Generate trips and assign fleet
separately. A route record alone creates neither bookable service nor capacity.

The commuter requests their journey/weekdays and verifies their phone.
In Standby, select the request and send an offer with coverage start/end,
payment deadline, package price and credit per unused ride in each direction.
Inspect the calculated calendar allowances. The commuter reviews and accepts,
then pays through Paystack. New direct purchases without an offer are refused.

The UI accepts GHS inputs and sends integer pesewas. Do not type a pesewa amount
into a GHS field. Sent offers are immutable; a fare edit never reprices them.
The offer form checks for published stop-pair fares and requires a reason.
Refused offers retain entered terms for correction rather than requiring a
fresh form; uncertain outcomes keep the original request locked for safe retry.
Money, security and operational decision forms collect reasons
for the attributed audit history.

In **Payments > Card renewals**, inspect failures, masked card details and the
next attempt. A `needs_offer` entry links to Standby; Ops still creates the new
offer there. This screen cannot opt a rider into recurring charges.

### Route demand and bulk offers

Standby opens on **Needs offer**. Route groups show full-queue counts, largest
first, not just the current page. Status, monthly/annual plan, travel weekday
and rider-name filters run on the server. Route totals respect those filters
but ignore the selected route, so groups remain comparable. Select a route to
narrow its paginated request list. Requests are not reservations; compare
actual schedules, shared journey segments and fleet capacity before offering.

Select up to 25 submitted requests on one route, including across pages, then
choose **Prepare bulk offers**. Changing filters clears the current selection.
The review shows each rider's stops, departure times, travel days and estimated
ride counts. Set shared coverage dates, payment duration and reason. Each rider
has their own package price and two unused-ride credit values. **Use fare-based
total** is optional per rider. All pricing pages are loaded before calculating.
Review every row and confirm before sending. No price is copied merely because
riders share a route.

Each offer uses the existing authenticated, idempotent offer command. Sends run
sequentially; results are shown per rider. Successful offers are not resent.
An uncertain response stops the batch and retains the exact key and payload
for retry. Definitive refusals allow that rider's price/credit values to be
corrected. Shared dates and reason stay locked once sending starts. Closing
is not rollback. When no outcome is uncertain, **Finish batch** keeps the sent
offers and releases the remaining requests for a new batch. Authorization and
rate-limit refusals do not discard saved receipt keys for uncertain sends. Closing
the dialog keeps the batch available through **Resume bulk offers**; leaving
or reloading the page loses this in-memory draft. Resolve uncertain outcomes
before leaving. After a reload, refresh the queue and inspect already-created
offers before preparing a new batch. Sending is not an atomic all-or-nothing
operation and does not allocate bus capacity.

`GET /v1/ops/standby?state=submitted&plan=monthly&day=1&limit=30`
returns matching applications and `routeDemand` counts. Add `routeId` for one
route or `q` for a literal partial rider name. Page cursors are bound to the
operator and exact filters; changing filters requires restarting pagination.

## Boundaries

An offer is not a guaranteed vehicle seat. Ops must review real recurring supply.
Work-request approval is not trip reassignment. Refund acceptance is not settled
cash. Erasure visibility is not certification of provider/back-up deletion.

Use the API's current conflict message and resource edit token after stale
edits. Do not bypass guards using direct database updates.

Sources: `apps/ops/src/{App.tsx,components/Shell.tsx,screens/}`.
See [Ops development](../../apps/ops/README.md).

## Ownership and handoffs

| Ops action                     | Who acts next                                            | What it does not do                           |
| ------------------------------ | -------------------------------------------------------- | --------------------------------------------- |
| Publish route/version/schedule | Ops generates and assigns departures                     | Does not create paid rider coverage           |
| Send subscription offer        | Commuter reviews and explicitly accepts/pays             | Does not reserve a guaranteed fleet seat      |
| Assign driver/vehicle          | Assigned driver starts eligible trip                     | Does not begin tracking from the Ops browser  |
| Decide driver request          | Ops separately updates operational assignments if needed | Does not automatically reassign trips         |
| Approve commute change         | Ops explicitly applies it when eligible                  | Does not switch the rider immediately         |
| Initiate refund                | Provider evidence and payment workers settle it          | Does not prove funds already arrived          |
| Read erasure status            | Support follows the retention/cleanup procedure          | Does not certify all backups/providers erased |

Start with [worked route setup](../api/worked-examples.md#1-ops-prepares-service),
then [the offer flow](../api/worked-examples.md#3-request-offer-and-pay).
The route/request/trip IDs belong to different resources; never pass one in
place of another because their UI labels look similar.

For every edit screen, retain the resource edit token, submit once, recover
an uncertain result with the same command identity, and reconcile conflicts.
Client permissions only affect presentation; server authorization is mandatory.

Code: [navigation](../../apps/ops/src/components/Shell.tsx),
[Network](../../apps/ops/src/screens/Network.tsx),
[Standby](../../apps/ops/src/screens/Standby.tsx).
Tests: [offers](../../apps/ops/src/screens/Standby.test.tsx),
[trips](../../apps/ops/src/screens/Trips.test.tsx),
[support](../../apps/ops/src/screens/Support.test.tsx).

## Administrator onboarding

The public front page contains only the Trotxi sign-in card. There is no public
administrator registration form. A superadmin opens **More → Team & access**,
enters a name and Google account email, then sends an invitation. The recipient
opens the emailed link, signs in with that exact Google account, and registers
or verifies a passkey before entering the workspace.

The directory distinguishes active members, pending invitations, expired links
and incomplete passkey setup. Email status means queued/provider accepted/failed,
not guaranteed delivery. Resend invalidates the old link. Cancel invalidates an
unclaimed invitation; if setup has started, its warning explains that cancellation
deletes the account created for that invitation. Invite a separate address: one
already used by a rider or driver account is refused. Team changes ask for your
passkey again when the last check is more than five minutes old. **Delete account** closes an active administrator's
entire account, not just Ops access. The confirmation warns about any commuter
profile too. Sessions and passkeys are revoked, personal details are erased,
and required financial/audit records remain. External cleanup is tracked separately.
Use **View access history** for attributed events.
Team & access is the only operator-management page. The duplicate People &
messages directory was removed; its old `/people` URL redirects to `/delivery`.
Support retains account-erasure tracking. Delivery status retains delivery
history, without fetching operators or exposing duplicate passkey-reset controls.

Only a superadmin can promote another active administrator to superadmin.
**Make administrator** removes only superadmin capability, not the account.
Nobody can change their own access here. Register a second recovery passkey and
establish a separately approved backup superadmin; there is no public recovery
or email-only bypass. See [first setup](../DEPLOY.md#first-superadmin-setup).
