// Push notifications (E3). A seam over the delivery channel: the daily
// ask-dispatch calls send(). The real backend is Firebase Cloud Messaging
// (notification.sender.live.ts), wired when FIREBASE_SERVICE_ACCOUNT is set; the
// Fake below records + logs for dev/tests so the ask-dispatch flow is fully
// exercisable without a network.

/** A push to one user (fanned out to their registered devices by the sender). */
export interface Notification {
  userId: string;
  title: string;
  body: string;
  /** Small key/value payload the app reads on tap (e.g. tripId, travelDate). */
  data?: Record<string, string>;
}

/** Delivers push notifications (FCM in prod, a recording fake in dev/tests). */
export interface NotificationSender {
  /**
   * Send a push to a user's devices. Best-effort: implementations must not throw
   * on a delivery failure (a dead token can't fail the ask-dispatch).
   *
   * @param notification - who to notify and what to say.
   */
  send(notification: Notification): Promise<void>;
}

/** Recording {@link NotificationSender} for dev and unit tests (no network). */
export class FakeNotificationSender implements NotificationSender {
  /** Everything "sent", for assertions and dev inspection. */
  readonly sent: Notification[] = [];

  async send(notification: Notification): Promise<void> {
    this.sent.push(notification);
    console.log(`[notify] → ${notification.userId}: ${notification.title}`);
  }
}
