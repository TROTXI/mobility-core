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
| More → Standby             | Review commuter requests and send priced subscription offers                                                        |
| More → Payments            | Purchases, recovery/review, TEST refund initiation and card-renewal status/attention list                           |
| More → People & messages   | Operators, access controls, delivery and erasure visibility                                                         |
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
The older People & messages directory links to Team for account changes and no
longer offers administrator-to-commuter role changes.

Only a superadmin can promote another active administrator to superadmin.
**Make administrator** removes only superadmin capability, not the account.
Nobody can change their own access here. Register a second recovery passkey and
establish a separately approved backup superadmin; there is no public recovery
or email-only bypass. See [first setup](../DEPLOY.md#first-superadmin-setup).
