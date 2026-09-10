import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/Presentations/Auth/models/sign_in_state.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/cant_sign_in_page.dart';
import 'package:trotxi_driver/Presentations/Auth/widgets/pin_field.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Driver sign-in (prototype frames 03, 04 and 06).
///
/// The code and PIN are issued by operations; there is no self-service recovery,
/// which is why "Can't sign in?" leads to a page that tells the driver who to
/// call rather than to a reset form.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.auth, required this.onSignedIn});

  final DriverAuthRepository auth;

  /// Called once a session exists. The caller decides where to go, since a
  /// driver still on the PIN operations issued has to change it first.
  final ValueChanged<DriverSession> onSignedIn;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();
  bool _rememberDevice = false;
  SignInState _state = SignInState.idle;

  @override
  void initState() {
    super.initState();
    // Any edit clears the previous failure, so the driver is not still reading
    // "check your PIN" while typing a different one.
    _codeController.addListener(_clearFailure);
    _pinController.addListener(_clearFailure);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _clearFailure() {
    if (_state.status == SignInStatus.idle || _state.isSubmitting) return;
    // A lock and a suspension survive editing: they are not about what was
    // typed, and clearing them would suggest another go might work.
    if (!_state.isRetryable) return;
    setState(() => _state = SignInState.idle);
  }

  bool get _canSubmit =>
      _codeController.text.trim().length >= 4 &&
      _pinController.text.length == 6 &&
      !_state.isSubmitting &&
      _state.isRetryable;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    FocusScope.of(context).unfocus();
    setState(() => _state = SignInState.submitting);

    try {
      final session = await widget.auth.signIn(
        driverCode: _codeController.text,
        pin: _pinController.text,
        rememberDevice: _rememberDevice,
      );
      if (!mounted) return;
      widget.onSignedIn(session);
    } on InvalidCredentialsException {
      _fail(const SignInState(status: SignInStatus.invalidCredentials));
    } on CredentialLockedException catch (err) {
      _pinController.clear();
      _fail(SignInState(status: SignInStatus.locked, retryAfter: err.retryAfter));
    } on AccountSuspendedException catch (err) {
      _fail(SignInState(status: SignInStatus.suspended, message: err.message));
    } on OfflineException {
      _fail(const SignInState(status: SignInStatus.offline));
    } on TrotxiException catch (err) {
      _fail(SignInState(status: SignInStatus.failed, message: err.message));
    }
  }

  void _fail(SignInState state) {
    if (!mounted) return;
    setState(() => _state = state);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Scaffold(
      body: SafeArea(
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space24,
              vertical: AppSpacing.space32,
            ),
            children: [
              Text('Sign in', style: AppTypography.heading1.copyWith(color: colors.textPrimary)),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Use the driver code and PIN your operator issued.',
                style: AppTypography.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space32),

              Text(
                'Driver code',
                style: AppTypography.label.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space8),
              TextField(
                controller: _codeController,
                enabled: _state.isRetryable && !_state.isSubmitting,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                // The server normalises case and the DR- prefix, so anything the
                // driver reads off a slip of paper is accepted as typed.
                decoration: const InputDecoration(hintText: 'DR-B7K9'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
                  LengthLimitingTextInputFormatter(12),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),

              Text('PIN', style: AppTypography.label.copyWith(color: colors.textSecondary)),
              const SizedBox(height: AppSpacing.space8),
              SizedBox(
                height: 56,
                child: PinField(
                  controller: _pinController,
                  hasError: _state.highlightsPin,
                  onCompleted: (_) => _submit(),
                ),
              ),

              if (_state.status != SignInStatus.idle && !_state.isSubmitting) ...[
                const SizedBox(height: AppSpacing.space16),
                _FailureNotice(state: _state),
              ],

              const SizedBox(height: AppSpacing.space24),
              _RememberDeviceToggle(
                value: _rememberDevice,
                onChanged: (value) => setState(() => _rememberDevice = value),
              ),
              const SizedBox(height: AppSpacing.space32),

              ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                child: _state.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
              const SizedBox(height: AppSpacing.space16),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CantSignInPage()),
                ),
                child: const Text("Can't sign in?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The failure banner, coloured and worded per outcome.
class _FailureNotice extends StatelessWidget {
  const _FailureNotice({required this.state});

  final SignInState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    final (tone, title, detail) = switch (state.status) {
      SignInStatus.invalidCredentials => (
        colors.danger,
        'Check your PIN',
        'That driver code and PIN do not match. Check both and try again.',
      ),
      SignInStatus.locked => (
        colors.danger,
        'Too many attempts',
        state.retryAfter == null
            ? 'This account is locked. Call operations to unlock it.'
            : 'Locked for ${_minutes(state.retryAfter!)}. Call operations if you need in sooner.',
      ),
      SignInStatus.suspended => (
        colors.warning,
        'Account suspended',
        state.message ?? 'Contact operations.',
      ),
      SignInStatus.offline => (
        colors.warning,
        'No connection',
        'You are offline. Sign-in needs a connection, so try again once you have signal.',
      ),
      _ => (colors.danger, 'Could not sign in', state.message ?? 'Please try again.'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: tone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.label.copyWith(color: tone)),
          const SizedBox(height: AppSpacing.space4),
          Text(detail, style: AppTypography.bodySmall.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }

  /// Round a lock window up to whole minutes, because "locked for 43 seconds"
  /// invites a driver to stand there counting.
  static String _minutes(Duration duration) {
    final minutes = (duration.inSeconds / 60).ceil();
    return minutes <= 1 ? 'a minute' : '$minutes minutes';
  }
}

/// "Remember this device", which picks the session length and nothing else.
class _RememberDeviceToggle extends StatelessWidget {
  const _RememberDeviceToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: AppRadii.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space8),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: (next) => onChanged(next ?? false)),
            const SizedBox(width: AppSpacing.space8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remember this device',
                    style: AppTypography.body.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    'Leave this off on a shared vehicle phone. Your session then '
                    'ends with the shift instead of lasting a month.',
                    style: AppTypography.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
