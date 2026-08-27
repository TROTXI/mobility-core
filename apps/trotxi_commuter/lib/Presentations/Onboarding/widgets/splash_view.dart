import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_progress_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';

/// Page 08 splash presentation with all user-facing copy kept as live Flutter
/// text and navigation left to the owning [SplashPage].
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = context.appColors;

    return ColoredBox(
      color: colors.backgroundDefault,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layout = ResponsiveLayoutInfo.fromSize(
            Size(constraints.maxWidth, constraints.maxHeight),
          );
          final config = _SplashLayoutConfig.forDevice(layout.deviceClass);
          final backgroundAsset = _backgroundAsset(
            layout.deviceClass,
            brightness,
          );

          return Stack(
            key: ValueKey('splash-layout-${layout.deviceClass.name}'),
            fit: StackFit.expand,
            children: [
              ExcludeSemantics(
                child: Image.asset(
                  backgroundAsset,
                  key: ValueKey(
                    'splash-background-${layout.deviceClass.name}-'
                    '${brightness.name}',
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, safeConstraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: safeConstraints.maxHeight,
                          minWidth: safeConstraints.maxWidth,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: config.horizontalPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: config.topGap),
                                _SplashLogo(
                                  width: config.logoWidth,
                                  height: config.logoHeight,
                                ),
                                SizedBox(height: config.logoTextGap),
                                Text(
                                  'Move smart, live better.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: config.headlineSize,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Your smart commuter platform.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: config.subtitleSize,
                                    fontWeight: FontWeight.w400,
                                    height: 1.7,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                ExcludeSemantics(
                                  child: Center(
                                    child: SizedBox(
                                      width: config.vehicleWidth,
                                      height: config.vehicleHeight,
                                      child: Image.asset(
                                        brightness == Brightness.dark
                                            ? Appvectors.lightvan
                                            : Appvectors.lightvan,
                                        key: ValueKey(
                                          'splash-vehicle-${brightness.name}',
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: config.vehicleTextGap),
                                _SplashLoadingStatus(config: config),
                                SizedBox(height: config.bottomGap),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _backgroundAsset(AppDeviceClass deviceClass, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (deviceClass) {
      AppDeviceClass.phone =>
        isDark ? Appvectors.splashImagedarktheme : Appvectors.splashImage,
      AppDeviceClass.tabletPortrait =>
        isDark
            ? Appvectors.splashTabletPortraitDark
            : Appvectors.splashTabletPortraitLight,
      AppDeviceClass.tabletLandscape =>
        isDark
            ? Appvectors.splashTabletLandscapeDark
            : Appvectors.splashTabletLandscapeLight,
    };
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Semantics(
      label: 'Trotxi',
      image: true,
      child: ExcludeSemantics(
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Image.asset(
              brightness == Brightness.dark
                  ? Appvectors.logodarktheme
                  : Appvectors.logo,
              key: ValueKey('splash-logo-${brightness.name}'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLoadingStatus extends StatelessWidget {
  const _SplashLoadingStatus({required this.config});

  final _SplashLayoutConfig config;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final progressColors = AppProgressColors.of(context);

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Preparing your journey. Loading.',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(
              'Preparing your journey…',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: config.statusSize,
                fontWeight: FontWeight.w500,
                height: 1.7,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: config.statusProgressGap),
            Center(
              child: SizedBox(
                width: math.min(
                  config.progressWidth,
                  MediaQuery.sizeOf(context).width -
                      (config.horizontalPadding * 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: progressColors.track,
                    color: progressColors.active,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _SplashLayoutConfig {
  const _SplashLayoutConfig({
    required this.horizontalPadding,
    required this.topGap,
    required this.logoWidth,
    required this.logoHeight,
    required this.logoTextGap,
    required this.headlineSize,
    required this.subtitleSize,
    required this.vehicleWidth,
    required this.vehicleHeight,
    required this.vehicleTextGap,
    required this.statusSize,
    required this.statusProgressGap,
    required this.progressWidth,
    required this.bottomGap,
  });

  factory _SplashLayoutConfig.forDevice(AppDeviceClass deviceClass) {
    return switch (deviceClass) {
      AppDeviceClass.phone => const _SplashLayoutConfig(
        horizontalPadding: 28,
        topGap: 220,
        logoWidth: 238,
        logoHeight: 104,
        logoTextGap: 8,
        headlineSize: 18,
        subtitleSize: 12,
        vehicleWidth: 108,
        vehicleHeight: 54,
        vehicleTextGap: 4,
        statusSize: 13,
        statusProgressGap: 6,
        progressWidth: 220,
        bottomGap: 56,
      ),
      AppDeviceClass.tabletPortrait => const _SplashLayoutConfig(
        horizontalPadding: 56,
        topGap: 221,
        logoWidth: 350,
        logoHeight: 153,
        logoTextGap: 8,
        headlineSize: 24,
        subtitleSize: 15,
        vehicleWidth: 194,
        vehicleHeight: 98,
        vehicleTextGap: 10,
        statusSize: 16,
        statusProgressGap: 8,
        progressWidth: 360,
        bottomGap: 54,
      ),
      AppDeviceClass.tabletLandscape => const _SplashLayoutConfig(
        horizontalPadding: 80,
        topGap: 81,
        logoWidth: 370,
        logoHeight: 162,
        logoTextGap: 0,
        headlineSize: 23,
        subtitleSize: 14,
        vehicleWidth: 190,
        vehicleHeight: 95,
        vehicleTextGap: 2,
        statusSize: 15,
        statusProgressGap: 6,
        progressWidth: 400,
        bottomGap: 8,
      ),
    };
  }

  final double horizontalPadding;
  final double topGap;
  final double logoWidth;
  final double logoHeight;
  final double logoTextGap;
  final double headlineSize;
  final double subtitleSize;
  final double vehicleWidth;
  final double vehicleHeight;
  final double vehicleTextGap;
  final double statusSize;
  final double statusProgressGap;
  final double progressWidth;
  final double bottomGap;
}
