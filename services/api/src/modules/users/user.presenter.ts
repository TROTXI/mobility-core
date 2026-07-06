// Serialize a User for API responses. The DB stores the avatar as a private
// object KEY; clients must never see it — we swap it for a short-lived signed
// URL here, so every route that returns a user does so consistently (#24).

import type { ObjectStore } from '../../storage/object-store';
import type { User } from './user.repository';

/** A user as returned by the API (see `userResponseSchema`). */
export interface UserResponse {
  id: string;
  displayName: string;
  phone: string | null;
  avatarUrl: string | null;
  role: User['role'];
  createdAt: Date;
}

/**
 * Build the public response for a user, signing the stored avatar key into a
 * short-lived URL (null when the user has no avatar).
 *
 * @param user - the persisted user.
 * @param objectStore - used to sign the avatar object key.
 * @returns the client-safe user representation.
 */
export async function toUserResponse(user: User, objectStore: ObjectStore): Promise<UserResponse> {
  return {
    id: user.id,
    displayName: user.displayName,
    phone: user.phone,
    avatarUrl: user.avatarUrl ? await objectStore.signedUrl(user.avatarUrl) : null,
    role: user.role,
    createdAt: user.createdAt,
  };
}
