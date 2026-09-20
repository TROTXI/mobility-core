import pg from 'pg';
import type { Pool } from 'pg';
import type { FastifyInstance } from 'fastify';
import { createReplacementApp } from '../http/replacement.js';
import type { AuthService } from '../auth/service.js';
import { TransportError } from '../transport/errors.js';
import { GoogleIdTokenVerifier } from '../auth/id-token-verifier.google.js';
import { AppleIdTokenVerifier } from '../auth/id-token-verifier.apple.js';
import { AppleHttpTokenClient } from '../auth/apple-token.client.apple.js';
import { PaystackEvidence } from '../payments/provider.js';
import { providerTokenBox } from '../auth/credentials.js';
import { FinancialFoundation } from '../payments/foundation.js';
import { PaymentRecovery } from '../payments/recovery.js';
import { Pricing } from '../payments/pricing.js';
import { Purchases } from '../payments/purchases.js';
import { RefundInitiation } from '../payments/refunds.js';
import { MembershipService } from '../membership/service.js';
import { AccountService } from '../account/service.js';
import { ConfigService } from '../config/service.js';
import { R2ObjectStore } from './avatars.js';
import { sharedAdmission } from './admission.js';
import { TransactionalEmail } from '../notifications/email.js';
import { ResendSender } from '../notifications/resend.js';
import { FcmSender } from '../notifications/fcm.js';
import { PushNotifications } from '../notifications/push.js';
import type { RuntimeConfig } from './config.js';

export interface Backend {
  app: FastifyInstance;
  pool: Pool;
  /** Opens and revokes the maintenance worker's own session. */
  auth: AuthService;
  /** Erasure's outstanding external work has no reviewed HTTP operation. */
  account: AccountService;
  /** Closed admission windows are the worker's to clear. */
  admission: import('./admission.js').Admission;
  maintenanceUserId: string;
  email?: TransactionalEmail;
  push?: PushNotifications;
  close(): Promise<void>;
}

/**
 * A startup spot check that this connection is not the schema owner.
 *
 * It asks two questions the owner answers yes to and the runtime role does not:
 * can it create objects in `app`, and can it update `app.trip_events`. That is
 * not a full audit of the grant — `grantRuntime` is what actually narrows the
 * role, table by table. It is here because a deployment pointed at the
 * migration owner would otherwise work perfectly and be quietly unauditable,
 * and that mistake is worth catching before the listener opens.
 */
export async function assertRuntimeRole(pool: Pool, existingStaging = false): Promise<void> {
  const row = (
    await pool.query<{
      create_schema: boolean;
      rewrite_history: boolean;
      installed: boolean;
      database: string;
      login: string;
    }>(
      `SELECT current_database() AS database, current_user AS login,
        to_regclass('app.users') IS NOT NULL AS installed,
        CASE WHEN to_regnamespace('app') IS NULL THEN false
          ELSE has_schema_privilege(current_user,'app','CREATE') END AS create_schema,
        CASE WHEN to_regclass('app.trip_events') IS NULL THEN false
          ELSE has_table_privilege(current_user,'app.trip_events','UPDATE') END AS rewrite_history`,
    )
  ).rows[0];
  if (!row?.installed) throw new Error('The replacement schema is not installed on this database');
  // Approved for the disposable, existing staging service only. Configuration
  // also pins the Render service, host and TEST key. This deliberately gives up
  // the narrow-login boundary; it is not a claim that owners are restricted.
  if (existingStaging) {
    if (row.database !== 'trotxi' || row.login !== 'trotxi')
      throw new Error(
        'The staging owner exception requires the existing trotxi database and login',
      );
    return;
  }
  if (row.create_schema)
    throw new Error('Refusing to start: this connection can create objects in the app schema');
  if (row.rewrite_history)
    throw new Error('Refusing to start: this connection can update append-only history');
}

