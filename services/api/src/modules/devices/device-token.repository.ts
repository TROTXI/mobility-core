// Device push-token registry — FCM tokens per user/device (#84). The foundation
// for push notifications: clients register a token at sign-in, and the future
// notification service reads them to deliver messages. Repository pattern
// (ADR-0009): interface + InMemory here, Postgres in *.pg.ts.

/** Mobile platform a push token belongs to. */
export type DevicePlatform = 'android' | 'ios' | 'web';

/** A persisted FCM push token for one of a user's devices. */
export interface DeviceToken {
  id: string;
  userId: string;
  /** The FCM registration token from the device. */
  fcmToken: string;
  platform: DevicePlatform;
  createdAt: Date;
  updatedAt: Date;
}

/** Persistence for device push tokens. */
export interface DeviceTokenRepository {
  /**
   * Register (upsert) an FCM token for a user. A token already registered — even
   * to another user — is re-pointed to this user (one token, one owner).
   *
   * @param userId - the owner of the token.
   * @param fcmToken - the FCM registration token from the device.
   * @param platform - the device platform.
   * @returns the persisted device token.
   */
  register(userId: string, fcmToken: string, platform: DevicePlatform): Promise<DeviceToken>;
  /**
   * Remove a token (e.g. on logout or when the device unregisters). No-op if absent.
   *
   * @param fcmToken - the FCM token to remove.
   */
  removeByToken(fcmToken: string): Promise<void>;
  /**
   * List a user's registered device tokens (for delivering push).
   *
   * @param userId - the user whose tokens to list.
   * @returns the user's device tokens.
   */
  listForUser(userId: string): Promise<DeviceToken[]>;
}

/** In-memory {@link DeviceTokenRepository} for dev and unit tests. */
export class InMemoryDeviceTokenRepository implements DeviceTokenRepository {
  private readonly byToken = new Map<string, DeviceToken>();

  async register(userId: string, fcmToken: string, platform: DevicePlatform): Promise<DeviceToken> {
    const now = new Date();
    const existing = this.byToken.get(fcmToken);
    const token: DeviceToken = {
      id: existing?.id ?? crypto.randomUUID(),
      userId,
      fcmToken,
      platform,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    };
    this.byToken.set(fcmToken, token);
    return token;
  }

  async removeByToken(fcmToken: string): Promise<void> {
    this.byToken.delete(fcmToken);
  }

  async listForUser(userId: string): Promise<DeviceToken[]> {
    return [...this.byToken.values()].filter((t) => t.userId === userId);
  }
}
