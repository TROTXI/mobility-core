import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Verifies possession of a Ghana mobile number on the signed-in account.
/// This never signs the rider out or merges another account.
class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({super.key, required this.client});
  final CommuterApi client;

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  VerificationStatus? _status;
  String? _challengeId;
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final generation = widget.client.sessionGeneration;
    try {
      final status = await widget.client.verificationStatus();
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() => _status = status);
    } catch (_) {
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() => _message = 'Could not load phone status. Please retry.');
    }
  }

  Future<void> _send() async {
    if (_busy) return;
    final generation = widget.client.sessionGeneration;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final challenge = await widget.client.startPhoneVerification(
        _phone.text.trim(),
      );
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() {
        _challengeId = challenge.challengeId;
        _message = 'We sent a six-digit code. It expires in five minutes.';
      });
    } on TrotxiException catch (error) {
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() => _message = error.message);
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _confirm() async {
    final challengeId = _challengeId;
    if (_busy || challengeId == null) return;
    final generation = widget.client.sessionGeneration;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await widget.client.confirmPhoneVerification(
        challengeId,
        _code.text.trim(),
      );
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() {
        _challengeId = null;
        _code.clear();
        _message = result.status.name == 'review'
            ? 'This number needs support review before it can be linked.'
            : 'Phone verified for this account.';
      });
      await _refresh();
    } on TrotxiException catch (error) {
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() => _message = error.message);
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final phone = _status?.phone;
    final verified = phone?.status.name == 'verified';
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(title: const Text('Phone number')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                Text(
                  verified ? 'Phone verified' : 'Verify your phone',
                  style: AppTypography.heading2.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  verified
                      ? 'Your verified number helps keep your account and rides secure.'
                      : 'We’ll text you a six-digit code to confirm this number.',
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (verified) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      border: Border.all(color: colors.borderSubtle),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_rounded, color: colors.success),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verified number',
                                style: AppTypography.caption.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                              Text(
                                phone?.maskedNumber ?? 'Verified',
                                style: AppTypography.title.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  verified ? 'Change number' : 'Your number',
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  verified
                      ? 'Enter a new number and verify it before we update your account.'
                      : 'Use a Ghana mobile number you can receive texts on.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(
                    labelText: verified ? 'New mobile number' : 'Mobile number',
                    hintText: '024 123 4567',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _send,
                    child: Text(verified ? 'Verify new number' : 'Send code'),
                  ),
                ),
                if (_challengeId != null) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Enter your code',
                    style: AppTypography.title.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _code,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    decoration: InputDecoration(
                      labelText: 'Six-digit code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _confirm,
                      child: const Text('Confirm code'),
                    ),
                  ),
                ],
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _message!,
                    semanticsLabel: _message,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                if (_busy) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
