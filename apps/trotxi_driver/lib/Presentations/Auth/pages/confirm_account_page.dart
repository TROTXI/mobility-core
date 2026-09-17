import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/trotxi_wordmark.dart';
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
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth >= 800
                      ? AppSpacing.space40
                      : AppSpacing.space20,
                  vertical: AppSpacing.space24,
                ),
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(child: TrotxiWordmark(height: 42)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton.outlined(
                          onPressed: _signingOut ? null : _reject,
                          icon: const Icon(Icons.chevron_left),
                          tooltip: 'Back to sign in',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space40),
                  Text(
                    'Confirm your account',
                    textAlign: TextAlign.center,
                    style: AppTypography.screenTitle.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'Check the details linked to the driver code you entered.',
                    textAlign: TextAlign.center,
                    style: AppTypography.screenContext.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppRadii.circular(AppRadii.xl),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: colors.surfaceSelected,
                              child: Text(
                                _initials(widget.session.fullName),
                                style: AppTypography.title.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.session.fullName,
                                    style: AppTypography.title.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Driver account · Verified',
                                    style: AppTypography.caption.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (code != null) ...[
                          const SizedBox(height: AppSpacing.space20),
                          Divider(color: colors.border, height: 1),
                          _DetailRow(label: 'Driver ID', value: code),
                        ],
                        const SizedBox(height: AppSpacing.space8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.space12,
                              vertical: AppSpacing.space4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.success.withValues(alpha: 0.1),
                              borderRadius: AppRadii.circular(AppRadii.full),
                            ),
                            child: Text(
                              'Account verified',
                              style: AppTypography.chipLabel.copyWith(
                                color: colors.success,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space32),
                  Text(
                    'Is this your account?',
                    textAlign: TextAlign.center,
                    style: AppTypography.heading3.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _signingOut ? null : widget.onConfirmed,
                          child: const Text('Yes, link account'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _signingOut ? null : _reject,
                          child: _signingOut
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Not my account'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    'Linking confirms this device can access your assigned Trotxi trips.',
                    textAlign: TextAlign.center,
                    style: AppTypography.footnote.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _initials(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}
