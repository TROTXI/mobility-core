import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/widgets/operations_contact.dart';
import 'package:trotxi_driver/core/widgets/public_information_links.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// Practical pilot notice. Not a substitute for published legal terms.
const driverInformationSections = <String, String>{
  'Your information':
      'Trotxi Driver uses your sign-in identity, profile and optional photo, assigned trips, boarding records, work requests and incident reports to operate the service. Device registration supports assignment notifications. Firebase processes device and app usage analytics, crash reports and request performance diagnostics to help us understand reliability.',
  'Location during an active trip':
      'Trotxi collects precise location, capture time and accuracy during your active trip to show the bus approaching and support route timing and operations. Sharing continues when the app is in the background or your screen is locked. Android displays a tracking notification; iOS can display a location indicator. Collection stops when the trip ends, your assignment is withdrawn after a successful check, or you sign out. Signing in or viewing a scheduled trip does not start tracking.',
  'Who can see it':
      'Operations and riders entitled to view the run can see its live bus position. It is not a public feed of your personal movements. Authorised staff handle trip, boarding and incident records. Hosting, storage, sign-in, messaging and monitoring providers process data needed to deliver those features.',
  'Offline storage and retention':
      'When the network drops, positions wait in protected storage on this phone and retry with their original time and identity. The queue holds up to 1,440 positions; entries older than 24 hours expire when the queue is next processed. Signing out clears queued positions. Server traces become eligible for deletion after 30 days; an active incident evidence hold can preserve the affected interval. Deletion depends on the retention maintenance job running. Trip, accounting and incident records have separate retention requirements.',
  'Your controls and requests':
      'You can change location, camera and notification permissions in device settings. Without location access the app cannot start a tracked trip. Camera is optional: use boarding codes instead. Contact operations below to request access, correction or deletion of your information, or raise a privacy concern. Driver account deletion is handled through support, not a self-service button.',
  'Safe operation and support':
      'Stop safely before using the app. Check the assigned route and vehicle before starting. Confirm stop arrivals only when reached and board only the rider whose pass, code or manifest identity you verified. Do not share rider photos, manifests or sign-in credentials. Finish the run and let pending positions upload before signing out. If the phone is force-stopped, restarted or its battery dies, reopen Trotxi to recover the active trip; uninterrupted tracking is not guaranteed. For immediate danger use emergency services and your operator’s emergency procedure; an incident report is not an emergency call or a promise of round-the-clock monitoring.',
};

class DriverInformationPage extends StatelessWidget {
  const DriverInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigController>();
    final colors = context.driverColors;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space20),
      children: [
        Text(
          'Driver privacy & guidance',
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
        Text(
          'Pilot information · updated 26 September 2026',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const PublicInformationLinks(),
        for (final section in driverInformationSections.entries) ...[
          const SizedBox(height: AppSpacing.space24),
          Text(
            section.key,
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            section.value,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space24),
        OperationsContactCard(
          contact: config.operations,
          isLoaded: config.isLoaded,
          title: 'Support & privacy requests',
        ),
      ],
    );
  }
}
