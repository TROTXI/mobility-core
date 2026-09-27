/** Ghana-only pilot numbers; one canonical identity for local and international forms. */
export function ghanaPhone(value: string): string {
  const phone = value.replace(/[ ()-]/g, '');
  const normalized = /^0\d{9}$/.test(phone)
    ? `+233${phone.slice(1)}`
    : /^233\d{9}$/.test(phone)
      ? `+${phone}`
      : phone;
  if (!/^\+233[235]\d{8}$/.test(normalized)) throw new Error('invalid_phone');
  return normalized;
}
export interface SmsSender {
  send(phone: string, text: string, otp: boolean): Promise<string>;
}
export class SmsSendError extends Error {
  constructor() {
    super('sms_delivery_unconfirmed');
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
  async send(phone: string, text: string, otp: boolean): Promise<string> {
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
            is_schedule: false,
            ...(otp ? { sms_type: 'otp' } : {}),
          }),
          redirect: 'error',
          signal: AbortSignal.timeout(10000),
        },
      );
      if (!response.ok) {
        await response.body?.cancel();
        throw new SmsSendError();
      }
      const body = (await response.json()) as {
        code?: unknown;
        status?: unknown;
        summary?: { _id?: unknown; total_sent?: unknown; total_rejected?: unknown };
      };
      if (
        String(body.code) !== '2000' ||
        body.status !== 'success' ||
        body.summary?.total_sent !== 1 ||
        body.summary?.total_rejected !== 0 ||
        typeof body.summary?._id !== 'string'
      )
        throw new SmsSendError();
      return body.summary._id;
    } catch (_) {
      // Never echo provider URLs (API key), response bodies, phone numbers or OTPs.
      // mNotify documents no idempotency token: do not blindly retry uncertain sends.
      throw new SmsSendError();
    }
  }
}
