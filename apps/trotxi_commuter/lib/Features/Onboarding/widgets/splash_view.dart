import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';

/// Shown only while session restoration is in flight. No artificial delay.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF244B38),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Appvectors.logodarktheme,
                width: 160,
                semanticLabel: 'Trotxi',
              ),
              const SizedBox(height: 20),
              Text(
                'A better way to move every day.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFFE7EFD9),
                ),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFDDF7A4),
                  semanticsLabel: 'Restoring your session',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
