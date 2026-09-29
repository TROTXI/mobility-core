import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

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
    if (!RegExp(
      r'^(0[235]\d{8}|\+?233[235]\d{8})$',
    ).hasMatch(phone.replaceAll(' ', ''))) {
      setState(
        () => _error = 'Enter a Ghana mobile number, such as 0241234567.',
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
      await widget.client.signInPhone(_challenge!, _code.text);
      // The app root replaces the navigator after a successful sign-in.
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
    return Scaffold(
      appBar: AppBar(title: const Text('Continue with phone')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign in with your phone',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text('We’ll send a six-digit code to your mobile number.'),
            const SizedBox(height: 24),
            TextField(
              controller: _phone,
              enabled: !_busy && _challenge == null,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              maxLength: 32,
              decoration: const InputDecoration(
                labelText: 'Ghana mobile number',
                hintText: '0241234567',
              ),
            ),
            if (_challenge != null) ...[
              const Text(
                'Enter the code sent by SMS. It expires after five minutes. Never share it.',
              ),
              TextField(
                controller: _code,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Six-digit code'),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
            ElevatedButton(
              onPressed: _busy ? null : (_challenge == null ? _send : _verify),
              child: Text(
                _busy
                    ? 'Please wait…'
                    : _challenge == null
                    ? 'Send code'
                    : 'Verify and continue',
              ),
            ),
            if (_challenge != null) ...[
              TextButton(
                onPressed: _busy || _wait > 0 ? null : _send,
                child: Text(_wait > 0 ? 'Resend in ${_wait}s' : 'Resend code'),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () {
                        setState(() {
                          _challenge = null;
                          _code.clear();
                          _error = null;
                        });
                      },
                child: const Text('Use another number'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
