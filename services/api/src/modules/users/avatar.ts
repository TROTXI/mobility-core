// Avatar image processing (#24). Every uploaded photo is re-encoded server-side
// before it ever reaches storage — this both bounds size and, crucially, STRIPS
// EXIF (phone photos embed GPS/PII in metadata; security.md §7). The client
// can't bypass this by sending a pre-sized image: we always re-encode.

import sharp from 'sharp';

/** Longest edge of a stored avatar, in pixels (a square thumbnail). */
export const AVATAR_SIZE_PX = 256;
/** JPEG quality for the re-encoded avatar (visually fine at 256px, small bytes). */
const AVATAR_JPEG_QUALITY = 80;
/** Max accepted upload size before processing — a guard on the raw bytes. */
export const MAX_UPLOAD_BYTES = 5 * 1024 * 1024; // 5 MB
/** Content types we accept for upload (all re-encoded to JPEG regardless). */
export const ACCEPTED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp']);

/** The MIME type every processed avatar is stored as. */
export const PROCESSED_MIME = 'image/jpeg';

/** Thrown when an upload isn't a decodable image of an accepted type. */
export class InvalidImageError extends Error {}

/**
 * Resize an uploaded image to a square avatar and re-encode to JPEG (dropping
 * EXIF and any other metadata).
 *
 * @param input - the raw uploaded bytes.
 * @returns the processed JPEG bytes ready for storage.
 * @throws InvalidImageError if the bytes aren't a decodable image.
 */
export async function processAvatar(input: Buffer): Promise<Buffer> {
  try {
    return await sharp(input)
      .rotate() // apply EXIF orientation, then the re-encode drops the metadata
      .resize(AVATAR_SIZE_PX, AVATAR_SIZE_PX, { fit: 'cover' })
      .jpeg({ quality: AVATAR_JPEG_QUALITY })
      .toBuffer();
  } catch {
    throw new InvalidImageError('Uploaded file is not a valid image');
  }
}
