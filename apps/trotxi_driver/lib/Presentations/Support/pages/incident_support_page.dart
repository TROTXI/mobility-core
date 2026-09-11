import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/pending_backend_notice.dart';

/// Incident and support (prototype page 15).
///
/// Skeleton: there is no incident API at all. The layout, copy and the
/// escalation hierarchy are the file's; nothing submits.
///
/// The hierarchy is the point and it is why this is worth building before the
/// backend. "Urgent safety actions remain visually distinct from routine
/// support and reporting": emergency help is a filled danger button standing
/// alone, and everything else is a quiet row. That ordering is a safety
/// decision, not a layout preference, so it should be settled in the UI before
/// anyone wires it to anything.
class IncidentSupportPage extends StatelessWidget {
  const IncidentSupportPage({super.key, this.activeRunLabel});

  /// "7:40 Madina → Circle" when a run is open, so support knows which trip.
  final String? activeRunLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space8,
      ),
      children: [
        Text(
          'Incident & support',
          style: AppTypography.heading2.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          activeRunLabel == null
              ? 'No active trip'
              : 'Active trip · $activeRunLabel',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space16),

        const PendingBackendNotice(
          waitingOn: 'an incident reporting API, which does not exist yet',
        ),

        // Before any of the actions, because every one of them takes a driver's
        // attention off the road.
        Container(
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadii.circular(AppRadii.lg),
            border: Border.all(color: colors.warning),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stop safely before using support',
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                'Do not report or call while the vehicle is moving.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space16),

        SkeletonCard(
          children: [
            SkeletonTile(
              title: 'Operations support',
              subtitle: 'Call the control room for immediate trip assistance.',
              onTap: null,
            ),
            Divider(height: 1, color: colors.border),
            SkeletonTile(
              title: 'Report incident',
              subtitle: 'Vehicle, road, passenger safety or route problems.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ReportIncidentPage(),
                ),
              ),
            ),
            Divider(height: 1, color: colors.border),
            const SkeletonTile(
              title: 'Call support',
              subtitle: 'Speak to the depot about a non-urgent problem.',
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.space8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            // Disabled rather than hidden. A driver who has looked for
            // emergency help once must be able to find it in the same place
            // the next time, and its absence would read as "not available".
            onPressed: null,
            style: FilledButton.styleFrom(
              backgroundColor: colors.danger,
              disabledBackgroundColor: colors.danger.withValues(alpha: 0.45),
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.circular(AppRadii.full),
              ),
            ),
            child: Text('EMERGENCY HELP', style: AppTypography.label),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Text(
          'Your active trip, vehicle and current or last-known location are shared with support.',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// Report an incident (prototype page 15, select and review).
///
/// Two steps in one screen: pick a category, then confirm what is attached.
/// The file separates them into frames, but the review step is only a summary
/// of the choice plus trip context a driver never edits, so a second screen
/// would be a second thing to navigate at a roadside.
class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  /// The file's wording, kept literally. "Classification principle: use short
  /// literal categories that support accurate routing without delaying urgent
  /// action."
  static const _categories = [
    'Vehicle problem',
    'Collision or road hazard',
    'Passenger safety concern',
    'Route blocked',
    'Other issue',
  ];

  String? _selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an incident')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            const PendingBackendNotice(
              waitingOn: 'an incident reporting API, which does not exist yet',
            ),
            Text(
              'What happened?',
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Select one issue. You can review everything before sending.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            SkeletonCard(
              children: [
                for (final category in _categories) ...[
                  SkeletonTile(
                    title: category,
                    subtitle: _selected == category
                        ? 'Selected'
                        : 'Tap to choose',
                    tone: _selected == category ? colors.action : null,
                    onTap: () => setState(() => _selected = category),
                  ),
                  if (category != _categories.last)
                    Divider(height: 1, color: colors.border),
                ],
              ],
            ),
            if (_selected != null) ...[
              Text(
                'ATTACHED TO THIS REPORT',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              SkeletonCard(
                children: const [
                  SkeletonTile(title: 'Trip', subtitle: 'The run you are on'),
                  SkeletonTile(
                    title: 'Vehicle',
                    subtitle: 'From the assignment',
                  ),
                  SkeletonTile(title: 'Time', subtitle: 'When you send it'),
                  SkeletonTile(
                    title: 'Location',
                    subtitle: 'Current or last known position',
                  ),
                ],
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.circular(AppRadii.full),
                  ),
                ),
                child: const Text('SEND REPORT'),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'Continue only when the vehicle is safely stopped.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
