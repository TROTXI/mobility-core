import { startAuthentication } from '@simplewebauthn/browser';
import { opsHeaders, type OpsSession } from '../api/session';

export async function verifyExistingPasskey(session: OpsSession) {
  const started = await session.client.POST('/v1/auth/passkeys/authentication/options', {
    params: { header: opsHeaders },
  });
  if (started.error) throw new Error(started.error.error.message);
  const credential = await startAuthentication({ optionsJSON: started.data.data as never });
  const finished = await session.client.POST('/v1/auth/passkeys/authentication/verification', {
    params: { header: opsHeaders },
    body: credential as never,
  });
  if (finished.error) throw new Error(finished.error.error.message);
}
