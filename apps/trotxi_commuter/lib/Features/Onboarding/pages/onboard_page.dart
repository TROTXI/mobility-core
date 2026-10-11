import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';
import 'package:trotxi_commuter/core/widgets/commute_illustration.dart';
import 'package:trotxi_commuter/core/widgets/public_information_links.dart';
import 'phone_password_page.dart';

class OnBoardPage extends StatelessWidget {
  const OnBoardPage({super.key, required this.client});
  final CommuterApi client;

  void _open(BuildContext context, bool signup) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PhonePasswordPage(client: client, signup: signup),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          dark ? Appvectors.logodarktheme : Appvectors.logo,
                          width: 100,
                          semanticLabel: 'Trotxi',
                        ),
                      ),
                      const SizedBox(height: 28),
                      const CommuteIllustration(),
                      const SizedBox(height: 28),
                      Text(
                        'Make room for\nbetter mornings.',
                        style: AppTypography.heading1.copyWith(
                          fontSize: 36,
                          height: 1.1,
                          letterSpacing: -1.4,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A planned commute. A familiar route.\nMore time for you.',
                        style: AppTypography.body.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          for (final text in [
                            'Scheduled journeys',
                            'Simple commute plans',
                          ])
                            Text(
                              text,
                              style: AppTypography.caption.copyWith(
                                color: colors.actionSecondary,
                              ),
                            ),
                        ],
                      ),
                      if (client.authNotice != null) ...[
                        const SizedBox(height: 20),
                        Semantics(
                          liveRegion: true,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                client.authNotice!,
                                style: AppTypography.bodySmall,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: () => _open(context, true),
                        child: const Text('Create account'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => _open(context, false),
                        child: const Text('Sign in'),
                      ),
                      const SizedBox(height: 4),
                      const PublicInformationLinks(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
