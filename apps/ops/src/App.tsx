import { Button, FluentProvider } from '@fluentui/react-components';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { lazy, Suspense, useState } from 'react';
import { AuthProvider, useAuth } from './auth/AuthContext';
import { PasskeyGate, AuthFrame } from './auth/PasskeyGate';
import { SignIn } from './auth/SignIn';
import { LoadingPage } from './components/Page';
import { Shell } from './components/Shell';
import { trotxiDark, trotxiLight } from './theme';

const Overview = lazy(() =>
  import('./screens/Overview').then((module) => ({ default: module.Overview })),
);
const Trips = lazy(() => import('./screens/Trips').then((module) => ({ default: module.Trips })));
const Network = lazy(() =>
  import('./screens/Network').then((module) => ({ default: module.Network })),
);
const Fleet = lazy(() => import('./screens/Fleet').then((module) => ({ default: module.Fleet })));
const Riders = lazy(() =>
  import('./screens/Riders').then((module) => ({ default: module.Riders })),
);
const Support = lazy(() =>
  import('./screens/Support').then((module) => ({ default: module.Support })),
);
const Payments = lazy(() =>
  import('./screens/Payments').then((module) => ({ default: module.Payments })),
);
const Platform = lazy(() =>
  import('./screens/Platform').then((module) => ({ default: module.Platform })),
);
const Reports = lazy(() =>
  import('./screens/Reports').then((module) => ({ default: module.Reports })),
);
const People = lazy(() =>
  import('./screens/People').then((module) => ({ default: module.People })),
);
const Audit = lazy(() => import('./screens/Audit').then((module) => ({ default: module.Audit })));
const Profile = lazy(() =>
  import('./screens/Profile').then((module) => ({ default: module.Profile })),
);

export function App() {
  const [appearance, setAppearance] = useState<'dark' | 'light'>(() => {
    try {
      return window.localStorage.getItem('trotxi-ops-appearance') === 'light' ? 'light' : 'dark';
    } catch {
      return 'dark';
    }
  });
  const toggleAppearance = () => {
    setAppearance((current) => {
      const next = current === 'dark' ? 'light' : 'dark';
      try {
        window.localStorage.setItem('trotxi-ops-appearance', next);
      } catch {
        // Appearance still changes in memory when storage is disabled.
      }
      return next;
    });
  };
  return (
    <FluentProvider
      theme={appearance === 'dark' ? trotxiDark : trotxiLight}
      data-theme={appearance}
      style={{ minHeight: '100vh' }}
    >
      <AuthProvider>
        <Entry appearance={appearance} toggleAppearance={toggleAppearance} />
      </AuthProvider>
    </FluentProvider>
  );
}

function Entry({
  appearance,
  toggleAppearance,
}: {
  appearance: 'dark' | 'light';
  toggleAppearance: () => void;
}) {
  const { account, restoring, session } = useAuth();
  if (restoring) return <LoadingPage />;
  if (!account) return <SignIn />;
  if (account.role !== 'admin')
    return (
      <AuthFrame
        title="This account has no Ops access"
        copy="You are signed in, but this Google account is not an approved Trotxi operator."
      >
        <Button appearance="primary" onClick={() => void session.logout()}>
          Use another account
        </Button>
      </AuthFrame>
    );
  return (
    <PasskeyGate>
      <BrowserRouter>
        <Suspense fallback={<LoadingPage />}>
          <Routes>
            <Route element={<Shell appearance={appearance} toggleAppearance={toggleAppearance} />}>
              <Route index element={<Overview />} />
              <Route path="trips" element={<Trips />} />
              <Route path="network" element={<Network />} />
              <Route path="fleet" element={<Fleet view="vehicles" />} />
              <Route path="drivers" element={<Fleet view="drivers" />} />
              <Route path="riders" element={<Riders />} />
              <Route path="support" element={<Support />} />
              <Route path="payments" element={<Payments />} />
              <Route path="reports" element={<Reports />} />
              <Route path="people" element={<People />} />
              <Route path="audit" element={<Audit />} />
              <Route path="platform" element={<Platform />} />
              <Route path="profile" element={<Profile />} />
            </Route>
          </Routes>
        </Suspense>
      </BrowserRouter>
    </PasskeyGate>
  );
}
