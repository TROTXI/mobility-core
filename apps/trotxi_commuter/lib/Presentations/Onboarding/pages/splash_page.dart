import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.client,
  });

  final TrotxiApiClient client;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();

    _splashTimer = Timer(
      const Duration(seconds: 10),
          () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnBoardPage(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

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

          // Centered Logo
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
