import { createHash, createHmac } from 'node:crypto';
import type { JournalStore } from '../account/erasure-journal.js';

export interface ErasureStoreConfig {
  accountId: string;
  accessKeyId: string;
  secretAccessKey: string;
  bucket: string;
  namespace: string;
  key: Buffer;
}
const hash = (value: Buffer | string) => createHash('sha256').update(value).digest('hex');
const mac = (key: Buffer, value: string) => createHmac('sha256', key).update(value).digest();

/** Private dedicated bucket; no list, public URL, delete or bucket-creation API. */
export class R2ErasureJournalStore implements JournalStore {
  constructor(
    private readonly config: ErasureStoreConfig,
    private readonly request: typeof fetch = fetch,
  ) {
    if (
      !/^[a-f0-9]{32}$/.test(config.accountId) ||
      !/^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$/.test(config.bucket)
    )
      throw new Error('erasure_store_configuration_invalid');
    if (!/^[a-f0-9-]{36}$/.test(config.namespace)) throw new Error('erasure_namespace_invalid');
  }
  private async send(method: 'GET' | 'PUT', body?: Buffer, etag?: string | null) {
    const host = `${this.config.accountId}.r2.cloudflarestorage.com`;
    const path = `/${this.config.bucket}/erasure-register/${this.config.namespace}.bin`;
    const dateTime = new Date().toISOString().replaceAll(/[-:]|\.\d{3}/g, '');
    const date = dateTime.slice(0, 8);
    const headers: Record<string, string> = {
      host,
      'x-amz-date': dateTime,
      'x-amz-content-sha256': hash(body ?? ''),
    };
    if (method === 'PUT') {
      if (etag !== null && (typeof etag !== 'string' || !/^"[a-zA-Z0-9-]+"$/.test(etag)))
        throw new Error('erasure_store_etag_invalid');
      headers[etag === null ? 'if-none-match' : 'if-match'] = etag ?? '*';
      headers['content-type'] = 'application/octet-stream';
    }
    const names = Object.keys(headers).sort();
    const canonical = [
      method,
      path,
      '',
      ...names.map((name) => `${name}:${headers[name]}`),
      '',
      names.join(';'),
      headers['x-amz-content-sha256'],
    ].join('\n');
    const scope = `${date}/auto/s3/aws4_request`;
    const key = mac(
      mac(mac(mac(Buffer.from(`AWS4${this.config.secretAccessKey}`), date), 'auto'), 's3'),
      'aws4_request',
    );
    headers.authorization = `AWS4-HMAC-SHA256 Credential=${this.config.accessKeyId}/${scope}, SignedHeaders=${names.join(';')}, Signature=${mac(key, ['AWS4-HMAC-SHA256', dateTime, scope, hash(canonical)].join('\n')).toString('hex')}`;
    return this.request(`https://${host}${path}`, {
      method,
      headers,
      body: body ? new Uint8Array(body) : undefined,
      redirect: 'error',
      signal: AbortSignal.timeout(5000),
    });
  }
  async read() {
    const response = await this.send('GET');
    if (response.status === 404) {
      await response.body?.cancel();
      return null;
    }
    if (!response.ok) {
      await response.body?.cancel();
      throw new Error('erasure_store_read_failed');
    }
    const etag = response.headers.get('etag');
    if (!etag || !response.body) {
      await response.body?.cancel();
      throw new Error('erasure_store_response_invalid');
    }
    const chunks: Uint8Array[] = [];
    let size = 0;
    const reader = response.body.getReader();
    try {
      for (;;) {
        const chunk = await reader.read();
        if (chunk.done) break;
        size += chunk.value.length;
        if (size > 2 * 1024 * 1024) throw new Error('erasure_store_response_too_large');
        chunks.push(chunk.value);
      }
    } finally {
      await reader.cancel();
    }
    return { etag, bytes: Buffer.concat(chunks) };
  }
  async replace(bytes: Buffer, etag: string | null) {
    if (bytes.length > 2 * 1024 * 1024) throw new Error('erasure_store_payload_too_large');
    const response = await this.send('PUT', bytes, etag);
    await response.body?.cancel();
    if (!response.ok)
      throw new Error(
        response.status === 412 ? 'erasure_store_conflict' : 'erasure_store_write_failed',
      );
  }
}
