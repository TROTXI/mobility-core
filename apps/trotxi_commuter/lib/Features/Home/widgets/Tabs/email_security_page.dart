import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/auth/password_policy.dart';
import 'package:trotxi_commuter/core/auth/password_requirements.dart';

class EmailSecurityPage extends StatefulWidget {
  const EmailSecurityPage({super.key, required this.client});
  final CommuterApi client;
  @override
  State<EmailSecurityPage> createState() => _EmailSecurityPageState();
}

class _EmailSecurityPageState extends State<EmailSecurityPage>
    with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(),
      _code = TextEditingController(),
      _old = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  bool _loading = true,
      _enabled = false,
      _verified = false,
      _sent = false,
      _checking = false,
      _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _password.addListener(_refreshPasswordRequirements);
    _confirm.addListener(_refreshPasswordRequirements);
    _load();
  }

  void _refreshPasswordRequirements() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_loading && !_verified) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_checking) return;
    if (_loading) {
      _checking = true;
    } else {
      setState(() => _checking = true);
    }
    try {
      final status = await widget.client.emailAccess();
      if (mounted) {
        setState(() {
          _error = null;
          _enabled = status.passwordEnabled;
          _verified = status.emailVerified;
          _email.text =
              status.email ?? widget.client.currentAccount?.email ?? '';
        });
      }
    } on TrotxiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load account security.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _checking = false;
        });
      }
    }
  }

  Future<void> _verifyEmail() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await widget.client.resendContactEmail();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } on TrotxiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _password.removeListener(_refreshPasswordRequirements);
    _confirm.removeListener(_refreshPasswordRequirements);
    for (final c in [_email, _code, _old, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_enabled) {
        await widget.client.changePassword(_old.text, _password.text);
      } else if (_sent) {
        await widget.client.finishEmailLink(_code.text.trim(), _password.text);
      } else {
        await widget.client.startEmailLink(_email.text.trim());
        if (mounted) setState(() => _sent = true);
      }
    } on TrotxiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not update account security. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Security & recovery')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    _enabled
                        ? 'Manage your contact email and password. A password change signs out all devices.'
                        : 'Add an email and password to this account without creating a second account.',
                  ),
                  if (_enabled && !_verified) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Your email is not verified yet. Verify it to use password recovery and receive important updates.',
                    ),
                    TextButton(
                      onPressed: _busy || _checking ? null : _verifyEmail,
                      child: const Text('Send email verification link'),
                    ),
                    TextButton(
                      onPressed: _busy || _checking ? null : _load,
                      child: Text(
                        _checking
                            ? 'Checking email status...'
                            : "I've verified my email",
                      ),
                    ),
                  ],
                  if (_enabled && _verified) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Contact email verified. You can use it for account recovery.',
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    _enabled
                        ? 'Changing your password requires a sign-in from the last 15 minutes.'
                        : 'Email setup requires a recent sign-in. The verification code works for 30 minutes in this session.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    enabled: !_busy && !_enabled && !_sent,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                    validator: (v) => v == null || !v.contains('@')
                        ? 'Enter a valid email'
                        : null,
                  ),
                  if (_sent) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Paste the verification code from your email. The code works only in this sign-in session.',
                    ),
                    TextFormField(
                      controller: _code,
                      enabled: !_busy,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                      ),
                      validator: (v) => v == null || v.trim().length != 43
                          ? 'Paste the complete code'
                          : null,
                    ),
                  ],
                  if (_enabled)
                    TextFormField(
                      controller: _old,
                      enabled: !_busy,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Current password',
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Enter your current password'
                          : null,
                    ),
                  if (_enabled || _sent) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      enabled: !_busy,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.newPassword],
                      maxLength: 128,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        counterText: '',
                      ),
                      validator: validateNewPassword,
                    ),
                    PasswordRequirements(password: _password.text),
                    TextFormField(
                      controller: _confirm,
                      enabled: !_busy,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                      ),
                      validator: (v) =>
                          v != _password.text ? 'Passwords do not match' : null,
                    ),
                    if (_confirm.text.isNotEmpty)
                      Text(
                        _confirm.text == _password.text
                            ? 'Passwords match'
                            : 'Passwords do not match yet',
                        style: TextStyle(
                          color: _confirm.text == _password.text
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(_error!),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:
                        _busy ||
                            ((_enabled || _sent) &&
                                (validateNewPassword(_password.text) != null ||
                                    _confirm.text != _password.text))
                        ? null
                        : _submit,
                    child: Text(
                      _busy
                          ? 'Please wait...'
                          : _enabled || _sent
                          ? 'Save password and sign out'
                          : 'Send verification email',
                    ),
                  ),
                  if (_sent)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              setState(() => _sent = false);
                            },
                      child: const Text('Request another code'),
                    ),
                ],
              ),
            ),
          ),
  );
}
