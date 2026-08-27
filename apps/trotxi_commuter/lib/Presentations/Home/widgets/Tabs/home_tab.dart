import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

// ---------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------

class ActiveTrip {
  const ActiveTrip({
    required this.fromStop,
    required this.toStop,
    required this.etaLabel,
    required this.progress,
  });

  final String fromStop;
  final String toStop;
  final String etaLabel;

  /// 0.0 - 1.0, how far along the route the vehicle currently is.
  final double progress;

  String get routeLabel => '$fromStop -> $toStop';
}

class RideStat {
  const RideStat({
    required this.value,
    required this.label,
    required this.sublabel,
  });

  final String value;
  final String label;
  final String sublabel;
}

class EveningPrompt {
  const EveningPrompt({required this.question, required this.timeInfo});

  final String question;
  final String timeInfo;
}

// ---------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.client,
    required this.userData,
    this.onShowBoardingPass,
  });

  final TrotxiApiClient client;

  /// Already fetched by [HomePage] — HomeTab doesn't need to load the
  /// user itself.
  final MeGet200Response userData;

  /// Called when the user taps "Show Boarding Pass". HomePage wires this
  /// to switch _currentIndex to the Pass tab.
  final VoidCallback? onShowBoardingPass;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // TODO: replace with real trip/stats/prompt data once those endpoints
  // exist on TrotxiApiClient — these are placeholders matching the design.
  final ActiveTrip _activeTrip = const ActiveTrip(
    fromStop: 'Shiashie',
    toStop: 'Your Stop',
    etaLabel: '6 mins away',
    progress: 0.51,
  );

  final List<RideStat> _rideStats = const [
    RideStat(value: '23', label: 'Rides left', sublabel: 'renews 1 Sep'),
    RideStat(value: '18.50', label: 'Ride Credit', sublabel: 'GHS'),
  ];

  final EveningPrompt _eveningPrompt = const EveningPrompt(
    question: 'Traveling home this evening?',
    timeInfo: '17:15 · answer by 15:00',
  );

  // TODO: confirm MeGet200Response exposes a dedicated first-name field
  // (e.g. widget.userData.firstName). Falling back to splitting
  // displayName since that's what Navbar already uses.
  String get _firstName {
    final displayName = widget.userData.displayName;
    if (displayName.trim().isEmpty) return 'there';
    return displayName.trim().split(' ').first;
  }

  final _busLocation = "Adenta";

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

  void _onEveningPromptResponse(bool travelingHome) {
    // TODO: submit the response via widget.client.
    debugPrint('Traveling home this evening? $travelingHome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _buildGreetingHeader(),
                const SizedBox(height: 24),
                _buildActiveTripCard(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 16),
                _buildEveningPromptCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Greeting header
  // ---------------------------------------------------------------------

  Widget _buildGreetingHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.06),
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
                  style: const TextStyle(
                    color: AppColors.dark,
                    fontSize: 22,
                    fontFamily: 'Hanken Grotesk',
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),

                const SizedBox(height: 4),
                Text(
                  "Your Van is approaching $_busLocation pickup",
                  style: const TextStyle(
                    color: AppColors.body,
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
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          // TODO: navigate to notifications.

          // Modal to pop up with notifications, or a new page? For now, just log the tap.
          debugPrint('Notifications tapped');
        },
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.notifications_none_rounded,
            color: AppColors.dark,
            size: 24,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Active trip card
  // ---------------------------------------------------------------------

  Widget _buildActiveTripCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.11, -0.18),
          end: Alignment(0.89, 1.18),
          colors: [AppColors.primary, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008751).withValues(alpha: 0.28),
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
                  _activeTrip.routeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildEtaChip(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _activeTrip.fromStop,
                style: const TextStyle(
                  color: Color(0xFFFDFFF9),
                  fontSize: 14,
                  fontFamily: 'Hanken Grotesk',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              Text(
                _activeTrip.toStop,
                style: const TextStyle(
                  color: Color(0xFFFDFFF9),
                  fontSize: 14,
                  fontFamily: 'Hanken Grotesk',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _activeTrip.progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.50),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.lightBackground,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _onShowBoardingPass,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: Color(0xFF006B3F),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Show Boarding Pass',
                        style: TextStyle(
                          color: Color(0xFF006B3F),
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

  Widget _buildEtaChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        _activeTrip.etaLabel,
        style: const TextStyle(
          color: Color(0xFF006B3F),
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Ride stats
  // ---------------------------------------------------------------------

  Widget _buildStatsRow() {
    return Row(
      children: [
        for (int i = 0; i < _rideStats.length; i++) ...[
          if (i != 0) const SizedBox(width: 16),
          Expanded(child: _buildStatCard(_rideStats[i])),
        ],
      ],
    );
  }

  Widget _buildStatCard(RideStat stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.value,
            style: const TextStyle(
              color: Color(0xFF006B3F),
              fontSize: 32,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat.label,
            style: const TextStyle(
              color: AppColors.dark,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.sublabel,
            style: const TextStyle(
              color: AppColors.body,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Evening prompt
  // ---------------------------------------------------------------------

  Widget _buildEveningPromptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _eveningPrompt.question,
            style: const TextStyle(
              color: AppColors.dark,
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _eveningPrompt.timeInfo,
            style: const TextStyle(
              color: AppColors.body,
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
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _onEveningPromptResponse(true),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Yes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _onEveningPromptResponse(false),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Not today',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
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
