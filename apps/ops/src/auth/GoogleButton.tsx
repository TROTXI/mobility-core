import { Button, Spinner } from '@fluentui/react-components';
import { useEffect, useRef, useState } from 'react';
import { useAuth } from './AuthContext';

declare global {
  interface Window {
    google?: {
      accounts: {
        id: {
          initialize(input: {
            client_id: string;
            callback: (value: { credential: string }) => void;
          }): void;
          renderButton(element: HTMLElement, options: Record<string, unknown>): void;
          cancel(): void;
        };
      };
    };
  }
}

export function GoogleButton() {
  const { session } = useAuth();
  const host = useRef<HTMLDivElement>(null);
  const [state, setState] = useState<'loading' | 'ready' | 'error'>('loading');
  const [message, setMessage] = useState('');
  const clientId = import.meta.env.VITE_GOOGLE_CLIENT_ID;

  useEffect(() => {
    if (!clientId) {
      setState('error');
      setMessage('Google sign-in is not configured for this website.');
      return;
    }
    const render = () => {
      if (!window.google || !host.current) return;
      window.google.accounts.id.initialize({
        client_id: clientId,
        callback: ({ credential }) => {
          setState('loading');
          void session
            .signInGoogle(credential)
            .then(() => setState('ready'))
            .catch((error: Error) => {
              setMessage(error.message);
              setState('error');
            });
        },
      });
      host.current.replaceChildren();
      window.google.accounts.id.renderButton(host.current, {
        type: 'standard',
        theme: 'filled_black',
        size: 'large',
        shape: 'pill',
        text: 'continue_with',
        width: 360,
      });
      setState('ready');
    };
    const existing = document.querySelector<HTMLScriptElement>('script[data-trotxi-google]');
    if (existing) {
      if (window.google) render();
      else existing.addEventListener('load', render, { once: true });
      return;
    }
    const script = document.createElement('script');
    script.src = 'https://accounts.google.com/gsi/client';
    script.async = true;
    script.defer = true;
    script.dataset.trotxiGoogle = 'true';
    script.addEventListener('load', render, { once: true });
    script.addEventListener('error', () => {
      setMessage('Google sign-in could not load. Check your connection and try again.');
      setState('error');
    });
    document.head.append(script);
  }, [clientId, session]);

  if (state === 'error')
    return (
      <div className="auth-actions">
        <div className="error-box">{message}</div>
        <Button appearance="primary" onClick={() => location.reload()}>
          Try again
        </Button>
      </div>
    );
  return (
    <div className="auth-actions">
      {state === 'loading' && <Spinner label="Preparing secure sign in" />}
      {/* Google owns every child of this host. Keeping React-rendered children
          outside it prevents the provider widget and React from removing the
          same DOM node during development remounts or a slow script load. */}
      <div ref={host} />
    </div>
  );
}
