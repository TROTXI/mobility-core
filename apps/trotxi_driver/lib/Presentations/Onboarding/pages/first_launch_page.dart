import 'dart:ui' show PathMetric;

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
      const _RouteHero(),
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
        child: Image.asset(_vanAsset, width: 104, excludeFromSemantics: true),
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

/// The branded van from the design file (page 04, "Welcome / Van"), exported
/// at 4x its 95 by 48 frame.
const _vanAsset = 'assets/brand/trotxi-van.png';

/// "Ready for today's run": the road from the design file runs behind the
/// title, ending at a stop beside it, and the van drives up onto it when the
/// screen opens.
///
/// The road is the file's own path (312:58), not a lookalike: the frame is
/// 350 by 180, and the path and van are scaled with the card so the stop still
/// lands beside the title on a tablet. The van drives in once and parks where
/// the file draws it. Looping would pull a driver's eye from the text they are
/// reading, and with reduce motion on it is simply parked.
class _RouteHero extends StatefulWidget {
  const _RouteHero();

  @override
  State<_RouteHero> createState() => _RouteHeroState();
}

class _RouteHeroState extends State<_RouteHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drive = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _drive.value = 1;
    } else if (_drive.status == AnimationStatus.dismissed) {
      _drive.forward();
    }
  }

  @override
  void dispose() {
    _drive.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return ClipRRect(
      borderRadius: AppRadii.circular(AppRadii.xl),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.circular(AppRadii.xl),
          border: Border.all(color: colors.border),
        ),
        child: AspectRatio(
          aspectRatio: _RoadGeometry.width / _RoadGeometry.height,
          child: LayoutBuilder(
            builder: (context, box) {
              final road = _RoadGeometry(box.biggest);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RoadPainter(road: road, colors: colors),
                    ),
                  ),
                  // The file's own sizes and places (11/600 at 18,18; 19/600 at
                  // 18,41), scaled with the card so the title still ends
                  // just short of the stop.
                  Positioned(
                    left: 18 * road.scale,
                    top: 18 * road.scale,
                    child: Text(
                      'Ready for today\u2019s run',
                      style: AppTypography.fieldLabel.copyWith(
                        fontSize: 11 * road.scale,
                        height: 16.5 / 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18 * road.scale,
                    top: 41 * road.scale,
                    child: Text(
                      'Everything the driver needs',
                      style: AppTypography.title.copyWith(
                        fontSize: 19 * road.scale,
                        height: 28.5 / 19,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _drive,
                    builder: (context, _) {
                      final pose = road.vanAt(
                        Curves.easeOutCubic.transform(_drive.value),
                      );
                      return Positioned(
                        left: pose.bottomCentre.dx - pose.size.width / 2,
                        top: pose.bottomCentre.dy - pose.size.height,
                        width: pose.size.width,
                        height: pose.size.height,
                        child: Transform.rotate(
                          angle: pose.angle,
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            _vanAsset,
                            fit: BoxFit.contain,
                            semanticLabel: 'Trotxi van on its route',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Where the van stands at a point along its drive.
class _VanPose {
  const _VanPose(this.bottomCentre, this.angle, this.size);

  final Offset bottomCentre;
  final double angle;
  final Size size;
}

/// The design's road, scaled from its 350 by 180 card to the card on screen.
class _RoadGeometry {
  _RoadGeometry(Size size)
    : scale = size.width / width,
      _sy = size.height / height {
    path = Path()
      ..moveTo(_x(3), _y(141))
      ..cubicTo(_x(73), _y(111), _x(127), _y(135), _x(171), _y(103))
      ..cubicTo(_x(221), _y(67), _x(265), _y(85), _x(309), _y(41))
      ..cubicTo(_x(333), _y(17), _x(353), _y(5), _x(395), _y(3));
    stop = Offset(_x(309), _y(41));
    _metric = path.computeMetrics().first;
    _parked = _distanceAtX(_parkedX * scale);
  }

  static const double width = 350;
  static const double height = 180;

  /// The file's van: 95 by 48, its middle at x 67.5 on the card.
  static const Size _van = Size(95, 48);
  static const double _parkedX = 67.5;

  final double scale;
  final double _sy;
  late final Path path;
  late final Offset stop;
  late final PathMetric _metric;
  late final double _parked;

  // The path was exported with a 3px stroke margin, 23 left of and 15 above
  // the card's origin.
  double _x(double svg) => (svg - 23) * scale;
  double _y(double svg) => (svg + 15) * _sy;

  double _distanceAtX(double x) {
    var low = 0.0, high = _metric.length;
    for (var i = 0; i < 30; i++) {
      final mid = (low + high) / 2;
      if (_metric.getTangentForOffset(mid)!.position.dx < x) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return low;
  }

  /// [progress] 0 is just off the card on the left, 1 is parked.
  _VanPose vanAt(double progress) {
    final size = _van * scale;
    final start = -size.width;
    final distance = progress * _parked;
    final tangent = _metric.getTangentForOffset(distance)!;
    // Before the road begins at the card's edge the van rolls in level.
    final x = progress == 0 ? start : tangent.position.dx;
    // The file seats the wheels just below the road's centre line.
    final bottom = Offset(x, tangent.position.dy + 6 * _sy);
    return _VanPose(bottom, -tangent.angle, size);
  }
}

class _RoadPainter extends CustomPainter {
  const _RoadPainter({required this.road, required this.colors});

  final _RoadGeometry road;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      road.path,
      Paint()
        ..color = colors.action
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * road.scale
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      road.stop,
      8 * road.scale,
      Paint()..color = colors.action,
    );
    canvas.drawCircle(
      road.stop,
      3 * road.scale,
      Paint()..color = colors.surface,
    );
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) =>
      oldDelegate.road.scale != road.scale || oldDelegate.colors != colors;
}
