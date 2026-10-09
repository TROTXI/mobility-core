# Technical references

Product behavior starts in [features](../features/README.md).
This directory holds current safety references and executable contract tooling,
not a history of the backend redesign.

## Current feature details

- [Phone verification](commuter-phone-verification.md)
- Account erasure: [data map](account-erasure-data-map.md),
  [retention](account-erasure-retention-policy.md),
  [operations checklist](account-erasure-operations-checklist.md) and
  [restore recovery](account-erasure-recovery.md)
- [Incident retention](driver-incident-retention.md)
- [Ops audit coverage](ops-audit-coverage.md)
- [Observability](observability.md)

## Contract tooling

- [Executable schemas](contracts/target-contract.mjs)
- [Implemented OpenAPI](contracts/replacement.openapi.json)
- [Full catalog including deferred operations](contracts/target.openapi.json)
- Generation and validation in `scripts/`

The generated `stage-1-endpoints.md`, `stage-1-invariants.md` and
`stage-2-operation-scope.md` are inventories used by generation/CI, not
developer setup guides or current deployment reports. Keep them synchronized
through their generators; do not edit them by hand.

Historical reports and proposals are removed from the working tree and remain
available through Git. Use the [developer guide](../development.md) for changes.
