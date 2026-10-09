# Developing Trotxi features

Read the relevant [feature guide](features/README.md) before changing behavior.
It explains what users can do and what must remain true. API schemas and tests
are the executable references when a detail needs checking.

## Where changes belong

| Feature                                                    | API code under `services/api-next/src` | Client entry point                                                   |
| ---------------------------------------------------------- | -------------------------------------- | -------------------------------------------------------------------- |
| Sign-in, verification, PIN and passkeys                    | `auth/`, `account/`                    | Shared `apps/trotxi_client`, app auth screens and Ops auth           |
| Catalog, trips, assignments and live positions             | `transport/`                           | Ops Network/Trips, driver runs, commuter trips and `apps/trotxi_map` |
| Requests, offers, reservations, pauses and commute changes | `membership/`                          | Ops Standby/Support, commuter request/wallet/trip screens            |
| Payment, credit, refund and recovery                       | `payments/`                            | Ops Payments and commuter wallet                                     |
| Boarding and no-show                                       | `boarding/`                            | Driver scanning/manifest and commuter pass                           |
| Profile, avatar and erasure                                | `account/`                             | App Profile and Ops account controls                                 |
| Runtime jobs and configuration                             | `runtime/`, `config/`                  | Worker entry point and Ops Platform                                  |
| HTTP contract and routing                                  | `http/`                                | Generated Dart client and Ops types                                  |

Application setup: [mobile](../apps/README.md), [Ops](../apps/ops/README.md),
[API](../services/api-next/README.md). Use Node 24 and the pinned pnpm version.
Use package-scoped API commands below; the root's retired `@trotxi/api`
convenience aliases do not target `api-next`.

## Change the whole flow

1. Identify the actor, owning account/trip/period, state transitions and retry behavior.
2. Inspect the feature service, schema, migrations/guards and tests together.
3. Change the executable contract when a wire shape changes. Never hand-edit
   generated clients or trust caller-supplied price, role or payment success.
4. Implement the API and client handling, including loading, stale, denied,
   empty and uncertain outcomes. Keep session handling in the shared client.
5. Test ownership, invalid input, replay, concurrency and expiry where relevant.
6. Update the feature guide with current behavior, not a change diary.

Money stays in integer pesewas. Dates and departure coverage determine funded
rides. A local GPS marker is not a delivery receipt, and a payment redirect is
not fulfilment. Mutation retry must use the same operation identity and payload,
not silently repeat the action with a new key.

## Contract generation

From the repository root:

```sh
node docs/design/scripts/build-contract.mjs
node docs/design/scripts/build-transport-contract.mjs
node --test docs/design/scripts/contract.test.mjs
pnpm --filter @trotxi/ops codegen
pnpm codegen:replacement
```

Then run `dart run build_runner build` in `apps/api_client` and format the
generated output. The full target catalog includes deferred operations;
`replacement.openapi.json` is the implemented subset used by apps and runtime.

## Verification

API changes:

```sh
pnpm --filter @trotxi/api-next typecheck
pnpm --filter @trotxi/api-next test
pnpm --filter @trotxi/api-next test:postgres
```

Postgres tests require a disposable loopback PostGIS database with the explicit
harness configuration described in the API README. Never use staging or production.
Run PG suites serially. Migration/operation additions must update the pinned
inventories and upgrade assertions in the same change.

Ops changes:

```sh
pnpm --filter @trotxi/ops typecheck
pnpm --filter @trotxi/ops test:coverage
pnpm --filter @trotxi/ops build
```

For each affected Flutter package/app, run `flutter analyze` and
`flutter test`; verify the native build when changing platform integration.
Handset GPS/push, provider messages, live environment configuration and money
flows need separately authorized acceptance. Unit tests do not certify those.

For documentation-only changes, check links, formatting and any executable
examples/generators affected. There is no need to rerun unrelated database or
mobile suites when no behavior or schema changed.
