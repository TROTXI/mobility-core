import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Full-page "Notifications" settings, pushed from ProfileTab's
/// "Notifications" row.
///
/// There's no notification-preferences endpoint on the backend yet, so
/// every toggle here is local-only state (flips immediately, like a native
/// settings screen) with a TODO for wiring it up once one exists.
class ProfileNotificationsPage extends StatefulWidget {
  const ProfileNotificationsPage({super.key});

  @override
  State<ProfileNotificationsPage> createState() =>
      _ProfileNotificationsPageState();
}

class _ProfileNotificationsPageState extends State<ProfileNotificationsPage> {
  bool _rideConfirmation = true;
  bool _vehicleApproaching = true;
  bool _boardingReminder = true;
  bool _tripChanges = true;
  bool _commutePlanAndPayment = true;
  bool _productUpdates = false;

  void _onToggle(ValueSetter<bool> setField, bool value) {
    // TODO: submit the new notification preference to the backend once
    // there's an endpoint for it — local-only for now.
    setState(() => setField(value));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final layout = ResponsiveLayoutInfo.of(context);
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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Ride alerts'),
                  const SizedBox(height: 12),
                  _NotificationToggleTile(
                    title: 'Ride confirmation',
                    subtitle: 'When your daily commute is confirmed',
                    value: _rideConfirmation,
                    onChanged: (v) =>
                        _onToggle((v) => _rideConfirmation = v, v),
                  ),
                  const SizedBox(height: 8),
                  _NotificationToggleTile(
                    title: 'Vehicle approaching',
                    subtitle: 'Live alert as your assigned van nears pickup',
                    value: _vehicleApproaching,
                    onChanged: (v) =>
                        _onToggle((v) => _vehicleApproaching = v, v),
                  ),
                  const SizedBox(height: 8),
                  _NotificationToggleTile(
                    title: 'Boarding reminder',
                    subtitle: 'Reminder before your scheduled pickup time',
                    value: _boardingReminder,
                    onChanged: (v) =>
                        _onToggle((v) => _boardingReminder = v, v),
                  ),
                  const SizedBox(height: 8),
                  _NotificationToggleTile(
                    title: 'Trip changes',
                    subtitle: 'Delays, route changes or service interruptions',
                    value: _tripChanges,
                    onChanged: (v) => _onToggle((v) => _tripChanges = v, v),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Account & updates'),
                  const SizedBox(height: 12),
                  _NotificationToggleTile(
                    title: 'Commute plan & payment',
                    subtitle: 'Renewal, payment and Ride Credit updates',
                    value: _commutePlanAndPayment,
                    onChanged: (v) =>
                        _onToggle((v) => _commutePlanAndPayment = v, v),
                  ),
                  const SizedBox(height: 8),
                  _NotificationToggleTile(
                    title: 'Product updates',
                    subtitle: 'New features, surveys and launch announcements',
                    value: _productUpdates,
                    onChanged: (v) => _onToggle((v) => _productUpdates = v, v),
                  ),
                  const SizedBox(height: 20),
                  _buildSafetyNotice(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Semantics(
              button: true,
              label: 'Back',
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Notifications',
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Choose how Trotxi keeps you informed.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.appColors;
    return Text(
      title,
      style: AppTypography.label.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSafetyNotice(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Critical safety and service notices cannot be disabled.',
        textAlign: TextAlign.center,
        style: AppTypography.caption.copyWith(
          color: colors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A titled/subtitled card row with a trailing switch. Every row shares the
/// same card shape (12 radius) — the source design had "Boarding reminder"
/// on a stray 36-radius card, which reads as a Figma export slip rather
/// than an intentional pill, so it's normalized here with the rest.
class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.actionPrimaryDefault,
          ),
        ],
      ),
    );
  }
}
