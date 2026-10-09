import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';

class FullNamePage extends StatefulWidget {
  const FullNamePage({
    super.key,
    required this.client,
    this.requiredForSignup = false,
  });
  final CommuterApi client;
  final bool requiredForSignup;
  @override
  State<FullNamePage> createState() => _FullNamePageState();
}

class _FullNamePageState extends State<FullNamePage> {
  final _form = GlobalKey<FormState>();
  late final _first = TextEditingController(
    text: widget.client.currentAccount?.firstName,
  );
  late final _last = TextEditingController(
    text: widget.client.currentAccount?.lastName,
  );
  late final _other = TextEditingController(
    text: widget.client.currentAccount?.otherNames,
  );
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _other.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.saveFullName(
        _first.text.trim(),
        _last.text.trim(),
        _other.text.trim().isEmpty ? null : _other.text.trim(),
      );
      if (mounted && !widget.requiredForSignup) Navigator.pop(context, true);
    } on TrotxiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save your name. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.requiredForSignup,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Your full name'),
        automaticallyImplyLeading: !widget.requiredForSignup,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Enter your full name so your driver and Trotxi support can recognise you.',
            ),
            const SizedBox(height: 24),
            Form(
              key: _form,
              child: AutofillGroup(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _first,
                      enabled: !_busy,
                      maxLength: 60,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.givenName],
                      decoration: const InputDecoration(
                        labelText: 'First name',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your first name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _other,
                      enabled: !_busy,
                      maxLength: 80,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.middleName],
                      decoration: const InputDecoration(
                        labelText: 'Other names (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _last,
                      enabled: !_busy,
                      maxLength: 60,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.familyName],
                      decoration: const InputDecoration(labelText: 'Last name'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your last name'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_error!, semanticsLabel: 'Error: $_error'),
              ),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save and continue'),
            ),
            if (widget.requiredForSignup)
              TextButton(
                onPressed: _busy ? null : widget.client.signOut,
                child: const Text('Sign out'),
              ),
          ],
        ),
      ),
    ),
  );
}
