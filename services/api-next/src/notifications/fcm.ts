import { importPKCS8, SignJWT } from 'jose';

export class PushSendError extends Error {
  constructor(
    readonly retryable: boolean,
    readonly invalidToken = false,
  ) {
    super('push_provider_failed');
  }
}
export interface PushSender {
  send(token: string, notificationId: string, reservationId: string): Promise<string>;
}
/** Fixed Google endpoints; service-account token_uri is never used as a URL. */
export class FcmSender implements PushSender {
  private credentials: { project_id: string; client_email: string; private_key: string };
  private cached?: { token: string; until: number };
  constructor(
    json: string,
    private request: typeof fetch = fetch,
  ) {
    let c;
    try {
      c = JSON.parse(json);
    } catch {
      throw new Error('Invalid FIREBASE_SERVICE_ACCOUNT');
    }
    if (!c || typeof c !== 'object') throw new Error('Invalid FIREBASE_SERVICE_ACCOUNT');
    if (
      c.type !== 'service_account' ||
      typeof c.project_id !== 'string' ||
      !/^[a-z0-9-]{6,63}$/.test(c.project_id) ||
      typeof c.client_email !== 'string' ||
      !c.client_email.endsWith('.iam.gserviceaccount.com') ||
      typeof c.private_key !== 'string' ||
      !c.private_key.includes('BEGIN PRIVATE KEY')
    )
      throw new Error('Invalid FIREBASE_SERVICE_ACCOUNT');
    this.credentials = c;
  }
  private async body(res: Response): Promise<any> {
    if (!res.body) throw new PushSendError(true);
    const reader = res.body.getReader(),
      chunks: Uint8Array[] = [];
    let size = 0;
    try {
      for (;;) {
        const part = await reader.read();
        if (part.done) break;
        size += part.value.length;
        if (size > 65536) {
          await reader.cancel();
          throw new PushSendError(true);
        }
        chunks.push(part.value);
      }
      return JSON.parse(Buffer.concat(chunks).toString('utf8'));
    } finally {
      reader.releaseLock();
    }
  }
  private async access(): Promise<string> {
    if (this.cached && this.cached.until > Date.now()) return this.cached.token;
    const c = this.credentials;
    const jwt = await new SignJWT({ scope: 'https://www.googleapis.com/auth/firebase.messaging' })
      .setProtectedHeader({ alg: 'RS256' })
      .setIssuer(c.client_email)
      .setAudience('https://oauth2.googleapis.com/token')
      .setIssuedAt()
      .setExpirationTime('1h')
      .sign(await importPKCS8(c.private_key, 'RS256'));
    const res = await this.request('https://oauth2.googleapis.com/token', {
      method: 'POST',
      redirect: 'error',
      signal: AbortSignal.timeout(10000),
      headers: { 'content-type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    });
    if (!res.ok) throw new PushSendError(true);
    const data = (await this.body(res)) as { access_token?: string; expires_in?: number };
    if (
      typeof data.access_token !== 'string' ||
      data.access_token.length > 8192 ||
      !Number.isFinite(data.expires_in)
    )
      throw new PushSendError(true);
    this.cached = {
      token: data.access_token,
      until: Date.now() + Math.max(0, Math.min(data.expires_in!, 3600) - 60) * 1000,
    };
    return data.access_token;
  }
  async send(token: string, notificationId: string, reservationId: string): Promise<string> {
    try {
      const access = await this.access();
      const res = await this.request(
        `https://fcm.googleapis.com/v1/projects/${this.credentials.project_id}/messages:send`,
        {
          method: 'POST',
          redirect: 'error',
          signal: AbortSignal.timeout(10000),
          headers: { authorization: `Bearer ${access}`, 'content-type': 'application/json' },
          body: JSON.stringify({
            message: {
              token,
              notification: {
                title: 'Confirm your commute',
                body: 'Open Trotxi to confirm or decline your upcoming trip.',
              },
              data: { type: 'reservation_prompt', notificationId, reservationId },
              android: { ttl: '300s', collapse_key: notificationId },
              apns: {
                headers: {
                  'apns-collapse-id': notificationId,
                  'apns-expiration': String(Math.floor(Date.now() / 1000) + 300),
                },
              },
            },
          }),
        },
      );
      const data = (await this.body(res)) as {
        name?: string;
        error?: { details?: Array<{ errorCode?: string }> };
      };
      if (!res.ok) {
        if (res.status === 401) this.cached = undefined;
        const dead = data.error?.details?.some((d) => d.errorCode === 'UNREGISTERED') ?? false;
        throw new PushSendError(
          res.status === 429 || res.status >= 500 || res.status === 401,
          dead,
        );
      }
      if (typeof data.name !== 'string' || data.name.length > 512) throw new PushSendError(true);
      return data.name;
    } catch (e) {
      if (e instanceof PushSendError) throw e;
      throw new PushSendError(true);
    }
  }
}
