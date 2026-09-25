import {
  AlertBadgeRegular,
  BoardRegular,
  CalendarRegular,
  DataTrendingRegular,
  HomeRegular,
  MoreHorizontalRegular,
  MoneyRegular,
  PeopleRegular,
  PersonSupportRegular,
  SearchRegular,
  SettingsRegular,
  SignOutRegular,
  WeatherMoonRegular,
  WeatherSunnyRegular,
  VehicleTruckRegular,
} from '@fluentui/react-icons';
import {
  Avatar,
  Button,
  Menu,
  MenuItem,
  MenuList,
  MenuPopover,
  MenuTrigger,
  Tooltip,
} from '@fluentui/react-components';
import { useState } from 'react';
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
  ['/payments', 'Payments', MoneyRegular],
  ['/reports', 'Reports', DataTrendingRegular],
  ['/people', 'People & messages', PeopleRegular],
  ['/audit', 'Audit log', BoardRegular],
  ['/platform', 'Platform', SettingsRegular],
] as const;

const items = [...primaryItems, ...secondaryItems, ['/profile', 'Profile', PeopleRegular]] as const;
const titles = Object.fromEntries(items.map(([path, label]) => [path, label]));

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
  const [search, setSearch] = useState('');
  return (
    <div className="app-shell">
      <aside className="sidebar" aria-label="Operations navigation">
        <div className="sidebar-brand">
          <NavLink to="/" className="brand-mark" aria-label="Trotxi operations home">
            <span className="brand-symbol" aria-hidden="true" />
          </NavLink>
        </div>
        <nav className="nav-list" aria-label="Operations">
          {primaryItems.map(([path, label, Icon]) => (
            <Tooltip key={path} content={label} relationship="label">
              <NavLink
                className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}
                to={path}
                end={path === '/'}
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
                {secondaryItems.map(([path, label, Icon]) => (
                  <MenuItem key={path} icon={<Icon />} onClick={() => navigate(path)}>
                    {label}
                  </MenuItem>
                ))}
              </MenuList>
            </MenuPopover>
          </Menu>
        </nav>
        <div className="sidebar-footer">
          <NavLink to="/profile" aria-label="Open profile">
            <Avatar
              name={account?.displayName}
              image={account?.avatarUrl ? { src: account.avatarUrl } : undefined}
              size={32}
            />
          </NavLink>
        </div>
      </aside>
      <section className="workspace">
        <header className="topbar">
          <div className="topbar-heading">
            <div className="topbar-title">{titles[pathname] ?? 'Trotxi Operations'}</div>
            <div className="topbar-subtitle">Accra network · Operations</div>
          </div>
          <form
            className="topbar-search"
            role="search"
            onSubmit={(event) => {
              event.preventDefault();
              navigate(`/trips?search=${encodeURIComponent(search.trim())}`);
            }}
          >
            <SearchRegular aria-hidden="true" />
            <input
              aria-label="Search trips, drivers and vehicles"
              placeholder="Search trip, driver or vehicle"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
            />
          </form>
          <div className="ops-status">
            <span className="connection-dot" /> Ops workspace
          </div>
          <Tooltip content="People & messages" relationship="label">
            <NavLink className="topbar-icon" to="/people" aria-label="People and messages">
              <AlertBadgeRegular aria-hidden="true" />
            </NavLink>
          </Tooltip>
          <Tooltip
            content={`Switch to ${appearance === 'dark' ? 'light' : 'dark'} mode`}
            relationship="label"
          >
            <Button
              appearance="subtle"
              aria-label={`Switch to ${appearance === 'dark' ? 'light' : 'dark'} mode`}
              icon={appearance === 'dark' ? <WeatherSunnyRegular /> : <WeatherMoonRegular />}
              onClick={toggleAppearance}
            />
          </Tooltip>
          <NavLink className="profile-link" to="/profile" aria-label="Open profile">
            <Avatar
              name={account?.displayName}
              image={account?.avatarUrl ? { src: account.avatarUrl } : undefined}
            />
            <span>{account?.displayName?.split(' ')[0] ?? 'Operator'}</span>
          </NavLink>
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
