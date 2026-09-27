import { Button } from '@fluentui/react-components';
import { ArrowDownloadRegular } from '@fluentui/react-icons';
import { useState } from 'react';
import type { components } from '../generated/api';
import { useAuth } from '../auth/AuthContext';
import { ErrorState, LoadingRows, Page, Panel, money } from '../components/Page';
import { useQuery } from '../hooks/useQuery';
import { opsHeaders } from '../api/session';

type Report = components['schemas']['OpsReportSummary'];

const today = () => new Date().toISOString().slice(0, 10);
const monthAgo = () => new Date(Date.now() - 29 * 86400000).toISOString().slice(0, 10);

export function Reports() {
  const { session } = useAuth();
  const [fromDate, setFromDate] = useState(monthAgo);
  const [toDate, setToDate] = useState(today);
  const query = useQuery<Report>(
    async (signal) => {
      const response = await session.client.GET('/v1/ops/reports/summary', {
        params: { query: { fromDate, toDate }, header: opsHeaders },
        signal,
      });
      if (response.error) throw new Error(response.error.error.message);
      return response.data.data;
    },
    [session, fromDate, toDate],
  );
  const report = query.data;
  const exportCsv = () => {
    if (!report) return;
    const rows = [
      ['metric', 'value'],
      ['riders_total', report.riders.total],
      ['riders_active', report.riders.active],
      ['riders_paused', report.riders.paused],
      ['riders_restricted', report.riders.restricted],
      ['trips_total', report.trips.total],
      ['trips_completed', report.trips.completed],
      ['trips_cancelled', report.trips.cancelled],
      ['boarded', report.trips.boarded],
      ['no_shows', report.trips.noShows],
      ['collected_pesewas', report.payments.collected.amountMinor],
      ['refunded_pesewas', report.payments.refunded.amountMinor],
      ['open_payment_reviews', report.payments.openReviews],
      ['deliveries_pending', report.delivery.pending],
      ['deliveries_failed', report.delivery.failed],
    ];
    const blob = new Blob([rows.map((row) => row.join(',')).join('\n')], { type: 'text/csv' });
    const href = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = href;
    link.download = `trotxi-operations-${report.fromDate}-${report.toDate}.csv`;
    link.click();
    URL.revokeObjectURL(href);
  };
  return (
    <Page
      title="Reports & analytics"
      description="Pilot operating facts. Long-running observability stays in Grafana."
      actions={
        <Button icon={<ArrowDownloadRegular />} disabled={!report} onClick={exportCsv}>
          Export CSV
        </Button>
      }
    >
      <div className="filter-bar">
        <label>
          From
          <input
            type="date"
            value={fromDate}
            onChange={(event) => setFromDate(event.target.value)}
          />
        </label>
        <label>
          To
          <input type="date" value={toDate} onChange={(event) => setToDate(event.target.value)} />
        </label>
      </div>
      {query.error && <ErrorState message={query.error} retry={query.retry} />}
      {query.loading ? (
        <LoadingRows rows={8} />
      ) : (
        report && (
          <>
            <div className="stat-grid">
              <Stat
                label="Active riders"
                value={report.riders.active}
                note={`${report.riders.paused} paused`}
              />
              <Stat
                label="Trips completed"
                value={report.trips.completed}
                note={`${report.trips.cancelled} cancelled`}
              />
              <Stat
                label="Collected"
                value={money(report.payments.collected)}
                note={`${money(report.payments.refunded)} refunded`}
              />
              <Stat
                label="Delivery exceptions"
                value={report.delivery.failed}
                note={`${report.delivery.pending} pending`}
                attention={report.delivery.failed > 0}
              />
            </div>
            <div className="split-grid">
              <Panel title="Service outcomes">
                <MetricBars
                  rows={[
                    ['Completed trips', report.trips.completed, report.trips.total],
                    [
                      'Boarded riders',
                      report.trips.boarded,
                      report.trips.boarded + report.trips.noShows,
                    ],
                    ['No-shows', report.trips.noShows, report.trips.boarded + report.trips.noShows],
                  ]}
                />
              </Panel>
              <Panel title="Rider state">
                <MetricBars
                  rows={[
                    ['Active', report.riders.active, report.riders.total],
                    ['Paused', report.riders.paused, report.riders.total],
                    ['Restricted', report.riders.restricted, report.riders.total],
                  ]}
                />
              </Panel>
            </div>
          </>
        )
      )}
    </Page>
  );
}

function Stat({
  label,
  value,
  note,
  attention = false,
}: {
  label: string;
  value: string | number;
  note: string;
  attention?: boolean;
}) {
  return (
    <div className={`stat-card${attention ? ' attention' : ''}`}>
      <div className="stat-label">{label}</div>
      <div className="stat-value">{value}</div>
      <div className="muted">{note}</div>
    </div>
  );
}

function MetricBars({ rows }: { rows: Array<[string, number, number]> }) {
  return (
    <div className="metric-bars">
      {rows.map(([label, value, total]) => (
        <div key={label} className="metric-row">
          <div>
            <strong>{label}</strong>
            <span>{value}</span>
          </div>
          <div className="metric-track">
            <span style={{ width: `${total ? Math.min(100, (value / total) * 100) : 0}%` }} />
          </div>
        </div>
      ))}
    </div>
  );
}
