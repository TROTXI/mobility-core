import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_labels.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/auto_renewal_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/checkout_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/notifications_inbox_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/standby_page.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/utils/money_format.dart';
import 'package:trotxi_commuter/core/widgets/app_surfaces.dart';
import 'package:trotxi_commuter/core/widgets/commuter_root_header.dart';

String _formatDay(DateTime date) => DateFormat('d MMM y').format(date.toUtc());
String _formatDate(Date date) => _formatDay(date.toDateTime());

String _blockLabel(AccessBlock block) => switch (block.kind) {
  AccessBlockKindEnum.paused => 'Your plan is paused.',
  AccessBlockKindEnum.dispute => 'A payment dispute needs attention.',
  AccessBlockKindEnum.opsRestriction =>
    'Operations has temporarily restricted reservations.',
  _ => 'Reservations are temporarily unavailable.',
};

/// Figma's commute-plan destination, backed by the existing Ops offer model.
class WalletTab extends StatefulWidget {
  const WalletTab({super.key, required this.client});
  final CommuterApi client;

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  Membership? _membership;
  List<Purchase> _purchases = const [];
  Object? _error;
  bool _loading = true;

  RiderOwnApi get _riderApi => widget.client.getRiderOwnApi();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final membershipFuture = _riderApi.getMembership(
        xTrotxiClient: widget.client.metadata.app,
        xTrotxiBuild: widget.client.metadata.build,
        xTrotxiPlatform: widget.client.metadata.platform,
      );
      final purchasesFuture = _riderApi.listPurchases(
        xTrotxiClient: widget.client.metadata.app,
        xTrotxiBuild: widget.client.metadata.build,
        xTrotxiPlatform: widget.client.metadata.platform,
        limit: 30,
      );
      final membershipResponse = await membershipFuture;
      final purchasesResponse = await purchasesFuture;
      if (!mounted) return;
      setState(() {
        _membership = membershipResponse.data?.data;
        _purchases = purchasesResponse.data?.data.toList() ?? const [];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Purchase? _purchaseFor(MembershipCoverage? coverage) {
    if (coverage == null) return null;
    for (final purchase in _purchases) {
      if (purchase.billingPeriodId == coverage.id) return purchase;
    }
    for (final purchase in _purchases) {
      if (purchase.state == PurchaseStateEnum.fulfilled) return purchase;
    }
    return null;
  }

  Future<void> _openNotifications() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => NotificationsInboxPage(client: widget.client),
    ),
  );

