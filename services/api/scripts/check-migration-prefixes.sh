#!/usr/bin/env bash
# Fail when two migrations share a numeric prefix (#184).
#
# migrate.ts applies files in `.sort()` order — the FULL filename, not the
# number. Two files numbered 016 therefore run in alphabetical order of their
# description, which nobody writing them is thinking about. Today that is
# harmless; the first pair that actually depends on each other will work on the
# author's machine and fail somewhere else for reasons nobody can see.
#
# NOTE: the fix for a duplicate is never to rename an APPLIED migration.
# _migrations is keyed by filename, so a rename makes the runner treat it as new
# and re-apply it against every environment. Pick the next free number instead.

set -euo pipefail

MIGRATIONS_DIR="$(dirname "$0")/../src/db/migrations"

# Grandfathered: 016_reservation_pin.sql and 016_trip_positions.sql are already
# applied everywhere. They touch unrelated tables and sort deterministically
# (reservation_pin before trip_positions), so the ordering is correct. Renaming
# them would re-run them. Decision recorded in #184 — not an oversight.
GRANDFATHERED="016"

duplicates="$(
  find "$MIGRATIONS_DIR" -name '*.sql' -exec basename {} \; \
    | cut -d_ -f1 \
    | sort \
    | uniq -d \
    | grep -vxF "$GRANDFATHERED" || true
)"

if [ -n "$duplicates" ]; then
  echo "::error::duplicate migration prefixes: $(echo "$duplicates" | tr '\n' ' ')"
  echo ""
  echo "Two migrations share a numeric prefix. Renumber the NEW one to the next"
  echo "free number — never rename a migration that has already been applied,"
  echo "because _migrations is keyed by filename and a rename re-runs it."
  echo ""
  for prefix in $duplicates; do
    echo "  $prefix:"
    find "$MIGRATIONS_DIR" -name "${prefix}_*.sql" -exec basename {} \; | sed 's/^/    /'
  done
  exit 1
fi

echo "migration prefixes are unique (grandfathered: $GRANDFATHERED)"
