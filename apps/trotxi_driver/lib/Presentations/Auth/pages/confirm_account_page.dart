import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// "Confirm your account" (prototype frame 05).
///
/// The session already exists by the time this shows: sign-in is one round trip,
/// and holding a half-authenticated state on the server so a screen can ask a
/// question would be more moving parts for the same answer. "Not my account"
/// therefore signs out rather than abandoning a pending flow.
///
/// It earns its place because depot handsets get passed around. A driver who
/// picks up a phone someone else just used, and whose code happens to be one
/// character off, should find out here rather than at the roadside.
class ConfirmAccountPage extends StatefulWidget {
  const ConfirmAccountPage({
    super.key,
    required this.session,
    required this.auth,
    required this.onConfirmed,
    required this.onRejected,
  });

  final DriverSession session;
  final DriverAuthRepository auth;
  final VoidCallback onConfirmed;

  /// Called after the session has been discarded.
  final VoidCallback onRejected;

  @override
  State<ConfirmAccountPage> createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends State<ConfirmAccountPage> {
  bool _signingOut = false;

  Future<void> _reject() async {
    setState(() => _signingOut = true);
    await widget.auth.signOut();
    if (!mounted) return;
    widget.onRejected();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final initials = _initials(widget.session.fullName);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm your account',
                style: AppTypography.heading1.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Check this is you before you start driving.',
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadii.circular(AppRadii.lg),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.surfaceSelected,
                        borderRadius: AppRadii.circular(AppRadii.full),
                      ),
                      child: Text(
                        initials,
                        style: AppTypography.title.copyWith(color: colors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.session.fullName,
                            style: AppTypography.title.copyWith(color: colors.textPrimary),
                          ),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            'Driver',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _signingOut ? null : widget.onConfirmed,
                child: const Text('Yes, this is me'),
              ),
              const SizedBox(height: AppSpacing.space12),
              OutlinedButton(
                onPressed: _signingOut ? null : _reject,
                child: _signingOut
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Not my account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Up to two initials from a name, for the avatar placeholder.
  ///
  /// @param fullName - the driver's name.
  /// @returns one or two uppercase letters.
  static String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}