  Future<void> _openOffers() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => StandbyPage(client: widget.client)),
    );
    if (mounted) await _load();
  }

  Future<void> _openPayments() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => CheckoutPage(client: widget.client)),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayoutInfo.of(context);
    final horizontalPadding = layout.select(
      phone: 24.0,
      tabletPortrait: 28.0,
      tabletLandscape: 32.0,
    );
    final maxWidth = layout.select(
      phone: 560.0,
      tabletPortrait: 700.0,
      tabletLandscape: 880.0,
    );
    return Scaffold(
      backgroundColor: context.appColors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: RefreshIndicator(
              onRefresh: _load,
              color: context.appColors.actionPrimaryDefault,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  36,
                ),
                children: _buildBody(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    final membership = _membership;
    final plan = _purchaseFor(membership?.coverage)?.plan;
    final subtitle = plan == null
        ? 'Your access to reliable Trotxi rides.'
        : 'Your ${commutePlanLabel(plan.name).toLowerCase()} access to reliable Trotxi rides.';
    final header = CommuterRootHeader(
      title: 'Commute plan',
      subtitle: subtitle,
      onNotifications: _openNotifications,
    );
    if (_loading) {
      return [header, const SizedBox(height: 20), const _PlanLoading()];
    }
    if (_error != null || membership == null) {
      return [header, const SizedBox(height: 20), _PlanError(onRetry: _load)];
    }

    final coverage = membership.coverage;
    final purchase = _purchaseFor(coverage);
    final blocks = membership.access.canReserve
        ? const <AccessBlock>[]
        : membership.access.blocks.toList();
    return [
      header,
      const SizedBox(height: 20),
      if (blocks.isNotEmpty) ...[
        _AccessNotice(blocks: blocks),
        const SizedBox(height: 14),
      ],
      _ActivePlanCard(
        membership: membership,
        purchase: purchase,
        onGetPlan: _openOffers,
      ),
      if (membership.upcomingCoverage case final upcoming?) ...[
        const SizedBox(height: 14),
        _UpcomingCoverage(coverage: upcoming),
      ],
      const SizedBox(height: 24),
      Text(
        'Plan usage',
        style: AppTypography.label.copyWith(
          color: context.appColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),
      _PlanUsageCard(membership: membership),
      const SizedBox(height: 24),
      Text(
        'Manage',
        style: AppTypography.label.copyWith(
          color: context.appColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),
      _PlanAction(
        title: 'Plan details',
        subtitle: 'View benefits, renewal and billing',
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => _PlanDetailsPage(
              client: widget.client,
              membership: membership,
              purchase: purchase,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      _PlanAction(
        title: coverage == null ? 'Get a commute plan' : 'Change plan',
        subtitle: coverage == null
            ? 'Tell us your route and travel days'
            : 'Request a new route, schedule or plan',
        onTap: _openOffers,
      ),
      const SizedBox(height: 8),
      _PlanAction(
        title: 'Billing & payments',
        subtitle: 'Manage payments and receipts',
        onTap: _openPayments,
      ),
    ];
  }
}

class _ActivePlanCard extends StatelessWidget {
  const _ActivePlanCard({
    required this.membership,
    required this.purchase,
    required this.onGetPlan,
  });
  final Membership membership;
  final Purchase? purchase;
  final VoidCallback onGetPlan;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final coverage = membership.coverage;
    if (coverage == null) {
      return AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NO ACTIVE PLAN',
              style: AppTypography.caption.copyWith(
                color: colors.actionSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Start your commute plan',
              style: AppTypography.heading3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Tell us your route and travel days. Operations will send an offer for you to review.',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onGetPlan,
              child: const Text('Join the waitlist'),
            ),
          ],
        ),
      );
    }

    final plan = purchase?.plan;
    final planName = plan == null
        ? 'Trotxi commute plan'
        : 'Trotxi ${commutePlanLabel(plan.name)}';
    final cadence = plan == null
        ? 'Reliable weekday commute access'
        : '${commutePlanLabel(plan.name)} commute access';
    final renewal = switch (plan) {
      PurchasePlanEnum.weekly => 'Renews weekly',
      PurchasePlanEnum.biweekly => 'Renews every two weeks',
      PurchasePlanEnum.monthly => 'Renews monthly',
      PurchasePlanEnum.annual => 'Previous annual plan',
      _ =>
        coverage.renewalMode == MembershipCoverageRenewalModeEnum.automatic
            ? 'Auto-renewal active'
            : 'Manual renewal',
    };
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coverage.paused ? 'PAUSED PLAN' : 'ACTIVE PLAN',
            style: AppTypography.caption.copyWith(
              color: coverage.paused ? colors.warning : colors.actionSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            planName,
            style: AppTypography.heading3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            cadence,
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                child: AppStatusBadge(
                  label: coverage.paused ? 'Paused' : renewal,
                  color: coverage.paused
                      ? colors.warning
                      : colors.actionSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  coverage.endsAt == null ? 'Started' : 'Next renewal',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  _formatDay(coverage.endsAt ?? coverage.startsAt),
                  textAlign: TextAlign.right,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanUsageCard extends StatelessWidget {
  const _PlanUsageCard({required this.membership});
  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final commute = membership.commute;
    final legs = commute?.legs.toList() ?? const <CommuteLegView>[];
    final hasOutbound = legs.any(
      (leg) => leg.direction == CommuteLegViewDirectionEnum.outbound,
    );
    final hasReturn = legs.any(
      (leg) => leg.direction == CommuteLegViewDirectionEnum.return_,
    );
    final windows = switch ((hasOutbound, hasReturn)) {
      (true, true) => 'Morning + evening commute windows',
      (true, false) => 'Morning commute window',
      (false, true) => 'Evening commute window',
      _ => 'Commute access is set by your offer',
    };
    return AppSurface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            commute?.routeName ?? 'Commute access',
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 5),
          Text(
            windows,
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: colors.borderSubtle),
          const SizedBox(height: 16),
          _UsageRow(
            label: 'Rides remaining',
            value: '${membership.entitlements.remainingRides}',
          ),
          const SizedBox(height: 12),
          _UsageRow(
            label: 'Ride Credit',
            value: membership.entitlements.availableCredit.formatted,
            accent: true,
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.label,
    required this.value,
    this.accent = false,
  });
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ),
      Text(
        value,
        style: AppTypography.label.copyWith(
          color: accent
              ? context.appColors.actionSecondary
              : context.appColors.textPrimary,
        ),
      ),
    ],
  );
}

