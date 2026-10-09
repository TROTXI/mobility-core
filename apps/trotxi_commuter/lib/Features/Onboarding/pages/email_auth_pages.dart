import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_spacing.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

// Email onboarding: sign in, create account, forgot password. Sign-up and
// password reset both end the same way: the API emails a one-time token and
// the rider sets a password with it, then signs in. Passwords and tokens are
// transient inputs: never logged, stored or put in analytics.

final _emailPattern = RegExp(r"^[^\s@]+@[^\s@]+\.[A-Za-z]{2,}$");
const _minPassword = 15;

/// The emailed token is 43 URL-safe characters. Accept the bare token or the
/// whole link/message pasted, so the rider need not pick it out of the URL.
String? extractEmailToken(String pasted) {
  final text = pasted.trim();
  if (RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(text)) {
    return text.length == 43 ? text : null;
  }
  final tokens = RegExp(r'(?<![A-Za-z0-9_-])[A-Za-z0-9_-]{43}(?![A-Za-z0-9_-])')
      .allMatches(text);
  return tokens.isEmpty ? null : tokens.last.group(0);
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final String title, subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: AppPrimitiveColors.authPage(
        Theme.of(context).brightness,
      ),
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
                title,
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
                subtitle,
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
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _decoration(
  BuildContext context,
  String label, {
  Widget? suffix,
}) {
  final colors = context.appColors;
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: colors.backgroundDefault,
    suffixIcon: suffix,
    border: border(colors.borderSubtle),
    enabledBorder: border(colors.borderSubtle),
    focusedBorder: border(colors.actionPrimaryDefault, 1.5),
  );
}

Widget _errorText(BuildContext context, String? error) => error == null
    ? const SizedBox.shrink()
    : Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          error,
          style: AppTypography.bodySmall.copyWith(
            color: context.appColors.error,
          ),
        ),
      );

Widget _primaryButton(
  BuildContext context,
  String label,
  bool busy,
  VoidCallback onPressed,
) {
  final colors = context.appColors;
  return FilledButton(
    onPressed: busy ? null : onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: colors.actionPrimaryDefault,
      foregroundColor: Colors.white,
      disabledBackgroundColor: colors.actionPrimaryDisabled,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    ),
    child: Text(busy ? 'Please wait…' : label, style: const TextStyle(fontSize: 16)),
  );
}

String _messageFor(Object error, String fallback) =>
    error is TrotxiException ? error.message : fallback;

