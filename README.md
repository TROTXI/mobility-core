# Trotxi Mobility Core

The implementation repository for the commuter app, driver app, Ops console
and transactional API.

Start with the [documentation guide](docs/README.md): implemented features,
request flows and where developers change them. The
[feature index](docs/features/README.md) explains product behavior;
[development](docs/development.md) covers setup and verification.
Product intent belongs in the private [strategy repository](https://github.com/TROTXI/strategy).

## Repository

| Path                      | Responsibility                                                        |
| ------------------------- | --------------------------------------------------------------------- |
| `services/api-next`       | Current Fastify/TypeScript API, PostgreSQL migrations and maintenance |
| `apps/ops`                | React/Vite operations website                                         |
| `apps/trotxi_commuter`    | Flutter commuter app                                                  |
| `apps/trotxi_driver`      | Flutter driver app                                                    |
| `apps/trotxi_client`      | Shared mobile session and domain integration                          |
| `apps/api_client`         | Generated Dart HTTP client                                            |
| `apps/trotxi_map`, `maps` | Shared Flutter map and basemap assets                                 |
| `docs/design/contracts`   | Executable schema sources and generated contracts                     |

Use Node 24 and the pinned pnpm version. Mobile build requirements are in
[apps/README.md](apps/README.md). The current API is not the retired
`services/api` implementation.

New subscriptions use a verified commuter request, an Ops-priced offer and
customer-authorized Paystack checkout. There is no public fixed-price plan,
44-ride product requirement or prepaid cash wallet. Amounts use integer pesewas.

Current rules live in feature docs and operating guides. Historical reports
and architecture decision records have been removed; Git preserves their history.
