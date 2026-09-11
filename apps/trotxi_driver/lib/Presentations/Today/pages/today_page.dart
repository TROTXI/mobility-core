import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/Presentations/Profile/pages/profile_page.dart';
import 'package:trotxi_driver/Presentations/Run/pages/run_page.dart';
import 'package:trotxi_driver/Presentations/Today/widgets/run_card.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/loadable.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';
import 'package:trotxi_driver/core/state/today_controller.dart';
import 'package:trotxi_driver/data/trips_repository.dart';

/// Today (prototype frames 14 to 18).
///
/// Five states, and they are not interchangeable. Nothing assigned reads
/// completely differently from everything finished, and a driver at the start
/// of a shift needs to tell them apart at a glance.
class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TodayController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final controller = context.watch<TodayController>();
    final board = controller.board;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            tooltip: 'Profile and settings',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: _body(context, controller, board, colors),
        ),
      ),
    );
  }

  /// Open a run, giving it its own controller scoped to that route.
  ///
  /// Scoped rather than app-wide: a run's manifest belongs to that run, and a
  /// controller outliving the screen would serve the previous run's riders to
  /// the next one.
  ///
  /// @param context - the calling context.
  /// @param run - the run to open.
  void _openRun(BuildContext context, DriverRun run) {
    final trips = context.read<TripsRepository>();
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => RunController(trips: trips, run: run),
              child: RunPage(run: run),
            ),
          ),
        )
        // The run's state may have moved while the driver was in there, so the
        // day is reloaded on the way back rather than showing a stale card.
        .then((_) {
          if (context.mounted) context.read<TodayController>().load();
        });
  }

  Widget _body(
    BuildContext context,
    TodayController controller,
    Loadable<TodayBoard> board,
    AppColors colors,
  ) {
    // Only a first load blanks the screen. A refresh keeps the day visible and
    // lets the indicator carry the news, because a driver mid-shift is reading
    // this to decide what to do next.
    if (board.isInitialLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = board.valueOrNull;
    if (data == null) {
      return _ScrollableMessage(
        title: 'Could not load your day',
        detail: board is Failure<TodayBoard> ? board.message : 'Pull down to try again.',
        colors: colors,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space20,
        vertical: AppSpacing.space16,
      ),
      children: [
        if (board is Failure<TodayBoard>) ...[
          _StaleBanner(message: board.message, colors: colors),
          const SizedBox(height: AppSpacing.space16),
        ],
        if (data.isEmpty)
          _ScrollableMessage(
            title: 'No trips assigned yet',
            detail:
                'Operations has not put you on a run today. This updates when they do, '
                'so pull down if you have just been told otherwise.',
            colors: colors,
            embedded: true,
          )
        else if (data.isDayDone)
          _DayDone(completed: data.completed.length, colors: colors)
        else ...[
          if (data.active != null) ...[
            _SectionLabel(text: 'Running now', colors: colors),
            const SizedBox(height: AppSpacing.space8),
            RunCard(
              run: data.active!,
              emphasis: RunCardEmphasis.active,
              primaryLabel: 'End trip',
              isBusy: controller.busyRunId == data.active!.id,
              onPrimary: () => controller.complete(data.active!.id),
              onTap: () => _openRun(context, data.active!),
            ),
            const SizedBox(height: AppSpacing.space24),
          ],
          if (data.next != null) ...[
            _SectionLabel(text: 'Next', colors: colors),
            const SizedBox(height: AppSpacing.space8),
            RunCard(
              run: data.next!,
              emphasis: RunCardEmphasis.next,
              primaryLabel: 'Start trip',
              isBusy: controller.busyRunId == data.next!.id,
              onPrimary: () => controller.start(data.next!.id),
              onTap: () => _openRun(context, data.next!),
            ),
            const SizedBox(height: AppSpacing.space24),
          ],
          if (data.later.isNotEmpty) ...[
            _SectionLabel(text: 'Later today', colors: colors),
            const SizedBox(height: AppSpacing.space8),
            for (final run in data.later) ...[
              RunCard(run: run, onTap: () => _openRun(context, run)),
              const SizedBox(height: AppSpacing.space8),
            ],
            const SizedBox(height: AppSpacing.space16),
          ],
          if (data.completed.isNotEmpty) ...[
            _SectionLabel(text: 'Done', colors: colors),
            const SizedBox(height: AppSpacing.space8),
            for (final run in data.completed) ...[
              RunCard(run: run),
              const SizedBox(height: AppSpacing.space8),
            ],
          ],
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.caption.copyWith(color: colors.textSecondary),
    );
  }
}

/// "You're done for today" (frame 17), which is a different message from having
/// nothing assigned and deserves its own shape.
class _DayDone extends StatelessWidget {
  const _DayDone({required this.completed, required this.colors});

  final int completed;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: colors.success),
          const SizedBox(height: AppSpacing.space16),
          Text(
            "You're done for today",
            style: AppTypography.heading3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            completed == 1 ? '1 trip completed' : '$completed trips completed',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// A failure banner shown ABOVE content that is still on screen, for a refresh
/// that failed while the day is already loaded.
class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.message, required this.colors});

  final String message;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: colors.warning),
      ),
      child: Text(message, style: AppTypography.bodySmall.copyWith(color: colors.textSecondary)),
    );
  }
}

/// A centred message that still scrolls, so pull-to-refresh works on it. A
/// non-scrolling empty state is an empty state you cannot retry from.
class _ScrollableMessage extends StatelessWidget {
  const _ScrollableMessage({
    required this.title,
    required this.detail,
    required this.colors,
    this.embedded = false,
  });

  final String title;
  final String detail;
  final AppColors colors;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space24,
        vertical: AppSpacing.space48,
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.heading3.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );

    if (embedded) return content;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [content],
    );
  }
}
