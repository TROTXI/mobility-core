# Public privacy and deletion pages

Pilot pages are static files in `apps/ops/public`. The existing Ops build copies
them into its deployment; they do not require Ops access or JavaScript.

- `/privacy`
- `/delete-account`

Render rewrites these clean public paths to the static `.html` files before
the Ops SPA fallback. The `.html` URLs remain working compatibility links.
Ops staging is Blueprint-managed: confirm its Blueprint sync applies these
rules when the change merges, then check both clean URLs after deployment.
For a service that is not Blueprint-managed, add the same two
rewrite rules in Render's Redirects/Rewrites settings; deploying files alone
does not apply `render.yaml` settings.

Both mobile apps link to these pages on the existing Ops staging hostname.
No new hosting service, environment variable or secret is required.

## Incoming requests

The owner approved `privacy@trotxi.com` forwarding to their monitored Gmail,
then explicitly approved replacing the obsolete Namecheap mail records.
Cloudflare Email Routing now has an active privacy-only rule and a verified
destination. Public MX lookup confirms the three Cloudflare mail servers.
Catch-all forwarding remains disabled. Website, maps, bucket and Resend
subdomain records were not changed. No new application secret is needed.

The pages contain the public alias and mailto request link, not the private
destination. End-to-end incoming delivery still needs confirmation: send a
clearly labelled test from a different mailbox and confirm it reaches the
destination. Do not declare delivery verified merely because DNS is active.

### Previous DNS values (rollback reference)

The following root-domain entries were removed with owner approval. They can
be recreated if necessary; do not mix them with active Cloudflare MX records.

| Type | Name | Value                                              | Priority | TTL  |
| ---- | ---- | -------------------------------------------------- | -------- | ---- |
| MX   | @    | eforward1.registrar-servers.com                    | 10       | Auto |
| MX   | @    | eforward2.registrar-servers.com                    | 10       | Auto |
| MX   | @    | eforward3.registrar-servers.com                    | 10       | Auto |
| MX   | @    | eforward4.registrar-servers.com                    | 15       | Auto |
| MX   | @    | eforward5.registrar-servers.com                    | 20       | Auto |
| TXT  | @    | v=spf1 include:spf.efwd.registrar-servers.com ~all | —        | Auto |

Verify ownership before erasure. Never request PINs, passwords, tokens or card
details. A driver suspension, PIN reset or archive is not account erasure.
Track external cleanup retries and explain legitimately retained records.

## Before store publication

- Verify incoming request delivery and both deployed public URLs without login.
- Confirm the legal operator/data-controller identity and postal address.
- Review legal bases, international transfers and retained-record durations.
- Confirm disclosures against the deployed SDKs and store data declarations.
- Replace staging URLs together in the shared mobile public-information class
  when the production website is selected.

These pages document current behavior; they are not a certification of legal
or app-store compliance. Commuter authenticated deletion remains in-app.
