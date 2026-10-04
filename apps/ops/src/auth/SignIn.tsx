import { GoogleButton } from './GoogleButton';
import { AuthFrame } from './PasskeyGate';

export function SignIn() {
  return (
    <AuthFrame
      title="Sign in to Trotxi Operations"
      copy="Use the Google account invited by your organisation."
    >
      <GoogleButton />
      <div className="auth-note">
        Access is by invitation. A passkey keeps your workspace secure.
      </div>
    </AuthFrame>
  );
}
