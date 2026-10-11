import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/widgets/trotxi_wordmark.dart';

/// Fixed navigation above scrollable account and device-readiness content.
/// Footer actions sit at the bottom when there is room and scroll when needed.
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

  /// Shows a fixed back control beside the wordmark when set.
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
      appBar: AppBar(
        leading: onBack == null
            ? null
            : IconButton(
                onPressed: onBack,
                tooltip: backTooltip,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
        title: const TrotxiWordmark(height: 28),
        actions: [
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: trailing!,
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (box.maxHeight - 56).clamp(0, double.infinity),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hero != null) ...[
                          Align(alignment: Alignment.centerLeft, child: hero!),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          title,
                          style: AppTypography.screenTitle.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            subtitle!,
                            style: AppTypography.body.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        ...children,
                        const Spacer(),
                        if (footer.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          ...footer,
                        ],
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
}

/// Main auth action with a 56dp minimum target.
ButtonStyle authPrimaryButton(AppColors colors) => FilledButton.styleFrom(
  minimumSize: const Size.fromHeight(56),
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.space16,
    vertical: 16,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: AppRadii.circular(AppRadii.button),
  ),
  textStyle: AppTypography.actionLabel,
  backgroundColor: colors.action,
  foregroundColor: colors.onAction,
  disabledBackgroundColor: colors.border,
  disabledForegroundColor: colors.textSecondary,
);

/// Outlined alternative to [authPrimaryButton].
ButtonStyle authSecondaryButton(AppColors colors) => OutlinedButton.styleFrom(
  minimumSize: const Size.fromHeight(56),
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.space16,
    vertical: 16,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: AppRadii.circular(AppRadii.button),
  ),
  textStyle: AppTypography.actionLabel.copyWith(fontWeight: FontWeight.w600),
  foregroundColor: colors.textPrimary,
  side: BorderSide(color: colors.borderStrong),
);

/// A small pill for an action inside a card row: "Allow camera".
ButtonStyle authRowButton(AppColors colors) => OutlinedButton.styleFrom(
  minimumSize: const Size(0, 40),
  padding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.space16,
    vertical: 16,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: AppRadii.circular(AppRadii.button),
  ),
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
  Widget build(BuildContext context) => Text(text, textAlign: TextAlign.center);
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
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.authRowValue.copyWith(
                color: colors.textPrimary,
              ),
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
