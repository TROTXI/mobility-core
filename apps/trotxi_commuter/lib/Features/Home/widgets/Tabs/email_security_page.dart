import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/auth/password_policy.dart';
import 'package:trotxi_commuter/core/auth/password_requirements.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

enum EmailSecuritySection { all, email, password }

class EmailSecurityPage extends StatefulWidget {
  const EmailSecurityPage({
    super.key,
    required this.client,
    this.section = EmailSecuritySection.all,
  });
  final EmailSecuritySection section;
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
  final _visiblePasswords = <String>{};
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
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final showEmail =
        widget.section != EmailSecuritySection.password || !_enabled;
    final showPassword =
        widget.section != EmailSecuritySection.email || !_enabled;
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        title: Text(switch (widget.section) {
          EmailSecuritySection.email => 'Recovery email',
          EmailSecuritySection.password => 'Change password',
          EmailSecuritySection.all => 'Security & recovery',
        }),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _form,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                      children: [
                        Text(
                          widget.section == EmailSecuritySection.email
                              ? 'A way back in.'
                              : 'Keep your account yours.',
                          style: AppTypography.heading2.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _enabled
                              ? (widget.section == EmailSecuritySection.email
                                    ? 'Verify your email to recover your account when you need it.'
                                    : 'Choose a password you don’t use anywhere else.')
                              : 'Add an email and password to this account.',
                          style: AppTypography.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_enabled && showEmail)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              border: Border.all(color: colors.borderSubtle),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _verified
                                      ? Icons.verified_outlined
                                      : Icons.mail_outline,
                                  color: _verified
                                      ? colors.success
                                      : colors.iconDefault,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Recovery email',
                                        style: AppTypography.caption.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _email.text,
                                        style: AppTypography.body.copyWith(
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _verified
                                            ? 'Verified'
                                            : 'Verification needed',
                                        style: AppTypography.caption.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_enabled && !_verified && showEmail) ...[
                          const SizedBox(height: 16),
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
                        if (_enabled && _verified && showEmail) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Contact email verified. You can use it for account recovery.',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              _error!,
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ),
                        if (showPassword) ...[
                          const SizedBox(height: 32),
                          Text(
                            _enabled
                                ? 'Change password'
                                : 'Set up email access',
                            style: AppTypography.title.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _enabled
                                ? 'For security, sign in again if it has been more than 15 minutes. Changing your password signs out all devices.'
                                : 'You’ll receive a code by email. It works for 30 minutes in this session.',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!_enabled)
                            TextFormField(
                              controller: _email,
                              enabled: !_busy && !_enabled && !_sent,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              decoration: _fieldDecoration('Email address'),
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
                              decoration: _fieldDecoration('Verification code'),
                              validator: (v) =>
                                  v == null || v.trim().length != 43
                                  ? 'Paste the complete code'
                                  : null,
                            ),
                          ],
                          if (_enabled) ...[
                            TextFormField(
                              controller: _old,
                              enabled: !_busy,
                              obscureText: !_visiblePasswords.contains(
                                'Current password',
                              ),
                              autocorrect: false,
                              enableSuggestions: false,
                              autofillHints: const [AutofillHints.password],
                              decoration: _fieldDecoration('Current password'),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Enter your current password'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (_enabled || _sent) ...[
                            TextFormField(
                              controller: _password,
                              enabled: !_busy,
                              obscureText: !_visiblePasswords.contains(
                                'New password',
                              ),
                              autocorrect: false,
                              enableSuggestions: false,
                              autofillHints: const [AutofillHints.newPassword],
                              maxLength: 128,
                              decoration: _fieldDecoration(
                                'New password',
                              ).copyWith(counterText: ''),
                              validator: validateNewPassword,
                            ),
                            const SizedBox(height: 12),
                            PasswordRequirements(password: _password.text),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _confirm,
                              enabled: !_busy,
                              obscureText: !_visiblePasswords.contains(
                                'Confirm password',
                              ),
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: _fieldDecoration('Confirm password'),
                              validator: (v) => v != _password.text
                                  ? 'Passwords do not match'
                                  : null,
                            ),
                            if (_confirm.text.isNotEmpty)
                              Text(
                                _confirm.text == _password.text
                                    ? 'Passwords match'
                                    : 'Passwords do not match yet',
                                style: TextStyle(
                                  color: _confirm.text == _password.text
                                      ? context.appColors.actionSecondary
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed:
                                  _busy ||
                                      ((_enabled || _sent) &&
                                          (validateNewPassword(
                                                    _password.text,
                                                  ) !=
                                                  null ||
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    suffixIcon: label.toLowerCase().contains('password')
        ? IconButton(
            tooltip: _visiblePasswords.contains(label)
                ? 'Hide password'
                : 'Show password',
            onPressed: () => setState(() {
              if (!_visiblePasswords.add(label)) {
                _visiblePasswords.remove(label);
              }
            }),
            icon: Icon(
              _visiblePasswords.contains(label)
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          )
        : null,
  );
}
