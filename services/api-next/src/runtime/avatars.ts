import { createHash, createHmac, randomUUID } from 'node:crypto';
import type { AvatarStore } from '../account/service.js';

export interface ObjectStoreOptions {
  accountId: string;
  accessKeyId: string;
  secretAccessKey: string;
  bucket: string;
  /** Swapped in tests; production uses the platform fetch. */
  request?: typeof fetch;
  /** Swapped in tests so a signature can be compared against a fixed clock. */
  now?: () => Date;
}

const EXTENSIONS: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};
/** What this store is allowed to name, and therefore allowed to sign. */
const UUID = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}';
const KEY = new RegExp(`^avatars/${UUID}/${UUID}\\.(jpg|png|webp)$`);
const REGION = 'auto';
const UNSIGNED = 'UNSIGNED-PAYLOAD';

const sha256 = (value: string | Buffer) => createHash('sha256').update(value).digest('hex');
const hmac = (key: Buffer, value: string) => createHmac('sha256', key).update(value).digest();
/** RFC 3986, which is stricter than encodeURIComponent about !'()* */
const escape = (value: string) =>
  encodeURIComponent(value).replaceAll(
    /[!'()*]/g,
    (c) => `%${c.charCodeAt(0).toString(16).toUpperCase()}`,
  );
const escapePath = (value: string) => value.split('/').map(escape).join('/');

/**
 * Cloudflare R2 through its S3 API, signed here rather than through an SDK.
 *
 * The bytes have already been checked against the declared type by the account
 * service; this only names, stores, signs and removes them. Every object key
 * this store hands out is one it generated, and it refuses to sign or delete
 * anything that does not have that shape, so a stored key that was tampered
 * with cannot escape the prefix or address a path of the caller's choosing.
 *
 * The shape alone does not say whose object it is: a well-formed key naming
 * another rider's id is still well formed. What keeps them apart is that the
 * key is only ever read back from the requester's own row.
 */
export class R2ObjectStore implements AvatarStore {
  private readonly host: string;
  private readonly fetch: typeof fetch;
  constructor(private readonly options: ObjectStoreOptions) {
    for (const [name, value] of Object.entries({
      accountId: options.accountId,
      accessKeyId: options.accessKeyId,
      secretAccessKey: options.secretAccessKey,
      bucket: options.bucket,
    }))
      if (!value || typeof value !== 'string')
        throw new Error(`Object storage ${name} is required`);
    if (!/^[a-z0-9][a-z0-9.-]{1,62}$/.test(options.bucket))
      throw new Error('Object storage bucket name is not a bucket name');
    this.host = `${options.accountId}.r2.cloudflarestorage.com`;
    this.fetch = options.request ?? fetch;
  }

  private signingKey(date: string): Buffer {
    return hmac(
      hmac(hmac(hmac(Buffer.from(`AWS4${this.options.secretAccessKey}`), date), REGION), 's3'),
      'aws4_request',
    );
  }
  private stamps(now: Date = this.options.now?.() ?? new Date()) {
    const amzDate = now.toISOString().replaceAll(/[-:]|\.\d{3}/g, '');
    return { amzDate, date: amzDate.slice(0, 8) };
  }
  private path(objectKey: string) {
    return `/${escape(this.options.bucket)}/${escapePath(objectKey)}`;
  }

  async put(request: { userId: string; bytes: Buffer; contentType: string }) {
    const extension = EXTENSIONS[request.contentType];
    if (!extension) throw new Error('Unsupported avatar media type');
    const objectKey = `avatars/${request.userId.toLowerCase()}/${randomUUID()}.${extension}`;
    // What this store mints has to be what it will later agree to sign.
    if (!KEY.test(objectKey)) throw new Error('Object storage owner is not a user id');
    const { amzDate, date } = this.stamps();
    const payloadHash = sha256(request.bytes);
    const headers: Record<string, string> = {
      'content-type': request.contentType,
      host: this.host,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
    };
    const signed = Object.keys(headers).sort();
    const canonical = [
      'PUT',
      this.path(objectKey),
      '',
      ...signed.map((name) => `${name}:${headers[name]}`),
      '',
      signed.join(';'),
      payloadHash,
    ].join('\n');
    const scope = `${date}/${REGION}/s3/aws4_request`;
    const signature = hmac(
      this.signingKey(date),
      ['AWS4-HMAC-SHA256', amzDate, scope, sha256(canonical)].join('\n'),
    ).toString('hex');
    const response = await this.fetch(`https://${this.host}${this.path(objectKey)}`, {
      method: 'PUT',
      body: new Uint8Array(request.bytes),
      redirect: 'error',
      signal: AbortSignal.timeout(15000),
      headers: {
        ...headers,
        authorization: `AWS4-HMAC-SHA256 Credential=${this.options.accessKeyId}/${scope}, SignedHeaders=${signed.join(';')}, Signature=${signature}`,
      },
    });
    // A store that did not take the bytes has not stored them. Recording the
    // key anyway would leave an account pointing at an object that is not there.
    if (!response.ok) throw new Error(`avatar_store_rejected_${response.status}`);
    return { objectKey };
  }

  /**
   * Query-signed GET. Local arithmetic only: never a network call, so it is
   * also safe to call while a database lock is held.
   */
  sign(objectKey: string, expiresInSeconds: number): string | null {
    if (!KEY.test(objectKey)) return null;
    if (!Number.isInteger(expiresInSeconds) || expiresInSeconds < 1 || expiresInSeconds > 604800)
      return null;
    const { amzDate, date } = this.stamps();
    const scope = `${date}/${REGION}/s3/aws4_request`;
    const query = [
      ['X-Amz-Algorithm', 'AWS4-HMAC-SHA256'],
      ['X-Amz-Credential', `${this.options.accessKeyId}/${scope}`],
      ['X-Amz-Date', amzDate],
      ['X-Amz-Expires', String(expiresInSeconds)],
      ['X-Amz-SignedHeaders', 'host'],
    ]
      .map(([name, value]) => [escape(name!), escape(value!)] as const)
      .sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0))
      .map(([name, value]) => `${name}=${value}`)
      .join('&');
    const canonical = [
      'GET',
      this.path(objectKey),
      query,
      `host:${this.host}`,
      '',
      'host',
      UNSIGNED,
    ].join('\n');
    const signature = hmac(
      this.signingKey(date),
      ['AWS4-HMAC-SHA256', amzDate, scope, sha256(canonical)].join('\n'),
    ).toString('hex');
    return `https://${this.host}${this.path(objectKey)}?${query}&X-Amz-Signature=${signature}`;
  }
  /** The AvatarStore port, which the account and boarding services await. */
  async signedUrl(objectKey: string, expiresInSeconds: number): Promise<string | null> {
    return this.sign(objectKey, expiresInSeconds);
  }

  /** Erasure's physical half. A refusal is reported, never treated as done. */
  async remove(objectKey: string): Promise<void> {
    if (!KEY.test(objectKey)) throw new Error('avatar_key_unrecognised');
    const { amzDate, date } = this.stamps();
    const headers: Record<string, string> = {
      host: this.host,
      'x-amz-content-sha256': sha256(''),
      'x-amz-date': amzDate,
    };
    const signed = Object.keys(headers).sort();
    const canonical = [
      'DELETE',
      this.path(objectKey),
      '',
      ...signed.map((name) => `${name}:${headers[name]}`),
      '',
      signed.join(';'),
      headers['x-amz-content-sha256'],
    ].join('\n');
    const scope = `${date}/${REGION}/s3/aws4_request`;
    const signature = hmac(
      this.signingKey(date),
      ['AWS4-HMAC-SHA256', amzDate, scope, sha256(canonical)].join('\n'),
    ).toString('hex');
    const response = await this.fetch(`https://${this.host}${this.path(objectKey)}`, {
      method: 'DELETE',
      redirect: 'error',
      signal: AbortSignal.timeout(15000),
      headers: {
        ...headers,
        authorization: `AWS4-HMAC-SHA256 Credential=${this.options.accessKeyId}/${scope}, SignedHeaders=${signed.join(';')}, Signature=${signature}`,
      },
    });
    // 404 means the object is already gone, which is the state erasure wants.
    if (!response.ok && response.status !== 404)
      throw new Error(`avatar_delete_rejected_${response.status}`);
  }
}
