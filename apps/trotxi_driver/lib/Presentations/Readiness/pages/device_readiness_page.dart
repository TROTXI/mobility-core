import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/device_readiness.dart';
import 'package:trotxi_driver/core/widgets/trotxi_wordmark.dart';

/// Location access and services are required to start. Camera is optional:
/// refusing it must not remove code boarding. Returning true follows a fresh
/// local check; the calling run page owns the API transition.
class DeviceReadinessPage extends StatefulWidget {
  const DeviceReadinessPage({
    super.key,
    this.beforeTrip = false,
    this.service = const NativeDeviceReadinessService(),
  });

  final bool beforeTrip;
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
    if (mounted && _state?.canStartTrip == true) {
      Navigator.of(context).pop(true);
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const TrotxiWordmark(height: 37),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.space20),
            child: Text(
              state == null
                  ? (_busy ? 'CHECKING' : 'CHECK')
                  : ready
                  ? 'READY'
                  : 'REQUIRED',
              style: AppTypography.chipLabel.copyWith(color: tone),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.withValues(alpha: 0.1),
                  ),
                  alignment: Alignment.center,
                  child: ExcludeSemantics(
                    child: ready
                        ? Icon(Icons.check_rounded, color: tone, size: 42)
                        : Text(
                            state == null ? '…' : '!',
                            style: AppTypography.heading1.copyWith(color: tone),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              Text(
                state == null
                    ? 'Check this device'
                    : ready
                    ? 'Location enabled'
                    : 'Location is required',
                textAlign: TextAlign.center,
                style: AppTypography.screenTitle,
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                ready
                    ? 'Location access is enabled for this trip. Check camera access before riders arrive.'
                    : 'Trips cannot start until location access is allowed and device location is on.',
                textAlign: TextAlign.center,
                style: AppTypography.screenContext.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              if (_busy) ...[
                const LinearProgressIndicator(
                  semanticsLabel: 'Checking device permissions',
                ),
                const SizedBox(height: AppSpacing.space16),
              ],
              if (_error != null) ...[
                Text(
                  _error!,
                  style: AppTypography.bodySmall.copyWith(color: colors.danger),
                ),
                const SizedBox(height: AppSpacing.space16),
              ],
              _permissionCard(
                'Location access',
                state?.location,
                state?.location == PermissionStatus.permanentlyDenied
                    ? 'In app settings, choose Location and allow access while using the app. Return here to check again.'
                    : 'Share the bus location while a trip is open. Only while-in-use access is requested.',
                DevicePermission.location,
              ),
              const SizedBox(height: AppSpacing.space12),
              _card(
                title: 'Location services',
                status: state == null
                    ? 'Not checked'
                    : state.locationServices
                    ? 'On'
                    : 'Off',
                detail:
                    'Device location must also be on for riders to see the bus approaching.',
                ready: state?.locationServices ?? false,
                action: state != null && !state.locationServices
                    ? OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _settings(location: true),
                        child: const Text('Turn on location services'),
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.space12),
              _permissionCard(
                'Camera (optional)',
                state?.camera,
                'Scan rider boarding passes. Without camera access, use Board by code.',
                DevicePermission.camera,
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'These checks work offline. Permission access does not confirm camera hardware, GPS signal or connectivity. '
                'No tracking starts on this screen.',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: _busy ? null : _refresh,
                child: const Text('Check again'),
              ),
              if (widget.beforeTrip) ...[
                if (!ready)
                  Text(
                    'Trips stay locked until location is enabled. Camera access is optional.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                const SizedBox(height: AppSpacing.space12),
                ElevatedButton(
                  onPressed: _busy || !ready ? null : _continue,
                  child: Text(
                    state?.camera.isGranted == true || !ready
                        ? 'Start trip'
                        : 'Start with code boarding',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionCard(
    String title,
    PermissionStatus? status,
    String detail,
    DevicePermission permission,
  ) {
    final blocked = status == PermissionStatus.permanentlyDenied;
    return _card(
      title: title,
      detail: detail,
      ready: status == PermissionStatus.granted,
      status: switch (status) {
        PermissionStatus.granted => 'Allowed',
        PermissionStatus.denied => 'Not allowed',
        PermissionStatus.permanentlyDenied => 'Denied — change in settings',
        PermissionStatus.restricted =>
          'Restricted by device policy — contact your administrator',
        null => 'Not checked',
        _ => 'Limited access — check device settings',
      },
      action: status == null || status.isGranted || status.isRestricted
          ? null
          : OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => blocked || !status.isDenied
                        ? _settings()
                        : _perform(() => widget.service.request(permission)),
              child: Text(
                blocked || !status.isDenied
                    ? 'Open ${permission == DevicePermission.camera ? 'camera' : 'location'} settings'
                    : 'Allow ${permission == DevicePermission.camera ? 'camera' : 'location access'}',
              ),
            ),
    );
  }

  Widget _card({
    required String title,
    required String status,
    required String detail,
    required bool ready,
    Widget? action,
  }) {
    final colors = context.driverColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.field,
        border: Border.all(color: colors.border),
        borderRadius: AppRadii.circular(AppRadii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (ready ? colors.success : colors.textSecondary)
                      .withValues(alpha: 0.1),
                ),
                child: ExcludeSemantics(
                  child: ready
                      ? Icon(
                          Icons.check_rounded,
                          color: colors.success,
                          size: 20,
                        )
                      : Text(
                          '!',
                          style: AppTypography.keyLabel.copyWith(
                            color: ready
                                ? colors.success
                                : colors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(child: Text(title, style: AppTypography.fieldLabel)),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(status, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.space8),
          Text(
            detail,
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.space12),
            action,
          ],
        ],
      ),
    );
  }
}
