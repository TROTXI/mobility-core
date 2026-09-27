import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_driver/core/api/driver_api.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/driver_note.dart';
import 'package:uuid/uuid.dart';

/// Six digits, not all the same, not a run up or down. The server applies the
/// same rule; checking here first saves a driver a round trip on a weak signal.
String? pinProblem(String pin) {
  if (!RegExp(r'^\d{6}$').hasMatch(pin)) return 'Enter six digits.';
  if (pin.split('').toSet().length == 1) {
    return 'Choose a PIN that is not one digit repeated.';
  }
  var up = true, down = true;
  for (var i = 1; i < pin.length; i++) {
    final step = pin.codeUnitAt(i) - pin.codeUnitAt(i - 1);
    if (step != 1) up = false;
    if (step != -1) down = false;
  }
  if (up || down) return 'Choose a PIN that is not a run like 123456.';
  return null;
}

/// Choose a private PIN after signing in with one from operations.
///
/// Reached from sign-in or from a restored session whose PIN is still
/// temporary. The server refuses assigned work until this succeeds, so this
/// screen is the only way on, apart from signing out.
///
/// Nothing submits itself: a sixth digit is not a decision. A retry after an
/// unanswered request reuses the same key, so the server applies the change
/// once; changing what was typed starts a new request.
class PinSetupPage extends StatefulWidget {
  const PinSetupPage({
    super.key,
    required this.changePin,
    required this.onChanged,
    required this.onUncertain,
    required this.onSignOut,
    this.temporaryPin,
  });

  /// The temporary PIN from sign-in, when this app still holds it. Null after
  /// a restored session, and the driver types it instead.
  final String? temporaryPin;

  final Future<void> Function({
    required String currentPin,
    required String newPin,
    required String idempotencyKey,
  })
  changePin;
  final Future<void> Function() onChanged;
  final Future<void> Function() onUncertain;
  final Future<void> Function() onSignOut;

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _working = false;
  String? _error;
  bool _expired = false;
  String? _key;
  String? _keyFor;
  bool _uncertain = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String get _currentPin => widget.temporaryPin ?? _current.text;

  Future<void> _submit() async {
    final problem = widget.temporaryPin == null && _current.text.length != 6
        ? 'Enter the six-digit temporary PIN from operations.'
        : pinProblem(_next.text) ??
              (_next.text != _confirm.text
                  ? 'The two new PINs do not match.'
                  : _next.text == _currentPin
                  ? 'Choose a PIN different from the temporary one.'
                  : null);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    // Same typed values, same key: a retry after no answer is the same request.
    final fingerprint = '$_currentPin:${_next.text}';
    if (_keyFor != fingerprint) {
      _key = const Uuid().v4();
      _keyFor = fingerprint;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await widget.changePin(
        currentPin: _currentPin,
        newPin: _next.text,
        idempotencyKey: _key!,
      );
      if (!mounted) return;
      await widget.onChanged();
    } on OfflineException {
      _uncertain = true;
      _fail(
        'No answer from Trotxi. The change may or may not have gone through. '
        'Try again when you have signal; it is safe to repeat.',
      );
    } on UnauthorizedException {
      // Only reachable once the session is gone. After an unanswered attempt
      // that means the change probably applied; otherwise it was revoked.
      if (_uncertain) {
        await widget.onUncertain();
      } else {
        _fail('Your session has ended. Sign in again with your temporary PIN.');
      }
    } on InvalidCredentialsException {
      _fail(
        'The temporary PIN is not right. Check the email or ask operations.',
      );
    } on CredentialLockedException catch (error) {
      final minutes = (error.retryAfter.inSeconds / 60).ceil();
      _fail(
        'Too many wrong PINs. Try again in $minutes '
        '${minutes == 1 ? 'minute' : 'minutes'}, or ask operations to unlock it.',
      );
    } on RateLimitException catch (error) {
      _fail(
        'Too many attempts. Wait ${error.retryAfter.inSeconds} seconds, then try again.',
      );
    } on ApiException catch (error) {
      if (error.code == 'temporary_pin_expired') {
        setState(() => _expired = true);
      }
      _fail(error.message);
    } on TrotxiException catch (error) {
      _fail(error.message);
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _working = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space20,
                AppSpacing.space32,
                AppSpacing.space20,
                AppSpacing.space32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose your PIN',
                    textAlign: TextAlign.center,
                    style: AppTypography.screenTitle.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    'You signed in with a temporary PIN from operations. Choose '
                    'your own six-digit PIN before you start work. Operations '
                    'will not be able to see it.',
                    textAlign: TextAlign.center,
                    style: AppTypography.screenContext.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space32),
                  if (widget.temporaryPin == null)
                    _PinField(
                      label: 'Temporary PIN',
                      controller: _current,
                      enabled: !_working && !_expired,
                    ),
                  _PinField(
                    label: 'New PIN',
                    controller: _next,
                    enabled: !_working && !_expired,
                  ),
                  _PinField(
                    label: 'Confirm new PIN',
                    controller: _confirm,
                    enabled: !_working && !_expired,
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: AppTypography.footnote.copyWith(
                          color: colors.danger,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                  ],
                  FilledButton(
                    onPressed: _working || _expired ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: colors.action,
                      foregroundColor: colors.onAction,
                      textStyle: AppTypography.actionLabel,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.circular(AppRadii.pill),
                      ),
                    ),
                    child: _working
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onAction,
                              semanticsLabel: 'Saving your PIN',
                            ),
                          )
                        : const Text('Save PIN'),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  TextButton(
                    onPressed: _working ? null : widget.onSignOut,
                    child: Text(
                      'Sign out',
                      style: AppTypography.fieldLabel.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  const DriverNote(
                    title: 'After you save',
                    body:
                        'Every device signed in to your account is signed out, '
                        'this one too. Sign in again with your driver code and '
                        'the PIN you just chose.',
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

class _PinField extends StatelessWidget {
  const _PinField({
    required this.label,
    required this.controller,
    required this.enabled,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space20),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: true,
        keyboardType: TextInputType.number,
        autocorrect: false,
        enableSuggestions: false,
        onSubmitted: onSubmitted,
        style: AppTypography.fieldText.copyWith(
          color: colors.textPrimary,
          letterSpacing: 4,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        decoration: InputDecoration(labelText: label, hintText: '•' * 6),
      ),
    );
  }
}
