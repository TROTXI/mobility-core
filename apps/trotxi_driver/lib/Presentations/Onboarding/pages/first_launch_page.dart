import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/trotxi_wordmark.dart';

/// The timed first-install splash from design page 04.
class DriverLaunchSplash extends StatelessWidget {
  const DriverLaunchSplash({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? AppSpacing.space64 : AppSpacing.space24,
                vertical: AppSpacing.space32,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const TrotxiWordmark(height: 72),
                  const SizedBox(height: AppSpacing.space16),
                  const _DriverPill(),
                  const SizedBox(height: AppSpacing.space24),
                  Text(
                    'Drive smart, move better.',
                    textAlign: TextAlign.center,
                    style: AppTypography.heading2.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Your Trotxi driver workspace.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: wide ? 620 : double.infinity,
                    height: wide ? 210 : 150,
                    child: const _RouteIllustration(showSkyline: true),
                  ),
                  const Spacer(),
                  Text(
                    'Preparing today’s assignments…',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  SizedBox(
                    width: wide ? 360 : double.infinity,
                    child: const LinearProgressIndicator(),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The first-launch welcome screen from design page 04.
///
/// Phone layouts stack the introduction and capabilities. Driver-mount and
/// tablet-landscape layouts put them side by side, matching the 1194×834
/// reference instead of stretching a phone column across the windscreen.
class DriverFirstLaunchPage extends StatelessWidget {
  const DriverFirstLaunchPage({super.key, required this.onContinue});

  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final content = wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: _WelcomeLead(colors: colors),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space40),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _WelcomeActions(onContinue: onContinue),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _WelcomeLead(colors: colors),
                        const SizedBox(height: AppSpacing.space24),
                        _WelcomeActions(onContinue: onContinue),
                      ],
                    ),
                  );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1194),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    wide ? AppSpacing.space48 : AppSpacing.space20,
                    AppSpacing.space24,
                    wide ? AppSpacing.space48 : AppSpacing.space20,
                    AppSpacing.space24,
                  ),
                  child: content,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeLead extends StatelessWidget {
  const _WelcomeLead({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [TrotxiWordmark(height: 42), _DriverPill()],
      ),
      const SizedBox(height: AppSpacing.space40),
      Text(
        'Hi Captain',
        style: AppTypography.body.copyWith(color: colors.textSecondary),
      ),
      const SizedBox(height: AppSpacing.space4),
      Text(
        'Welcome to Trotxi Driver',
        style: AppTypography.heading1.copyWith(color: colors.textPrimary),
      ),
      const SizedBox(height: AppSpacing.space8),
      Text(
        'Your assignments, passenger boarding and trip support—all in one workspace.',
        style: AppTypography.body.copyWith(color: colors.textSecondary),
      ),
      const SizedBox(height: AppSpacing.space24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.space20),
        decoration: BoxDecoration(
          color: colors.surfaceSelected,
          borderRadius: AppRadii.circular(AppRadii.xl),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready for today’s run',
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              'Everything the driver needs',
              style: AppTypography.heading3.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.space12),
            const SizedBox(height: 132, child: _RouteIllustration()),
          ],
        ),
      ),
    ],
  );
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({required this.onContinue});

  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _FeatureCard(
          icon: Icons.assignment_outlined,
          title: 'See today’s assignments',
          detail: 'Route, vehicle and departure details',
        ),
        const SizedBox(height: AppSpacing.space12),
        const _FeatureCard(
          icon: Icons.qr_code_scanner,
          title: 'Board passengers quickly',
          detail: 'Scan QR codes or enter a boarding code',
        ),
        const SizedBox(height: AppSpacing.space12),
        const _FeatureCard(
          icon: Icons.route_outlined,
          title: 'Stay connected on route',
          detail: 'Navigation, GPS and operations support',
        ),
        const SizedBox(height: AppSpacing.space24),
        FilledButton(onPressed: onContinue, child: const Text('Continue')),
        const SizedBox(height: AppSpacing.space12),
        Text(
          'Your operator must have linked your driver ID.',
          textAlign: TextAlign.center,
          style: AppTypography.footnote.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: AppRadii.circular(AppRadii.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceSelected,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.tileLabel.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  detail,
                  style: AppTypography.tileCaption.copyWith(
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
}

class _DriverPill extends StatelessWidget {
  const _DriverPill();

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        borderRadius: AppRadii.circular(AppRadii.full),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        'DRIVER',
        style: AppTypography.chipLabel.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

class _RouteIllustration extends StatelessWidget {
  const _RouteIllustration({this.showSkyline = false});

  final bool showSkyline;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return CustomPaint(
      painter: _RoutePainter(colors: colors, showSkyline: showSkyline),
      child: Align(
        alignment: const Alignment(0.12, 0.1),
        child: Container(
          width: 88,
          height: 58,
          decoration: BoxDecoration(
            color: colors.action,
            borderRadius: AppRadii.circular(AppRadii.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.airport_shuttle_rounded,
            size: 42,
            color: colors.onAction,
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.colors, required this.showSkyline});

  final AppColors colors;
  final bool showSkyline;

  @override
  void paint(Canvas canvas, Size size) {
    if (showSkyline) {
      final skyline = Paint()
        ..color = colors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      final buildings = Path()
        ..moveTo(0, size.height * 0.72)
        ..lineTo(size.width * 0.08, size.height * 0.72)
        ..lineTo(size.width * 0.08, size.height * 0.48)
        ..lineTo(size.width * 0.16, size.height * 0.48)
        ..lineTo(size.width * 0.16, size.height * 0.65)
        ..lineTo(size.width * 0.28, size.height * 0.65)
        ..lineTo(size.width * 0.28, size.height * 0.36)
        ..lineTo(size.width * 0.39, size.height * 0.36)
        ..lineTo(size.width * 0.39, size.height * 0.7)
        ..lineTo(size.width * 0.62, size.height * 0.7)
        ..lineTo(size.width * 0.62, size.height * 0.42)
        ..lineTo(size.width * 0.74, size.height * 0.42)
        ..lineTo(size.width * 0.74, size.height * 0.62)
        ..lineTo(size.width * 0.88, size.height * 0.62)
        ..lineTo(size.width * 0.88, size.height * 0.5)
        ..lineTo(size.width, size.height * 0.5);
      canvas.drawPath(buildings, skyline);
    }

    final route = Paint()
      ..color = colors.info
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.04, size.height * 0.82)
      ..cubicTo(
        size.width * 0.24,
        size.height * 0.25,
        size.width * 0.68,
        size.height * 1.05,
        size.width * 0.96,
        size.height * 0.28,
      );
    canvas.drawPath(path, route);
    final stop = Paint()..color = colors.success;
    for (final point in [
      Offset(size.width * 0.04, size.height * 0.82),
      Offset(size.width * 0.96, size.height * 0.28),
    ]) {
      canvas.drawCircle(point, 6, stop);
      canvas.drawCircle(point, 2.5, Paint()..color = colors.surface);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.showSkyline != showSkyline;
}
