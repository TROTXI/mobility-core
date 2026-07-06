// Object storage for user media (avatars, #24). Repository-style seam (ADR-0009):
// an interface with an in-memory Fake (dev/tests) and a Cloudflare R2 impl
// (object-store.r2.ts), selected by env. Buckets are PRIVATE — objects are read
// only through short-lived signed URLs, never a public URL (security.md §7: the
// avatar is PII, served transiently to the verifying driver).

/**
 * The object key where a user's avatar lives (stored in `users.avatar_url`).
 *
 * @param userId - the avatar owner.
 * @returns the deterministic object key for that user's avatar.
 */
export function avatarKey(userId: string): string {
  return `avatars/${userId}`;
}

/** Default lifetime of a signed avatar URL — long enough to render, short
 * enough that a leaked link dies quickly. */
export const SIGNED_URL_TTL_SECONDS = 300;

/** Storage for user media. R2 in prod, in-memory Fake in dev/tests. */
export interface ObjectStore {
  /**
   * Store a user's avatar bytes (already resized/re-encoded by the caller).
   *
   * @param userId - the avatar owner; determines the object key.
   * @param bytes - the processed image bytes.
   * @param contentType - the stored object's MIME type (e.g. `image/jpeg`).
   * @returns the object key to persist on the user record.
   */
  putAvatar(userId: string, bytes: Buffer, contentType: string): Promise<string>;
  /**
   * Mint a short-lived signed GET URL for an object key.
   *
   * @param key - the object key (from {@link ObjectStore.putAvatar}).
   * @param ttlSeconds - link lifetime (defaults to {@link SIGNED_URL_TTL_SECONDS}).
   * @returns a time-limited URL the client can GET directly.
   */
  signedUrl(key: string, ttlSeconds?: number): Promise<string>;
}

/** In-memory {@link ObjectStore} for dev and unit tests (no network). */
export class FakeObjectStore implements ObjectStore {
  private readonly objects = new Map<string, { bytes: Buffer; contentType: string }>();

  async putAvatar(userId: string, bytes: Buffer, contentType: string): Promise<string> {
    const key = avatarKey(userId);
    this.objects.set(key, { bytes, contentType });
    return key;
  }

  async signedUrl(key: string, ttlSeconds = SIGNED_URL_TTL_SECONDS): Promise<string> {
    return `https://fake-object-store.local/${key}?expires=${ttlSeconds}`;
  }

  /**
   * Test/dev helper: read back stored bytes for a key.
   *
   * @param key - the object key.
   * @returns the stored object, or undefined if absent.
   */
  peek(key: string): { bytes: Buffer; contentType: string } | undefined {
    return this.objects.get(key);
  }
}
