import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/widgets/public_information_links.dart';

enum EmailMode { login, signup, reset }

class EmailSignInPage extends StatefulWidget {
  const EmailSignInPage({super.key, required this.client});
  final CommuterApi client;
  @override
  State<EmailSignInPage> createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(),
      _password = TextEditingController(),
      _first = TextEditingController(),
      _last = TextEditingController(),
      _other = TextEditingController();
  EmailMode _mode = EmailMode.login;
  bool _busy = false, _showPassword = false;
  String? _error, _message;
  @override
  void dispose() {
    for (final c in [_email, _password, _first, _last, _other]) {
      c.dispose();
    }
    super.dispose();
  }

  void _switch(EmailMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
      _message = null;
      _password.clear();
    });
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      if (_mode == EmailMode.login) {
        await widget.client.signInEmail(_email.text.trim(), _password.text);
        TextInput.finishAutofillContext();
      } else {
        final message = _mode == EmailMode.reset
            ? await widget.client.auth.requestPasswordReset(_email.text.trim())
            : await widget.client.auth.requestEmailSignup(
                email: _email.text.trim(),
                firstName: _first.text.trim(),
                lastName: _last.text.trim(),
                otherNames: _other.text.trim().isEmpty
                    ? null
                    : _other.text.trim(),
              );
        if (mounted) setState(() => _message = message);
      }
    } on TrotxiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not connect. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(switch (_mode) {
        EmailMode.login => 'Sign in with email',
        EmailMode.signup => 'Create your account',
        EmailMode.reset => 'Forgot password',
      }),
    ),
    body: SafeArea(
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (_mode == EmailMode.signup) ...[
                const Text(
                  'Use any email address you own. We will email you a secure link to verify it and set your password.',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _first,
                  enabled: !_busy,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.givenName],
                  decoration: const InputDecoration(labelText: 'First name'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter your first name'
                      : null,
                ),
                TextFormField(
                  controller: _other,
                  enabled: !_busy,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Other names (optional)',
                  ),
                ),
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
              if (_mode == EmailMode.reset)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Enter your email and we will send a secure password reset link if email sign-in is enabled for your account.',
                  ),
                ),
              TextFormField(
                controller: _email,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                maxLength: 320,
                decoration: const InputDecoration(labelText: 'Email address'),
                validator: (v) => v == null || !v.trim().contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              if (_mode == EmailMode.login) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  enabled: !_busy,
                  obscureText: !_showPassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      tooltip: _showPassword
                          ? 'Hide password'
                          : 'Show password',
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your password' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _busy ? null : () => _switch(EmailMode.reset),
                    child: const Text('Forgot password?'),
                  ),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(_error!),
                ),
              if (_message != null) ...[
                Text(_message!),
                const SizedBox(height: 8),
                const Text(
                  'Open the email, save your password, then return here to sign in. If you normally use Google or phone, sign in that way and add email under Security & sign-in.',
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(
                  _busy
                      ? 'Please wait...'
                      : _mode == EmailMode.login
                      ? 'Sign in'
                      : _message != null
                      ? 'Resend email'
                      : 'Send verification email',
                ),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _switch(
                        _mode == EmailMode.login
                            ? EmailMode.signup
                            : EmailMode.login,
                      ),
                child: Text(
                  _mode == EmailMode.login
                      ? 'Create an account'
                      : 'Back to sign in',
                ),
              ),
              if (_mode == EmailMode.signup)
                const Text(
                  'By creating an account, you agree to Trotxi’s Terms and acknowledge the Privacy Policy.',
                ),
              const PublicInformationLinks(),
            ],
          ),
        ),
      ),
    ),
  );
}
