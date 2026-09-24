import {
  AlertBadgeRegular,
  CalendarRegular,
  DataTrendingRegular,
  HomeRegular,
  MoneyRegular,
  PeopleRegular,
  PersonSupportRegular,
  SettingsRegular,
  SignOutRegular,
  VehicleTruckRegular,
} from '@fluentui/react-icons';
import { Avatar, Button, Tooltip } from '@fluentui/react-components';
import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';

const items = [
  ['/', 'Live operations', HomeRegular],
  ['/trips', 'Trips', CalendarRegular],
  ['/network', 'Routes & stops', DataTrendingRegular],
  ['/fleet', 'Drivers & vehicles', VehicleTruckRegular],
  ['/riders', 'Riders', PeopleRegular],
  ['/support', 'Support', PersonSupportRegular],
  ['/payments', 'Payments', MoneyRegular],
  ['/platform', 'Platform', SettingsRegular],
] as const;

const titles = Object.fromEntries(items.map(([path, label]) => [path, label]));

export function Shell() {
  const { pathname } = useLocation();
  const { account, session } = useAuth();
  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="sidebar-brand">
          <div className="brand-mark">
            <span className="brand-symbol" aria-hidden="true" />
            <span>Trotxi</span>
          </div>
          <div className="sidebar-kicker">Routekeeper HQ</div>
        </div>
        <nav className="nav-list" aria-label="Operations">
          {items.map(([path, label, Icon]) => (
            <Tooltip key={path} content={label} relationship="label">
              <NavLink
                className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}
                to={path}
                end={path === '/'}
              >
                <Icon aria-hidden="true" />
                <span>{label}</span>
              </NavLink>
            </Tooltip>
          ))}
        </nav>
        <div className="sidebar-footer">
          <div>Internal operations</div>
          <div>Every change is attributable.</div>
        </div>
      </aside>
      <section className="workspace">
        <header className="topbar">
          <div className="connection-dot" aria-label="Connected" />
          <div className="topbar-title">{titles[pathname] ?? 'Trotxi Operations'}</div>
          <AlertBadgeRegular aria-label="Notifications" />
          <Avatar
            name={account?.displayName}
            image={account?.avatarUrl ? { src: account.avatarUrl } : undefined}
          />
          <span>{account?.displayName}</span>
          <Tooltip content="Sign out" relationship="label">
            <Button
              appearance="subtle"
              icon={<SignOutRegular />}
              onClick={() => void session.logout()}
            />
          </Tooltip>
        </header>
        <Outlet />
      </section>
    </div>
  );
}
