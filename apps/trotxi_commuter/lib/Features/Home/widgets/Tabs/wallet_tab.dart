import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

// ---------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------

/// The commuter's ride-credit balance, from `GET /me/rides`: how many
/// rides they can still take.
class RideCreditsSummary {
  const RideCreditsSummary({required this.remainingRides});

  final int remainingRides;
}

/// The commuter's recurring ride plan. Built only when `ridesPerPeriod`
/// comes back non-null from `GET /me/rides` — null means no active plan.
class WalletSubscription {
  const WalletSubscription({required this.ridesPerPeriod, this.renewsAt});

  final int ridesPerPeriod;
  final DateTime? renewsAt;
}

class WalletPaymentMethod {
  const WalletPaymentMethod({
    required this.brandLabel,
    required this.last4,
    required this.isPrimary,
  });

  final String brandLabel; // e.g. 'VISA'
  final String last4;
  final bool isPrimary;

  String get displayName =>
      '${brandLabel[0]}${brandLabel.substring(1).toLowerCase()} •••• $last4';
}

enum CreditActivityDirection { credit, debit }

class CreditActivity {
  const CreditActivity({
    required this.title,
    required this.subtitle,
    required this.amountLabel,
    required this.direction,
  });

  final String title;
  final String subtitle;

  /// Pre-formatted, e.g. '+1 credit' or '1 ride' — credits are counted,
  /// not priced.
  final String amountLabel;
  final CreditActivityDirection direction;
}

// ---------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------

String _formatRenewsAt(DateTime date) => DateFormat('d MMM').format(date);

// ---------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------

class WalletTab extends StatefulWidget {
  const WalletTab({super.key, required this.client});

  final TrotxiApiClient client;

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  RideCreditsSummary? _credits;
  WalletSubscription? _subscription;
  bool _loadingEntitlement = true;
  Object? _entitlementError;

  @override
  void initState() {
    super.initState();
    _fetchEntitlement();
  }

  Future<void> _fetchEntitlement() async {
    setState(() {
      _loadingEntitlement = true;
      _entitlementError = null;
    });

    try {
      final response = await widget.client.getRidesApi().meRidesGet();
      final data = response.data;
      if (!mounted || data == null) return;

      setState(() {
        _credits = RideCreditsSummary(remainingRides: data.remainingRides);
        _subscription = data.ridesPerPeriod == null
            ? null
            : WalletSubscription(
                ridesPerPeriod: data.ridesPerPeriod!,
                renewsAt: data.renewsAt,
              );
        _loadingEntitlement = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _entitlementError = e;
        _loadingEntitlement = false;
      });
      debugPrint('Error fetching ride entitlement: $e');
    }
  }

  // TODO: replace with real data from your wallet API once it's wired up.
  final WalletPaymentMethod _paymentMethod = const WalletPaymentMethod(
    brandLabel: 'VISA',
    last4: '4281',
    isPrimary: true,
  );

  bool _autoRenew = true;

  final List<CreditActivity> _activity = const [
    CreditActivity(
      title: 'Ride Credit added',
      subtitle: 'Unused value · 11 Aug',
      amountLabel: '+1 credit',
      direction: CreditActivityDirection.credit,
    ),
    CreditActivity(
      title: 'Morning commute',
      subtitle: 'Adenta → Airport City',
      amountLabel: '1 ride',
      direction: CreditActivityDirection.debit,
    ),
  ];

  void _onUseCredits() {
    // TODO: navigate to / open the "use credits" flow.
    debugPrint('Use credits tapped');
  }

  void _onChangePaymentMethod() {
    // TODO: navigate to the payment method management screen.
    debugPrint('Payment method tapped');
  }

  void _onToggleAutoRenew(bool value) {
    // TODO: submit the new auto-renew preference via widget.client.
    setState(() => _autoRenew = value);
  }

