// Cloudflare R2 ObjectStore (the real impl behind object-store.ts). R2 speaks
// the S3 API, so we use the AWS S3 SDK pointed at the account's R2 endpoint.
// The bucket is private; reads go through presigned GET URLs (zero egress on R2).
// Excluded from unit coverage (needs a live bucket) — exercised via staging.

import { GetObjectCommand, PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { avatarKey, SIGNED_URL_TTL_SECONDS, type ObjectStore } from './object-store';

/** Credentials + bucket for an R2-backed {@link ObjectStore}. */
export interface R2Config {
  accountId: string;
  accessKeyId: string;
  secretAccessKey: string;
  bucket: string;
}

export class R2ObjectStore implements ObjectStore {
  private readonly client: S3Client;

  constructor(private readonly config: R2Config) {
    this.client = new S3Client({
      region: 'auto',
      endpoint: `https://${config.accountId}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: config.accessKeyId,
        secretAccessKey: config.secretAccessKey,
      },
    });
  }

  async putAvatar(userId: string, bytes: Buffer, contentType: string): Promise<string> {
    const key = avatarKey(userId);
    await this.client.send(
      new PutObjectCommand({
        Bucket: this.config.bucket,
        Key: key,
        Body: bytes,
        ContentType: contentType,
      }),
    );
    return key;
  }

  async signedUrl(key: string, ttlSeconds = SIGNED_URL_TTL_SECONDS): Promise<string> {
    return getSignedUrl(
      this.client,
      new GetObjectCommand({ Bucket: this.config.bucket, Key: key }),
      { expiresIn: ttlSeconds },
    );
  }
}
