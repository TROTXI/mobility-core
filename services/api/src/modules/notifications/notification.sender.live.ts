// Firebase Cloud Messaging sender — the real backend behind NotificationSender.
// Looks up a user's registered device tokens (#84) and delivers a multicast
// push, pruning tokens FCM reports as permanently dead. Wired only when
// FIREBASE_SERVICE_ACCOUNT is set (server.ts); dev/tests use the fake. Excluded
// from unit coverage (needs a real Firebase project), like the other *.live/.pg
// integrations.

import { cert, getApps, initializeApp, type App } from 'firebase-admin/app';
import { getMessaging, type Messaging } from 'firebase-admin/messaging';
import type { DeviceTokenRepository } from '../devices/device-token.repository';
import type { Notification, NotificationSender } from './notification.sender';

// FCM error codes that mean the token is gone for good (app uninstalled, token
// rotated) — prune these so we stop delivering to them.
const DEAD_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

/** {@link NotificationSender} backed by Firebase Cloud Messaging. */
export class FcmNotificationSender implements NotificationSender {
  constructor(
    private readonly deviceTokens: DeviceTokenRepository,
    private readonly messaging: Messaging,
  ) {}

  async send(notification: Notification): Promise<void> {
    const tokens = (await this.deviceTokens.listForUser(notification.userId)).map(
      (t) => t.fcmToken,
    );
    if (tokens.length === 0) return;
    try {
      const res = await this.messaging.sendEachForMulticast({
        tokens,
        notification: { title: notification.title, body: notification.body },
        data: notification.data,
      });
      await Promise.all(
        res.responses.map(async (r, i) => {
          const token = tokens[i];
          if (r.success || token === undefined) return;
          if (r.error && DEAD_TOKEN_CODES.has(r.error.code)) {
            await this.deviceTokens.removeByToken(token);
          }
        }),
      );
    } catch (err) {
      // Best-effort (per the interface): a transport/auth failure must not abort
      // the ask-dispatch loop — the seeded reservation is the durable unit.
      console.warn(`[notify] FCM send to ${notification.userId} failed:`, err);
    }
  }
}

/**
 * Build an FCM sender from a service-account JSON string (the
 * `FIREBASE_SERVICE_ACCOUNT` Render secret). Initializes the Firebase Admin app
 * once and reuses it on subsequent calls.
 *
 * @param serviceAccountJson - the service-account key JSON (a secret).
 * @param deviceTokens - the device-token registry to fan out to.
 * @returns an FCM-backed {@link NotificationSender}.
 */
export function createFcmSender(
  serviceAccountJson: string,
  deviceTokens: DeviceTokenRepository,
): FcmNotificationSender {
  const app: App =
    getApps()[0] ?? initializeApp({ credential: cert(JSON.parse(serviceAccountJson)) });
  return new FcmNotificationSender(deviceTokens, getMessaging(app));
}
