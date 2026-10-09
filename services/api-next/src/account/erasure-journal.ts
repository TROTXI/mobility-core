import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
import { z } from 'zod';

export const journalSchema = z
  .object({
    version: z.literal(1),
    namespace: z.uuid(),
    writer: z.uuid(),
    database: z.string().min(1).max(63),
    deviceKeyHash: z.string().regex(/^[a-f0-9]{64}$/),
    revision: z.number().int().nonnegative().max(Number.MAX_SAFE_INTEGER),
    fenced: z.boolean(),
    entries: z.array(z.object({ userId: z.uuid(), sessionId: z.uuid() }).strict()).max(10000),
  })
  .strict();
export type Journal = z.infer<typeof journalSchema>;
export interface JournalStore {
  read(): Promise<{ bytes: Buffer; etag: string } | null>;
  /** Must be an atomic conditional write. null means create only. */
  replace(bytes: Buffer, etag: string | null): Promise<void>;
}
export const keyHash = (key: Buffer) => createHash('sha256').update(key).digest('hex');
export const journalHash = (journal: Journal) => keyHash(Buffer.from(JSON.stringify(journal)));

/** Bounded pilot register. No profile data, provider payloads or auth tokens. */
export class ErasureJournal {
  constructor(
    readonly store: JournalStore,
    readonly namespace: string,
    private readonly key: Buffer,
  ) {
    z.uuid().parse(namespace);
    if (key.length !== 32) throw new Error('erasure_journal_key_invalid');
  }
  private encode(value: Journal) {
    const parsed = journalSchema.parse(value);
    if (parsed.namespace !== this.namespace) throw new Error('erasure_journal_namespace_mismatch');
    const iv = randomBytes(12);
    const cipher = createCipheriv('aes-256-gcm', this.key, iv);
    cipher.setAAD(Buffer.from(`erasure-journal-v1:${this.namespace}`));
    return Buffer.concat([
      iv,
      cipher.update(JSON.stringify(parsed)),
      cipher.final(),
      cipher.getAuthTag(),
    ]);
  }
  async read() {
    const stored = await this.store.read();
    if (!stored) return null;
    if (stored.bytes.length < 28 || stored.bytes.length > 2 * 1024 * 1024)
      throw new Error('erasure_journal_size_invalid');
    const decipher = createDecipheriv('aes-256-gcm', this.key, stored.bytes.subarray(0, 12));
    decipher.setAAD(Buffer.from(`erasure-journal-v1:${this.namespace}`));
    decipher.setAuthTag(stored.bytes.subarray(-16));
    const value = journalSchema.parse(
      JSON.parse(
        Buffer.concat([
          decipher.update(stored.bytes.subarray(12, -16)),
          decipher.final(),
        ]).toString(),
      ),
    );
    if (
      value.namespace !== this.namespace ||
      new Set(value.entries.map((e) => e.userId)).size !== value.entries.length
    )
      throw new Error('erasure_journal_invalid');
    return { value, etag: stored.etag };
  }
  async require() {
    const row = await this.read();
    if (!row) throw new Error('erasure_journal_missing');
    return row;
  }
  async write(value: Journal, etag: string | null) {
    await this.store.replace(this.encode(value), etag);
  }
  assertWriter(value: Journal, writer: string, database: string, deviceKey: Buffer) {
    if (
      value.fenced ||
      value.writer !== writer ||
      value.database !== database ||
      value.deviceKeyHash !== keyHash(deviceKey)
    )
      throw new Error('erasure_journal_writer_fenced');
  }
  async record(
    writer: string,
    database: string,
    deviceKey: Buffer,
    userId: string,
    sessionId: string,
  ) {
    // CAS conflicts are safe failures, not blind overwrites. The client can retry.
    const { value, etag } = await this.require();
    this.assertWriter(value, writer, database, deviceKey);
    if (value.entries.some((entry) => entry.userId === userId)) return;
    await this.write(
      {
        ...value,
        revision: value.revision + 1,
        entries: [...value.entries, { userId, sessionId }],
      },
      etag,
    );
  }
}
