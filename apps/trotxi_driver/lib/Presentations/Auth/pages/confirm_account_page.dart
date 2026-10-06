import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/Presentations/Auth/widgets/auth_layout.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Confirms the authenticated identity before this device is linked (page 05).
///
/// Only authenticated values are shown. The design's operator, depot and
/// vehicle examples are placeholders, and the current auth response does not
/// return those fields; presenting them here would turn sample copy into fleet
/// data. The entered driver code is safe to show because the server just
/// accepted it for this session.
class ConfirmAccountPage extends StatefulWidget {
  const ConfirmAccountPage({
    super.key,
    required this.session,
    required this.onConfirmed,
    required this.onRejected,
  });

  final DriverSession session;
  final VoidCallback onConfirmed;
  final Future<void> Function() onRejected;

  @override
  State<ConfirmAccountPage> createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends State<ConfirmAccountPage> {
  bool _signingOut = false;

  Future<void> _reject() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await widget.onRejected();
    } on TrotxiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final code = widget.session.driverCode;
    return AuthLayout(
      title: 'Confirm your account',
      subtitle: 'Check the details linked to the driver code you entered.',
      onBack: _signingOut ? null : _reject,
      backTooltip: 'Back to sign in',
      footer: [
        Text(
          'Is this your account?',
          textAlign: TextAlign.center,
          style: AppTypography.authQuestion.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                style: authPrimaryButton(colors),
                onPressed: _signingOut ? null : widget.onConfirmed,
                child: const AuthButtonLabel('Yes, link account'),
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: OutlinedButton(
                style: authSecondaryButton(colors),
                onPressed: _signingOut ? null : _reject,
                child: _signingOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const AuthButtonLabel('Not my account'),
              ),
            ),
          ],
        ),
        const AuthCaption(
          'Linking confirms this device can access your assigned Trotxi trips.',
        ),
      ],
      children: [
        AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthIdentity(
                name: widget.session.fullName,
                detail: 'Driver account',
              ),
              const SizedBox(height: AppSpacing.space16),
              Divider(color: colors.border, height: 1),
              if (code != null) AuthDetailRow(label: 'Driver ID', value: code),
              const SizedBox(height: AppSpacing.space4),
              Align(
                alignment: Alignment.centerLeft,
                child: AuthChip('ACCOUNT VERIFIED', color: colors.success),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