/// Email + password sign-in, with entry points to create an account and to
/// recover a forgotten password.
class EmailSignInPage extends StatefulWidget {
  const EmailSignInPage({super.key, required this.client});
  final CommuterApi client;
  @override
  State<EmailSignInPage> createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false, _obscure = true;
  String? _error;

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email) || _password.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // The app root swaps this page out once the session is ready.
      await widget.client.signInEmail(email, _password.text);
    } catch (e) {
      if (mounted) {
        setState(() => _error = _messageFor(e, 'Could not sign in. Please try again.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _push(Widget page) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Sign in with email',
      subtitle: 'Use the email and password for your Trotxi account.',
      children: [
        TextField(
          key: const ValueKey('email-field'),
          controller: _email,
          enabled: !_busy,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: _decoration(context, 'Email'),
        ),
        const SizedBox(height: 14),
        TextField(
          key: const ValueKey('password-field'),
          controller: _password,
          enabled: !_busy,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _submit(),
          decoration: _decoration(
            context,
            'Password',
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        _errorText(context, _error),
        const SizedBox(height: AppSpacing.space20),
        _primaryButton(context, 'Sign in', _busy, _submit),
        const SizedBox(height: AppSpacing.space8),
        TextButton(
          onPressed: _busy
              ? null
              : () => _push(
                  ForgotPasswordPage(
                    client: widget.client,
                    initialEmail: _email.text.trim(),
                  ),
                ),
          child: const Text('Forgot password?'),
        ),
        TextButton(
          onPressed: _busy
              ? null
              : () => _push(EmailSignUpPage(client: widget.client)),
          child: const Text('New to Trotxi? Create account'),
        ),
      ],
    );
  }
}

/// Create an account with email. The API emails a link; the rider then sets a
/// password on [SetPasswordPage].
class EmailSignUpPage extends StatefulWidget {
  const EmailSignUpPage({super.key, required this.client});
  final CommuterApi client;
  @override
  State<EmailSignUpPage> createState() => _EmailSignUpPageState();
}

class _EmailSignUpPageState extends State<EmailSignUpPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (_first.text.trim().isEmpty || _last.text.trim().isEmpty) {
      setState(() => _error = 'Enter your first and last name.');
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await widget.client.requestEmailSignup(
        email: email,
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SetPasswordPage(
            client: widget.client,
            email: email,
            title: 'Check your email',
            notice: message,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = _messageFor(e, 'Could not create your account. Please try again.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create your account',
      subtitle: 'We’ll email you a link to confirm your address and choose a password.',
      children: [
        TextField(
          controller: _first,
          enabled: !_busy,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.givenName],
          decoration: _decoration(context, 'First name'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _last,
          enabled: !_busy,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.familyName],
          decoration: _decoration(context, 'Last name'),
        ),
        const SizedBox(height: 14),
        TextField(
          key: const ValueKey('email-field'),
          controller: _email,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => _submit(),
          decoration: _decoration(context, 'Email'),
        ),
        _errorText(context, _error),
        const SizedBox(height: AppSpacing.space20),
        _primaryButton(context, 'Send link', _busy, _submit),
        TextButton(
          onPressed: _busy
              ? null
              : () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => SetPasswordPage(
                      client: widget.client,
                      email: _email.text.trim(),
                      title: 'Set your password',
                      notice: 'Already have your emailed link? Paste it below.',
                    ),
                  ),
                ),
          child: const Text('I already have a link'),
        ),
      ],
    );
  }
}

/// Request a reset link. The API gives the same answer whether or not the
/// email has an account, so this never says which.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    required this.client,
    this.initialEmail = '',
  });
  final CommuterApi client;
  final String initialEmail;
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Enter the email address on your account.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await widget.client.requestPasswordReset(email);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SetPasswordPage(
            client: widget.client,
            email: email,
            title: 'Reset your password',
            notice: message,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = _messageFor(e, 'Could not send the reset link. Please try again.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Forgot password?',
      subtitle: 'Enter your email and we’ll send a link to reset it.',
      children: [
        TextField(
          key: const ValueKey('email-field'),
          controller: _email,
          enabled: !_busy,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => _submit(),
          decoration: _decoration(context, 'Email'),
        ),
        _errorText(context, _error),
        const SizedBox(height: AppSpacing.space20),
        _primaryButton(context, 'Send reset link', _busy, _submit),
        TextButton(
          onPressed: _busy
              ? null
              : () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => SetPasswordPage(
                      client: widget.client,
                      email: _email.text.trim(),
                      title: 'Reset your password',
                      notice: 'Already have your emailed link? Paste it below.',
                    ),
                  ),
                ),
          child: const Text('I already have a link'),
        ),
      ],
    );
  }
}

/// Final step of sign-up and password reset: the emailed token plus a new
/// password. On success it returns to the email sign-in screen.
class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({
    super.key,
    required this.client,
    required this.email,
    required this.title,
    required this.notice,
  });
  final CommuterApi client;
  final String email, title, notice;
  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false, _obscure = true;
  String? _error;

  Future<void> _submit() async {
    final token = extractEmailToken(_token.text);
    if (token == null) {
      setState(() => _error = 'Paste the link or code from your email.');
      return;
    }
    if (_password.text.length < _minPassword) {
      setState(() => _error = 'Use at least $_minPassword characters for your password.');
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = 'The passwords don’t match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.client.completeEmailAccess(token, _password.text);
      if (!mounted) return;
      final navigator = Navigator.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password saved. Sign in to continue.')),
      );
      navigator.popUntil((r) => r.isFirst);
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => EmailSignInPage(client: widget.client),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = _messageFor(e, 'That link has expired or was already used. Request a new one.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _token.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final to = widget.email.isEmpty ? '' : ' (${widget.email})';
    return _AuthScaffold(
      title: widget.title,
      subtitle: '${widget.notice}\nOpen the email$to, copy the link, and paste it here.',
      children: [
        TextField(
          key: const ValueKey('token-field'),
          controller: _token,
          enabled: !_busy,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          decoration: _decoration(context, 'Link or code from email'),
        ),
        const SizedBox(height: 14),
        TextField(
          key: const ValueKey('new-password-field'),
          controller: _password,
          enabled: !_busy,
          obscureText: _obscure,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          decoration: _decoration(
            context,
            'New password ($_minPassword+ characters)',
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          key: const ValueKey('confirm-password-field'),
          controller: _confirm,
          enabled: !_busy,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          onSubmitted: (_) => _submit(),
          decoration: _decoration(context, 'Confirm password'),
        ),
        _errorText(context, _error),
        const SizedBox(height: AppSpacing.space20),
        _primaryButton(context, 'Save password', _busy, _submit),
      ],
    );
  }
}
