import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/pending_backend_notice.dart';

/// Work routes and requests (prototype page 19).
///
/// Skeleton. None of it exists: no open-route listing, no request records, no
/// leave. Worth drawing now because the file states a rule the backend has to
/// honour and which is easy to get wrong once code is being written —
/// "submitting a request never changes the active or published assignment
/// automatically". Requests are proposals to operations, not edits.
class WorkRequestsPage extends StatelessWidget {
  const WorkRequestsPage({super.key, this.nextAssignmentLabel});

  /// "17:15 Circle → Madina" when there is one.
  final String? nextAssignmentLabel;

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
          'Work & Requests',
          style: AppTypography.heading2.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space4),
        Text(
          'Routes, schedule changes and time-away requests.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space16),

        const PendingBackendNotice(
          waitingOn:
              'route requests, leave and request tracking, none of which exist',
        ),

        if (nextAssignmentLabel != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.space16),
            decoration: BoxDecoration(
              color: colors.surfaceSelected,
              borderRadius: AppRadii.circular(AppRadii.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT ASSIGNMENT',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  nextAssignmentLabel!,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
        ],

        SkeletonCard(
          children: [
            SkeletonTile(
              title: 'Available routes',
              subtitle: 'Browse open routes',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AvailableRoutesPage(),
                ),
              ),
            ),
            Divider(height: 1, color: colors.border),
            const SkeletonTile(
              title: 'Request route change',
              subtitle: 'Ask operations to reassign a future run',
            ),
            Divider(height: 1, color: colors.border),
            const SkeletonTile(
              title: 'Request leave',
              subtitle: 'Submit dates and coverage information',
            ),
            Divider(height: 1, color: colors.border),
            const SkeletonTile(
              title: 'Track requests',
              subtitle: 'Review pending requests',
            ),
          ],
        ),

        Text(
          // The control principle, said in the app rather than only in the
          // design file, because it is the thing a driver would otherwise
          // assume wrongly while waiting for an answer.
          'Submitting a request never changes your current assignment. Operations '
          'has to approve it first.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// Routes open for future assignment (prototype page 19).
///
/// Skeleton. The filters and the row shape are the frame's; there is no
/// endpoint that answers "which routes can be requested", and that is a
/// genuine operations question rather than a listing of every corridor.
class AvailableRoutesPage extends StatefulWidget {
  const AvailableRoutesPage({super.key});

  @override
  State<AvailableRoutesPage> createState() => _AvailableRoutesPageState();
}

class _AvailableRoutesPageState extends State<AvailableRoutesPage> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      appBar: AppBar(title: const Text('Available Routes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            const PendingBackendNotice(
              waitingOn: 'an endpoint listing routes open for reassignment',
            ),
            Text(
              'Browse routes open for future driver assignments.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            Row(
              children: [
                for (final option in ['ALL', 'MORNING', 'EVENING'])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.space8),
                    child: ChoiceChip(
                      label: Text(option),
                      selected: _filter == option,
                      onSelected: (_) => setState(() => _filter = option),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space24),
            Container(
              padding: const EdgeInsets.all(AppSpacing.space24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.circular(AppRadii.lg),
              ),
              child: Text(
                'Open routes appear here once operations can publish which ones '
                'accept reassignment requests.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'Routes are shown only when operations can accept reassignment requests.',
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
