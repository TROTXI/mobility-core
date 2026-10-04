# Ops workflows

Source audit: 2026-10-03. Sign in with an approved Google account, then complete
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
| More → Payments            | Purchases, recovery/review and TEST refund initiation                                                               |
| More → People & messages   | Operators, access controls, delivery and erasure visibility                                                         |
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

## Boundaries

An offer is not a guaranteed vehicle seat. Ops must review real recurring supply.
Work-request approval is not trip reassignment. Refund acceptance is not settled
cash. Erasure visibility is not certification of provider/back-up deletion.

Use the API's current conflict message and resource edit token after stale
edits. Do not bypass guards using direct database updates.

Sources: `apps/ops/src/{App.tsx,components/Shell.tsx,screens/}`.
See [Ops development](../../apps/ops/README.md).
