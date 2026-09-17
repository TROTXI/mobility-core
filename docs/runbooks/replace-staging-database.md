# Replace the staging database in place

Wipes the old model out of the existing `trotxi` database and installs the
replacement schema into the same database. One way. There is no undo and no
backup step here: this is written for a database whose contents are
disposable.

The moment the wipe runs, the currently deployed old API starts failing every
request, because its tables are gone. That is expected. It stays broken until
`trotxi-api-staging` is deployed from `services/api-next`.

## 1. Provision the runtime role

The installer refuses to grant to the owner. It needs a separate login role
that cannot create objects and is not a member of anything else. Run this once
as the owner:

```sql
CREATE ROLE trotxi_runtime_v1 LOGIN PASSWORD 'pick-a-strong-one';
REVOKE ALL ON DATABASE trotxi FROM trotxi_runtime_v1;
GRANT CONNECT ON DATABASE trotxi TO trotxi_runtime_v1;
```

The name must match `trotxi_runtime_[a-z0-9_]{1,40}`. If the provider does not
let the owner create roles, create it from the provider's own dashboard.

## 2. Look before leaping

From `services/api-next`, with the **owner** connection string:

```bash
REPLACEMENT_DATABASE_URL='<owner url>' \
REPLACEMENT_RUNTIME_ROLE=trotxi_runtime_v1 \
  node --import tsx scripts/replace-in-place.ts
```

This changes nothing. It prints every relation it would drop with a counted
number of rows, and the total. Read the total. If it is not a number you are
willing to lose, stop.

## 3. Run it

```bash
REPLACEMENT_DATABASE_URL='<owner url>' \
REPLACEMENT_RUNTIME_ROLE=trotxi_runtime_v1 \
REPLACE_IN_PLACE=i-have-read-this \
  node --import tsx scripts/replace-in-place.ts
```

It drops the old relations, then hands over to the ordinary installer, so the
migrations applied are the reviewed files with their recorded hashes. It prints
the installed migration list as JSON on success. Running it a second time is
refused: a database that already has the `app` schema has nothing to replace.

PostGIS is not touched. Extension-owned relations are never dropped, so
`spatial_ref_sys` survives and the extension does not need reinstalling.

## 4. Deploy

Set the 14 required values on `trotxi-api-staging` in the Render dashboard, set
`REPLACEMENT_RUNTIME_DATABASE_URL` to the **runtime** role's connection string,
not the owner's, then deploy. `/healthz` is the check.

The service refuses to start if any required value is missing, and says which
one by name. That is the intended behaviour, not a failure to diagnose.
