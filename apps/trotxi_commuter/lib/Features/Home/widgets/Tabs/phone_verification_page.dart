import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/widgets/app_surfaces.dart';
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
  bool _editing = false;

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
        _editing = result.status.name != 'verified';
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
    final enteringCode = _challengeId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(enteringCode ? 'Verify your number' : 'Phone number'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              children: [
                AppPageHeading(
                  title: enteringCode
                      ? 'Check your messages.'
                      : verified
                      ? 'Phone verified'
                      : 'Your sign-in number.',
                  subtitle: enteringCode
                      ? 'Enter the six-digit code sent to ${_phone.text.trim()}.'
                      : 'Use your verified phone number and password to sign in.',
                ),
                const SizedBox(height: 24),
                if (_status == null && _message == null)
                  const Center(child: CircularProgressIndicator()),
                if (verified && !enteringCode) ...[
                  AppSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: colors.actionPrimaryDefault,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CURRENT NUMBER',
                                    style: AppTypography.caption.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
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
                        const SizedBox(height: 16),
                        AppStatusBadge(
                          label: 'Verified',
                          color: colors.success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_editing) ...[
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _editing = true),
                      child: const Text('Change phone number'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your current number stays in place until you verify the new one.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
                if (_status != null &&
                    (!verified || _editing) &&
                    !enteringCode) ...[
                  TextField(
                    controller: _phone,
                    enabled: !_busy,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: InputDecoration(
                      labelText: verified
                          ? 'New mobile number'
                          : 'Mobile number',
                      hintText: '024 123 4567',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _send,
                    child: Text(verified ? 'Verify new number' : 'Send code'),
                  ),
                  if (verified)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _editing = false),
                      child: const Text('Keep current number'),
                    ),
                ],
                if (enteringCode) ...[
                  TextField(
                    controller: _code,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Six-digit code',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy || _code.text.length != 6
                        ? null
                        : _confirm,
                    child: const Text('Confirm code'),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _challengeId = null;
                            _code.clear();
                            _message = null;
                            _editing = true;
                          }),
                    child: const Text('Change phone number'),
                  ),
                ],
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _message!,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  if (_status == null)
                    TextButton(onPressed: _refresh, child: const Text('Retry')),
                ],
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
