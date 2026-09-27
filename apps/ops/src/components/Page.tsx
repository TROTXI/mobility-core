import { Badge, Button, Spinner } from '@fluentui/react-components';
import { ArrowClockwiseRegular } from '@fluentui/react-icons';
import type { ReactNode } from 'react';
import { formatAccraTime } from '../api/accra-time';

export function Page({
  title,
  description,
  actions,
  children,
}: {
  title: string;
  description: string;
  actions?: ReactNode;
  children: ReactNode;
}) {
  return (
    <main className="page">
      <div className="page-heading">
        <div>
          <h1>{title}</h1>
          <p>{description}</p>
        </div>
        {actions && <div className="toolbar">{actions}</div>}
      </div>
      {children}
    </main>
  );
}

export function Panel({
  title,
  action,
  children,
}: {
  title: string;
  action?: ReactNode;
  children: ReactNode;
}) {
  return (
    <section className="panel">
      <div className="panel-header">
        <h2>{title}</h2>
        {action}
      </div>
      {children}
    </section>
  );
}

export function LoadingRows({ rows = 5 }: { rows?: number }) {
  return (
    <div className="panel-body" aria-label="Loading">
      {Array.from({ length: rows }, (_, index) => (
        <div
          key={index}
          className="skeleton"
          style={{ marginBottom: 18, width: `${92 - index * 6}%` }}
        />
      ))}
    </div>
  );
}

export function LoadingPage() {
  return (
    <main className="auth-page">
      <Spinner size="large" label="Opening Trotxi Operations" />
    </main>
  );
}

export function ErrorState({ message, retry }: { message: string; retry?: () => void }) {
  return (
    <div className="error-box" role="alert">
      {message}
      {retry && (
        <Button appearance="subtle" icon={<ArrowClockwiseRegular />} onClick={retry}>
          Retry
        </Button>
      )}
    </div>
  );
}

export function StatusBadge({ value }: { value: string }) {
  const normalized = value.toLowerCase();
  const color =
    normalized.includes('active') ||
    normalized.includes('complete') ||
    normalized.includes('on_time')
      ? 'success'
      : normalized.includes('cancel') ||
          normalized.includes('failed') ||
          normalized.includes('stale')
        ? 'danger'
        : normalized.includes('pending') ||
            normalized.includes('unassigned') ||
            normalized.includes('awaiting')
          ? 'warning'
          : 'informative';
  return (
    <Badge appearance="tint" color={color}>
      {value.replaceAll('_', ' ').toUpperCase()}
    </Badge>
  );
}

export function Empty({
  children = 'Nothing to show for these filters.',
}: {
  children?: ReactNode;
}) {
  return <div className="empty">{children}</div>;
}

export function money(value?: { amountMinor: number; currency: 'GHS' } | null) {
  if (!value) return '—';
  return new Intl.NumberFormat('en-GH', { style: 'currency', currency: value.currency }).format(
    value.amountMinor / 100,
  );
}

export function when(value?: string | null) {
  if (!value) return '—';
  return formatAccraTime(value);
}
