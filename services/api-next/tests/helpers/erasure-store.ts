import { createHash } from 'node:crypto';
import type { JournalStore } from '../../src/account/erasure-journal.js';

export class MemoryErasureStore implements JournalStore {
  value: { bytes: Buffer; etag: string } | null = null;
  refuse = false;
  loseReply = false;
  async read() {
    return this.value ? { bytes: Buffer.from(this.value.bytes), etag: this.value.etag } : null;
  }
  async replace(bytes: Buffer, etag: string | null) {
    if (this.refuse) throw new Error('refused');
    if ((this.value?.etag ?? null) !== etag) throw new Error('conflict');
    this.value = {
      bytes: Buffer.from(bytes),
      etag: '"' + createHash('sha256').update(bytes).digest('hex') + '"',
    };
    if (this.loseReply) {
      this.loseReply = false;
      throw new Error('lost_reply');
    }
  }
}
