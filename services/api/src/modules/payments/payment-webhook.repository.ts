/** Work item persisted before a provider webhook is acknowledged. */
export interface PaymentWebhookEvent {
  id: string;
  payloadSha256: string;
  eventType: string;
  reference: string | null;
  rawBody: string;
  payload: unknown;
  attempts: number;
}

/** Provider event fields accepted by the durable inbox. */
export interface NewPaymentWebhookEvent {
  payloadSha256: string;
  eventType: string;
  reference?: string | null;
  rawBody: string;
  payload: unknown;
}

/** Durable inbox with competing-consumer claims. */
export interface PaymentWebhookRepository {
  /** Persist an event once, deduplicated by raw-payload digest. */
  enqueue(event: NewPaymentWebhookEvent): Promise<void>;
  /** Atomically claim retryable work, including abandoned stale claims. */
  claimBatch(limit: number, staleBefore: Date): Promise<PaymentWebhookEvent[]>;
  /** Mark successful work terminal. */
  markProcessed(id: string): Promise<void>;
  /** Keep failed work retryable and record a bounded diagnostic. */
  markFailed(id: string, error: string): Promise<void>;
}

interface StoredEvent extends PaymentWebhookEvent {
  status: 'received' | 'processing' | 'processed' | 'failed';
  receivedAt: Date;
  processingAt: Date | null;
  lastError: string | null;
}

/** In-memory inbox for tests and local development. */
export class InMemoryPaymentWebhookRepository implements PaymentWebhookRepository {
  private readonly events = new Map<string, StoredEvent>();

  async enqueue(event: NewPaymentWebhookEvent): Promise<void> {
    if (this.events.has(event.payloadSha256)) return;
    this.events.set(event.payloadSha256, {
      id: crypto.randomUUID(),
      payloadSha256: event.payloadSha256,
      eventType: event.eventType,
      reference: event.reference ?? null,
      rawBody: event.rawBody,
      payload: event.payload,
      status: 'received',
      attempts: 0,
      receivedAt: new Date(),
      processingAt: null,
      lastError: null,
    });
  }

  async claimBatch(limit: number, staleBefore: Date): Promise<PaymentWebhookEvent[]> {
    const claimable = [...this.events.values()]
      .filter(
        (event) =>
          event.attempts < 10 &&
          (event.status === 'received' ||
            event.status === 'failed' ||
            (event.status === 'processing' &&
              event.processingAt !== null &&
              event.processingAt.getTime() <= staleBefore.getTime())),
      )
      .sort((a, b) => a.receivedAt.getTime() - b.receivedAt.getTime())
      .slice(0, Math.max(0, limit));
    const now = new Date();
    for (const event of claimable) {
      event.status = 'processing';
      event.processingAt = now;
      event.attempts++;
    }
    return claimable;
  }

  async markProcessed(id: string): Promise<void> {
    const event = [...this.events.values()].find((candidate) => candidate.id === id);
    if (event) event.status = 'processed';
  }

  async markFailed(id: string, error: string): Promise<void> {
    const event = [...this.events.values()].find((candidate) => candidate.id === id);
    if (event) {
      event.status = 'failed';
      event.lastError = error;
    }
  }
}
