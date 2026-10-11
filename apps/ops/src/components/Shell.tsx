import {
  BoardRegular,
  CalendarRegular,
  DataTrendingRegular,
  DismissRegular,
  HomeRegular,
  MoneyRegular,
  NavigationRegular,
  PeopleRegular,
  PersonSupportRegular,
  SettingsRegular,
  SignOutRegular,
  VehicleTruckRegular,
  WeatherMoonRegular,
  WeatherSunnyRegular,
} from '@fluentui/react-icons';
import {
  Avatar,
  Menu,
  MenuItem,
  MenuList,
  MenuPopover,
  MenuTrigger,
  Tooltip,
} from '@fluentui/react-components';
import { useEffect, useState } from 'react';
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';

const sections = [
  {
    label: 'Run service',
    items: [
      ['/', 'Live operations', HomeRegular],
      ['/trips', 'Dispatch & trips', CalendarRegular],
      ['/standby', 'Standby & offers', BoardRegular],
    ],
  },
  {
    label: 'Manage',
    items: [
      ['/network', 'Routes & schedules', DataTrendingRegular],
      ['/fleet', 'Fleet & drivers', VehicleTruckRegular],
      ['/riders', 'Riders', PeopleRegular],
    ],
  },
  {
    label: 'Resolve',
    items: [
      ['/support', 'Support', PersonSupportRegular],
      ['/payments', 'Payments', MoneyRegular],
    ],
  },
  {
    label: 'Monitor & control',
    items: [
      ['/reports', 'Reports', DataTrendingRegular],
      ['/delivery', 'Message delivery', PeopleRegular],
      ['/audit', 'Audit log', BoardRegular],
      ['/platform', 'Platform', SettingsRegular],
    ],
  },
] as const;

const sectionTitles: Record<string, string> = Object.fromEntries(
  sections.flatMap((section) => section.items.map(([path, title]) => [path, title])),
);

export function Shell({
  appearance,
  toggleAppearance,
}: {
  appearance: 'dark' | 'light';
  toggleAppearance: () => void;
}) {
  const { pathname } = useLocation();
  const navigate = useNavigate();
  const { account, session } = useAuth();
  const [navigationOpen, setNavigationOpen] = useState(false);
  useEffect(() => setNavigationOpen(false), [pathname]);
  useEffect(() => {
    if (!navigationOpen) return;
    const closeOnEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setNavigationOpen(false);
    };
    window.addEventListener('keydown', closeOnEscape);
    return () => window.removeEventListener('keydown', closeOnEscape);
  }, [navigationOpen]);
  const currentTitle =
    pathname === '/drivers'
      ? 'Fleet & drivers'
      : pathname === '/team'
        ? 'Team & access'
        : pathname === '/profile'
          ? 'My profile'
          : (sectionTitles[pathname] ?? 'Operations');

  return (
    <div className="app-shell">
      {navigationOpen && (
        <button
          type="button"
          className="navigation-backdrop"
          aria-label="Close navigation"
          onClick={() => setNavigationOpen(false)}
        />
      )}
      <aside
        className={`sidebar${navigationOpen ? ' sidebar-open' : ''}`}
        aria-label="Operations navigation"
      >
        <div className="sidebar-brand">
          <NavLink to="/" className="brand-mark" aria-label="Trotxi operations home">
            <img
              className="brand-rail-logo logo-light"
              src="/trotxi-wordmark-light.png"
              alt=""
              width={568}
              height={208}
            />
            <img
              className="brand-rail-logo logo-dark"
              src="/trotxi-wordmark-dark.png"
              alt=""
              width={568}
              height={208}
            />
          </NavLink>
          <button
            type="button"
            className="sidebar-close"
            aria-label="Close navigation"
            onClick={() => setNavigationOpen(false)}
          >
            <DismissRegular aria-hidden="true" />
          </button>
        </div>
        <nav className="nav-list" aria-label="Operations">
          {sections.map((section) => (
            <div className="nav-group" key={section.label}>
              <span className="nav-section-label">{section.label}</span>
              {section.items.map(([path, label, Icon]) => (
                <Tooltip key={path} content={label} relationship="label">
                  <NavLink
                    className={({ isActive }) =>
                      `nav-link${isActive || (path === '/fleet' && pathname === '/drivers') ? ' active' : ''}`
                    }
                    to={path}
                    end={path === '/'}
                    aria-label={label}
                  >
                    <Icon aria-hidden="true" />
                    <span className="nav-label">{label}</span>
                  </NavLink>
                </Tooltip>
              ))}
              {section.label === 'Monitor & control' && account?.isSuperadmin && (
                <Tooltip content="Team & access" relationship="label">
                  <NavLink
                    className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}
                    to="/team"
                    aria-label="Team & access"
                  >
                    <PeopleRegular aria-hidden="true" />
                    <span className="nav-label">Team & access</span>
                  </NavLink>
                </Tooltip>
              )}
            </div>
          ))}
        </nav>
      </aside>
      <section className="workspace">
        <header className="topbar">
          <div className="topbar-location">
            <button
              type="button"
              className="mobile-navigation-trigger"
              aria-label="Open navigation"
              aria-expanded={navigationOpen}
              onClick={() => setNavigationOpen(true)}
            >
              <NavigationRegular aria-hidden="true" />
            </button>
            <span className="topbar-context">{currentTitle}</span>
          </div>
          <Menu positioning="below-end">
            <MenuTrigger disableButtonEnhancement>
              <button
                type="button"
                className="account-menu-trigger"
                aria-label={`Account menu for ${account?.displayName ?? 'operator'}`}
              >
                <Avatar
                  name={account?.displayName}
                  image={account?.avatarUrl ? { src: account.avatarUrl } : undefined}
                  size={32}
                />
                <span>{account?.displayName?.split(' ')[0] ?? 'Operator'}</span>
              </button>
            </MenuTrigger>
            <MenuPopover>
              <MenuList>
                <MenuItem icon={<PeopleRegular />} onClick={() => navigate('/profile')}>
                  My profile
                </MenuItem>
                <MenuItem
                  icon={appearance === 'dark' ? <WeatherSunnyRegular /> : <WeatherMoonRegular />}
                  onClick={toggleAppearance}
                >
                  {appearance === 'dark' ? 'Light appearance' : 'Dark appearance'}
                </MenuItem>
                <MenuItem icon={<SignOutRegular />} onClick={() => void session.logout()}>
                  Sign out
                </MenuItem>
              </MenuList>
            </MenuPopover>
          </Menu>
        </header>
        <Outlet />
      </section>
    </div>
  );
}
