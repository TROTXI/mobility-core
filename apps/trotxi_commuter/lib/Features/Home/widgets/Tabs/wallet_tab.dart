import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/paystack_checkout_page.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_details_sheet.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/purchase_labels.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Payments/subscribe_monthly_dialog.dart';
import 'package:trotxi_commuter/core/config/client_metadata.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/utils/money_format.dart';

// ---------------------------------------------------------------------
// Activity feed
// ---------------------------------------------------------------------

/// One line in the recent-activity list. Rides and purchases come from two
/// separate ledgers, so each is normalised into this before being merged
/// into a single newest-first feed.
sealed class _Activity {
  const _Activity();

  DateTime get at;
}

class _RideActivity extends _Activity {
  const _RideActivity(this.entry);
  final RideEntry entry;

  @override
  DateTime get at => entry.createdAt;
}

class _PurchaseActivity extends _Activity {
  const _PurchaseActivity(this.purchase);
  final Purchase purchase;

  @override
  DateTime get at => purchase.createdAt;
}

// ---------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------

String _formatDay(DateTime date) => DateFormat('d MMM').format(date.toLocal());

String _formatFullDay(DateTime date) =>
    DateFormat('d MMM y').format(date.toLocal());

String _formatDate(Date date) => _formatFullDay(date.toDateTime());

/// Ledger reasons are wire enums; these are the rider-facing sentences.
String _rideReasonLabel(RideEntryReasonEnum reason) {
  return switch (reason) {
    RideEntryReasonEnum.allocation => 'Rides added',
    RideEntryReasonEnum.boarding => 'Ride taken',
    RideEntryReasonEnum.noShow => 'Missed ride',
    RideEntryReasonEnum.returned => 'Ride returned',
    RideEntryReasonEnum.refund => 'Rides refunded',
    RideEntryReasonEnum.converted => 'Converted to credit',
    _ => 'Ride entry',
  };
}

/// Why the rider cannot reserve, from `access.blocks`.
String _blockLabel(AccessBlock block) {
  return switch (block.kind) {
    AccessBlockKindEnum.paused => 'Your membership is paused.',
    AccessBlockKindEnum.dispute => 'A payment dispute is open on your account.',
    AccessBlockKindEnum.opsRestriction =>
      'Operations has restricted this account.',
    _ => 'Reservations are blocked on this account.',
  };
}

// ---------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------

