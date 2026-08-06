import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Home/pages/home_page.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';

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
          () => _navigateNext(),
    );
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final token = await TokenStorage.instance.getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn
            ? HomePage(client: widget.client,)
            : OnBoardPage(client: widget.client),
      ),
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
          Positioned.fill(
            child: Image.asset(
              Appvectors.splashImage,
              fit: BoxFit.cover,
            ),
          ),
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
