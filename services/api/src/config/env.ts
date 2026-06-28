import { z } from 'zod';

const envSchema = z
  .object({
    NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
    PORT: z.coerce.number().int().positive().default(3000),
    HOST: z.string().default('0.0.0.0'),
    // Unset -> in-memory repositories (zero-infra dev/tests). Set -> Postgres.
    DATABASE_URL: z.string().optional(),
    // Unset -> in-memory KV (zero-infra dev/tests). Set -> Redis.
    REDIS_URL: z.string().optional(),
    // Auth (JWT). Unset -> a dev-only secret is used (local/tests). Required in
    // production (enforced below). Access tokens are short-lived; see auth/jwt.ts.
    JWT_SECRET: z.string().min(32).optional(),
    JWT_ACCESS_TTL: z.string().default('15m'),
    JWT_ISSUER: z.string().default('trotxi'),
    JWT_AUDIENCE: z.string().default('trotxi-api'),
    JWT_REFRESH_TTL_DAYS: z.coerce.number().int().positive().default(30),
    // Google "Web" client ID — the audience verified on sign-in. Set to enable
    // real Google sign-in; unset -> dev fake verifier (non-prod) / 503 (prod).
    GOOGLE_CLIENT_ID: z.string().optional(),
    // Paystack SECRET key (sk_...). Used for the API + webhook signature check.
    // Set -> real payments; unset -> dev fake client (non-prod) / 503 (prod).
    PAYSTACK_SECRET_KEY: z.string().optional(),
    // Rate limiting (fixed window). Tunable without a code change.
    RATE_LIMIT_MAX: z.coerce.number().int().positive().default(100),
    RATE_LIMIT_WINDOW_SECONDS: z.coerce.number().int().positive().default(60),
  })
  .superRefine((env, ctx) => {
    if (env.NODE_ENV === 'production' && !env.JWT_SECRET) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['JWT_SECRET'],
        message: 'JWT_SECRET is required in production (min 32 chars)',
      });
    }
  });

export type Env = z.infer<typeof envSchema>;

export function loadEnv(source: Record<string, string | undefined> = process.env): Env {
  const parsed = envSchema.safeParse(source);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((issue) => `${issue.path.join('.')}: ${issue.message}`)
      .join(', ');
    throw new Error(`Invalid environment configuration: ${issues}`);
  }
  return parsed.data;
}
