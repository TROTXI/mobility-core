// Ghanaian phone normalisation to E.164 (#182). users.phone is UNIQUE and
// Paystack returns the same handset as "0244…", "233244…" or "+233244…", so
// raw storage would let one person occupy three rows.

const GH_CODE = '233';
/** Digits after the country code. */
const GH_SUBSCRIBER_LEN = 9;

/**
 * Normalise to E.164, assuming Ghana for local formats.
 *
 * @param raw - the number as received, in any format.
 * @returns the E.164 number, or null when unrecognised — callers should skip
 *   the write rather than store a guess.
 */
export function normaliseGhanaPhone(raw: string | null | undefined): string | null {
  if (!raw) return null;

  // A leading + is the "already international" signal.
  const trimmed = raw.trim();
  const hadPlus = trimmed.startsWith('+');
  const digits = trimmed.replace(/\D/g, '');
  if (digits.length === 0) return null;

  if (digits.startsWith(GH_CODE) && digits.length === GH_CODE.length + GH_SUBSCRIBER_LEN) {
    return `+${digits}`;
  }

  // Another country code: pass through rather than forcing +233.
  if (hadPlus) {
    return digits.length >= 8 && digits.length <= 15 ? `+${digits}` : null;
  }

  if (digits.startsWith('0') && digits.length === GH_SUBSCRIBER_LEN + 1) {
    return `+${GH_CODE}${digits.slice(1)}`;
  }

  if (digits.length === GH_SUBSCRIBER_LEN) {
    return `+${GH_CODE}${digits}`;
  }

  return null;
}
