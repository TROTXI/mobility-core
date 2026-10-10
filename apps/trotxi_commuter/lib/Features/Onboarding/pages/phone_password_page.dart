import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/auth/password_policy.dart';
import 'package:trotxi_commuter/core/auth/password_requirements.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/widgets/public_information_links.dart';

enum _Step { signIn, signUp, credentials, code, finish, reset }

/// One public commuter entry point. The password never leaves this form except
/// in the TLS registration or sign-in request and is never persisted locally.
class PhonePasswordPage extends StatefulWidget {
  const PhonePasswordPage({
    super.key,
    required this.client,
    this.signup = false,
    this.resume = false,
  });

  final CommuterApi client;
  final bool signup;
  final bool resume;

  @override
  State<PhonePasswordPage> createState() => _PhonePasswordPageState();
}

class _PhonePasswordPageState extends State<PhonePasswordPage> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _other = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();
  late _Step _step = widget.resume
      ? _Step.finish
      : widget.signup
      ? _Step.signUp
      : _Step.signIn;
  bool _busy = false;
  bool _showPassword = false;
  String? _error;
  String? _message;
  String? _challengeId;
  String? _challengePhone;
  DateTime? _expiresAt;
  DateTime? _resendAt;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _password.addListener(_refreshPasswordChecklist);
    _confirm.addListener(_refreshPasswordChecklist);
  }

  void _refreshPasswordChecklist() {
    if (mounted && (_step == _Step.credentials || _step == _Step.finish)) {
      setState(() {});
    }
  }

  int get _wait =>
      ((_resendAt?.difference(DateTime.now()).inSeconds ?? 0)).clamp(0, 60);

  @override
  void dispose() {
    _ticker?.cancel();
    _password.removeListener(_refreshPasswordChecklist);
    _confirm.removeListener(_refreshPasswordChecklist);
    for (final controller in [
      _first,
      _last,
      _other,
      _phone,
      _email,
      _password,
      _confirm,
      _code,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _change(_Step step) {
    setState(() {
      _step = step;
      _error = null;
      _message = null;
      _password.clear();
      _confirm.clear();
    });
  }

  void _showStep(_Step step) {
    setState(() {
      _step = step;
      _error = null;
      _message = null;
    });
  }

  Future<void> _back() async {
    if (_busy) return;
    switch (_step) {
      case _Step.credentials:
        _showStep(_Step.signUp);
        return;
      case _Step.code:
        _showStep(_Step.credentials);
        return;
      case _Step.reset:
        _change(_Step.signIn);
        return;
      case _Step.finish:
        await widget.client.auth.signOut();
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        return;
      case _Step.signIn:
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        return;
      case _Step.signUp:
        if (!widget.signup) {
          _change(_Step.signIn);
          return;
        }
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        return;
    }
  }

  Future<void> _sendCode() async {
    if (_busy || (_wait > 0 && _challengePhone == _phone.text.trim())) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final challenge = await widget.client.requestPhoneCode(
        _phone.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _challengeId = challenge.challengeId;
        _challengePhone = _phone.text.trim();
        _expiresAt = challenge.expiresAt;
        _resendAt = DateTime.now().add(
          Duration(seconds: challenge.resendAfterSeconds),
        );
        _step = _Step.code;
        _code.clear();
      });
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } on TrotxiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not send a code. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      switch (_step) {
        case _Step.signIn:
          await widget.client.signInPhonePassword(
            _phone.text.trim(),
            _password.text,
          );
          TextInput.finishAutofillContext();
          break;
        case _Step.signUp:
          _showStep(_Step.credentials);
          break;
        case _Step.credentials:
          // Keep the details in memory. Create the account only after the SMS
          // challenge succeeds, and reuse a valid challenge after navigating back.
          if (_challengeId != null &&
              _challengePhone == _phone.text.trim() &&
              _expiresAt != null &&
              DateTime.now().isBefore(_expiresAt!)) {
            _showStep(_Step.code);
            break;
          }
          setState(() => _busy = false);
          await _sendCode();
          return;
        case _Step.code:
          if (_challengeId == null ||
              (_expiresAt != null && !DateTime.now().isBefore(_expiresAt!))) {
            setState(() => _error = 'This code expired. Request a new one.');
            return;
          }
          final account = await widget.client.verifyPhone(
            _challengeId!,
            _code.text,
          );
          if (account.phoneRegistrationPending != true) {
            await widget.client.auth.signOut();
            if (mounted) _showExistingAccount();
            return;
          }
          await _finishRegistration();
          break;
        case _Step.finish:
          await _finishRegistration();
          break;
        case _Step.reset:
          final message = await widget.client.auth.requestPasswordReset(
            _email.text.trim(),
          );
          if (mounted) setState(() => _message = message);
          break;
      }
    } on TrotxiException catch (error) {
      if (mounted) {
        if (_step == _Step.code &&
            error is ApiException &&
            error.code == 'password_required') {
          _showExistingAccount();
        } else {
          setState(() => _error = error.message);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not connect. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showExistingAccount() {
    setState(() {
      _step = _Step.signIn;
      _challengeId = null;
      _challengePhone = null;
      _code.clear();
      _password.clear();
      _confirm.clear();
      _error =
          'This number already has an account. Sign in with your password.';
    });
  }

  Future<void> _finishRegistration() async {
    try {
      await widget.client.finishPhoneRegistration(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        otherNames: _other.text.trim().isEmpty ? null : _other.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      TextInput.finishAutofillContext();
      if (!mounted) return;
      setState(() {
        _step = _Step.signIn;
        _password.clear();
        _confirm.clear();
        _message =
            'Account created. Sign in with your phone and password. Check your email to verify your contact address.';
      });
    } on TrotxiException {
      if (mounted) setState(() => _step = _Step.finish);
      rethrow;
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _phoneCheck(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'[ ()-]'), '');
    return RegExp(r'^(0[25]\d{8}|\+?233[25]\d{8})$').hasMatch(phone)
        ? null
        : 'Enter a Ghana mobile number, such as 0241234567 or +233241234567.';
  }

  String? _emailCheck(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
      ? null
      : 'Enter a valid email address.';

  Widget _input(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
    bool secret = false,
    int? maxLength,
  }) {
    final colors = context.appColors;
    final hint = switch (label) {
      'First name' => 'As on your ID',
      'Last name' => 'Family name',
      'Other names (optional)' => 'Middle name, if any',
      'Phone number' => '024 123 4567',
      'Email' => 'name@example.com',
      'Six-digit code' => '000000',
      _ => null,
    };
    final icon = switch (label) {
      'Phone number' => Icons.phone_outlined,
      'Email' => Icons.mail_outline_rounded,
      'Password' || 'Confirm password' => Icons.lock_outline_rounded,
      'Six-digit code' => Icons.sms_outlined,
      _ => null,
    };
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.borderSubtle),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: !_busy,
        keyboardType: keyboard,
        autofocus: label == 'Six-digit code',
        textCapitalization:
            label == 'First name' ||
                label == 'Last name' ||
                label == 'Other names (optional)'
            ? TextCapitalization.words
            : TextCapitalization.none,
        textInputAction:
            label == 'Six-digit code' ||
                label == 'Confirm password' ||
                (_step == _Step.signIn && label == 'Password')
            ? TextInputAction.done
            : TextInputAction.next,
        inputFormatters: label == 'Six-digit code'
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        validator: validator,
        maxLength: maxLength,
        obscureText: secret && !_showPassword,
        enableSuggestions: !secret,
        autocorrect: !secret,
        autofillHints: switch (label) {
          'Phone number' => const [AutofillHints.telephoneNumber],
          'Email' => const [AutofillHints.email],
          'Password' =>
            _step == _Step.signIn
                ? const [AutofillHints.password]
                : const [AutofillHints.newPassword],
          'Confirm password' => const [AutofillHints.newPassword],
          'Six-digit code' => const [AutofillHints.oneTimeCode],
          'First name' => const [AutofillHints.givenName],
          'Last name' => const [AutofillHints.familyName],
          _ => null,
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          counterText: '',
          filled: true,
          fillColor: colors.surfaceElevated,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: colors.actionPrimaryDefault,
              width: 2,
            ),
          ),
          errorBorder: border.copyWith(
            borderSide: BorderSide(color: colors.error),
          ),
          focusedErrorBorder: border.copyWith(
            borderSide: BorderSide(color: colors.error, width: 2),
          ),
          prefixIcon: icon == null
              ? null
              : Icon(icon, size: 20, color: colors.iconSubtle),
          suffixIcon: secret
              ? IconButton(
                  tooltip: _showPassword ? 'Hide password' : 'Show password',
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 0, 16),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: context.appColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _signupProgress(BuildContext context) {
    final colors = context.appColors;
    final current = switch (_step) {
      _Step.signUp => 0,
      _Step.credentials || _Step.finish => 1,
      _Step.code => 2,
      _ => 0,
    };
    const labels = ['Your details', 'Password', 'Phone verification'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'STEP ${current + 1} OF 3',
                style: AppTypography.caption.copyWith(
                  color: colors.actionPrimaryDefault,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                labels[current],
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: LinearProgressIndicator(
                    value: i <= current ? 1 : 0,
                    color: colors.actionPrimaryDefault,
                    backgroundColor: colors.borderSubtle,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final brightness = Theme.of(context).brightness;
    final title = switch (_step) {
      _Step.signIn => 'Sign in',
      _Step.signUp || _Step.credentials || _Step.finish => 'Create account',
      _Step.code => 'Verify your phone',
      _Step.reset => 'Reset password',
    };
    final heading = switch (_step) {
      _Step.signIn => 'Good to see you again.',
      _Step.signUp => 'Your details',
      _Step.credentials => 'Create a password',
      _Step.code => 'One last check',
      _Step.finish => 'Finish your account',
      _Step.reset => 'Reset your password',
    };
    final action = switch (_step) {
      _Step.signIn => 'Sign in',
      _Step.signUp => 'Continue',
      _Step.credentials => 'Send verification code',
      _Step.code => 'Verify and create account',
      _Step.finish => 'Complete signup',
      _Step.reset => 'Send reset link',
    };
    return PopScope(
      canPop:
          !_busy &&
          !widget.resume &&
          (_step == _Step.signIn || (_step == _Step.signUp && widget.signup)),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppPrimitiveColors.authPage(brightness),
        appBar: AppBar(
          backgroundColor: AppPrimitiveColors.authPage(brightness),
          scrolledUnderElevation: 0,
          title: Text(title),
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: _busy ? null : _back,
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: AutofillGroup(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_step == _Step.signUp ||
                                    _step == _Step.credentials ||
                                    _step == _Step.code ||
                                    _step == _Step.finish)
                                  _signupProgress(context),
                                Text(
                                  heading,
                                  style: AppTypography.heading1.copyWith(
                                    color: colors.textPrimary,
                                    letterSpacing: -0.9,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  switch (_step) {
                                    _Step.signIn =>
                                      'Sign in to see your trips, offers and ride updates.',
                                    _Step.signUp =>
                                      'Let us know who is joining the journey.',
                                    _Step.credentials =>
                                      'Keep your account safe with a password only you know.',
                                    _Step.code =>
                                      'Enter the six-digit code we sent to ${_phone.text.trim()}.',
                                    _Step.finish =>
                                      'Phone verified. Complete your details to finish signup.',
                                    _Step.reset =>
                                      'We will email a secure reset link to your verified address.',
                                  },
                                  style: AppTypography.body.copyWith(
                                    color: colors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                if (_step == _Step.signUp ||
                                    _step == _Step.finish) ...[
                                  _sectionLabel(context, 'Personal details'),
                                  _input(
                                    'First name',
                                    _first,
                                    validator: _required,
                                  ),
                                  _input(
                                    'Last name',
                                    _last,
                                    validator: _required,
                                  ),
                                  _input('Other names (optional)', _other),
                                  _sectionLabel(context, 'How we reach you'),
                                ],
                                if (_step == _Step.signIn ||
                                    _step == _Step.signUp)
                                  _input(
                                    'Phone number',
                                    _phone,
                                    validator: _phoneCheck,
                                    keyboard: TextInputType.phone,
                                    maxLength: 16,
                                  ),
                                if (_step == _Step.signUp ||
                                    _step == _Step.finish ||
                                    _step == _Step.reset)
                                  _input(
                                    'Email',
                                    _email,
                                    validator: _emailCheck,
                                    keyboard: TextInputType.emailAddress,
                                  ),
                                if (_step == _Step.signIn ||
                                    _step == _Step.credentials ||
                                    _step == _Step.finish) ...[
                                  if (_step == _Step.credentials ||
                                      _step == _Step.finish)
                                    _sectionLabel(context, 'Account security'),
                                  _input(
                                    'Password',
                                    _password,
                                    secret: true,
                                    maxLength: 128,
                                    validator: (value) => _step == _Step.signIn
                                        ? _required(value)
                                        : validateNewPassword(value),
                                  ),
                                  if (_step != _Step.signIn)
                                    PasswordRequirements(
                                      password: _password.text,
                                    ),
                                ],
                                if (_step == _Step.credentials ||
                                    _step == _Step.finish)
                                  _input(
                                    'Confirm password',
                                    _confirm,
                                    secret: true,
                                    maxLength: 128,
                                    validator: (value) =>
                                        value == _password.text
                                        ? null
                                        : 'Passwords do not match.',
                                  ),
                                if ((_step == _Step.credentials ||
                                        _step == _Step.finish) &&
                                    _confirm.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      _confirm.text == _password.text
                                          ? 'Passwords match'
                                          : 'Passwords do not match yet',
                                      style: AppTypography.caption.copyWith(
                                        color: _confirm.text == _password.text
                                            ? colors.actionPrimaryDefault
                                            : colors.error,
                                      ),
                                    ),
                                  ),
                                if (_step == _Step.code)
                                  _input(
                                    'Six-digit code',
                                    _code,
                                    validator: (value) =>
                                        RegExp(r'^\d{6}$').hasMatch(value ?? '')
                                        ? null
                                        : 'Enter the six-digit code.',
                                    keyboard: TextInputType.number,
                                    maxLength: 6,
                                  ),
                                if (_error != null) ...[
                                  Semantics(
                                    liveRegion: true,
                                    child: Card(
                                      color: colors.error.withValues(
                                        alpha: 0.10,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          _error!,
                                          style: TextStyle(color: colors.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (_message != null) ...[
                                  Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      _message!,
                                      style: TextStyle(
                                        color: colors.actionPrimaryDefault,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (_step == _Step.code) ...[
                                  TextButton(
                                    onPressed: _busy || _wait > 0
                                        ? null
                                        : _sendCode,
                                    child: Text(
                                      _wait > 0
                                          ? 'Resend in ${_wait}s'
                                          : 'Resend code',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _showStep(_Step.signUp),
                                    child: const Text('Change phone number'),
                                  ),
                                ],
                                if (_step == _Step.signIn) ...[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _change(_Step.reset),
                                      child: const Text('Forgot password?'),
                                    ),
                                  ),
                                ] else if (_step == _Step.reset) ...[
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _change(_Step.signIn),
                                    child: const Text('Back to sign in'),
                                  ),
                                ],
                                if (_step == _Step.signUp ||
                                    _step == _Step.credentials ||
                                    _step == _Step.finish) ...[
                                  Text(
                                    'Your information is used to set up your account and commute.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.caption.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const PublicInformationLinks(
                                    showDeletion: false,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    decoration: BoxDecoration(
                      color: AppPrimitiveColors.authPage(brightness),
                      border: Border(
                        top: BorderSide(color: colors.borderSubtle),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                onPressed:
                                    _busy ||
                                        ((_step == _Step.credentials ||
                                                _step == _Step.finish) &&
                                            (validateNewPassword(
                                                      _password.text,
                                                    ) !=
                                                    null ||
                                                _confirm.text !=
                                                    _password.text))
                                    ? null
                                    : _submit,
                                child: Text(_busy ? 'Please wait…' : action),
                              ),
                            ),
                            if (_step == _Step.signIn ||
                                _step == _Step.signUp) ...[
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () => _change(
                                        _step == _Step.signIn
                                            ? _Step.signUp
                                            : _Step.signIn,
                                      ),
                                child: Text(
                                  _step == _Step.signIn
                                      ? 'New to Trotxi? Create an account'
                                      : 'Already have an account? Sign in',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
