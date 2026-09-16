import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_client_next/trotxi_client_next.dart' as wire;
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';

// ---------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------

class QuickAction {
  const QuickAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

// ---------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({
    super.key,
    required this.client,
    required this.userData,
    this.onShowBoardingPass,
  });

  final CommuterApi client;

  final Account userData;

  final VoidCallback? onShowBoardingPass;

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  // TODO: replace with real stats data once that endpoint exists on
  // CommuterApi — these are placeholders matching the design.
  final List<QuickAction> _quickActions = const [
    QuickAction(icon: Icons.event_seat_rounded, label: 'Track ride'),
    QuickAction(icon: Icons.history_rounded, label: 'Schedule'),
    QuickAction(icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
    QuickAction(icon: Icons.support_agent_rounded, label: 'Support'),
  ];
  bool _deciding = false;

  String get _firstName {
    final displayName = widget.userData.displayName;
    if (displayName.trim().isEmpty) return 'there';
    return displayName.trim().split(' ').first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _onShowBoardingPass() {
    if (widget.onShowBoardingPass != null) {
      widget.onShowBoardingPass!();
      return;
    }
    debugPrint(
      'Show boarding pass tapped, but no onShowBoardingPass callback '
      'was provided to HomeTab.',
    );
  }

  Future<void> _onEveningPromptResponse(bool travelingHome) async {
    if (_deciding) return;
    setState(() => _deciding = true);
    final direction = ref.read(selectedDirectionProvider);
    try {
      await widget.client.decideReservation(
        wire.ReservationDecision(
          (b) => b
            ..travelDate = wire.Date.now(utc: true)
            ..direction = direction == CommuteDirection.outbound
                ? wire.ReservationDecisionDirectionEnum.outbound
                : wire.ReservationDecisionDirectionEnum.return_
            ..decision = travelingHome
                ? wire.ReservationDecisionDecisionEnum.confirm
                : wire.ReservationDecisionDecisionEnum.decline,
        ),
      );
      if (mounted) ref.invalidate(rideLifecycleProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is TrotxiException
                  ? e.message
                  : 'Could not update your reservation.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deciding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lifecycleAsync = ref.watch(rideLifecycleProvider);

    return Scaffold(
      backgroundColor: context.appColors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(rideLifecycleProvider.future),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  DropdownButton<CommuteDirection>(
                    value: ref.watch(selectedDirectionProvider),
                    items: const [
                      DropdownMenuItem(
                        value: CommuteDirection.outbound,
                        child: Text('Today · Outbound'),
                      ),
                      DropdownMenuItem(
                        value: CommuteDirection.returning,
                        child: Text('Today · Return'),
                      ),
                    ],
                    onChanged: _deciding
                        ? null
                        : (value) {
                            if (value != null) {
                              ref
                                  .read(selectedDirectionProvider.notifier)
                                  .select(value);
                            }
                          },
                  ),
                  _buildGreetingHeader(lifecycleAsync.asData?.value),
                  const SizedBox(height: 24),
                  ...lifecycleAsync.when(
                    data: (state) => _buildLifecycleSection(state),
                    loading: () => [_buildLoadingCard()],
                    error: (err, st) => [_buildErrorCard()],
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionsRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Greeting header
  // ---------------------------------------------------------------------

  Widget _buildGreetingHeader(RideLifecycleState? state) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitle = switch (state) {
      RideReserved() || RideBoarded() => 'You have boarded this departure.',
      _ => "Let's get you moving today",
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, $_firstName',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 22,
                    fontFamily: 'Hanken Grotesk',
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          _buildNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    final colors = context.appColors;
    return Material(
      color: colors.borderSubtle,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          // TODO: navigate to notifications.
          debugPrint('Notifications tapped');
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.notifications_none_rounded,
            color: colors.iconDefault,
            size: 24,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Lifecycle-driven section
  //
  // This is the piece that actually answers "render a given UI at a
  // particular time within the ride lifecycle": one card (or two, for
  // loading/error) per RideLifecycleState, sitting between the greeting
  // and the stats row.
  // ---------------------------------------------------------------------

  List<Widget> _buildLifecycleSection(RideLifecycleState? state) {
    final colors = context.appColors;
    return switch (state) {
      // No reservation exists yet for today's direction.
      null => [_buildNoReservationCard()],

      RidePending() => [_buildPendingCard()],

      RideReserved(:final etaPhase) => [_buildReservedCard(etaPhase)],

      RideBoarded() => [_buildBoardedCard()],

      RideDeclined() => [
        _buildStatusCard(
          icon: Icons.event_busy_rounded,
          title: 'Reservation declined',
          message: "This trip wasn't confirmed. Try reserving another slot.",
          accentColor: colors.actionPrimaryDefault,
        ),
      ],

      RideUnseated() => [
        _buildStatusCard(
          icon: Icons.airline_seat_recline_normal_rounded,
          title: 'No seat available',
          message: 'The van filled up before your seat was confirmed.',
          accentColor: colors.warning,
        ),
      ],

      RideNoShow() => [
        _buildStatusCard(
          icon: Icons.timer_off_rounded,
          title: 'Marked as no-show',
          message: "We didn't see you board for this trip.",
          accentColor: colors.error,
        ),
      ],

      RideReleased() => [
        _buildStatusCard(
          icon: Icons.event_available_rounded,
          title: 'Seat released',
          message: 'Your seat was released back to the pool.',
          accentColor: colors.textSecondary,
        ),
      ],

      RideOperatorCancelled() => [
        _buildStatusCard(
          icon: Icons.report_gmailerrorred_rounded,
          title: 'Trip cancelled',
          message:
              'The operator cancelled this trip. Sorry for the inconvenience.',
          accentColor: colors.error,
        ),
      ],
    };
  }

  Widget _buildLoadingCard() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(28),
      ),
      child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
    );
  }

  Widget _buildErrorCard() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Couldn't load your ride status",
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(rideLifecycleProvider),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  /// No reservation exists yet for today's direction — invites the user
  /// to reserve a seat. This replaces the old hardcoded "evening prompt".
  Widget _buildNoReservationCard() {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReturn =
        ref.watch(selectedDirectionProvider) == CommuteDirection.returning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isReturn
                ? 'Traveling on your return leg today?'
                : 'Traveling outbound today?',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reserve a seat to lock in your spot.',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _pillButton(
                  label: 'Yes',
                  filled: true,
                  onTap: () => _onEveningPromptResponse(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pillButton(
                  label: 'Not today',
                  filled: false,
                  onTap: () => _onEveningPromptResponse(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.actionPrimaryDefault.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.actionPrimaryDefault,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Confirming your reservation…',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservedCard(EtaPhase etaPhase) {
    final colors = context.appColors;
    final etaLabel = etaPhase.eta == null
        ? 'Confirmed'
        : '${etaPhase.eta!.inMinutes} mins away';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.11, -0.18),
          end: const Alignment(0.89, 1.18),
          colors: [colors.actionPrimaryDefault, colors.actionPrimaryDefault],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.actionPrimaryDefault.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your seat is reserved',
                  style: TextStyle(
                    color: colors.actionOnPrimary,
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildEtaChip(etaLabel),
            ],
          ),
          if (etaPhase.isEstimated) ...[
            const SizedBox(height: 8),
            Text(
              'Van position not live yet — ETA is estimated',
              style: TextStyle(
                color: colors.actionOnPrimary.withValues(alpha: 0.85),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: colors.actionOnPrimary,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _onShowBoardingPass,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: colors.actionPrimaryPressed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Show Boarding Pass',
                        style: TextStyle(
                          color: colors.actionPrimaryPressed,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardedCard() {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceStrong,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.onSurfaceStrong.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_bus_filled_rounded,
              color: colors.onSurfaceStrong,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "You're on board — enjoy the ride!",
              style: TextStyle(
                color: colors.onSurfaceStrong,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String message,
    required Color accentColor,
  }) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaChip(String label) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colors.actionOnPrimary.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.actionPrimaryPressed,
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return Material(
      color: filled ? colors.actionPrimaryDefault : colors.borderSubtle,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: filled
                  ? colors.actionOnPrimary
                  : colors.actionPrimaryDefault,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Quick Actions
  // ---------------------------------------------------------------------
  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        for (int i = 0; i < _quickActions.length; i++) ...[
          if (i != 0) const SizedBox(width: 12),
          Expanded(child: _buildQuickActionButton(_quickActions[i])),
        ],
      ],
    );
  }

  Widget _buildQuickActionButton(QuickAction action) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, color: colors.actionPrimaryDefault, size: 24),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
