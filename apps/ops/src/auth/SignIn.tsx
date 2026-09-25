import { GoogleButton } from './GoogleButton';
import { AuthFrame } from './PasskeyGate';

export function SignIn() {
  return (
    <AuthFrame
      title="Right person. Right workspace."
      copy="Sign in with the organisation account attached to Trotxi Operations."
    >
      <GoogleButton />
      <div className="auth-note">Only approved operations accounts can continue.</div>
    </AuthFrame>
  );
}
