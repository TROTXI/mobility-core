import { z } from 'zod';
import { userResponseSchema } from '../users/user.schema';

/** The PIN as typed: exactly six digits, nothing else. */
const pinSchema = z.string().regex(/^\d{6}$/, 'expected a 6-digit PIN');

export const driverSignInBodySchema = z.object({
  /** The ops-issued code. Case and the `DR-` prefix are normalised server-side. */
  driverCode: z.string().min(3).max(32),
  pin: pinSchema,
  /**
   * True on the driver's own handset, false (the default) on a shared one.
   * Chooses the refresh-token lifetime and nothing else.
   */
  rememberDevice: z.boolean().optional(),
});

export const driverAuthResultSchema = z.object({
  accessToken: z.string(),
  refreshToken: z.string(),
  user: userResponseSchema,
  driver: z.object({ id: z.string().uuid(), fullName: z.string() }),
  /**
   * True while the driver is still on the PIN ops issued. The app sends them
   * straight to the change-PIN screen.
   */
  mustChangePin: z.boolean(),
});

export const changePinBodySchema = z.object({
  currentPin: pinSchema,
  newPin: pinSchema,
});

export const issuedCredentialSchema = z.object({
  driverCode: z.string(),
  /** Shown to ops once. Not stored in plaintext and not recoverable. */
  pin: z.string(),
});

export const resetPinResponseSchema = z.object({ pin: z.string() });

export const credentialPatchBodySchema = z
  .object({
    status: z.enum(['active', 'suspended']).optional(),
    /** Clears the failure count and any lockout. */
    unlock: z.boolean().optional(),
  })
  .refine((body) => body.status !== undefined || body.unlock !== undefined, {
    message: 'Provide status, unlock, or both',
  });
