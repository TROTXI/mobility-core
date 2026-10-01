import 'package:flutter/material.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';

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
    final phone = _status?.phone;
    final verified = phone?.status.name == 'verified';
    return Scaffold(
      appBar: AppBar(title: const Text('Verify phone')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            verified ? 'Phone verified' : 'Verify your Ghana mobile number',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            verified
                ? 'Current number: ${phone?.maskedNumber ?? 'verified'}'
                : 'We’ll text a code to the number you enter. This verifies possession of the phone, not Ghana Card identity.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            decoration: InputDecoration(
              labelText: verified
                  ? 'New Ghana mobile number'
                  : 'Ghana mobile number',
              hintText: '024 123 4567',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _send,
            child: Text(verified ? 'Verify a new number' : 'Send code'),
          ),
          if (_challengeId != null) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: const InputDecoration(labelText: 'Six-digit code'),
            ),
            FilledButton(
              onPressed: _busy ? null : _confirm,
              child: const Text('Confirm code'),
            ),
          ],
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, semanticsLabel: _message),
          ],
          if (_busy) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
