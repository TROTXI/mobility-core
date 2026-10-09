import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_spacing.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

enum _PhoneStep { phone, code }

/// One flow for sign-up and sign-in. A returning commuter goes phone → code →
/// app. A first-time commuter (the API names them "New commuter") is then sent
/// to FullNamePage by the app root.
///
/// OTP inputs are transient: never saved to preferences, analytics or logs.
class PhoneSignInPage extends StatefulWidget {
  const PhoneSignInPage({super.key, required this.client});
  final CommuterApi client;
  @override
  State<PhoneSignInPage> createState() => _PhoneSignInPageState();
}

class _PhoneSignInPageState extends State<PhoneSignInPage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  Timer? _timer;
  _PhoneStep _step = _PhoneStep.phone;
  String? _challenge, _error;
  DateTime? _expires, _resendAt;
  bool _busy = false;
  int get _wait =>
      ((_resendAt?.difference(DateTime.now()).inMilliseconds ?? 0) / 1000)
          .ceil()
          .clamp(0, 60);

  Future<void> _send() async {
    if (_busy || _wait > 0) return;
    final phone = _phone.text.trim();
    if (!RegExp(r'^0[25]\d{8}$').hasMatch(phone)) {
      setState(
        () => _error =
            'Enter a Ghana mobile number: 10 digits starting with 02 or 05, such as 0241234567.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final challenge = await widget.client.requestPhoneCode(phone);
      if (!mounted) return;
      setState(() {
        _step = _PhoneStep.code;
        _challenge = challenge.challengeId;
        _expires = challenge.expiresAt;
        _resendAt = DateTime.now().add(
          Duration(seconds: challenge.resendAfterSeconds),
        );
        _code.clear();
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } on TrotxiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not send a code. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_busy || _challenge == null) return;
    if (_code.text.length != 6) {
      setState(() => _error = 'Enter the six-digit code.');
      return;
    }
    if (_expires != null && !DateTime.now().isBefore(_expires!)) {
      setState(() => _error = 'This code expired. Request a new one.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final account = await widget.client.verifyPhone(_challenge!, _code.text);
      if (!mounted) return;
      // The app root swaps this page out. A first-time rider (placeholder
      // name) lands on FullNamePage before reaching Home.
      widget.client.completeSignIn(account);
    } on TrotxiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not verify the code. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _changeNumber() {
    setState(() {
      _step = _PhoneStep.phone;
      _challenge = null;
      _code.clear();
      _error = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppPrimitiveColors.authPage(brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: colors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                switch (_step) {
                  _PhoneStep.phone => 'Continue with phone',
                  _PhoneStep.code => 'Enter the code',
                },
                textAlign: TextAlign.center,
                style: AppTypography.heading1.copyWith(
                  color: colors.textPrimary,
                  fontSize: 27,
                  height: 34 / 27,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.space12),
              Text(
                switch (_step) {
                  _PhoneStep.phone =>
                    'Sign in or create your account. We’ll text a six-digit code to your mobile number.',
                  _PhoneStep.code =>
                    'We sent a code to ${_phone.text.trim()}. It expires after five minutes. Never share it.',
                },
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: colors.textSecondary,
                  fontSize: 14.5,
                  height: 22 / 14.5,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  border: Border.all(color: colors.borderSubtle),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _field(context),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.space20),
                    _primaryButton(context),
                    if (_step == _PhoneStep.code) ...[
                      const SizedBox(height: AppSpacing.space8),
                      TextButton(
                        onPressed: _busy || _wait > 0 ? null : _send,
                        child: Text(
                          _wait > 0 ? 'Resend in ${_wait}s' : 'Resend code',
                        ),
                      ),
                      TextButton(
                        onPressed: _busy ? null : _changeNumber,
                        child: const Text('Use another number'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(BuildContext context) {
    final colors = context.appColors;
    final decoration = InputDecoration(
      filled: true,
      fillColor: colors.backgroundDefault,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.actionPrimaryDefault, width: 1.5),
      ),
    );
    return switch (_step) {
      _PhoneStep.phone => TextField(
        key: const ValueKey('phone-field'),
        controller: _phone,
        enabled: !_busy,
        autofocus: true,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.telephoneNumber],
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _send(),
        decoration: decoration.copyWith(
          labelText: 'Ghana mobile number',
          hintText: '0241234567',
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
      ),
      _PhoneStep.code => TextField(
        key: const ValueKey('code-field'),
        controller: _code,
        enabled: !_busy,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.center,
        autofillHints: const [AutofillHints.oneTimeCode],
        maxLength: 6,
        style: AppTypography.heading1.copyWith(
          color: colors.textPrimary,
          letterSpacing: 8,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _verify(),
        decoration: decoration.copyWith(hintText: '••••••'),
      ),
    };
  }

  Widget _primaryButton(BuildContext context) {
    final colors = context.appColors;
    final label = _busy
        ? 'Please wait…'
        : switch (_step) {
            _PhoneStep.phone => 'Send code',
            _PhoneStep.code => 'Verify',
          };
    return FilledButton(
      onPressed: _busy
          ? null
          : switch (_step) {
              _PhoneStep.phone => _send,
              _PhoneStep.code => _verify,
            },
      style: FilledButton.styleFrom(
        backgroundColor: colors.actionPrimaryDefault,
        foregroundColor: Colors.white,
        disabledBackgroundColor: colors.actionPrimaryDisabled,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
