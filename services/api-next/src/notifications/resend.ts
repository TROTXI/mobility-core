export interface EmailMessage {
  from: string;
  to: string;
  subject: string;
  text: string;
}
export interface EmailSender {
  send(message: EmailMessage, key: string): Promise<string>;
}
export class EmailSendError extends Error {
  constructor(readonly retryable: boolean) {
    // No provider body, address, API key or message content in errors/logs.
    super(retryable ? 'email_provider_unavailable' : 'email_provider_rejected');
  }
}
export class ResendSender implements EmailSender {
  constructor(
    private readonly apiKey: string,
    private readonly request: typeof fetch = fetch,
  ) {
    if (!apiKey.startsWith('re_') || /\s/.test(apiKey)) throw new Error('Invalid RESEND_API_KEY');
  }
  async send(message: EmailMessage, key: string): Promise<string> {
    try {
      const response = await this.request('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
          'Idempotency-Key': key,
        },
        body: JSON.stringify({ ...message, to: [message.to] }),
        signal: AbortSignal.timeout(10000),
        redirect: 'error',
      });
      if (!response.ok) {
        await response.body?.cancel();
        throw new EmailSendError(
          response.status === 429 || response.status === 409 || response.status >= 500,
        );
      }
      const body = (await response.json()) as { id?: unknown };
      if (typeof body.id !== 'string' || !/^[a-zA-Z0-9_-]{1,200}$/.test(body.id))
        throw new EmailSendError(true);
      return body.id;
    } catch (error) {
      if (error instanceof EmailSendError) throw error;
      throw new EmailSendError(true);
    }
  }
}
