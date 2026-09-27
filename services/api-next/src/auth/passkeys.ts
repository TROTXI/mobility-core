import {
  generateAuthenticationOptions,
  generateRegistrationOptions,
  verifyAuthenticationResponse,
  verifyRegistrationResponse,
} from '@simplewebauthn/server';
import type {
  AuthenticationResponseJSON,
  PublicKeyCredentialCreationOptionsJSON,
  PublicKeyCredentialRequestOptionsJSON,
  RegistrationResponseJSON,
  WebAuthnCredential,
} from '@simplewebauthn/server';

export type StoredPasskey = WebAuthnCredential;

export type RegisteredPasskey = StoredPasskey & {
  deviceType: 'singleDevice' | 'multiDevice';
  backedUp: boolean;
};

/**
 * Narrow seam around WebAuthn. Tests substitute only the browser ceremony;
 * production always uses the standards verifier below.
 */
export interface PasskeyRelyingParty {
  registrationOptions(input: {
    userId: string;
    userName: string;
    displayName: string;
    credentials: Pick<StoredPasskey, 'id' | 'transports'>[];
  }): Promise<PublicKeyCredentialCreationOptionsJSON>;
  verifyRegistration(
    response: RegistrationResponseJSON,
    challenge: string,
  ): Promise<RegisteredPasskey>;
  authenticationOptions(
    credentials: Pick<StoredPasskey, 'id' | 'transports'>[],
  ): Promise<PublicKeyCredentialRequestOptionsJSON>;
  verifyAuthentication(
    response: AuthenticationResponseJSON,
    challenge: string,
    credential: StoredPasskey,
  ): Promise<{ newCounter: number; deviceType: 'singleDevice' | 'multiDevice'; backedUp: boolean }>;
}

export function webAuthnRelyingParty(originValue: string): PasskeyRelyingParty {
  const parsed = new URL(originValue);
  const localhost = parsed.hostname === 'localhost' || parsed.hostname === '127.0.0.1';
  if (
    (parsed.protocol !== 'https:' && !(localhost && parsed.protocol === 'http:')) ||
    parsed.pathname !== '/' ||
    parsed.search ||
    parsed.hash ||
    parsed.username ||
    parsed.password
  )
    throw new Error('Ops WebAuthn origin must be an HTTPS origin (HTTP is allowed for localhost)');
  const origin = parsed.origin;
  const rpID = parsed.hostname;

  return {
    registrationOptions: ({ userId, userName, displayName, credentials }) =>
      generateRegistrationOptions({
        rpName: 'Trotxi Ops',
        rpID,
        userID: Buffer.from(userId, 'utf8'),
        userName,
        userDisplayName: displayName,
        timeout: 300_000,
        attestationType: 'none',
        excludeCredentials: credentials.map((credential) => ({
          id: credential.id,
          ...(credential.transports?.length ? { transports: credential.transports } : {}),
        })),
        authenticatorSelection: {
          residentKey: 'required',
          userVerification: 'required',
        },
      }),
    verifyRegistration: async (response, challenge) => {
      const verification = await verifyRegistrationResponse({
        response,
        expectedChallenge: challenge,
        expectedOrigin: origin,
        expectedRPID: rpID,
        requireUserPresence: true,
        requireUserVerification: true,
      });
      if (!verification.verified) throw new Error('Passkey registration was not verified');
      const info = verification.registrationInfo;
      return {
        id: info.credential.id,
        publicKey: info.credential.publicKey,
        counter: info.credential.counter,
        transports: info.credential.transports,
        deviceType: info.credentialDeviceType,
        backedUp: info.credentialBackedUp,
      };
    },
    authenticationOptions: (credentials) =>
      generateAuthenticationOptions({
        rpID,
        timeout: 300_000,
        userVerification: 'required',
        allowCredentials: credentials.map((credential) => ({
          id: credential.id,
          ...(credential.transports?.length ? { transports: credential.transports } : {}),
        })),
      }),
    verifyAuthentication: async (response, challenge, credential) => {
      const verification = await verifyAuthenticationResponse({
        response,
        expectedChallenge: challenge,
        expectedOrigin: origin,
        expectedRPID: rpID,
        credential,
        requireUserVerification: true,
      });
      if (!verification.verified) throw new Error('Passkey authentication was not verified');
      return {
        newCounter: verification.authenticationInfo.newCounter,
        deviceType: verification.authenticationInfo.credentialDeviceType,
        backedUp: verification.authenticationInfo.credentialBackedUp,
      };
    },
  };
}
