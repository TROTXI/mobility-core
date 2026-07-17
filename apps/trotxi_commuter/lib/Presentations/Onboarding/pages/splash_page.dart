import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
    required this.client,
  });

  final TrotxiApiClient client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background PNG
          Positioned.fill(
            child: Image.asset(
              Appvectors.splashImage,
              fit: BoxFit.cover,
            ),
          ),

          // Centered SVG Logo
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Image.asset(
                  Appvectors.logo,
                  width: 180,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