class _PlanAction extends StatelessWidget {
  const _PlanAction({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.label.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.iconSubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessNotice extends StatelessWidget {
  const _AccessNotice({required this.blocks});
  final List<AccessBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: .1),
        border: Border.all(color: colors.warning.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservations need attention',
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                for (final block in blocks)
                  Text(
                    _blockLabel(block),
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCoverage extends StatelessWidget {
  const _UpcomingCoverage({required this.coverage});
  final MembershipCoverage coverage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.actionPrimaryDefault.withValues(alpha: .08),
        border: Border.all(
          color: colors.actionPrimaryDefault.withValues(alpha: .24),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_available_rounded, color: colors.actionSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming coverage paid',
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Starts ${_formatDay(coverage.startsAt)}${coverage.endsAt == null ? '' : ' · Ends ${_formatDay(coverage.endsAt!)}'}',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These rides become available when this coverage starts.',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanDetailsPage extends StatelessWidget {
  const _PlanDetailsPage({
    required this.client,
    required this.membership,
    required this.purchase,
  });
  final CommuterApi client;
  final Membership membership;
  final Purchase? purchase;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final coverage = membership.coverage;
    final commute = membership.commute;
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(title: const Text('Plan details')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          children: [
            AppPageHeading(
              title: purchase == null
                  ? 'Your commute plan'
                  : 'Trotxi ${commutePlanLabel(purchase!.plan.name)}',
              subtitle: coverage == null
                  ? 'You do not have active coverage.'
                  : 'Your route, rides and renewal in one place.',
            ),
            const SizedBox(height: 20),
            AppSurface(
              child: Column(
                children: [
                  AppDetailRow(
                    label: 'Status',
                    value: coverage == null
                        ? 'No active plan'
                        : coverage.paused
                        ? 'Paused'
                        : 'Active',
                  ),
                  if (coverage != null) ...[
                    const Divider(height: 24),
                    AppDetailRow(
                      label: 'Coverage',
                      value: coverage.endsAt == null
                          ? 'From ${_formatDay(coverage.startsAt)}'
                          : '${_formatDay(coverage.startsAt)} to ${_formatDay(coverage.endsAt!)}',
                    ),
                  ],
                  const Divider(height: 24),
                  AppDetailRow(
                    label: 'Rides remaining',
                    value: '${membership.entitlements.remainingRides}',
                  ),
                  const Divider(height: 24),
                  AppDetailRow(
                    label: 'Available Ride Credit',
                    value: membership.entitlements.availableCredit.formatted,
                  ),
                  const Divider(height: 24),
                  AppDetailRow(
                    label: 'Total Ride Credit',
                    value: membership.entitlements.credit.formatted,
                  ),
                  if (membership.entitlements.heldCredit.amountMinor > 0) ...[
                    const Divider(height: 24),
                    AppDetailRow(
                      label: 'Credit being processed',
                      value: membership.entitlements.heldCredit.formatted,
                    ),
                  ],
                ],
              ),
            ),
            if (commute != null) ...[
              const SizedBox(height: 20),
              Text(
                'Your commute',
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 12),
              AppSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commute.routeName,
                      style: AppTypography.heading3.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final leg in commute.legs)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${leg.direction == CommuteLegViewDirectionEnum.outbound ? 'Outbound' : 'Return'} · ${leg.localDeparture}\n${leg.pickupName} → ${leg.dropoffName}',
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      commute.effectiveTo == null
                          ? 'From ${_formatDate(commute.effectiveFrom)}'
                          : '${_formatDate(commute.effectiveFrom)} to ${_formatDate(commute.effectiveTo!)}',
                      style: AppTypography.caption.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            _PlanAction(
              title: 'Card auto-renewal',
              subtitle: 'Manage renewal and saved-card controls',
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => AutoRenewalPage(client: client),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanLoading extends StatelessWidget {
  const _PlanLoading();

  @override
  Widget build(BuildContext context) => AppSurface(
    child: SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(
          color: context.appColors.actionPrimaryDefault,
        ),
      ),
    ),
  );
}

class _PlanError extends StatelessWidget {
  const _PlanError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Could not load your commute plan',
          style: AppTypography.label.copyWith(
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
