# Ops website content security policy

The staging static site's enforced `Content-Security-Policy` lives in
`render.yaml`. Keep it on the static site, not the API: it governs the document
that runs the React application. `apps/ops/tests/csp.test.ts` guards the audited
source list against accidental broadening or removal.

## Audited resource origins

| Resource                                           | Allowed source                                                          | Reason                                                                                                                                                                                                                                                          |
| -------------------------------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Vite JavaScript, CSS, MapLibre worker and wordmark | `'self'`                                                                | The Ops build is served from its own static origin. The map worker is emitted as a same-origin Vite chunk via `?worker&url`.                                                                                                                                    |
| Google Identity Services                           | `https://accounts.google.com/gsi/client`, `/gsi/` and `/o/fedcm/` paths | The sole external script and its sign-in iframe/network requests. No whole-Google-domain script allowance.                                                                                                                                                      |
| API requests                                       | `https://trotxi-api-staging.onrender.com`                               | The configured staging API origin, including public `/flags` map bootstrap.                                                                                                                                                                                     |
| Map style, PMTiles byte ranges and glyphs          | `https://tiles.trotxi.com`                                              | Both published styles, the Ghana archive and map fonts use this one host.                                                                                                                                                                                       |
| Private avatar images                              | `https://*.r2.cloudflarestorage.com`                                    | The API returns short-lived signed URLs on an account-specific Cloudflare R2 host. This is the only subdomain wildcard; no script, worker or connection directive accepts it. Replace with an exact origin if R2 delivery is moved to a dedicated, stable host. |

`style-src 'unsafe-inline'` is limited to styles: Fluent UI injects styles at
runtime, MapLibre styles its controls, and several React elements use inline
style attributes. **Scripts do not allow `unsafe-inline` or `unsafe-eval`.**
MapLibre needs `img-src data: blob:` for generated map images. Download links
created from Blob objects do not require a script allowance.

The policy has no broad `https:`, `*`, or `blob:` script/worker allowance. It
preserves `frame-ancestors 'none'`, `base-uri 'none'`, `object-src 'none'`, and
the existing anti-framing, referrer and MIME-sniffing headers.

## Required Render apply before deployment

The GitHub deploy workflow calls Render's service-deploy endpoint, which does
**not** sync `render.yaml` headers. After this change is merged, first inspect
the linked Blueprint's proposed changes in Render and manually sync it if the
diff contains only intended staging changes. A Blueprint sync can affect other
services and configuration, so do not apply an unrelated diff just to update
this header. If this static site is not Blueprint-managed, update its
`Content-Security-Policy` under the site's Render Headers settings to match
`render.yaml` exactly. Do not paste the policy into an API service's headers.

The deploy workflow now checks the live Ops response header **before**
deploying anything and again after the Ops deploy. A mismatch fails the run;
apply the header and rerun the workflow. You can check it locally from the
repository root with `bash .github/scripts/check-ops-csp.sh`. The check does
not read credentials or make a test sign-in request.

## Browser deployment check

A matching header does **not** prove the hosted policy works for every browser
flow. After the header is applied and the PR deploys, run this walkthrough with
the console open:

1. In a fresh signed-out session, load the sign-in page. Verify the Google
   button appears, complete Google sign-in, then complete the Ops passkey step.
2. On an already enrolled account, sign out and sign back in with the passkey.
   For a disposable operator, also verify passkey registration.
3. Open Live operations and Dispatch & trips. Check that the basemap, labels,
   planned line, vehicle marker, map worker and zoom controls load in both
   light and dark themes. A blank map or `Basemap unavailable` is a failure.
4. Open a profile with an avatar and a trip manifest with a rider photo to
   verify signed R2 images load; initials alone do not test `img-src`.
5. Check that the browser console has no CSP violations from these flows.
   Record any blocked URL and the directive, then narrow or adjust the source
   list. Do not replace it with a scheme-wide or general wildcard allowance.

If sign-in or dispatch breaks, revert the header change on staging while the
blocked source is diagnosed. Do not mark issue #365 complete solely from a
unit test or a successful static build.

References: [Google Identity Services CSP](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid#content_security_policy),
[MapLibre GL JS CSP](https://maplibre.org/maplibre-gl-js/docs/#csp-directives),
[Render static-site headers](https://render.com/docs/static-site-headers).
