import 'package:flutter/material.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/widgets/app_button.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';

class OnBoardPage extends StatelessWidget {
  const OnBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Logo at the top
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Image.asset(
                Appvectors.logo,
                width: 180,
              ),
            ),

            // Center the remaining content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Welcome to Trotxi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    AppSignInButton(
                      onPressed: () {
                        print('Continue with Google');
                      },
                      text: "Continue with Google",
                      icon: Image.asset(
                        Appvectors.googleIconImage,
                      ),
                    ),

                    const SizedBox(height: 16),

                    AppSignInButton(
                      onPressed: () {
                        print('Continue with Apple');
                      },
                      text: "Continue with Apple",
                      icon: Image.asset(
                        Appvectors.appleIconImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
