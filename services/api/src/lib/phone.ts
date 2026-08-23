// Ghanaian phone-number normalisation (#182).
//
// users.phone is UNIQUE, and Paystack hands the same handset back in at least
// three shapes depending on how the payer typed it into the checkout page:
// "0244123456", "233244123456", "+233244123456". Stored raw, one person could
// occupy three rows — or collide with themselves and fail the write.
//
// Everything is normalised to E.164 (+233…) on the way in. Ghana is the only
// market for the pilot, so a local 0-prefixed number is assumed Ghanaian; a
// number that already carries some other country code is passed through rather
// than mangled into +233.

/** Ghana's country calling code. */
const GH_CODE = '233';

/** Ghanaian subscriber numbers are 9 digits after the country code. */
const GH_SUBSCRIBER_LEN = 9;

/**
 * Normalise a phone number to E.164, assuming Ghana for local formats.
 *
 * Accepts the shapes Paystack and riders actually produce: `0244123456`,
 * `244123456`, `233244123456`, `+233 244 123 456`, `(024) 412-3456`.
 *
 * @param raw - the number as received, in any format.
 * @returns the E.164 number (`+233244123456`), or null when it cannot be
 *   recognised — callers should skip the write rather than store a guess.
 */
export function normaliseGhanaPhone(raw: string | null | undefined): string | null {
  if (!raw) return null;

  // Keep a leading + as the "already international" signal, drop all other
  // punctuation (spaces, dashes, brackets) that humans and checkout pages add.
  const trimmed = raw.trim();
  const hadPlus = trimmed.startsWith('+');
  const digits = trimmed.replace(/\D/g, '');
  if (digits.length === 0) return null;

  // Already Ghanaian and fully qualified: 233 + 9 digits.
  if (digits.startsWith(GH_CODE) && digits.length === GH_CODE.length + GH_SUBSCRIBER_LEN) {
    return `+${digits}`;
  }

  // A different country code, explicitly marked with +. Pass it through rather
  // than forcing +233 onto a number that is plainly not Ghanaian.
  if (hadPlus) {
    return digits.length >= 8 && digits.length <= 15 ? `+${digits}` : null;
  }

  // Local trunk form: 0 + 9 digits.
  if (digits.startsWith('0') && digits.length === GH_SUBSCRIBER_LEN + 1) {
    return `+${GH_CODE}${digits.slice(1)}`;
  }

  // Bare subscriber number, no trunk prefix.
  if (digits.length === GH_SUBSCRIBER_LEN) {
    return `+${GH_CODE}${digits}`;
  }

  return null;
}