/**
 * Build the whole backend from validated configuration.
 *
 * Nothing here is optional and nothing degrades. Every port is a real adapter:
 * Google and Apple verification, Apple's token endpoint, Paystack, Cloudflare
 * R2. There is no recording fake, no permissive session callback and no
 * silently absent route group, because every group's dependency is required.
 */
export async function composeBackend(config: RuntimeConfig): Promise<Backend> {
  const pool = new pg.Pool({
    connectionString: config.databaseUrl,
    max: config.poolSize,
    application_name: `${config.build.service}@${config.build.commit.slice(0, 12)}`,
    connectionTimeoutMillis: 5000,
    idleTimeoutMillis: 30000,
  });
  try {
    await assertRuntimeRole(pool, config.existingStaging);
    const avatars = new R2ObjectStore(config.avatars);
    const push = config.firebaseServiceAccount
      ? new PushNotifications({
          pool,
          deviceKey: config.keys.device,
          sender: new FcmSender(config.firebaseServiceAccount),
        })
      : undefined;
    const signAvatar = (objectKey: string) => {
      const url = avatars.sign(objectKey, config.avatars.urlTtlSeconds);
      if (!url)
        throw new TransportError(
          503,
          'avatar_signer_unavailable',
          'Account details are temporarily unavailable.',
        );
      return url;
    };
    const provider = new PaystackEvidence(config.paystack.secretKey, config.keys.paystackEvidence);
    const email = config.email
      ? new TransactionalEmail({
          pool,
          encryptionKey: config.keys.device,
          sender: new ResendSender(config.email.apiKey),
          staging: config.email.staging,
        })
      : undefined;
    // Built only where the deployment says it offers Apple. Where it does not,
    // there is no verifier, no token client and no route, so nothing can half
    // work: erasure's provider revocation reports that it had no reach, which
    // is true, instead of appearing to have withdrawn a grant.
    const appleTokens = config.apple
      ? new AppleHttpTokenClient({
          clientId: config.apple.clientIds[0]!,
          teamId: config.apple.teamId,
          keyId: config.apple.keyId,
          privateKey: config.apple.privateKey,
        })
      : undefined;
    // Paystack wants a stable customer key. The rider's own address when we
    // hold one, and otherwise the same unroutable per-user address the
    // deployed service already uses, so a rider who signed in with a private
    // relay can still be sent to checkout.
    const payerEmail = async (userId: string) => {
      const row = (await pool.query('SELECT email FROM app.users WHERE id=$1', [userId])).rows[0];
      return (row?.email as string | null) ?? `${userId}@users.trotxi.app`;
    };
    // Filled by compose below, which runs before the application is built.
    let identity: { auth: AuthService; membership: MembershipService; account: AccountService };
    const built = () => {
      if (!identity) throw new Error('The backend was used before it finished composing');
      return identity;
    };
    const admission = sharedAdmission(pool);
    const app = await createReplacementApp({
      pool,
      cursorSecret: config.keys.cursorSecret,
      credentialReplayKey: config.keys.credentialReplay,
      authProviders: config.providers,
      admit: (subject) => admission.spend(subject),
      trustProxy: config.trustProxy,
      requestsPerMinute: config.limits.perUser,
      requestsPerIpPerMinute: config.limits.perIp,
      authRequestsPerMinute: config.limits.perAuth,
      minimumBuilds: config.floors,
      maxAvatarBytes: config.avatars.maxBytes,
      identity: {
        access: {
          secret: config.keys.accessSecret,
          issuer: config.access.issuer,
          audience: config.access.audience,
          ttlSeconds: config.access.ttlSeconds,
        },
        pinSecret: config.pinSecretText,
        refreshTtlDays: config.refreshTtlDays,
        shiftTtlHours: config.shiftTtlHours,
        providerEncryptionKey: config.keys.providerEncryption,
        google: new GoogleIdTokenVerifier(config.google.clientId),
        ...(config.apple ? { apple: new AppleIdTokenVerifier(config.apple.clientIds) } : {}),
        ...(appleTokens ? { appleTokens } : {}),
        avatarUrl: signAvatar,
      },
      boarding: {
        proofKey: config.keys.boardingProof,
        avatarUrl: (key, seconds) => avatars.signedUrl(key, seconds),
      },
      // Built once identity exists, in dependency order: authoritative prices,
      // then the membership rules that read them, then the money foundation
      // those rules bound, then the surfaces over it.
      compose: ({ auth, authorizeSession }) => {
        const pricing = new Pricing({
          pool,
          authorizeSession,
          cursorSecret: config.keys.cursorSecret,
        });
        const membership = new MembershipService({
          pool,
          authorizeSession,
          cursorSecret: config.keys.cursorSecret,
          fareForSelection: pricing.fareForSelection,
        });
        const financial = new FinancialFoundation({
          pool,
          environment: provider.environment,
          authorizeSession,
          assertCheckoutAllowed: membership.assertCheckoutAllowed,
          assertPeriodCanClose: membership.assertPeriodCanClose,
          materializeAssignment: membership.materializeAssignment,
          quote: pricing.quote,
          subscriptionActive: email?.subscriptionActive,
        });
        const account = new AccountService({
          pool,
          authorizeSession,
          deviceKey: config.keys.device,
          erasureRequested: email?.erasureRequested,
          avatars,
          // Erasure's external half. Marking a row deleted withdraws nothing
          // from Apple and removes no object, so both are wired and both
          // report a refusal rather than settling as done.
          reach: {
            removeAvatarObject: (key) => avatars.remove(key),
            revokeProviderGrant: async ({ provider, subject, tokenCiphertext }) => {
              // Account erasure records ID-token-only identities as terminal
              // not-applicable tasks. Only a real Apple grant reaches this port.
              if (provider !== 'apple' || !appleTokens)
                throw new Error('provider_revocation_unsupported');
              if (!tokenCiphertext) throw new Error('no_stored_grant');
              await appleTokens.revoke(
                providerTokenBox(config.keys.providerEncryption).open(tokenCiphertext, subject),
              );
            },
          },
          avatarUrlTtlSeconds: config.avatars.urlTtlSeconds,
          maxAvatarBytes: config.avatars.maxBytes,
        });
        identity = { auth, membership, account };
        return {
          pricing,
          refunds: new RefundInitiation({
            pool,
            authorizeSession,
            environment: provider.environment,
            initiate: (reference, amount, intentId) =>
              provider.initiateRefund(reference, amount, intentId),
          }),
          membership,
          account,
          purchases: new Purchases({
            pool,
            financial,
            authorizeSession,
            cursorSecret: config.keys.cursorSecret,
            initializeCheckout: async (request) =>
              provider.initialize({
                reference: request.reference,
                amountPesewas: request.amountPesewas,
                email: await payerEmail(request.userId),
              }),
          }),
          payments: new PaymentRecovery({
            pool,
            provider,
            foundation: financial,
            authorizeSession,
            cursorSecret: config.keys.cursorSecret,
            reversePeriod: membership.reversePeriod,
          }),
          config: new ConfigService({
            pool,
            authorizeSession,
            build: config.build,
            cursorSecret: config.keys.cursorSecret,
            mapTiles: config.mapTiles,
            support: config.support,
            fallbackBuilds: { driver: config.floors.driver, commuter: config.floors.commuter },
            docsUrl: config.docsUrl,
          }),
        };
      },
      coordinateReservations: (client, change) =>
        built().membership.coordinateReservations(client, change),
    });
    // Shutting down twice is a signal arriving twice, not a fault, and a
    // second end() on the pool would turn an orderly stop into a crash.
    let closed = false;
    return {
      app,
      pool,
      auth: built().auth,
      account: built().account,
      admission,
      maintenanceUserId: config.maintenanceUserId,
      email,
      push,
      close: async () => {
        if (closed) return;
        closed = true;
        try {
          await app.close();
        } finally {
          await pool.end();
        }
      },
    };
  } catch (error) {
    await pool.end().catch(() => undefined);
    throw error;
  }
}
