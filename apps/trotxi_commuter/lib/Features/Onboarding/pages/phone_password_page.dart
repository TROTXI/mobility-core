import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/auth/password_policy.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_spacing.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/widgets/public_information_links.dart';

enum _Step { signIn, signUp, code, finish, reset }

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
  DateTime? _expiresAt;
  DateTime? _resendAt;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _password.addListener(_refreshPasswordChecklist);
  }

  void _refreshPasswordChecklist() {
    if (mounted && (_step == _Step.signUp || _step == _Step.finish)) {
      setState(() {});
    }
  }

  int get _wait =>
      ((_resendAt?.difference(DateTime.now()).inSeconds ?? 0)).clamp(0, 60);

  @override
  void dispose() {
    _ticker?.cancel();
    _password.removeListener(_refreshPasswordChecklist);
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

  Future<void> _sendCode() async {
    if (_busy || _wait > 0) return;
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
          // Keep the entered details in memory while the phone is verified.
          // Never create a commuter account before the SMS challenge succeeds.
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
          counterText: '',
          filled: true,
          fillColor: context.appColors.surfaceElevated,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _passwordChecklist(BuildContext context) {
    final value = _password.text;
    final rules = [
      ('12 to 128 characters', value.runes.length >= 12 && value.length <= 128),
      ('Capital letter', RegExp(r'[A-Z]').hasMatch(value)),
      ('Number', RegExp(r'[0-9]').hasMatch(value)),
      (
        'Symbol',
        RegExp(r'[\x21-\x2f\x3a-\x40\x5b-\x60\x7b-\x7e]').hasMatch(value),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final (label, valid) in rules)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  valid ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: valid
                      ? context.appColors.actionPrimaryDefault
                      : context.appColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(label, style: AppTypography.caption),
              ],
            ),
        ],
      ),
    );
  }

  Widget _signupProgress(BuildContext context) {
    final current = _step == _Step.signUp ? 0 : 1;
    const labels = ['Your details', 'Phone verification'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: LinearProgressIndicator(
                    value: i <= current ? 1 : 0,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Step ${current + 1} of 2 · ${labels[current]}',
              style: AppTypography.caption.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
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
      _Step.signUp || _Step.finish => 'Create your account',
      _Step.code => 'Verify your phone',
      _Step.reset => 'Reset password',
    };
    return Scaffold(
      backgroundColor: AppPrimitiveColors.authPage(brightness),
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_step == _Step.signUp ||
                            _step == _Step.code ||
                            _step == _Step.finish)
                          _signupProgress(context),
                        Text(
                          title,
                          style: AppTypography.heading1.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space12),
                        Text(
                          switch (_step) {
                            _Step.signIn =>
                              'Use your verified phone number and password.',
                            _Step.signUp =>
                              'Enter your details, then verify your phone by SMS.',
                            _Step.code =>
                              'Enter the six-digit code sent to ${_phone.text.trim()}.',
                            _Step.finish =>
                              'Phone verified. Complete your details to finish signup.',
                            _Step.reset =>
                              'We will send a reset link to your verified contact email.',
                          },
                          style: AppTypography.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space24),
                        if (_step == _Step.signUp || _step == _Step.finish) ...[
                          Text(
                            'Personal details',
                            style: AppTypography.title.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_step == _Step.signUp || _step == _Step.finish) ...[
                          _input('First name', _first, validator: _required),
                          _input('Last name', _last, validator: _required),
                          _input('Other names (optional)', _other),
                        ],
                        if (_step == _Step.signIn || _step == _Step.signUp)
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
                            _step == _Step.signUp ||
                            _step == _Step.finish) ...[
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
                            _passwordChecklist(context),
                        ],
                        if (_step == _Step.signUp || _step == _Step.finish)
                          _input(
                            'Confirm password',
                            _confirm,
                            secret: true,
                            maxLength: 128,
                            validator: (value) => value == _password.text
                                ? null
                                : 'Passwords do not match.',
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
                              color: colors.error.withValues(alpha: 0.10),
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
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _busy ? null : _submit,
                            child: Text(
                              _busy
                                  ? 'Please wait…'
                                  : switch (_step) {
                                      _Step.signIn => 'Sign in',
                                      _Step.signUp => 'Send verification code',
                                      _Step.code => 'Verify and create account',
                                      _Step.finish => 'Complete signup',
                                      _Step.reset => 'Send reset link',
                                    },
                            ),
                          ),
                        ),
                        if (_step == _Step.code) ...[
                          TextButton(
                            onPressed: _busy || _wait > 0 ? null : _sendCode,
                            child: Text(
                              _wait > 0 ? 'Resend in ${_wait}s' : 'Resend code',
                            ),
                          ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _change(_Step.signUp),
                            child: const Text('Change phone number'),
                          ),
                        ],
                        if (_step == _Step.signIn) ...[
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _change(_Step.reset),
                            child: const Text('Forgot password?'),
                          ),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _change(_Step.signUp),
                            child: const Text('Create an account'),
                          ),
                        ] else if (_step == _Step.reset) ...[
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _change(_Step.signIn),
                            child: const Text('Back to sign in'),
                          ),
                        ],
                        if (_step == _Step.signUp || _step == _Step.finish)
                          const PublicInformationLinks(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
