import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/data/profile_repository.dart';
import 'package:trotxi_driver/Presentations/Profile/widgets/photo_action.dart';
import 'package:trotxi_driver/Presentations/Readiness/pages/device_readiness_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/Presentations/Schedule/pages/schedule_page.dart';
import 'package:trotxi_driver/Presentations/Support/pages/incident_support_page.dart';
import 'package:trotxi_driver/Presentations/Work/pages/work_requests_page.dart';
import 'package:trotxi_driver/core/state/session_controller.dart';
import 'package:trotxi_driver/core/state/driver_notifications.dart';

/// Profile and settings (prototype frames 49 to 54).
///
/// Assignment alerts reflect device permission and actual API registration;
/// general notification preferences remain outside this driver's workflow.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  LocationPermission? _locationPermission;
  bool? _locationServices;
  String? _photoUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _readDeviceState();
    _readPhoto();
  }

  /// A missing photo is the ordinary case, not an error worth showing: the
  /// card falls back to initials, which is what it drew before there were
  /// photos at all.
  Future<void> _readPhoto() async {
    try {
      final account = await DriverProfileRepository(
        context.read<DriverApi>(),
      ).account();
      if (mounted) setState(() => _photoUrl = account.avatarUrl);
    } on TrotxiException {
      // Leave the initials in place.
    }
  }

  void _say(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  /// Riders already see a driver's manifest photo of themselves; this is the
  /// other half of that. Resized before it leaves the handset because a phone
  /// photo is several megabytes and the server caps the upload, so sending the
  /// original spends a driver's data to earn a 413.
  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheet).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () => Navigator.of(sheet).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } on PlatformException {
      if (mounted) {
        _say('Trotxi needs permission to use that. Check your settings.');
      }
      return;
    }
    if (picked == null || !mounted) return;

    final contentType =
        DriverProfileRepository.accepted[picked.name.split('.').last
            .toLowerCase()];
    if (contentType == null) {
      _say('Choose a JPEG, PNG or WebP image.');
      return;
    }

    final repository = DriverProfileRepository(context.read<DriverApi>());
    setState(() => _uploading = true);
    try {
      final Uint8List bytes = await picked.readAsBytes();
      final url = await repository.uploadPhoto(
        bytes,
        contentType: contentType,
        filename: picked.name,
      );
      if (!mounted) return;
      setState(() => _photoUrl = url);
      _say('Photo updated.');
    } on ApiException catch (error) {
      if (!mounted) return;
      _say(switch (error.statusCode) {
        413 => 'That photo is too large. Try a smaller one.',
        415 => 'That file is not an image Trotxi can read.',
        429 => 'Too many attempts. Wait a moment and try again.',
        _ => 'Could not upload that photo. Try again.',
      });
    } on TrotxiException {
      if (mounted) _say('Could not upload that photo. Try again.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
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
    final alerts = context.watch<DriverNotifications?>();
    final identity = Container(
      padding: const EdgeInsets.all(AppSpacing.space20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _Photo(
            url: _photoUrl,
            initials: _initials(driver?.fullName ?? '?'),
            busy: _uploading,
            colors: colors,
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver?.fullName ?? 'Driver',
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  driver?.driverCode == null
                      ? 'Driver'
                      : 'Driver · ${driver!.driverCode}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                PhotoAction(
                  hasPhoto: _photoUrl != null,
                  busy: _uploading,
                  onPressed: _changePhoto,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final appearance = _ProfileSection(
      label: 'Appearance',
      colors: colors,
      child: _Card(
        colors: colors,
        child: RadioGroup<ThemeMode>(
          groupValue: theme.themeMode,
          onChanged: (next) => theme.setThemeMode(next ?? ThemeMode.system),
          child: Column(
            children: [
              for (final mode in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  value: mode,
                  title: Text(
                    switch (mode) {
                      ThemeMode.system => 'Match device',
                      ThemeMode.light => 'Light',
                      ThemeMode.dark => 'Dark',
                    },
                    style: AppTypography.body.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final work = _ProfileSection(
      label: 'Work',
      colors: colors,
      child: _Card(
        colors: colors,
        child: Column(
          children: [
            _destination(
              context,
              title: 'Schedule',
              subtitle: 'Assigned trips by date',
              pageTitle: 'Schedule',
              page: const SchedulePage(),
              colors: colors,
            ),
            _destination(
              context,
              title: 'Work & requests',
              subtitle: 'Routes, changes and leave',
              pageTitle: 'Work & Requests',
              page: const WorkRequestsPage(),
              colors: colors,
            ),
            _destination(
              context,
              title: 'Incident & support',
              subtitle: 'Report a problem or call operations',
              pageTitle: 'Incident & support',
              page: const IncidentSupportPage(),
              colors: colors,
              danger: true,
            ),
          ],
        ),
      ),
    );

    final device = _ProfileSection(
      label: 'Device & permissions',
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (alerts != null)
            ListTile(
              title: const Text('Assignment alerts'),
              subtitle: Text(alerts.status),
              trailing: alerts.enabled
                  ? const Icon(Icons.notifications_active_outlined)
                  : TextButton(
                      onPressed: alerts.busy ? null : alerts.enable,
                      child: const Text('Enable'),
                    ),
            ),
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
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const DeviceReadinessPage()),
              );
              if (mounted) await _readDeviceState();
            },
            child: const Text('Check camera & location'),
          ),
        ],
      ),
    );

    final signOut = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: session.isBusy
              ? null
              : () => _confirmSignOut(context, session),
          style: ElevatedButton.styleFrom(backgroundColor: colors.danger),
          child: const Text('Sign out'),
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          'Signing out on a shared vehicle phone is what stops the next driver boarding riders as you.',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final content = wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        identity,
                        const SizedBox(height: AppSpacing.space24),
                        device,
                        const SizedBox(height: AppSpacing.space32),
                        signOut,
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space32),
                  Expanded(
                    child: Column(
                      children: [
                        work,
                        const SizedBox(height: AppSpacing.space24),
                        appearance,
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  identity,
                  const SizedBox(height: AppSpacing.space24),
                  appearance,
                  const SizedBox(height: AppSpacing.space24),
                  work,
                  const SizedBox(height: AppSpacing.space24),
                  device,
                  const SizedBox(height: AppSpacing.space32),
                  signOut,
                ],
              );
        return RefreshIndicator(
          onRefresh: _readDeviceState,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.space20),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: content,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _destination(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String pageTitle,
    required Widget page,
    required AppColors colors,
    bool danger = false,
  }) => ListTile(
    title: Text(
      title,
      style: AppTypography.body.copyWith(
        color: danger ? colors.danger : colors.textPrimary,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: AppTypography.caption.copyWith(color: colors.textSecondary),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(pageTitle)),
          body: SafeArea(child: page),
        ),
      ),
    ),
  );

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

  Future<void> _confirmSignOut(
    BuildContext context,
    SessionController session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need your driver code and PIN to sign back in. Any trip you '
          'have running stays running. GPS positions not yet uploaded are removed '
          'from this phone when you sign out. Reconnect first to preserve them.',
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
    if (confirmed ?? false) {
      try {
        await session.signOut();
      } on TrotxiException catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.message)));
        }
      }
    }
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
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

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.label,
    required this.colors,
    required this.child,
  });

  final String label;
  final AppColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SectionLabel(text: label, colors: colors),
      child,
    ],
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
      title: Text(
        label,
        style: AppTypography.body.copyWith(color: colors.textPrimary),
      ),
      subtitle: Text(
        detail,
        style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }
}

/// The driver's photo, or their initials until there is one.
///
/// A photo that will not load falls back to the initials rather than a broken
/// image: the card has to read as a person either way.
class _Photo extends StatelessWidget {
  const _Photo({
    required this.url,
    required this.initials,
    required this.busy,
    required this.colors,
  });

  final String? url;
  final String initials;
  final bool busy;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final letters = Text(
      initials,
      style: AppTypography.title.copyWith(color: colors.textPrimary),
    );
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceSelected,
        borderRadius: AppRadii.circular(AppRadii.full),
      ),
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : url == null
          ? letters
          : Image.network(
              url!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => letters,
            ),
    );
  }
}
