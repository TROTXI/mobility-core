import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/trotxi_wordmark.dart';

/// The frame every sign-in, account and device-readiness screen shares
/// (design pages 05 and 06): the wordmark, an optional back control, a centred
/// title and one line under it, the screen's content, and its actions held to
/// the bottom of the screen when there is room for them.
///
/// One frame so the screens cannot drift apart again. They had: each set its
/// own padding, title gap and footer, which is most of why moving from one to
/// the next felt like moving between apps.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.backTooltip = 'Back',
    this.hero,
    this.trailing,
    this.children = const [],
    this.footer = const [],
  });

  final String title;
  final String? subtitle;

  /// Shows the round back control beside the wordmark when set.
  final VoidCallback? onBack;
  final String backTooltip;

  /// A status mark drawn between the wordmark and the title.
  final Widget? hero;

  /// A small element at the top right, such as a READY chip.
  final Widget? trailing;
  final List<Widget> children;

  /// Actions and the small print under them.
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final gutter = box.maxWidth >= 800
                ? AppSpacing.space40
                : AppSpacing.space20;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: gutter,
                vertical: AppSpacing.space16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 560,
                    minHeight: (box.maxHeight - AppSpacing.space32).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              TrotxiWordmark(height: onBack == null ? 46 : 40),
                              if (onBack != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton.outlined(
                                    onPressed: onBack,
                                    tooltip: backTooltip,
                                    style: IconButton.styleFrom(
                                      fixedSize: const Size.square(44),
                                      side: BorderSide(color: colors.border),
                                    ),
                                    icon: const Icon(
                                      Icons.chevron_left_rounded,
                                    ),
                                  ),
                                ),
                              if (trailing != null)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: trailing,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space32),
                        if (hero != null) ...[
                          Center(child: hero),
                          const SizedBox(height: AppSpacing.space20),
                        ],
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.screenTitle.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            style: AppTypography.authRowDetail.copyWith(
                              fontSize: 13,
                              height: 20 / 13,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.space24),
                        ...children,
                        const Spacer(),
                        if (footer.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.space24),
                          ...footer,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The main action on an auth screen: a 56-high pill.
ButtonStyle authPrimaryButton(AppColors colors) => FilledButton.styleFrom(
  minimumSize: const Size.fromHeight(56),
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
  shape: const StadiumBorder(),
  textStyle: AppTypography.actionLabel,
  backgroundColor: colors.action,
  foregroundColor: colors.onAction,
  disabledBackgroundColor: colors.border,
  disabledForegroundColor: colors.textSecondary,
);

/// The alternative beside or under [authPrimaryButton]: the same pill,
/// outlined, so a pair of choices reads as a pair.
ButtonStyle authSecondaryButton(AppColors colors) => OutlinedButton.styleFrom(
  minimumSize: const Size.fromHeight(56),
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
  shape: const StadiumBorder(),
  textStyle: AppTypography.actionLabel.copyWith(fontWeight: FontWeight.w600),
  foregroundColor: colors.textPrimary,
  side: BorderSide(color: colors.borderStrong),
);

/// A small pill for an action inside a card row: "Allow camera".
ButtonStyle authRowButton(AppColors colors) => OutlinedButton.styleFrom(
  minimumSize: const Size(0, 40),
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
  shape: const StadiumBorder(),
  textStyle: AppTypography.authRowValue.copyWith(fontSize: 13),
  foregroundColor: colors.textPrimary,
  side: BorderSide(color: colors.borderStrong),
  tapTargetSize: MaterialTapTargetSize.padded,
);

/// A button label that stays on one line, shrinking a little on a narrow
/// phone rather than wrapping "Yes, link account" over two.
class AuthButtonLabel extends StatelessWidget {
  const AuthButtonLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, softWrap: false),
  );
}

/// The rounded panel the auth screens group details in.
class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.space20),
    this.raised = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// White in light mode instead of the tinted field fill, for a card that
  /// sits under another card.
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: raised ? colors.surface : colors.field,
        borderRadius: AppRadii.circular(AppRadii.xl),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }
}

/// The driver's initials, name and one line under it.
class AuthIdentity extends StatelessWidget {
  const AuthIdentity({super.key, required this.name, required this.detail});

  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surfaceStrong,
          ),
          child: Text(
            initials(name),
            style: AppTypography.authRowTitle.copyWith(
              fontSize: 16,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.authName.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              Text(
                detail,
                style: AppTypography.authRowDetail.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

/// A label on the left and its value on the right.
class AuthDetailRow extends StatelessWidget {
  const AuthDetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.authRowDetail.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.authRowValue.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The small print under a screen's actions.
class AuthCaption extends StatelessWidget {
  const AuthCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.space12),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.authCaption.copyWith(
        color: context.driverColors.textMuted,
      ),
    ),
  );
}

/// The round status mark above a title: a tick for done, "!" for needed.
class AuthStatusMark extends StatelessWidget {
  const AuthStatusMark({super.key, required this.color, this.icon});

  final Color color;

  /// Null draws an exclamation mark.
  final IconData? icon;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: icon != null
          ? Icon(icon, size: 44, color: color)
          : Text('!', style: AppTypography.heading1.copyWith(color: color)),
    ),
  );
}

/// An uppercase status chip: READY, REQUIRED.
class AuthChip extends StatelessWidget {
  const AuthChip(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.space12,
      vertical: AppSpacing.space4,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: AppRadii.circular(AppRadii.full),
    ),
    child: Text(label, style: AppTypography.chipLabel.copyWith(color: color)),
  );
}
