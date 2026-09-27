import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/config_controller.dart';
import 'package:trotxi_driver/core/widgets/driver_note.dart';
import 'package:trotxi_driver/core/widgets/operations_contact.dart';

/// "Forgot PIN?" while signed out.
///
/// Recovery runs through operations. There is no self-service reset: nothing
/// on a driver record is a verified channel, so a code sent to it would trust
/// whoever holds the handset. Operations confirms who they are talking to,
/// then issues a temporary PIN, by email where the fleet record has an
/// address. This page says exactly that and nothing it cannot back up.
class ForgotPinPage extends StatelessWidget {
  const ForgotPinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final config = context.watch<ConfigController>();
    final step = AppTypography.body.copyWith(color: colors.textPrimary);
    final detail = AppTypography.bodySmall.copyWith(
      color: colors.textSecondary,
    );

    Widget item(String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: step),
          const SizedBox(height: AppSpacing.space4),
          Text(body, style: detail),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot PIN?')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          children: [
            Text(
              'Operations resets your PIN for you. It takes one call.',
              style: AppTypography.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space24),
            item(
              'Contact operations',
              'Use the contact below. Tell them your full name, your driver code '
                  '(it starts with DR-) and the phone number on your driver record, '
                  'so they can confirm it is you.',
            ),
            item(
              'Get a temporary PIN',
              'Operations issues a new six-digit temporary PIN. If they have your '
                  'email address it arrives by email; otherwise they give it to you '
                  'directly. It works for 72 hours, and your old PIN stops working '
                  'straight away.',
            ),
            item(
              'Sign in and choose your own PIN',
              'Sign in with your driver code and the temporary PIN. The app then '
                  'asks you to choose a private PIN before you can start work.',
            ),
            OperationsContactCard(
              contact: config.operations,
              isLoaded: config.isLoaded,
              emptyDetail:
                  'Your operator has not published a number. Ask at the depot '
                  'office, or another driver on your corridor will have it.',
            ),
            const SizedBox(height: AppSpacing.space24),
            const DriverNote(
              title: 'Keep your PIN to yourself',
              body:
                  'Operations cannot see the PIN you choose and will never ask for '
                  'it. Nobody from Trotxi will ask you to reply to an email with a PIN.',
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
