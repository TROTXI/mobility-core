import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_spacing.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';
import 'package:trotxi_commuter/Features/Onboarding/widgets/app_button.dart';
import 'package:trotxi_commuter/core/widgets/public_information_links.dart';
import 'phone_password_page.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key, required this.client});

  final CommuterApi client;

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  void _open(bool signup) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PhonePasswordPage(client: widget.client, signup: signup),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Theme-aware entry screen for the single commuter sign-in method.
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final pageColor = AppPrimitiveColors.authPage(brightness);
    final systemIconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: pageColor,
        statusBarIconBrightness: systemIconBrightness,
        statusBarBrightness: brightness,
        systemNavigationBarColor: pageColor,
        systemNavigationBarIconBrightness: systemIconBrightness,
      ),
      child: Scaffold(
        backgroundColor: pageColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 30,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLogo(context),
                        const SizedBox(height: AppSpacing.space24),
                        _buildHeader(context),
                        const SizedBox(height: 22),
                        _buildAuthCard(context),
                        if (widget.client.authNotice != null) ...[
                          const SizedBox(height: AppSpacing.space12),
                          Text(
                            widget.client.authNotice!,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),

                        const Spacer(),
                        const SizedBox(height: AppSpacing.space24),

                        const SizedBox(height: AppSpacing.space20),
                        _buildTagline(context),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Image.asset(
        isDark ? Appvectors.logodarktheme : Appvectors.logo,
        key: ValueKey('onboard-logo-${isDark ? 'dark' : 'light'}'),
        width: 180,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome to Trotxi',
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
          'Create an account or sign in with your phone number.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: colors.textSecondary,
            fontSize: 14.5,
            height: 22 / 14.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSignInButton(
            onPressed: () => _open(true),
            text: 'Create account',
            icon: Icon(
              Icons.person_add_outlined,
              color: colors.actionOnPrimary,
            ),
            backgroundColor: colors.actionPrimaryDefault,
            borderColor: colors.actionPrimaryDefault,
            textColor: colors.actionOnPrimary,
          ),
          const SizedBox(height: 13),
          AppSignInButton(
            onPressed: () => _open(false),
            text: 'Sign in',
            icon: Icon(Icons.phone_outlined, color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space20),
          Text(
            'Read how Trotxi handles your information before creating an account.',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const PublicInformationLinks(),
        ],
      ),
    );
  }

  Widget _buildTagline(BuildContext context) {
    return Text(
      'Move smart. Live better.',
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(
        color: context.appColors.textTertiary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
