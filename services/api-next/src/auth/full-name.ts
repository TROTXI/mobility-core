import { fail } from '../transport/errors.js';

export function fullName(input: { firstName?: unknown; lastName?: unknown; otherNames?: unknown }) {
  const part = (value: unknown, max: number, required: boolean): string | null => {
    if ((value === undefined || value === null || value === '') && !required) return null;
    if (typeof value !== 'string') fail(400, 'invalid_name', 'Enter your first and last names.');
    const text = (value as string).trim().replace(/\s+/gu, ' ');
    if (!text || text.length > max || /[\p{Cc}\p{Cf}]/u.test(text))
      fail(400, 'invalid_name', 'Enter a valid full name.');
    return text;
  };
  const firstName = part(input.firstName, 60, true)!;
  const lastName = part(input.lastName, 60, true)!;
  const otherNames = part(input.otherNames, 80, false);
  const displayName = [firstName, otherNames, lastName].filter(Boolean).join(' ');
  if (displayName.length > 200)
    fail(400, 'invalid_name', 'Your full name must be at most 200 characters.');
  return {
    firstName,
    lastName,
    otherNames,
    displayName,
  };
}
