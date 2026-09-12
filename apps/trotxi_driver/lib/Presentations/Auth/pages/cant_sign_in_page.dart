import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/widgets/operations_contact.dart';

/// "Can't sign in?" (prototype frame 06).
///
/// Deliberately not a reset form. A driver's phone number is optional on the
/// fleet record, so there is no verified channel to send a new PIN to, and
/// inventing one would mean trusting whoever is holding the handset. Recovery
/// runs through operations, who can confirm who they are talking to.
class CantSignInPage extends StatelessWidget {
  const CantSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final config = context.watch<ConfigController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Can't sign in?")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          children: [
            Text(
              'Work through these before calling. Most sign-in problems are one of the first two.',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space24),
            const _Step(
              number: '1',
              title: 'Check your driver code',
              detail:
                  'It starts with DR- and has four characters after it. There is no '
                  'letter O or letter I in a code: those are the digits zero and one.',
            ),
            const _Step(
              number: '2',
              title: 'Check your PIN',
              detail:
                  'Six digits, issued by operations. If you have changed it, use the '
                  'one you chose rather than the one on your slip.',
            ),
            const _Step(
              number: '3',
              title: 'Ask operations for a new PIN',
              detail:
                  'They can issue one over the phone once they have confirmed who you '
                  'are. Your old PIN stops working straight away.',
            ),
            const _Step(
              number: '4',
              title: 'Locked out?',
              detail:
                  'Five wrong PINs locks the account for fifteen minutes. Operations '
                  'can unlock it sooner.',
              isLast: true,
            ),
            const SizedBox(height: AppSpacing.space24),
            // Served from /flags (#234), which answers before sign-in — which
            // is the whole reason this screen can show it at all. Depots differ
            // and a number compiled into the build goes stale, so when the
            // operator has published nothing the card says so rather than
            // promising details will turn up later. The old copy promised
            // exactly that, and nothing kept it.
            OperationsContactCard(
              contact: config.operations,
              isLoaded: config.isLoaded,
              emptyDetail:
                  'Your operator has not published a number. Ask at the depot '
                  'office, or another driver on your corridor will have it.',
            ),
            const SizedBox(height: AppSpacing.space24),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.detail,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String detail;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.space20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceSelected,
              borderRadius: AppRadii.circular(AppRadii.full),
            ),
            child: Text(
              number,
              style: AppTypography.caption.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  detail,
                  style: AppTypography.bodySmall.copyWith(
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
