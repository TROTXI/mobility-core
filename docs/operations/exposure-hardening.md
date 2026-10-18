# Exposure hardening rollout

## New avatar uploads

The API validates and re-encodes JPEG, PNG and WebP uploads before private object
storage. It applies EXIF orientation, strips metadata and trailing input bytes,
and caps the output at 1024 pixels per edge without enlarging small photos.
The original MIME type and upload digest still determine idempotency.

Inputs must be complete still images within the existing compressed-byte limit,
12 million decoded pixels and 8192 pixels per edge. Native processing has a
five-second timeout and a per-process limit of two concurrent images. Excess
work returns 503 rather than building an unbounded in-memory queue. Decoder
errors are replaced by fixed messages, not exposed or logged as raw metadata.

Authentication precedes decoding, and the existing authorization check before
attaching the object remains in place. Private storage, short-lived signed URLs
and the durable erasure workflow are unchanged. No database migration is needed.

Existing stored photos are **not** cleaned by deployment. Inventory and rewrite
them only through a separately approved cleanup that preserves owner references,
concurrent-upload safety and erasure tracking. Do not claim old photos are free
of metadata based on this change.

## Public Ops bundles

Ops production builds no longer generate source maps. The published JavaScript
and API addresses remain observable and must never contain secrets. This is an
exposure reduction, not an authentication boundary.

Previously published `.map` files may survive in hosting/CDN caches. After an
approved deployment, check the previous asset URLs and arrange a scoped purge
if they remain reachable. A code change does not itself purge old assets.

## Dependencies and secret scanning

Workspace overrides require patched `shell-quote`, `source-map-js` and
`ip-address` versions. The lockfile records the resolved versions. The API also
requires Sharp and its platform-specific runtime packages for image processing;
deployment must retain optional dependencies. Verify the Linux build in CI.

Gitleaks has no whole-file Firebase exceptions. Exceptions are limited to
reviewed paths and public client-key fields for the two detecting rules. Server
credentials and unrelated fields in those files remain scanned. Regression
fixtures are generated at runtime and never use working provider credentials.

## Remaining verification

This source change does not verify Firebase console key restrictions, bucket
public-access settings, Cloudflare rules, hosting access, or production account
permissions. Record read-only infrastructure evidence separately before calling
those controls verified. Never include credential values in that evidence.
