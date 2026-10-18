import sharp, { type Sharp } from 'sharp';
import { fail, TransportError } from '../transport/errors.js';

export const MAX_AVATAR_PIXELS = 12_000_000;
export const MAX_AVATAR_EDGE = 8192;
export const AVATAR_OUTPUT_EDGE = 1024;
// Bound native work per API process. Reject excess work rather than retaining
// arbitrary image buffers in an unbounded decoding queue.
const MAX_CONCURRENT_IMAGES = 2;
let active = 0;

/** Decode pixels and write a new image, never copy uploaded metadata or bytes. */
export async function sanitizeAvatar(bytes: Buffer, contentType: string, maxBytes: number) {
  if (active >= MAX_CONCURRENT_IMAGES)
    fail(503, 'avatar_processing_busy', 'Please try uploading your photo again shortly.');
  active++;
  let image: Sharp | undefined;
  try {
    image = sharp(bytes, {
      failOn: 'warning',
      limitInputPixels: MAX_AVATAR_PIXELS,
      sequentialRead: true,
    }).timeout({ seconds: 5 });
    const metadata = await image.metadata();
    const expected = { 'image/jpeg': 'jpeg', 'image/png': 'png', 'image/webp': 'webp' };
    if (metadata.format !== expected[contentType as keyof typeof expected])
      fail(415, 'unsupported_media_type', 'Supply a valid JPEG, PNG or WebP image.');
    if (
      !metadata.width ||
      !metadata.height ||
      metadata.width > MAX_AVATAR_EDGE ||
      metadata.height > MAX_AVATAR_EDGE ||
      metadata.width * metadata.height > MAX_AVATAR_PIXELS ||
      (metadata.pages ?? 1) !== 1
    )
      fail(415, 'unsupported_media_type', 'Supply a still photo with smaller dimensions.');

    // rotate() applies EXIF orientation before the default metadata stripping.
    // Do not add keepMetadata/withMetadata: GPS, EXIF, XMP and IPTC stay out.
    const output = image.rotate().resize({
      width: AVATAR_OUTPUT_EDGE,
      height: AVATAR_OUTPUT_EDGE,
      fit: 'inside',
      withoutEnlargement: true,
    });
    let clean: Buffer;
    switch (contentType) {
      case 'image/jpeg':
        clean = await output.jpeg({ quality: 85 }).toBuffer();
        break;
      case 'image/png':
        clean = await output.png().toBuffer();
        break;
      case 'image/webp':
        clean = await output.webp({ quality: 85 }).toBuffer();
        break;
      default:
        return fail(415, 'unsupported_media_type', 'Unsupported image type.');
    }
    if (clean.length > maxBytes) fail(413, 'payload_too_large', 'Choose a smaller photo.');
    return clean;
  } catch (error) {
    if (error instanceof TransportError) throw error;
    // Decoder errors can contain attacker-supplied metadata. Never expose it.
    fail(415, 'unsupported_media_type', 'Supply a complete, valid JPEG, PNG or WebP image.');
  } finally {
    image?.destroy();
    active--;
  }
}
