/** Test-only extension point. No candidate adapter is implemented in stage 2. */
export interface HarnessAdapter {
  /** Translate domain actions from catalog.mjs; unknown actions must throw. */
  act(action: Record<string, unknown>): Promise<unknown>;
  /** Query committed persistence; never manufacture observations from expectations. */
  observe(): Promise<{
    state: Record<string, unknown>;
    raw: Record<string, unknown>;
    evidence: Array<Record<string, unknown>>;
  }>;
  metadata(): Promise<Record<string, unknown>>;
  dispose(): Promise<void>;
}

/** Receives a unique, already migrated database for exactly one scenario. */
export type AdapterFactory = (options: { databaseUrl: string }) => Promise<HarnessAdapter>;
