import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_driver/Presentations/Auth/models/sign_in_state.dart';
import 'package:trotxi_driver/Presentations/Auth/pages/cant_sign_in_page.dart';
import 'package:trotxi_driver/core/widgets/driver_note.dart';
import 'package:trotxi_driver/core/widgets/trotxi_wordmark.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/driver_auth_repository.dart';

/// Driver sign-in (design page 05, frames "Sign in" and "Invalid PIN").
///
/// The code and PIN are issued by operations; there is no self-service recovery,
/// which is why "Can't sign in?" leads to a page that tells the driver who to
/// call rather than to a reset form.
///
/// Two existing differences from the design remain:
///
/// The PIN is SIX digits. `driver-auth.schema.ts` rejects anything else, and
/// the frames label it "4-digit". Changing that contract requires a separate
/// credential decision; it is not part of removing forced PIN setup.
///
/// The field is called "Driver code", not "Driver ID". The placeholder the file
/// itself draws is `TRX-DR-0248`, which is what operations prints on a slip and
/// calls a code everywhere else in this product.
///
/// The error state is the same screen, not a different one: the file keeps the
/// entered code, thickens the PIN field's border and adds one line underneath.
/// A driver who mistypes should not lose what they got right.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.auth, required this.onSignedIn});

  final DriverAuthRepository auth;

  /// Called once a session exists. The caller shows account confirmation
  /// before opening the driver's assigned runs.
  final ValueChanged<DriverSession> onSignedIn;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();
  bool _rememberDevice = false;
  bool _pinVisible = false;
  SignInState _state = SignInState.idle;

  @override
  void initState() {
    super.initState();
    // Any edit clears the previous failure, so the driver is not still reading
    // "check your PIN" while typing a different one.
    _codeController.addListener(_clearFailure);
    _pinController.addListener(_onPinChanged);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  /// A completed PIN submits itself. The file draws a button, but a driver
  /// typing one-handed at a depot gate should not then have to find it, and
  /// this is what the PIN boxes did before this screen matched the frames.
  void _onPinChanged() {
    _clearFailure();
    if (_pinController.text.length == _pinDigits && _canSubmit) {
      unawaited(_submit());
    }
  }

  void _clearFailure() {
    if (_state.status == SignInStatus.idle || _state.isSubmitting) return;
    // A lock and a suspension survive editing: they are not about what was
    // typed, and clearing them would suggest another go might work.
    if (!_state.isRetryable) return;
    setState(() => _state = SignInState.idle);
  }

  /// What the API accepts, not what the frames label. See the class doc.
  static const int _pinDigits = 6;

  bool get _canSubmit =>
      _codeController.text.trim().length >= 4 &&
      _pinController.text.length == _pinDigits &&
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
      _fail(
        SignInState(status: SignInStatus.locked, retryAfter: err.retryAfter),
      );
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
    final editable = _state.isRetryable && !_state.isSubmitting;

    // The file draws the credential failure as this screen with a thicker PIN
    // border and one line underneath, which keeps the typed code. The states it
    // never drew — a lock, a suspension, no connection — carry a retry window
    // or an instruction to ring operations, and none of that survives being
    // squeezed into a 10px line, so those keep the card.
    final inlineError = _state.status == SignInStatus.invalidCredentials;
    final showCard =
        _state.status != SignInStatus.idle &&
        !_state.isSubmitting &&
        !inlineError;

    final pinBorder = OutlineInputBorder(
      borderRadius: AppRadii.circular(AppRadii.field),
      borderSide: BorderSide(color: colors.danger, width: 2),
    );

    return Scaffold(
      body: SafeArea(
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space20,
              AppSpacing.space32,
              AppSpacing.space20,
              AppSpacing.space32,
            ),
            children: [
              const Center(child: TrotxiWordmark()),
              const SizedBox(height: AppSpacing.space40),

              Text(
                inlineError ? 'Check your PIN' : 'Sign in',
                textAlign: TextAlign.center,
                style: AppTypography.screenTitle.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                inlineError
                    ? 'The PIN did not match this driver account.'
                    : 'Use the driver code and PIN provided by your operator.',
                textAlign: TextAlign.center,
                style: AppTypography.screenContext.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space40),

              _FieldLabel('Driver code'),
              const SizedBox(height: AppSpacing.space8),
              TextField(
                controller: _codeController,
                enabled: editable,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                style: AppTypography.fieldText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
                // The server normalises case and the DR- prefix, so anything the
                // driver reads off a slip of paper is accepted as typed.
                //
                // The file draws `TRX-DR-0248` here. Not copied: a placeholder
                // shaped like a real value reads as one already filled in, and
                // that particular value contradicts the format this app's own
                // recovery page teaches ("starts with DR-, four characters
                // after it"). An instruction cannot be mistaken for an entry.
                decoration: const InputDecoration(
                  hintText: 'Enter driver code',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
                  LengthLimitingTextInputFormatter(12),
                ],
              ),
              const SizedBox(height: AppSpacing.space24),

              _FieldLabel('$_pinDigits-digit PIN'),
              const SizedBox(height: AppSpacing.space8),
              TextField(
                controller: _pinController,
                enabled: editable,
                obscureText: !_pinVisible,
                keyboardType: TextInputType.number,
                autocorrect: false,
                enableSuggestions: false,
                onSubmitted: (_) => _submit(),
                style: AppTypography.fieldText.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                  letterSpacing: _pinVisible ? 2 : 4,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_pinDigits),
                ],
                decoration: InputDecoration(
                  hintText: '\u2022' * _pinDigits,
                  enabledBorder: _state.highlightsPin ? pinBorder : null,
                  focusedBorder: _state.highlightsPin ? pinBorder : null,
                  // Held rather than toggled would be better on a phone in one
                  // hand, but a driver checking a PIN they mistyped needs it to
                  // stay visible while they read it off the slip again.
                  suffixIcon: IconButton(
                    onPressed: editable
                        ? () => setState(() => _pinVisible = !_pinVisible)
                        : null,
                    icon: Icon(
                      _pinVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    tooltip: _pinVisible ? 'Hide PIN' : 'Show PIN',
                  ),
                ),
              ),

              if (inlineError) ...[
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'PIN not recognised. Check the $_pinDigits digits, or ask '
                  'operations for a new PIN.',
                  style: AppTypography.footnote.copyWith(color: colors.danger),
                ),
              ],
              if (showCard) ...[
                const SizedBox(height: AppSpacing.space8),
                _FailureNotice(state: _state),
              ],

              const SizedBox(height: AppSpacing.space12),
              _RememberDeviceToggle(
                value: _rememberDevice,
                onChanged: (value) => setState(() => _rememberDevice = value),
              ),
              const SizedBox(height: AppSpacing.space24),

              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: colors.action,
                  foregroundColor: colors.onAction,
                  textStyle: AppTypography.actionLabel,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.circular(AppRadii.pill),
                  ),
                ),
                child: _state.isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onAction,
                        ),
                      )
                    : Text(inlineError ? 'Try again' : 'Sign in'),
              ),
              const SizedBox(height: AppSpacing.space16),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CantSignInPage(),
                    ),
                  ),
                  child: Text(
                    "Can't sign in?",
                    style: AppTypography.fieldLabel.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              const DriverNote(
                title: 'Need access?',
                body:
                    'Ask your operator to link your driver account before '
                    'signing in.',
              ),
              const SizedBox(height: AppSpacing.space20),

              Text(
                'Your PIN is encrypted and is never shown to operations.',
                textAlign: TextAlign.center,
                style: AppTypography.footnote.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 12/600 label above an input, on every auth frame.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.fieldLabel.copyWith(
      color: context.driverColors.textPrimary,
    ),
  );
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
      _ => (
        colors.danger,
        'Could not sign in',
        state.message ?? 'Please try again.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: AppRadii.circular(AppRadii.note),
        border: Border.all(color: tone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.fieldLabel.copyWith(color: tone)),
          const SizedBox(height: AppSpacing.space2),
          Text(
            detail,
            style: AppTypography.footnote.copyWith(color: colors.textSecondary),
          ),
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
///
/// The file draws a bare 22px box and a label. The caption is kept anyway: a
/// vehicle phone passes between drivers, and leaving this on there hands the
/// next person a month-long session. That is a security outcome the frame does
/// not appear to have weighed, and one line of footnote is the cheapest place
/// to say it.
class _RememberDeviceToggle extends StatelessWidget {
  const _RememberDeviceToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Semantics(
      checked: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: AppRadii.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value ? colors.action : colors.surfaceStrong,
                  borderRadius: AppRadii.circular(7),
                  border: Border.all(color: colors.action),
                ),
                child: value
                    ? Icon(Icons.check, size: 15, color: colors.onAction)
                    : null,
              ),
              const SizedBox(width: AppSpacing.space10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remember this device',
                      style: AppTypography.screenContext.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Leave this off on a shared vehicle phone. Your session '
                      'then ends with the shift instead of lasting a month.',
                      style: AppTypography.footnote.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
