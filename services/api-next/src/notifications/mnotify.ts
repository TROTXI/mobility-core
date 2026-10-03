/** Ghana-only pilot numbers; one canonical identity for local and international forms. */
export function ghanaPhone(value: string): string {
  const phone = value.replace(/[ ()-]/g, '');
  const normalized = /^0\d{9}$/.test(phone)
    ? `+233${phone.slice(1)}`
    : /^233\d{9}$/.test(phone)
      ? `+${phone}`
      : phone;
  if (!/^\+233[25]\d{8}$/.test(normalized)) throw new Error('invalid_phone');
  return normalized;
}
export interface SmsSender {
  send(phone: string, text: string): Promise<string>;
}
export class SmsSendError extends Error {
  constructor(readonly outcome: 'rejected' | 'unknown' = 'unknown') {
    super(outcome === 'rejected' ? 'sms_delivery_rejected' : 'sms_delivery_unconfirmed');
  }
}
export class MnotifySender implements SmsSender {
  constructor(
    private readonly key: string,
    private readonly sender: string,
    private readonly request: typeof fetch = fetch,
  ) {
    if (!key || /\s/.test(key) || !/^[A-Za-z0-9 ._-]{1,11}$/.test(sender))
      throw new Error('Valid mNotify key and approved sender ID required');
  }
  async send(phone: string, text: string): Promise<string> {
    try {
      const response = await this.request(
        `https://api.mnotify.com/api/sms/quick?key=${encodeURIComponent(this.key)}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            recipient: [ghanaPhone(phone).slice(1)],
            sender: this.sender,
            message: text,
            // No sms_type 'otp': mNotify bills OTP messages to the cash wallet,
            // not the SMS credit bundle, and refuses them with 402 when it is empty.
            is_schedule: false,
          }),
          redirect: 'error',
          signal: AbortSignal.timeout(10000),
        },
      );
      if (!response.ok) {
        await response.body?.cancel();
        // Explicit client/auth/validation refusals are not lost replies.
        // Timeouts, server errors and redirects remain ambiguous.
        throw new SmsSendError(
          [400, 401, 402, 403, 404, 413, 422, 429].includes(response.status)
            ? 'rejected'
            : 'unknown',
        );
      }
      const body = (await response.json()) as {
        code?: unknown;
        status?: unknown;
        summary?: { _id?: unknown; total_sent?: unknown; total_rejected?: unknown };
      };
      if (body.summary?.total_sent === 0 && body.summary.total_rejected === 1)
        throw new SmsSendError('rejected');
      if (
        String(body.code) !== '2000' ||
        body.status !== 'success' ||
        body.summary?.total_sent !== 1 ||
        body.summary?.total_rejected !== 0 ||
        typeof body.summary?._id !== 'string'
      )
        throw new SmsSendError();
      return body.summary._id;
    } catch (error) {
      // Never echo provider URLs (API key), response bodies, phone numbers or OTPs.
      // mNotify documents no idempotency token: do not blindly retry uncertain sends.
      throw error instanceof SmsSendError ? error : new SmsSendError();
    }
  }
}
