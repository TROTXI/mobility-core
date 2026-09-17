import { createHmac, timingSafeEqual } from 'node:crypto';
import { fail } from './errors.js';

// 79 bytes / 106 base64url chars: fits the reviewed 128-character cursor.
// Keep all six PostgreSQL microsecond digits; Date would lose the tie-breaker.
export function cursorCodec(secret: Buffer) {
  if (secret.length < 32)
    throw new Error('A separate cursor signing secret of at least 32 bytes is required');
  const mac = (bytes: Buffer | string) =>
    createHmac('sha256', secret).update(bytes).digest().subarray(0, 16);
  return {
    encode(time: string, id: string, context: string, now: Date) {
      if (!/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{6}Z$/.test(time))
        throw new Error('Invalid persisted cursor timestamp');
      const expiry = Buffer.alloc(4);
      expiry.writeUInt32BE(Math.floor(now.getTime() / 1000) + 86400);
      const value = Buffer.concat([
        Buffer.from(time),
        Buffer.from(id.replaceAll('-', ''), 'hex'),
        expiry,
        mac(context),
      ]);
      return Buffer.concat([value, mac(value)]).toString('base64url');
    },
    decode(token: string, context: string, now: Date) {
      const value = Buffer.from(token, 'base64url');
      const bad = () => fail(400, 'invalid_cursor', 'The page cursor is invalid or expired.');
      if (value.length !== 79 || value.toString('base64url') !== token) return bad();
      if (
        !timingSafeEqual(mac(value.subarray(0, 63)), value.subarray(63)) ||
        !timingSafeEqual(mac(context), value.subarray(47, 63)) ||
        value.readUInt32BE(43) <= Math.floor(now.getTime() / 1000)
      )
        return bad();
      const id = value.subarray(27, 43).toString('hex');
      return {
        time: value.subarray(0, 27).toString(),
        id: `${id.slice(0, 8)}-${id.slice(8, 12)}-${id.slice(12, 16)}-${id.slice(16, 20)}-${id.slice(20)}`,
      };
    },
  };
}
