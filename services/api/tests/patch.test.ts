import { describe, expect, it } from 'vitest';
import { applyPatch } from '../src/lib/patch';

describe('applyPatch', () => {
  it('applies defined fields and leaves the base otherwise unchanged', () => {
    const base = { a: 1, b: 'x', c: true };
    expect(applyPatch(base, { b: 'y' })).toEqual({ a: 1, b: 'y', c: true });
  });

  it('ignores keys whose value is undefined (omitted → unchanged)', () => {
    const base = { a: 1, b: 'x' };
    expect(applyPatch(base, { a: undefined, b: 'y' })).toEqual({ a: 1, b: 'y' });
  });

  it('applies an explicit null (clears a nullable field)', () => {
    const base = { a: 1, note: 'keep' as string | null };
    expect(applyPatch(base, { note: null })).toEqual({ a: 1, note: null });
  });

  it('does not mutate the base object', () => {
    const base = { a: 1 };
    applyPatch(base, { a: 2 });
    expect(base.a).toBe(1);
  });
});
