# User profile & avatars

**Owner:** Godfred Awuku · **Last updated:** 2026-07-05 · **Issue:** #24

Profile edits and the avatar upload that feeds the **photo pass** (the driver
sees the rider's name + photo at boarding — E4 manifest, `security.md §7`).
Avatars live in **Cloudflare R2** (S3-compatible, zero egress); the bucket is
**private** and images are served only through **short-lived signed URLs**.

---

## Concepts

- **Server-side processing is mandatory.** Every upload is **resized to 256×256
  and re-encoded to JPEG** on the server (`sharp`). The re-encode **strips EXIF**
  — phone photos embed GPS/PII in metadata, which must never reach storage. A
  client cannot bypass this by pre-sizing: we always re-encode.
- **Key, not URL, in the DB.** `users.avatar_url` stores the R2 **object key**
  (`avatars/<userId>`), never a public URL. Responses swap it for a **signed GET
  URL** (default TTL 300s) at serialization time.
- **Proxy upload, not presigned PUT.** The image flows through the API so the
  server controls resize/validation; R2 ingress is free and avatars are tiny.
- **Selected by env.** All four `R2_*` vars set → real R2; any unset → an
  in-memory Fake (zero-infra dev/tests). Same pattern as Redis/Paystack.

---

## API

#### `GET /me` _(in auth.routes)_

Returns the user; `avatarUrl` is a **signed URL** when an avatar is set, else null.

#### `PATCH /me`

Update editable profile fields.

- **Auth:** `Bearer`. **Rate limit:** per user.
- **Body:** `{ "displayName": "Ama Mensah" }` (1–80 chars, trimmed)
- **200:** the updated user · **400** invalid · **401** · **404** · **503**

#### `POST /me/avatar`

Upload an avatar (**multipart/form-data**, field `file`).

- **Auth:** `Bearer`. **Rate limit:** per user.
- **Accepts:** JPEG/PNG/WebP, ≤ 5 MB — resized to 256px JPEG, EXIF stripped.
- **200:** `{ "avatarUrl": "<signed URL>" }`
- **400** not an image / unsupported type · **401** · **404** · **413** too large · **503**

#### `GET /me/avatar`

- **200:** `{ "avatarUrl": "<signed URL>" }` · **404** no avatar set · **401** · **503**

---

## Data

`users.avatar_url` (existing column) holds the R2 object key `avatars/<userId>`.
No migration needed.

## Configuration

| Env var                | Notes                                                                    |
| ---------------------- | ------------------------------------------------------------------------ |
| `R2_ACCOUNT_ID`        | Cloudflare account id → endpoint `https://<id>.r2.cloudflarestorage.com` |
| `R2_ACCESS_KEY_ID`     | R2 **S3 API** token — Access Key ID (secret; dashboard only)             |
| `R2_SECRET_ACCESS_KEY` | R2 **S3 API** token — Secret Access Key (secret; dashboard only)         |
| `R2_BUCKET`            | bucket name, e.g. `trotxi-avatars` (keep it **private**)                 |

All four unset (or partial) → in-memory Fake object store. Cloudflare's native
**API "Token value" is not used** — we authenticate via the S3 keys.

## Security notes

- **EXIF/PII stripped** on every upload (re-encode) — no location leaks.
- **Private bucket + short-lived signed URLs** — no public avatar URLs; a leaked
  link expires in ~5 min.
- **Raw object key never exposed** — responses always sign it.
- **Server-authoritative size/type** — client-declared MIME is checked _and_ the
  bytes must decode as an image, or it's a 400.

## Where the code lives

```
services/api/src/storage/
  object-store.ts        # ObjectStore interface + FakeObjectStore + avatarKey
  object-store.r2.ts     # Cloudflare R2 impl (S3 SDK; excluded from unit coverage)
services/api/src/modules/users/
  avatar.ts              # sharp resize + EXIF-strip (processAvatar)
  users.routes.ts        # PATCH /me, POST /me/avatar, GET /me/avatar
  user.presenter.ts      # toUserResponse — signs the avatar key
  user.repository.ts(.pg)# updateProfile + setAvatarKey
```

## Related

- `strategy/system-design.md §4.3` (photo pass) · `security.md §7` (object storage, PII)
- Feeds **E4** (boarding manifest) — ADR-0014
