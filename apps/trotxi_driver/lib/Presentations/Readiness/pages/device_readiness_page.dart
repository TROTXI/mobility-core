import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/device_readiness.dart';
import 'package:trotxi_driver/Presentations/Auth/widgets/auth_layout.dart';

/// Location access and services are required to start. Camera is optional:
/// refusing it must not remove code boarding. Returning true follows a fresh
/// local check; the calling run page owns the API transition.
class DeviceReadinessPage extends StatefulWidget {
  const DeviceReadinessPage({
    super.key,
    this.beforeTrip = false,
    this.onContinue,
    this.service = const NativeDeviceReadinessService(),
  });

  final bool beforeTrip;
  final VoidCallback? onContinue;
  final DeviceReadinessService service;

  @override
  State<DeviceReadinessPage> createState() => _DeviceReadinessPageState();
}

class _DeviceReadinessPageState extends State<DeviceReadinessPage>
    with WidgetsBindingObserver {
  DeviceReadiness? _state;
  bool _busy = false;
  bool _checkAgain = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    if (_busy) {
      // Permission dialogs/settings can resume the app before their Future
      // finishes. Serialize native calls, but do not lose that final recheck.
      _checkAgain = true;
      return;
    }
    await _perform();
  }

  Future<void> _perform([Future<void> Function()? action]) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action?.call();
      if (!mounted) return;
      do {
        _checkAgain = false;
        final result = await widget.service.check();
        if (!mounted) return;
        setState(() => _state = result);
      } while (_checkAgain);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = null;
        _error =
            'Could not check device permissions or open settings. Try again, '
            'or open this app’s permissions in device settings.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _settings({bool location = false}) => _perform(() async {
    final opened = await (location
        ? widget.service.openLocationSettings()
        : widget.service.openAppSettings());
    if (!opened) throw StateError('Settings unavailable');
  });

  Future<void> _continue() async {
    if (_busy) return;
    // Revalidate on the action, not only when the screen was opened/resumed.
    await _perform();
    if (!mounted) return;
    if (widget.beforeTrip && _state?.canStartTrip == true) {
      Navigator.of(context).pop(true);
    } else if (!widget.beforeTrip) {
      widget.onContinue?.call();
    }
  }

  Future<void> _request(DevicePermission permission) async {
    if (permission == DevicePermission.location) {
      final agreed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Active trip location sharing'),
          content: const Text(
            'Trotxi Driver collects precise location during an active trip, including in the background or with the screen locked, so eligible riders and operations can see the bus approaching. Collection stops when the trip ends or you sign out. Android shows a tracking notification. Continue to the location permission request?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (agreed != true || !mounted) return;
    }
    await _perform(() => widget.service.request(permission));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final state = _state;
    final ready = state?.canStartTrip == true;
    final tone = state == null
        ? colors.textSecondary
        : ready
        ? colors.success
        : colors.danger;
    final canPop = widget.beforeTrip && Navigator.of(context).canPop();
    final blockedLocation =
        state?.location == PermissionStatus.permanentlyDenied;
    return AuthLayout(
      onBack: canPop ? () => Navigator.of(context).maybePop() : null,
      trailing: AuthChip(
        state == null
            ? (_busy ? 'CHECKING' : 'CHECK')
            : ready
            ? 'READY'
            : 'REQUIRED',
        color: tone,
      ),
      hero: state == null
          ? null
          : AuthStatusMark(
              color: tone,
              icon: ready ? Icons.check_rounded : null,
            ),
      title: state == null
          ? 'Check this device'
          : ready
          ? 'Device ready'
          : 'Location is required',
      subtitle: ready
          ? 'Location is on for trips. Camera access makes boarding faster.'
          : 'Trips cannot start until location access is allowed and device location is on.',
      footer: [
        if (widget.beforeTrip) ...[
          if (!ready)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space12),
              child: Text(
                'Trips stay locked until location is enabled. Camera access is optional.',
                textAlign: TextAlign.center,
                style: AppTypography.authRowDetail.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ElevatedButton(
            style: authPrimaryButton(colors),
            onPressed: _busy || !ready ? null : _continue,
            child: AuthButtonLabel(
              state?.camera.isGranted == true || !ready
                  ? 'Start trip'
                  : 'Start with code boarding',
            ),
          ),
        ] else if (widget.onContinue != null)
          FilledButton(
            style: authPrimaryButton(colors),
            onPressed: _busy ? null : _continue,
            child: const AuthButtonLabel('Continue to today'),
          ),
        const AuthCaption(
          'Location is collected only during an active trip, including in the background, '
          'and stops when the trip ends or you sign out. No tracking starts on this screen.',
        ),
      ],
      children: [
        if (_busy) ...[
          ClipRRect(
            borderRadius: AppRadii.circular(AppRadii.full),
            child: const LinearProgressIndicator(
              minHeight: 3,
              semanticsLabel: 'Checking device permissions',
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
        ],
        if (_error != null) ...[
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTypography.authRowDetail.copyWith(color: colors.danger),
          ),
          const SizedBox(height: AppSpacing.space16),
        ],
        AuthCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space4,
          ),
          child: Column(
            children: [
              _permissionRow(
                Icons.location_on_outlined,
                'Location access',
                state?.location,
                blockedLocation
                    ? 'In settings, allow location while using the app, then come back.'
                    : 'Shows riders and operations the bus approaching during a trip.',
                DevicePermission.location,
              ),
              Divider(color: colors.border, height: 1),
              _row(
                icon: Icons.gps_fixed_rounded,
                title: 'Location services',
                status: state == null
                    ? 'Not checked'
                    : state.locationServices
                    ? 'On'
                    : 'Off',
                detail: 'Device location must also be on.',
                ready: state?.locationServices ?? false,
                action: state != null && !state.locationServices
                    ? OutlinedButton(
                        style: authRowButton(colors),
                        onPressed: _busy
                            ? null
                            : () => _settings(location: true),
                        child: const Text('Turn on location services'),
                      )
                    : null,
              ),
              Divider(color: colors.border, height: 1),
              _permissionRow(
                Icons.qr_code_scanner_rounded,
                'Camera (optional)',
                state?.camera,
                'Scan boarding passes. Without camera access, use Board by code.',
                DevicePermission.camera,
              ),
            ],
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _busy ? null : _refresh,
            child: const Text('Check again'),
          ),
        ),
      ],
    );
  }

  Widget _permissionRow(
    IconData icon,
    String title,
    PermissionStatus? status,
    String detail,
    DevicePermission permission,
  ) {
    final colors = context.driverColors;
    final blocked = status == PermissionStatus.permanentlyDenied;
    return _row(
      icon: icon,
      title: title,
      detail: detail,
      ready: status == PermissionStatus.granted,
      status: switch (status) {
        PermissionStatus.granted => 'Allowed',
        PermissionStatus.denied => 'Not allowed',
        PermissionStatus.permanentlyDenied =>
          'Denied \u2014 change in settings',
        PermissionStatus.restricted =>
          'Restricted by device policy \u2014 contact your administrator',
        null => 'Not checked',
        _ => 'Limited access \u2014 check device settings',
      },
      action: status == null || status.isGranted || status.isRestricted
          ? null
          : OutlinedButton(
              style: authRowButton(colors),
              onPressed: _busy
                  ? null
                  : () => blocked || !status.isDenied
                        ? _settings()
                        : _request(permission),
              child: Text(
                blocked || !status.isDenied
                    ? 'Open ${permission == DevicePermission.camera ? 'camera' : 'location'} settings'
                    : 'Allow ${permission == DevicePermission.camera ? 'camera' : 'location access'}',
              ),
            ),
    );
  }

  /// One line of the readiness card: what it is, where it stands, why it
  /// matters, and the one action that fixes it.
  Widget _row({
    required IconData icon,
    required String title,
    required String status,
    required String detail,
    required bool ready,
    Widget? action,
  }) {
    final colors = context.driverColors;
    final tone = ready ? colors.success : colors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tone.withValues(alpha: 0.12),
              ),
              child: Icon(
                ready ? Icons.check_rounded : icon,
                size: 20,
                color: ready ? colors.success : colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.authRowTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  status,
                  style: AppTypography.authRowValue.copyWith(
                    color: ready ? colors.success : colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  detail,
                  style: AppTypography.authRowDetail.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: AppSpacing.space12),
                  Align(alignment: Alignment.centerLeft, child: action),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
