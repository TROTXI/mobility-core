import { createCipheriv, createDecipheriv, createHmac, randomBytes } from 'node:crypto';

export function credentialReplay(key: Buffer) {
  if (!Buffer.isBuffer(key) || key.length !== 32)
    throw new Error('Dedicated 32-byte credential replay key required');
  return {
    digest(input: string) {
      return createHmac('sha256', key)
        .update('trotxi:driver-input:v1:')
        .update(input)
        .digest('hex');
    },
    seal(value: unknown, scope: string) {
      const iv = randomBytes(12),
        cipher = createCipheriv('aes-256-gcm', key, iv);
      cipher.setAAD(Buffer.from(`trotxi:driver-replay:v1:${scope}`));
      return Buffer.concat([
        iv,
        cipher.update(JSON.stringify(value), 'utf8'),
        cipher.final(),
        cipher.getAuthTag(),
      ]).toString('base64url');
    },
    open(value: string, scope: string): unknown {
      const bytes = Buffer.from(value, 'base64url');
      if (bytes.length < 29) throw new Error('Invalid encrypted credential replay');
      const cipher = createDecipheriv('aes-256-gcm', key, bytes.subarray(0, 12));
      cipher.setAAD(Buffer.from(`trotxi:driver-replay:v1:${scope}`));
      cipher.setAuthTag(bytes.subarray(-16));
      return JSON.parse(
        Buffer.concat([cipher.update(bytes.subarray(12, -16)), cipher.final()]).toString('utf8'),
      );
    },
  };
}
