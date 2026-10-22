import sharp from 'sharp';

// Real pixels: header-only fixtures must fail the production decoder.
export const avatarPng = await sharp({
  create: { width: 2, height: 2, channels: 3, background: '#058740' },
})
  .png()
  .toBuffer();
