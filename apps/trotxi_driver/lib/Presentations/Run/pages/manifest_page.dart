import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Boarding/pages/board_by_code_page.dart';
import 'package:trotxi_driver/Presentations/Run/widgets/rider_row.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// The passenger manifest (prototype page 13).
///
/// One list in manifest order, not grouped into waiting and aboard. Grouping
/// was the earlier build's invention and it fights the way the screen is used:
/// a driver is looking for one named person at a door, and moving someone
/// between sections the moment they board makes the row they were just reading
/// jump somewhere else.
///
/// Search exists for the same reason. Eighteen rows is more than anyone scans
/// while a queue waits.
class ManifestPage extends StatefulWidget {
  const ManifestPage({super.key});

  @override
  State<ManifestPage> createState() => _ManifestPageState();
}

class _ManifestPageState extends State<ManifestPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final controller = context.watch<RunController>();
    final data = controller.detail.valueOrNull;

    if (data == null) return const Center(child: CircularProgressIndicator());

    final riders = _filter(data.riders, _query);

    return RefreshIndicator(
      onRefresh: controller.refreshManifest,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        children: [
          Text(
            'Passenger manifest',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            data.run.routeName,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space16),

          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search passenger by name or boarding code',
              prefixIcon: Icon(Icons.search, color: colors.textSecondary),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: AppRadii.circular(AppRadii.full),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space12),

          _Progress(
            boarded: data.boarded,
            expected: data.expected,
            standby: data.standby,
            colors: colors,
          ),
          const SizedBox(height: AppSpacing.space12),

          if (data.riders.isEmpty)
            _Empty(
              text: 'Nobody has confirmed a seat on this run yet.',
              colors: colors,
            )
          else if (riders.isEmpty)
            _Empty(text: 'No passenger matches "$_query".', colors: colors)
          else
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.circular(AppRadii.lg),
              ),
              child: Column(
                children: [
                  for (final rider in riders)
                    RiderRow(
                      rider: rider,
                      // Both open the detail sheet rather than boarding from
                      // the list. The design puts BOARD PASSENGER on the detail
                      // frame for a reason: the photo pass only works if the
                      // driver has actually looked at the photo, and a pill
                      // that debits a ride from a 44-pixel thumbnail defeats it.
                      onAction: rider.boarded
                          ? null
                          : () => _openRider(context, controller, rider),
                      onTap: () => _openRider(context, controller, rider),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Open one rider, with the photo big enough to check a face against.
  ///
  /// @param context - for the sheet.
  /// @param controller - the run, for the actions.
  /// @param rider - the rider tapped.
  void _openRider(
    BuildContext context,
    RunController controller,
    ManifestRider rider,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: _RiderSheet(rider: rider),
      ),
    );
  }

  /// Match on name, since that is what a driver has in front of them. Boarding
  /// codes are hashed server-side, so searching one is not possible and the
  /// hint promises only what the field can do.
  static List<ManifestRider> _filter(List<ManifestRider> riders, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return riders;
    return riders
        .where((r) => (r.name ?? '').toLowerCase().contains(q))
        .toList();
  }
}

/// "12 of 18 boarded · 6 remaining", with a bar behind it.
class _Progress extends StatelessWidget {
  const _Progress({
    required this.boarded,
    required this.expected,
    required this.standby,
    required this.colors,
  });

  final int boarded;
  final int expected;

  /// Seats filled from the standby pool (#230). Called out because a driver
  /// looking for a familiar face on a standby seat will not find one.
  final int standby;

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final remaining = expected - boarded;
    final fraction = expected == 0 ? 0.0 : boarded / expected;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        borderRadius: AppRadii.circular(AppRadii.full),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$boarded of $expected boarded',
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                [
                  if (remaining == 0) 'all aboard' else '$remaining remaining',
                  if (standby > 0) '$standby standby',
                ].join(' · '),
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          ClipRRect(
            borderRadius: AppRadii.circular(AppRadii.full),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation(colors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text, required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.space48),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.body.copyWith(color: colors.textSecondary),
    ),
  );
}

/// One rider, opened from the manifest (prototype page 13, detail).
///
/// The photo is the point. It is the server's copy, never the rider's, so a
/// faker cannot supply their own face — and it is shown large because the whole
/// photo-pass fallback rests on the driver actually looking at it before
/// tapping BOARD PASSENGER.
class _RiderSheet extends StatefulWidget {
  const _RiderSheet({required this.rider});

  final ManifestRider rider;

  @override
  State<_RiderSheet> createState() => _RiderSheetState();
}

class _RiderSheetState extends State<_RiderSheet> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final rider = widget.rider;
    final name = rider.name?.trim().isNotEmpty == true
        ? rider.name!.trim()
        : 'Unnamed rider';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rider.avatarUrl != null)
              ClipRRect(
                borderRadius: AppRadii.circular(AppRadii.lg),
                child: Image.network(
                  rider.avatarUrl!,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _NoPhoto(colors: colors),
                ),
              )
            else
              _NoPhoto(colors: colors),
            const SizedBox(height: AppSpacing.space16),
            Text(
              name,
              style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              [
                rider.direction == 'evening' ? 'Evening' : 'Morning',
                if (rider.isStandby) 'standby seat',
                if (rider.boarded) 'boarded',
                if (rider.noShow) 'marked no-show',
              ].join(' · '),
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space24),

            if (rider.boarded)
              Text(
                'This rider is aboard. Nothing to do.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: colors.success),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _board,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.circular(AppRadii.full),
                    ),
                  ),
                  child: const Text('BOARD PASSENGER'),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _busy ? null : _boardByCode,
                  child: const Text('Board by code instead'),
                ),
              ),
              if (!rider.noShow) ...[
                const SizedBox(height: AppSpacing.space8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _busy ? null : _markNoShow,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.danger,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('MARK NO-SHOW'),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.space8),
              Text(
                rider.noShow
                    ? 'You marked this rider as a no-show. Boarding them now '
                          'still works, and does not charge them twice.'
                    : 'A no-show uses the seat\'s ride. Boarding them later '
                          'still works if they catch up.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Board from the photo, with no code (#227).
  Future<void> _board() async {
    setState(() => _busy = true);
    final controller = context.read<RunController>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await controller.boardFromManifest(
      widget.rider.reservationId,
    );
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('${result.title}. ${result.detail}')),
    );
  }

  /// Mark them absent, after confirming — this debits the seat's ride.
  Future<void> _markNoShow() async {
    final name = widget.rider.name ?? 'this rider';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark no-show?'),
        content: Text(
          '$name did not board at their stop. This uses their ride now. If '
          'they catch up at a later stop you can still board them, and they '
          'will not be charged twice.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Mark no-show'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;

    setState(() => _busy = true);
    final controller = context.read<RunController>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await controller.markNoShow(widget.rider.reservationId);
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(result.message)));
  }

  /// Fall through to the code path, for when the face is not enough.
  void _boardByCode() {
    final controller = context.read<RunController>();
    Navigator.of(context)
      ..pop()
      ..push(
        MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider.value(
            value: controller,
            child: BoardByCodePage(preselected: widget.rider),
          ),
        ),
      );
  }
}

class _NoPhoto extends StatelessWidget {
  const _NoPhoto({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    height: 160,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: colors.surfaceSelected,
      borderRadius: AppRadii.circular(AppRadii.lg),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person_outline, size: 48, color: colors.textSecondary),
        const SizedBox(height: AppSpacing.space8),
        Text(
          'No photo',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
        Text(
          'Board by code',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    ),
  );
}
