import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { OpsSession, apiBaseUrl, type Account } from '../api/session';

type State = {
  session: OpsSession;
  account: Account | null;
  restoring: boolean;
};

const AuthContext = createContext<State | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const session = useMemo(() => new OpsSession(apiBaseUrl), []);
  const [account, setAccount] = useState(session.account);
  const [restoring, setRestoring] = useState(true);

  useEffect(() => {
    const update = () => setAccount(session.account);
    session.addEventListener('change', update);
    void session.restore().finally(() => setRestoring(false));
    return () => session.removeEventListener('change', update);
  }, [session]);

  return (
    <AuthContext.Provider value={{ session, account, restoring }}>{children}</AuthContext.Provider>
  );
}

export function useAuth() {
  const value = useContext(AuthContext);
  if (!value) throw new Error('AuthProvider is missing');
  return value;
}