  void _onViewAllActivity() {
    // TODO: navigate to the full activity list.
    debugPrint('View all activity tapped');
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
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                ..._buildCreditsSection(context, isWide),
                const SizedBox(height: 24),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Payment & renewal'),
                            const SizedBox(height: 12),
                            _buildPaymentSection(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Recent activity'),
                            const SizedBox(height: 12),
                            _buildActivitySection(context),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildSectionTitle(context, 'Payment & renewal'),
                  const SizedBox(height: 12),
                  _buildPaymentSection(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Recent activity'),
                  const SizedBox(height: 12),
                  _buildActivitySection(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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

  // ---------------------------------------------------------------------
  // Ride credits + subscription — driven by GET /me/rides
  // ---------------------------------------------------------------------

  List<Widget> _buildCreditsSection(BuildContext context, bool isWide) {
    if (_loadingEntitlement) {
      return [_buildEntitlementLoadingCard(context)];
    }
    if (_entitlementError != null) {
      return [_buildEntitlementErrorCard(context)];
    }

    final credits = _credits;
    if (credits == null) {
      return [_buildEntitlementErrorCard(context)];
    }

    if (isWide) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildCreditsCard(context, credits)),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildSubscriptionCard(context, _subscription),
            ),
          ],
        ),
      ];
    }

    return [
      _buildCreditsCard(context, credits),
      const SizedBox(height: 16),
      _buildSubscriptionCard(context, _subscription),
    ];
  }

  Widget _buildEntitlementLoadingCard(BuildContext context) {
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

  Widget _buildEntitlementErrorCard(BuildContext context) {
    final colors = context.appColors;
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
            "Couldn't load your ride credits",
            style: AppTypography.label.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _fetchEntitlement,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsCard(BuildContext context, RideCreditsSummary credits) {
    final colors = context.appColors;
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
                '${credits.remainingRides}',
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildUseCreditsButton(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Eligible Ride Credits are automatically applied automatically when available',
            style: AppTypography.caption.copyWith(
              color: colors.onSurfaceStrong.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseCreditsButton(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.actionPrimaryDefault,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _onUseCredits,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Use credits',
            style: AppTypography.buttonAction.copyWith(
              color: colors.actionOnPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Subscription card
  // ---------------------------------------------------------------------

  Widget _buildSubscriptionCard(
    BuildContext context,
    WalletSubscription? subscription,
  ) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subscription == null
                      ? 'No active plan'
                      : '${subscription.ridesPerPeriod} rides per period',
                  style: AppTypography.buttonAction.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subscription == null
                      ? 'Subscribe to unlock recurring rides.'
                      : subscription.renewsAt == null
                      ? 'Renewal date pending'
                      : 'Renews ${_formatRenewsAt(subscription.renewsAt!)}',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (subscription != null) _buildActiveBadge(context),
        ],
      ),
    );
  }

  Widget _buildActiveBadge(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Active',
        style: AppTypography.label.copyWith(color: colors.success),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Payment & renewal
  // ---------------------------------------------------------------------

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.appColors;
    return Text(
      title,
      style: AppTypography.buttonAction.copyWith(color: colors.textPrimary),
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildPaymentMethodTile(context),
          Divider(height: 1, color: colors.borderSubtle),
          _buildAutoRenewTile(context),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onChangePaymentMethod,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  _paymentMethod.brandLabel,
                  style: AppTypography.caption.copyWith(
                    color: colors.textPrimary,
                    fontSize: 8,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _paymentMethod.displayName,
                      style: AppTypography.label.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _paymentMethod.isPrimary
                          ? 'Primary payment method'
                          : 'Payment method',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.iconSubtle,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoRenewTile(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Auto-renew subscription',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: _autoRenew,
            activeThumbColor: colors.actionPrimaryDefault,
            onChanged: _onToggleAutoRenew,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Recent activity
  // ---------------------------------------------------------------------

  Widget _buildActivitySection(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _activity.length; i++) ...[
            _buildActivityTile(context, _activity[i]),
            if (i != _activity.length - 1)
              Divider(height: 1, color: colors.borderSubtle),
          ],
          Divider(height: 1, color: colors.borderSubtle),
          _buildViewAllActivityTile(context),
        ],
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, CreditActivity activity) {
    final colors = context.appColors;
    final isCredit = activity.direction == CreditActivityDirection.credit;
    return Padding(
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
                  activity.title,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            activity.amountLabel,
            textAlign: TextAlign.right,
            style: AppTypography.label.copyWith(
              color: isCredit
                  ? colors.actionPrimaryDefault
                  : colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllActivityTile(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onViewAllActivity,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'View all activity',
              style: AppTypography.buttonAction.copyWith(
                color: colors.actionPrimaryDefault,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
