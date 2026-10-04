# Design and evidence documents

Start with [current features](../features/README.md), [architecture](../architecture.md)
and [implementation status](../STATUS.md). The stale ADR collection has been
removed; its history remains in Git.

## Current controls and runbooks

- [Phone verification](commuter-phone-verification.md)
- [Account erasure data map](account-erasure-data-map.md),
  [retention policy](account-erasure-retention-policy.md),
  [operations checklist](account-erasure-operations-checklist.md) and
  [restore recovery](account-erasure-recovery.md)
- [Incident retention](driver-incident-retention.md)
- [Ops audit coverage](ops-audit-coverage.md)
- [Observability](observability.md)
- [Generated API contract](contracts/replacement.openapi.json)

Use source and tests to resolve discrepancies. A runbook describes a procedure;
it does not establish that production configuration or a scheduled job exists.

## Historical material

The `stage-*` reports, API/database redesign proposals, redesign harness and
invariant notes describe the replacement project's design and staged acceptance.
They are preserved for traceability, not current deployment instructions.
In particular, statements that api-next is undeployed, clients are unmigrated,
or old seeds/migrations are needed must not be used to operate the current API.

Generated stage inventories are contract-build artifacts. Their historical
names do not make the surrounding staged rollout reports current.

Dated hosted-erasure drills and Ops-dispatch acceptance reports establish only
the tested commit, environment and scope. Figma parity notes describe design
comparisons, not proof that every proposed screen or provider integration exists.
