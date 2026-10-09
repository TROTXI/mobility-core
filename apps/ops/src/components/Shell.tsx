import {
  BoardRegular,
  CalendarRegular,
  DataTrendingRegular,
  HomeRegular,
  MoreHorizontalRegular,
  MoneyRegular,
  PeopleRegular,
  PersonSupportRegular,
  SettingsRegular,
  SignOutRegular,
  WeatherMoonRegular,
  WeatherSunnyRegular,
  VehicleTruckRegular,
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
import { NavLink, Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';

const primaryItems = [
  ['/', 'Live operations', HomeRegular],
  ['/trips', 'Trips', CalendarRegular],
  ['/network', 'Routes & stops', DataTrendingRegular],
  ['/fleet', 'Fleet', VehicleTruckRegular],
  ['/drivers', 'Drivers', PeopleRegular],
  ['/riders', 'Riders', PeopleRegular],
  ['/support', 'Support', PersonSupportRegular],
] as const;

const secondaryItems = [
  ['/standby', 'Standby', CalendarRegular],
  ['/payments', 'Payments', MoneyRegular],
  ['/reports', 'Reports', DataTrendingRegular],
  ['/people', 'People & messages', PeopleRegular],
  ['/audit', 'Audit log', BoardRegular],
  ['/platform', 'Platform', SettingsRegular],
] as const;

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
  return (
    <div className="app-shell">
      <aside className="sidebar" aria-label="Operations navigation">
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
        </div>
        <nav className="nav-list" aria-label="Operations">
          <span className="nav-section-label">Workspace</span>
          {primaryItems.map(([path, label, Icon]) => (
            <Tooltip key={path} content={label} relationship="label">
              <NavLink
                className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}
                to={path}
                end={path === '/'}
                aria-label={label}
              >
                <Icon aria-hidden="true" />
                <span className="nav-label">{label}</span>
              </NavLink>
            </Tooltip>
          ))}
          <Menu positioning="after">
            <MenuTrigger disableButtonEnhancement>
              <button
                type="button"
                className={`nav-link sidebar-more-trigger${secondaryItems.some(([path]) => pathname === path) ? ' active' : ''}`}
                aria-label="More sections"
                title="More sections"
              >
                <MoreHorizontalRegular aria-hidden="true" />
                <span className="nav-label">More</span>
              </button>
            </MenuTrigger>
            <MenuPopover>
              <MenuList>
                {account?.isSuperadmin && (
                  <MenuItem icon={<PeopleRegular />} onClick={() => navigate('/team')}>
                    Team & access
                  </MenuItem>
                )}
                {secondaryItems.map(([path, label, Icon]) => (
                  <MenuItem key={path} icon={<Icon />} onClick={() => navigate(path)}>
                    {label}
                  </MenuItem>
                ))}
              </MenuList>
            </MenuPopover>
          </Menu>
        </nav>
      </aside>
      <section className="workspace">
        <header className="topbar">
          <span className="topbar-context">Trotxi Operations</span>
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
