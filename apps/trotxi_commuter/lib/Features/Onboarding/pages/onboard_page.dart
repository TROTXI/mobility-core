import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    final pageColor = AppPrimitiveColors.authPage(brightness);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: pageColor,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
        systemNavigationBarColor: pageColor,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: pageColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              dark ? Appvectors.logodarktheme : Appvectors.logo,
                              width: 118,
                              semanticLabel: 'Trotxi',
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            'A better way to\nmove every day.',
                            style: AppTypography.heading1.copyWith(
                              color: colors.textPrimary,
                              fontSize: 35,
                              height: 1.13,
                              letterSpacing: -1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tell us your commute. We will find the right route and send you an offer to review.',
                            style: AppTypography.body.copyWith(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          if (constraints.maxHeight >= 700) ...[
                            const SizedBox(height: 28),
                            _JourneyCard(dark: dark),
                            const SizedBox(height: 28),
                          ] else
                            const SizedBox(height: 24),
                          if (widget.client.authNotice != null) ...[
                            Semantics(
                              liveRegion: true,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.actionPrimaryDefault.withValues(
                                    alpha: 0.09,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  widget.client.authNotice!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: () => _open(true),
                              child: const Text('Create account'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => _open(false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: colors.borderDefault),
                                foregroundColor: colors.textPrimary,
                              ),
                              child: const Text('Sign in'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Privacy and account help',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const PublicInformationLinks(),
                        ],
                      ),
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
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final green = colors.actionPrimaryDefault;
    final surface = dark
        ? AppPrimitiveColors.green950
        : AppPrimitiveColors.green50;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: green.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR JOURNEY WITH TROTXI',
            style: AppTypography.caption.copyWith(
              color: green,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 18),
          _stop(context, Icons.edit_road_rounded, 'Choose your commute', true),
          _connector(green),
          _stop(
            context,
            Icons.local_offer_outlined,
            'Review your offer',
            false,
          ),
          _connector(green),
          _stop(context, Icons.directions_bus_rounded, 'Get moving', false),
        ],
      ),
    );
  }

  Widget _connector(Color green) => Padding(
    padding: const EdgeInsets.only(left: 18),
    child: Container(
      height: 12,
      width: 2,
      color: green.withValues(alpha: 0.30),
    ),
  );

  Widget _stop(
    BuildContext context,
    IconData icon,
    String label,
    bool highlighted,
  ) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: highlighted
                ? colors.actionPrimaryDefault
                : colors.actionPrimaryDefault.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: highlighted
                ? colors.actionOnPrimary
                : colors.actionPrimaryDefault,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