/// The rider's wallet and subscription, driven by `GET /v1/me/membership`
/// (membership, coverage, access, commute and entitlements) plus the two
/// ledgers behind the activity feed: `GET /v1/me/ride-entries` and
/// `GET /v1/me/purchases`.
class WalletTab extends StatefulWidget {
  const WalletTab({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  /// How many ledger rows each side of the feed contributes.
  static const _activityPageSize = 20;

  /// How many merged rows are shown at once.
  static const _activityShown = 8;

  Membership? _membership;
  List<_Activity> _activity = const [];

  bool _loading = true;
  Object? _error;

  /// True while a checkout round-trip is in flight, so the subscribe button
  /// cannot be tapped twice into two purchases.
  bool _subscribing = false;

  /// How long to keep asking whether a purchase has settled after checkout,
  /// and how often to ask.
  static const _settleTimeout = Duration(seconds: 24);
  static const _settlePollInterval = Duration(seconds: 2);

  RiderOwnApi get _riderApi => widget.client.getRiderOwnApi();

  MembershipEntitlements? get _entitlements => _membership?.entitlements;

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
      // All three are started together; the page only renders once they've
      // all landed, so there's nothing to gain from staggering them.
      final membership = _riderApi.getMembership(
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
      );
      final rides = _riderApi.listRideEntries(
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
        limit: _activityPageSize,
      );
      final purchases = _riderApi.listPurchases(
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
        limit: _activityPageSize,
      );

      final membershipResponse = await membership;
      final rideResponse = await rides;
      final purchaseResponse = await purchases;

      final membershipData = membershipResponse.data?.data;
      final rideData = rideResponse.data?.data ?? const <RideEntry>[];
      final purchaseData = purchaseResponse.data?.data ?? const <Purchase>[];

      _debugLogRideCredits(membershipData, rideResponse);

      if (!mounted) return;
      setState(() {
        _membership = membershipData;
        _activity = <_Activity>[
          ...rideData.map(_RideActivity.new),
          ...purchaseData.map(_PurchaseActivity.new),
        ]..sort((a, b) => b.at.compareTo(a.at));
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error loading wallet: $e');
    }
  }

  /// Debug-only dump of everything behind the RIDE CREDITS card: the
  /// entitlements the card renders (from `GET /v1/me/membership`) and the
  /// ride-credit ledger rows that feed the activity list (from
  /// `GET /v1/me/ride-entries`), so both can be compared against what Swagger
  /// returns for the same account.
  ///
  /// `remainingRides` and the three Money fields are the card's inputs;
  /// `deltaRides` across the ledger is what they should add up to, which is
  /// the mismatch this is most useful for catching.
  void _debugLogRideCredits(
    Membership? membership,
    Response<RideEntryPage> rideResponse,
  ) {
    if (!kDebugMode) return;

    debugPrint('===== RIDE CREDITS =====');

    final entitlements = membership?.entitlements;
    if (entitlements == null) {
      debugPrint(
        'entitlements: null (membership was ${membership == null ? 'null' : 'present'})',
      );
    } else {
      debugPrint('remainingRides:  ${entitlements.remainingRides}');
      debugPrint(
        'credit:          ${entitlements.credit.amountMinor} '
        '${entitlements.credit.currency.name} (${entitlements.credit.formatted})',
      );
      debugPrint(
        'heldCredit:      ${entitlements.heldCredit.amountMinor} '
        '${entitlements.heldCredit.currency.name} (${entitlements.heldCredit.formatted})',
      );
      debugPrint(
        'availableCredit: ${entitlements.availableCredit.amountMinor} '
        '${entitlements.availableCredit.currency.name} '
        '(${entitlements.availableCredit.formatted})',
      );
    }

    final page = rideResponse.data;
    final entries = page?.data ?? const <RideEntry>[];
    debugPrint(
      'ride-entries: HTTP ${rideResponse.statusCode} · '
      '${entries.length} row(s) · nextCursor=${page?.page.nextCursor}',
    );
    for (final entry in entries) {
      debugPrint(
        '  ${entry.createdAt.toIso8601String()}  '
        '${entry.deltaRides > 0 ? '+' : ''}${entry.deltaRides}  '
        '${entry.reason.name}  billingPeriodId=${entry.billingPeriodId}  '
        'id=${entry.id}',
      );
    }
    final net = entries.fold<int>(0, (sum, e) => sum + e.deltaRides);
    debugPrint('net deltaRides over these ${entries.length} row(s): $net');
    debugPrint('========================');
  }

  /// Runs the monthly purchase: pick route and commute, pay any cash due on
  /// Paystack, then reload. The charge is confirmed by the backend's own
  /// webhook, so the reload is the only thing that can be trusted here.
  Future<void> _onSubscribe() async {
    if (_subscribing) return;
    setState(() => _subscribing = true);
    try {
      final purchase = await showSubscribeMonthlyDialog(
        context,
        client: widget.client,
        availableCredit: _entitlements?.availableCredit,
        currentCommute: _membership?.commute,
      );
      if (purchase == null || !mounted) return;

      final checkoutUrl = purchase.checkout?.url;
      if (checkoutUrl != null) {
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) =>
                PaystackCheckoutPage(checkoutUrl: checkoutUrl),
          ),
        );
      } else {
        // Credit covered the whole price, so there was nothing to pay.
        _showSnack('Your credit covered this purchase.');
      }
      if (!mounted) return;

      // PaystackCheckoutPage pops the moment the WebView leaves Paystack's
      // domain, which is ahead of the webhook that actually settles the
      // purchase. Reloading right there reads entitlements the backend has
      // not granted yet: the purchase shows up in the activity feed while
      // credits and membership still read as unpaid. So wait for the
      // purchase to leave its settling state before reloading.
      _showSnack('Confirming your payment...');
      final settled = await _awaitPurchaseSettled(purchase);
      if (!mounted) return;

      await _load();
      if (!mounted) return;
      _showSnack(_settlementMessage(settled));
    } finally {
      if (mounted) setState(() => _subscribing = false);
    }
  }

  /// A purchase the backend has not finished settling. Everything else is a
  /// resting state whose effect on entitlements is already visible.
  static bool _isSettling(PurchaseStateEnum state) =>
      state == PurchaseStateEnum.awaitingPayment ||
      state == PurchaseStateEnum.processing;

  /// Re-reads the purchase until it settles or [_settleTimeout] runs out,
  /// and answers with the last state seen.
  Future<PurchaseStateEnum> _awaitPurchaseSettled(Purchase purchase) async {
    var state = purchase.state;
    final deadline = DateTime.now().add(_settleTimeout);

    while (_isSettling(state) && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(_settlePollInterval);
      if (!mounted) return state;
      try {
        final response = await _riderApi.getPurchase(
          id: purchase.id,
          xTrotxiClient: commuterMetadata.client,
          xTrotxiBuild: commuterMetadata.build,
          xTrotxiPlatform: commuterMetadata.platform,
        );
        final refreshed = response.data?.data;
        if (refreshed != null) state = refreshed.state;
      } catch (e) {
        // One failed poll is not fatal — the reload still runs afterwards and
        // the rider can pull to refresh.
        debugPrint('Error polling purchase ${purchase.id}: $e');
      }
    }
    return state;
  }

  String _settlementMessage(PurchaseStateEnum state) {
    return switch (state) {
      PurchaseStateEnum.fulfilled => 'Payment confirmed.',
      PurchaseStateEnum.failed => "That payment didn't go through.",
      PurchaseStateEnum.cancelled => 'That purchase was cancelled.',
      PurchaseStateEnum.reviewRequired => 'Your payment is under review.',
      // Still settling when the timeout ran out: the webhook is late rather
      // than lost, so point at the refresh instead of claiming a failure.
      _ => 'Still confirming your payment. Pull down to refresh in a moment.',
    };
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------
  // UI — theme-aware via context.appColors (light/dark) and laid out from
  // ResponsiveLayoutInfo (phone / tablet portrait / tablet landscape), the
  // same pattern OnBoardPage and SplashView use.
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final layout = ResponsiveLayoutInfo.of(context);
    final isWide = layout.isTabletLandscape;

    final maxContentWidth = layout.select(
      phone: 520.0,
      tabletPortrait: 680.0,
      tabletLandscape: 960.0,
    );
    final horizontalPadding = layout.select(
      phone: 16.0,
      tabletPortrait: 24.0,
      tabletLandscape: 32.0,
    );

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: RefreshIndicator(
              onRefresh: _load,
              color: colors.actionPrimaryDefault,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  32,
                ),
                children: _buildBody(context, isWide),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, bool isWide) {
    final header = _buildHeader(context);

    if (_loading) {
      return [header, const SizedBox(height: 20), _buildLoadingCard(context)];
    }

    final membership = _membership;
    if (_error != null || membership == null) {
      return [header, const SizedBox(height: 20), _buildErrorCard(context)];
    }

    // blocks is only populated while access is denied, so an empty list here
    // is the ordinary "everything is fine" case.
    final blocks = membership.access.canReserve
        ? const <AccessBlock>[]
        : membership.access.blocks.toList();

    return [
      header,
      const SizedBox(height: 20),
      if (blocks.isNotEmpty) ...[
        _buildAccessBanner(context, blocks),
        const SizedBox(height: 16),
      ],
      ..._buildBalanceSection(context, membership, isWide),
      const SizedBox(height: 24),
      _buildSectionTitle(context, 'Recent activity'),
      const SizedBox(height: 12),
      _buildActivitySection(context),
    ];
  }

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wallet',
          style: AppTypography.heading2.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage credits, payments and your plan.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    final colors = context.appColors;
    final error = _error;
    final message = error is TrotxiException
        ? error.message
        : "Couldn't load your wallet";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Try again')),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Access blocks — why reservations are closed
  // ---------------------------------------------------------------------

  Widget _buildAccessBanner(BuildContext context, List<AccessBlock> blocks) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.12),
        border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: colors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You can't reserve rides right now",
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

  // ---------------------------------------------------------------------
  // Entitlements + membership — both from GET /v1/me/membership
  // ---------------------------------------------------------------------

  List<Widget> _buildBalanceSection(
    BuildContext context,
    Membership membership,
    bool isWide,
  ) {
    if (isWide) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildCreditsCard(context, membership.entitlements),
            ),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildMembershipCard(context, membership)),
          ],
        ),
      ];
    }

    return [
      _buildCreditsCard(context, membership.entitlements),
      const SizedBox(height: 16),
      _buildMembershipCard(context, membership),
    ];
  }

  Widget _buildCreditsCard(
    BuildContext context,
    MembershipEntitlements entitlements,
  ) {
    final colors = context.appColors;
    final held = entitlements.heldCredit.amountMinor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RIDE CREDITS',
            style: AppTypography.label.copyWith(
              color: colors.actionPrimaryDefault,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entitlements.remainingRides}',
                style: AppTypography.display.copyWith(
                  color: colors.onSurfaceStrong,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'rides remaining',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceStrong,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${entitlements.availableCredit.formatted} credit available',
            style: AppTypography.label.copyWith(color: colors.onSurfaceStrong),
          ),
          const SizedBox(height: 4),
          Text(
            // Held credit is committed to a purchase that hasn't settled, so
            // it isn't spendable until that purchase resolves.
            held > 0
                ? '${entitlements.heldCredit.formatted} is held against a '
                      'purchase that is still settling.'
                : 'Credit is applied automatically when you renew.',
            style: AppTypography.caption.copyWith(
              color: colors.onSurfaceStrong.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(BuildContext context, Membership membership) {
    final colors = context.appColors;
    final coverage = membership.coverage;
    final commute = membership.commute;
    final isCovered =
        coverage != null && coverage.state == MembershipCoverageStateEnum.open;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membership',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _membershipHeadline(membership),
                      style: AppTypography.buttonAction.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _membershipDetail(membership),
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCovered) _buildStatusBadge(context, coverage.paused),
            ],
          ),
          if (commute != null) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: colors.borderSubtle),
            const SizedBox(height: 14),
            _buildCommuteSummary(context, commute),
          ],
          const SizedBox(height: 16),
          _buildSubscribeButton(context, isCovered),
        ],
      ),
    );
  }

  /// The one-line status: what the rider has, not what the ledger calls it.
  String _membershipHeadline(Membership membership) {
    final coverage = membership.coverage;
    if (coverage == null) {
      return membership.lastCoverageEndedAt == null
          ? 'No active plan'
          : 'Plan expired';
    }
    if (coverage.paused) return 'Paused';
    return switch (coverage.state) {
      MembershipCoverageStateEnum.open => 'Monthly plan active',
      MembershipCoverageStateEnum.closed => 'Plan ended',
      MembershipCoverageStateEnum.reversed => 'Plan reversed',
      _ => 'Monthly plan',
    };
  }

  String _membershipDetail(Membership membership) {
    final coverage = membership.coverage;
    if (coverage == null) {
      final endedAt = membership.lastCoverageEndedAt;
      return endedAt == null
          ? 'Subscribe to unlock recurring rides.'
          : 'Ended ${_formatFullDay(endedAt)}. Subscribe again to keep riding.';
    }
    final endsAt = coverage.endsAt;
    if (endsAt == null) return 'Started ${_formatFullDay(coverage.startsAt)}';
    // renewalMode is manual-only today, so this is a deadline for the rider
    // to act on, not a promise that we will charge them again.
    return coverage.renewalMode == MembershipCoverageRenewalModeEnum.manual
        ? 'Renew by ${_formatFullDay(endsAt)}'
        : 'Renews ${_formatFullDay(endsAt)}';
  }

  Widget _buildStatusBadge(BuildContext context, bool paused) {
    final colors = context.appColors;
    final color = paused ? colors.warning : colors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        paused ? 'Paused' : 'Active',
        style: AppTypography.label.copyWith(color: color),
      ),
    );
  }

  Widget _buildCommuteSummary(BuildContext context, MembershipCommute commute) {
    final colors = context.appColors;
    // Outbound before return, whatever order the API listed them in.
    final legs = commute.legs.toList()
      ..sort((a, b) => a.direction.name.compareTo(b.direction.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          commute.routeName,
          style: AppTypography.label.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        for (final leg in legs)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${leg.direction == CommuteLegViewDirectionEnum.outbound ? 'Out' : 'Back'}'
              ' · ${leg.localDeparture} · '
              '${leg.pickupName} → ${leg.dropoffName}',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          commute.effectiveTo == null
              ? 'From ${_formatDate(commute.effectiveFrom)}'
              : '${_formatDate(commute.effectiveFrom)} – '
                    '${_formatDate(commute.effectiveTo!)}',
          style: AppTypography.caption.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context, bool isCovered) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _subscribing ? null : _onSubscribe,
        style: FilledButton.styleFrom(
          backgroundColor: colors.actionPrimaryDefault,
          disabledBackgroundColor: colors.actionPrimaryDisabled,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _subscribing
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.actionOnPrimary,
                ),
              )
            : Text(
                isCovered ? 'Renew monthly plan' : 'Subscribe monthly',
                style: AppTypography.buttonAction.copyWith(
                  color: colors.actionOnPrimary,
                ),
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Recent activity — ride entries merged with purchases
  // ---------------------------------------------------------------------

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.appColors;
    return Text(
      title,
      style: AppTypography.buttonAction.copyWith(color: colors.textPrimary),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    final colors = context.appColors;
    final shown = _activity.take(_activityShown).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      child: shown.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nothing here yet. Your rides and payments will show up as '
                'they happen.',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            )
          : Column(
              children: [
                for (int i = 0; i < shown.length; i++) ...[
                  _buildActivityTile(context, shown[i]),
                  if (i != shown.length - 1)
                    Divider(height: 1, color: colors.borderSubtle),
                ],
              ],
            ),
    );
  }

  Widget _buildActivityTile(BuildContext context, _Activity activity) {
    final (title, subtitle, amount, isCredit) = switch (activity) {
      _RideActivity(:final entry) => (
        _rideReasonLabel(entry.reason),
        _formatDay(entry.createdAt),
        '${entry.deltaRides > 0 ? '+' : ''}${entry.deltaRides} '
            '${entry.deltaRides.abs() == 1 ? 'ride' : 'rides'}',
        entry.deltaRides > 0,
      ),
      _PurchaseActivity(:final purchase) => (
        purchasePlanLabel(purchase.plan),
        '${purchaseStateLabel(purchase.state)} · ${_formatDay(purchase.createdAt)}',
        purchase.price.formatted,
        false,
      ),
    };

    final colors = context.appColors;
    // Only purchases have a detail endpoint (`GET /v1/me/purchases/{id}`), so
    // ride entries stay inert and show no affordance.
    final purchase = activity is _PurchaseActivity ? activity.purchase : null;

    final row = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            isCredit ? '+' : '−',
            style: AppTypography.bodyLarge.copyWith(
              color: isCredit
                  ? colors.actionPrimaryDefault
                  : colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 2),
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
          Text(
            amount,
            textAlign: TextAlign.right,
            style: AppTypography.label.copyWith(
              color: isCredit
                  ? colors.actionPrimaryDefault
                  : colors.textSecondary,
            ),
          ),
          if (purchase != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colors.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (purchase == null) return row;

    // The surrounding card paints its own opaque background over the
    // Scaffold's Material, so the splash needs a transparent Material of its
    // own above that fill or it never shows.
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: () => _openPurchase(purchase), child: row),
    );
  }

  /// Opens the details sheet for [purchase] and reloads if the purchase moved
  /// on since the feed was built — a purchase that was settling when the list
  /// loaded is the common case, and its entitlements would otherwise stay
  /// stale behind the sheet.
  Future<void> _openPurchase(Purchase purchase) async {
    final refreshed = await showPurchaseDetailsSheet(
      context,
      client: widget.client,
      purchaseId: purchase.id,
    );
    if (!mounted) return;
    if (refreshed != null && refreshed.state != purchase.state) {
      await _load();
    }
  }
}
