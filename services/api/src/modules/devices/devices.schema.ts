import { z } from 'zod';

export const registerDeviceBodySchema = z.object({
  /** The FCM registration token from the device. */
  fcmToken: z.string().min(1),
  platform: z.enum(['android', 'ios', 'web']),
});

export const registerDeviceResponseSchema = z.object({
  registered: z.boolean(),
});
