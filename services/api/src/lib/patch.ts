// Shared helper for partial (PATCH) updates in the repositories. Merging a patch
// over a stored row must treat a key whose value is `undefined` as "not
// provided" — leaving the stored value unchanged — while an explicit `null`
// still clears a nullable field. A plain `{ ...base, ...patch }` spread breaks
// this: an `undefined` in the patch overwrites the stored value (and, on the
// Postgres path, would write NULL). applyPatch copies only defined keys.

/**
 * Merge a partial patch over a base object, ignoring keys whose value is
 * `undefined` (an omitted field leaves the stored value unchanged; an explicit
 * `null` is applied).
 *
 * @param base - the current object.
 * @param patch - the fields to change; `undefined` values are skipped.
 * @returns a new object with the defined patch fields applied.
 */
export function applyPatch<T extends object>(base: T, patch: Partial<T>): T {
  const out = { ...base };
  for (const key of Object.keys(patch) as (keyof T)[]) {
    const value = patch[key];
    if (value !== undefined) out[key] = value as T[keyof T];
  }
  return out;
}
