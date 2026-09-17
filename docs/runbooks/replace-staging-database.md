# Disposable staging cutover

Target: `trotxi` on `dpg-d8sugvv7f7vs73bifff0-a` only. The owner approved
discarding the legacy fixtures and retaining the existing database credentials.
Do not create another database, login, or set of service secrets.

1. Verify the exact database and list the non-extension legacy tables read-only.
2. Prepare the tested replacement image and confirm the existing settings load.
3. In one transaction, remove only the inventoried legacy application relations,
   install the reviewed 001–021 migrations, and record their hashes in
   `public._replacement_migrations`. Preserve extension-owned PostGIS objects.
   Roll back the whole transaction on failure. Do not run against an existing
   `app` schema or against a database with retained data.
4. Deploy the reviewed main commit to `trotxi-api-staging`, using
   `services/api-next/Dockerfile`. Verify health, readiness, version and v1 routes.

The reset is a one-time operator action, not a startup flag or CI workflow.
Future deployments apply pending migrations automatically and verify old hashes.
The staging-only owner-login exception is explicitly approved; normal deployment
configuration continues to require a restricted runtime login.

Existing Render values remain unchanged: DATABASE_URL, JWT_SECRET, Paystack TEST,
Google and R2 credentials. Internal cryptographic keys derive from JWT_SECRET;
changing that root invalidates tokens and requires a retained-ciphertext plan.
