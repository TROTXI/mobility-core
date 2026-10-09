import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';

/// Figma "Auth V2 / Complete Profile". The app root shows this whenever the
/// signed-in account still has the placeholder name (see
/// [CommuterApi.needsName]), so it also catches a rider who quit mid-onboarding.
/// It has no back or skip path: a name is required to continue.
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({
    super.key,
    required this.client,
    required this.account,
  });

  final CommuterApi client;
  final Account account;

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _name = TextEditingController();
  String? _error;
  bool _busy = false;

  /// "+233241234567" -> "+233 24 ••• 4567"; anything unexpected is hidden.
  String? get _maskedPhone {
    final phone = widget.account.phone;
    if (phone == null || !RegExp(r'^\+233\d{9}$').hasMatch(phone)) return null;
    return '+233 ${phone.substring(4, 6)} ••• ${phone.substring(9)}';
  }

  Future<void> _save() async {
    if (_busy) return;
    // The API stores first / last / other names; the form takes one full name.
    final parts = _name.text.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      setState(() => _error = 'Enter your first and last name.');
      return;
    }
    final first = parts.first;
    final last = parts.last;
    final other = parts.sublist(1, parts.length - 1).join(' ');
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await widget.client.updateName(
        firstName: first,
        lastName: last,
        otherNames: other,
      );
      // The root swaps this page for Home once the account has a real name.
      widget.client.completeSignIn(updated);
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
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final pageColor = AppPrimitiveColors.authPage(brightness);
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;
    final phone = _maskedPhone;
    final buttonColor = isDark
        ? colors.actionPrimaryDefault
        : AppPrimitiveColors.green950;

    return PopScope(
      canPop: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: pageColor,
          statusBarIconBrightness: iconBrightness,
          statusBarBrightness: brightness,
          systemNavigationBarColor: pageColor,
          systemNavigationBarIconBrightness: iconBrightness,
        ),
        child: Scaffold(
          backgroundColor: pageColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 30,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            isDark ? Appvectors.logodarktheme : Appvectors.logo,
                            width: 180,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'STEP 3 OF 3',
                          style: AppTypography.caption.copyWith(
                            color: colors.actionPrimaryDefault,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Complete your profile',
                          style: AppTypography.heading1.copyWith(
                            color: colors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tell us how to identify you. You can update these details later from Profile.',
                          style: AppTypography.body.copyWith(
                            color: colors.textSecondary,
                            fontSize: 14.5,
                            height: 22 / 14.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _label(colors, 'Full name'),
                        const SizedBox(height: 6),
                        _field(
                          colors,
                          _name,
                          hint: 'Your full name',
                          autofocus: true,
                          maxLength: 100,
                          hints: const [AutofillHints.name],
                          action: TextInputAction.done,
                          onSubmit: _save,
                        ),
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
                        if (phone != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              border: Border.all(color: colors.borderSubtle),
                              borderRadius: BorderRadius.circular(11.6),
                            ),
                            child: Text(
                              '✓ Phone verified · $phone',
                              style: AppTypography.caption.copyWith(
                                color: colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: _busy ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                colors.actionPrimaryDisabled,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _busy ? 'Saving…' : 'Create Trotxi account',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'By continuing, you agree to Trotxi’s Terms and acknowledge the Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                            fontSize: 10.6,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 20),
                        Text(
                          'Move smart. Live better.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: colors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(AppSemanticColors colors, String text) => Text(
    text,
    style: AppTypography.caption.copyWith(
      color: colors.textSecondary,
      fontSize: 12,
    ),
  );

  Widget _field(
    AppSemanticColors colors,
    TextEditingController controller, {
    required String hint,
    bool autofocus = false,
    int maxLength = 60,
    Iterable<String>? hints,
    TextInputAction action = TextInputAction.next,
    VoidCallback? onSubmit,
  }) => TextField(
    controller: controller,
    enabled: !_busy,
    autofocus: autofocus,
    keyboardType: TextInputType.name,
    textCapitalization: TextCapitalization.words,
    textInputAction: action,
    autofillHints: hints,
    maxLength: maxLength,
    onSubmitted: onSubmit == null ? null : (_) => onSubmit(),
    style: AppTypography.body.copyWith(color: colors.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      counterText: '',
      filled: true,
      fillColor: colors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: _border(colors.borderSubtle),
      enabledBorder: _border(colors.borderSubtle),
      focusedBorder: _border(colors.actionPrimaryDefault, width: 1.5),
    ),
  );

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.6),
        borderSide: BorderSide(color: color, width: width),
      );
}
