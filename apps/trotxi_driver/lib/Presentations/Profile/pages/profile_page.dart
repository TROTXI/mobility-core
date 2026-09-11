import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';

/// Profile and settings (prototype frames 49 to 54).
///
/// Only what the app can actually honour. The prototype also draws notification
/// preferences, and those are left out on purpose: there is no API behind them,
/// so shipping the toggles would mean a driver switching off assignment alerts
/// and still being woken by them. A control that lies is worse than a missing
/// one.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  LocationPermission? _locationPermission;
  bool? _locationServices;

  @override
  void initState() {
    super.initState();
    _readDeviceState();
  }

  Future<void> _readDeviceState() async {
    final permission = await Geolocator.checkPermission();
    final services = await Geolocator.isLocationServiceEnabled();
    if (mounted) {
      setState(() {
        _locationPermission = permission;
        _locationServices = services;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final session = context.watch<SessionController>();
    final theme = context.watch<AppThemeController>();
    final driver = session.session;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & settings')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _readDeviceState,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space20),
            children: [
              Container(
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
                        _initials(driver?.fullName ?? '?'),
                        style: AppTypography.title.copyWith(color: colors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver?.fullName ?? 'Driver',
                            style: AppTypography.title.copyWith(color: colors.textPrimary),
                          ),
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
              const SizedBox(height: AppSpacing.space24),

              _SectionLabel(text: 'Appearance', colors: colors),
              _Card(
                colors: colors,
                child: Column(
                  children: [
                    for (final mode in ThemeMode.values)
                      RadioListTile<ThemeMode>(
                        value: mode,
                        groupValue: theme.themeMode,
                        onChanged: (next) => theme.setThemeMode(next ?? ThemeMode.system),
                        title: Text(
                          switch (mode) {
                            ThemeMode.system => 'Match device',
                            ThemeMode.light => 'Light',
                            ThemeMode.dark => 'Dark',
                          },
                          style: AppTypography.body.copyWith(color: colors.textPrimary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space24),

              _SectionLabel(text: 'Device & permissions', colors: colors),
              _Card(
                colors: colors,
                child: Column(
                  children: [
                    _StatusRow(
                      label: 'Location services',
                      ok: _locationServices ?? false,
                      detail: (_locationServices ?? false)
                          ? 'On'
                          : 'Off — riders cannot see the bus',
                      colors: colors,
                    ),
                    _StatusRow(
                      label: 'Location access',
                      ok: _locationGranted,
                      detail: _locationDetail,
                      colors: colors,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space12),
              OutlinedButton(
                onPressed: Geolocator.openAppSettings,
                child: const Text('Open device settings'),
              ),
              const SizedBox(height: AppSpacing.space32),

              ElevatedButton(
                onPressed: session.isBusy ? null : () => _confirmSignOut(context, session),
                style: ElevatedButton.styleFrom(backgroundColor: colors.danger),
                child: const Text('Sign out'),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Signing out on a shared vehicle phone is what stops the next '
                'driver boarding riders as you.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _locationGranted =>
      _locationPermission == LocationPermission.always ||
      _locationPermission == LocationPermission.whileInUse;

  String get _locationDetail => switch (_locationPermission) {
    LocationPermission.whileInUse => 'Allowed while using the app',
    LocationPermission.always => 'Always allowed',
    LocationPermission.deniedForever => 'Denied — change it in device settings',
    LocationPermission.denied => 'Not allowed yet',
    _ => 'Unknown',
  };

  Future<void> _confirmSignOut(BuildContext context, SessionController session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need your driver code and PIN to sign back in. Any trip you '
          'have running stays running.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await session.signOut();
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.space8),
    child: Text(
      text.toUpperCase(),
      style: AppTypography.caption.copyWith(color: colors.textSecondary),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.colors});

  final Widget child;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: AppRadii.circular(AppRadii.lg),
      border: Border.all(color: colors.border),
    ),
    child: child,
  );
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.ok,
    required this.detail,
    required this.colors,
  });

  final String label;
  final bool ok;
  final String detail;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle_outline : Icons.error_outline,
        color: ok ? colors.success : colors.warning,
      ),
      title: Text(label, style: AppTypography.body.copyWith(color: colors.textPrimary)),
      subtitle: Text(
        detail,
        style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
