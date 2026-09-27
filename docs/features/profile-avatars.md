# Profile, avatars and account erasure

**Owner:** Godfred Awuku · **Last verified:** 2026-09-12

**Status:** Live.

## API

| Endpoint          | Behaviour                                                                |
| ----------------- | ------------------------------------------------------------------------ |
| `GET /me`         | Current user with a short-lived avatar URL when present                  |
| `PATCH /me`       | Update trimmed display name                                              |
| `POST /me/avatar` | Upload JPEG, PNG or WebP up to 5 MB                                      |
| `GET /me/avatar`  | Return a new short-lived signed avatar URL                               |
| `DELETE /me`      | Revoke access and erase personal data while retaining accounting records |

All routes require a bearer token and use the per-user rate limit.

## Avatar processing

Uploads are proxied through the API. Every image is decoded, resized to
256×256 and re-encoded as JPEG with `sharp`; this strips EXIF metadata including
location. The database stores only `avatars/<userId>`, never a public URL.

Production uses a private Cloudflare R2 bucket and approximately five-minute
signed GET URLs. Development and tests use an in-memory object store when any
R2 setting is absent.

## Account erasure

Deletion is idempotent and ordered to cut access before removing identity:

1. Revoke all sessions and remove FCM device tokens.
2. Best-effort revoke Apple access while the provider token is still available.
3. Delete social-identity links so a later sign-in creates a new account.
4. Best-effort delete the avatar object.
5. Anonymise the user row.

The row and stable ID remain because payments, entitlement entries and credit
entries are accounting records. Direct deletion would cascade away the audit
history.

## Configuration

`R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` and `R2_BUCKET` must
all be set for persistent object storage. The bucket remains private.

## Code

- `services/api/src/modules/users/`
- `services/api/src/storage/object-store.*`
- migration `026_account_deletion.sql`
