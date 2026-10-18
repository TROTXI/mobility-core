# Public legal and account pages

Pilot pages are static files in `apps/ops/public`. The existing Ops build copies
them into its deployment; they do not require Ops access or JavaScript.

- `/privacy`
- `/delete-account`
- `/terms`

Render rewrites these clean public paths to the static `.html` files before
the Ops SPA fallback. The `.html` URLs remain working compatibility links.
Ops staging is Blueprint-managed: confirm its Blueprint sync applies these
rules when the change merges, then check both clean URLs after deployment.
For a service that is not Blueprint-managed, add the same three
rewrite rules in Render's Redirects/Rewrites settings; deploying files alone
does not apply `render.yaml` settings.

Both mobile apps link to these pages on the existing Ops staging hostname.
No new hosting service, environment variable or secret is required.

## Company website publication (#274 and #275)

The target public addresses are `https://www.trotxi.com/terms`,
`https://www.trotxi.com/privacy` and `https://www.trotxi.com/delete-account`.
All three returned HTTP 404 during this implementation. The company Sites
project was not available to the connected account. This is a publishing blocker,
not a reason to change the apps to dead links or mark the issues complete.

The website owner must publish these repository files together, without a login
wall, challenge requiring an account, analytics additions or an Ops SPA fallback:

- `apps/ops/public/terms.html` at `/terms`
- `apps/ops/public/privacy.html` at `/privacy`
- `apps/ops/public/delete-account.html` at `/delete-account`
- `apps/ops/public/legal.css` at `/legal.css`
- `apps/ops/public/trotxi-wordmark-light.png` and `trotxi-wordmark-dark.png` at the root

Preserve the HTML, accessible headings, relative links and `privacy#choices`
anchor. Add Terms, Privacy and Account deletion links to the company website
footer. Keep the Terms version `2026-10-14`: it matches
`TrotxiPublicInformation.currentTermsVersion` and the signup acceptance record.
The existing Terms apply to commuters. The driver app labels the link
**Commuter terms**; it does not claim those Terms replace a driver/operator
agreement or record driver acceptance of them.

After publication, verify all three URLs return their actual page (not just a
200 homepage), the stylesheet/logos load, links work at narrow widths and 200%
zoom, keyboard focus is visible, and the mailbox can be copied without a mail
app. Verify the page titles and Terms version in an unauthenticated browser.
Only then select the company public-site origin in the reviewed production
mobile policy and production build files under #273. Leave staging unchanged.
Use those exact verified URLs in the store listings and the Play Console data
deletion URL field. A source change does not update either store console.

## App navigation coverage

| App      | Signed out                                                       | Signed in                                                                        |
| -------- | ---------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Commuter | Welcome: Terms, Privacy, deletion                                | Help and support: Terms, Privacy, privacy choices, deletion                      |
| Driver   | Sign in: commuter Terms and Privacy; Can't sign in: deletion too | Profile > Driver information: commuter Terms, Privacy, privacy choices, deletion |

Link widgets retain a selectable URL when the external browser returns failure
or throws. Labels describe external opening, touch targets are at least 48
logical pixels and wrapping supports enlarged text. Widget regression tests
cover URLs, failure paths, semantics and large-text targets. Physical-device
screen-reader and browser checks remain release evidence, not inferred from tests.

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

### Manual case handling

Use the existing restricted privacy mailbox and a restricted case register, not
public GitHub issues. Assign a case reference and an owner for each incoming
request. Record received time, requested scope, acknowledgement time, identity
verification method/result, authorised action and its audit reference, retained
categories/reasons, external cleanup status and next follow-up date. Avoid copying
credentials, identity documents or raw message bodies into a second system.

1. Acknowledge receipt without confirming whether an account exists. Use the same
   neutral response for an unknown account or an unverified requester.
2. Verify control through the existing authenticated flow or an approved
   operations-assisted check. A supplied phone, email or driver code alone is
   insufficient. Never send a verification code to an arbitrary replacement
   address supplied in the request.
3. Confirm scope with the verified owner. Use the authorised erasure workflow;
   do not perform ad hoc SQL deletion, archive a driver as a substitute or bypass
   permissions. Refer disputed ownership to the privacy owner without disclosure.
4. Record the erasure/audit result, retained records and pending external cleanup.
   Follow retries to completion and tell the verified requester what remains.
5. Keep abusive/repeated unverified messages in mailbox spam controls without
   exposing an account lookup or unauthenticated deletion endpoint. Do not discard
   a legitimate request merely because the app is unavailable to the requester.

**Response target pending owner approval:** proposed acknowledgement within three
working days. Do not publish this as an operational commitment until the mailbox
owner approves it. The acknowledgement target is not a guaranteed erasure deadline.
After approval, add the target to the public deletion page, assign a backup owner
and check overdue cases against the approved target.

### Closure evidence still required

- Company website owner publishes the files and footer links; actual public URLs
  are checked without authentication.
- Privacy owner approves the response target and records ownership of the queue.
- Send a clearly labelled delivery-only test from another mailbox, confirm receipt
  and a reply with its case reference. Do not delete a real account for this test.
- In an isolated test environment, walk through a synthetic deletion request,
  unsuccessful identity check, successful verification, authorised erasure and
  retained-record explanation. Confirm unknown-account replies do not enumerate.
- Complete device/browser accessibility checks and production URL/store setup.

Keep #274 and #275 open until their applicable evidence is recorded. Do not add
production credentials or private mailbox destinations to this repository.

## Before store publication

- Verify incoming request delivery and all three deployed public URLs without login.
- Confirm the legal operator/data-controller identity and postal address.
- Add and verify a monitored company phone number before publishing the Terms.
- Have Ghanaian counsel approve the Terms version linked from signup.
- Review legal bases, international transfers and retained-record durations.
- Confirm disclosures against the deployed SDKs and store data declarations.
- Configure the verified public origin in the production build definitions and
  approved environment policy; keep staging configuration separate.

These pages document current behavior; they are not a certification of legal
or app-store compliance. Commuter authenticated deletion remains in-app.
