import type { Pool } from 'pg';
import type {
  NewPaymentWebhookEvent,
  PaymentWebhookEvent,
  PaymentWebhookRepository,
} from './payment-webhook.repository';

interface WebhookRow {
  id: string;
  payload_sha256: string;
  event_type: string;
  reference: string | null;
  raw_body: string;
  payload: unknown;
  attempts: number;
}

function toEvent(row: WebhookRow): PaymentWebhookEvent {
  return {
    id: row.id,
    payloadSha256: row.payload_sha256,
    eventType: row.event_type,
    reference: row.reference,
    rawBody: row.raw_body,
    payload: row.payload,
    attempts: row.attempts,
  };
}

/** PostgreSQL inbox; SKIP LOCKED allows multiple workers without duplicate work. */
export class PgPaymentWebhookRepository implements PaymentWebhookRepository {
  constructor(private readonly pool: Pool) {}

  async enqueue(event: NewPaymentWebhookEvent): Promise<void> {
    await this.pool.query(
      `INSERT INTO payment_webhook_events
         (payload_sha256, event_type, reference, raw_body, payload)
       VALUES ($1, $2, $3, $4, $5::jsonb)
       ON CONFLICT (payload_sha256) DO NOTHING`,
      [
        event.payloadSha256,
        event.eventType,
        event.reference ?? null,
        event.rawBody,
        JSON.stringify(event.payload),
      ],
    );
  }

  async claimBatch(limit: number, staleBefore: Date): Promise<PaymentWebhookEvent[]> {
    const { rows } = await this.pool.query<WebhookRow>(
      `WITH claimed AS (
         SELECT id
           FROM payment_webhook_events
          WHERE (status IN ('received', 'failed')
             OR (status = 'processing' AND processing_at <= $2)
            ) AND attempts < 10
          ORDER BY received_at
          LIMIT $1
          FOR UPDATE SKIP LOCKED
       )
       UPDATE payment_webhook_events event
          SET status = 'processing', processing_at = now(), attempts = event.attempts + 1
         FROM claimed
        WHERE event.id = claimed.id
       RETURNING event.*`,
      [Math.max(0, limit), staleBefore],
    );
    return rows.map(toEvent);
  }

  async markProcessed(id: string): Promise<void> {
    await this.pool.query(
      `UPDATE payment_webhook_events
          SET status = 'processed', processed_at = now(), last_error = NULL
        WHERE id = $1`,
      [id],
    );
  }

  async markFailed(id: string, error: string): Promise<void> {
    await this.pool.query(
      `UPDATE payment_webhook_events SET status = 'failed', last_error = $2 WHERE id = $1`,
      [id, error.slice(0, 2_000)],
    );
  }
}
