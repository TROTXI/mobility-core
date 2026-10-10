import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/config/theme/app_vectors.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({
    super.key,
    required this.userData,
    required this.userName,
    this.onProfile,
  });

  final Account userData;
  final String userName;
  final VoidCallback? onProfile;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avatarUrl = userData.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          border: Border(bottom: BorderSide(color: colors.borderSubtle)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              isDark ? Appvectors.logodarktheme : Appvectors.logo,
              width: 86,
              height: 42,
              fit: BoxFit.contain,
            ),
            Tooltip(
              message: 'Open profile',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onProfile,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colors.actionPrimaryDefault,
                      backgroundImage: hasAvatar
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: hasAvatar
                          ? null
                          : Text(
                              _initials(userName),
                              style: AppTypography.label.copyWith(
                                color: colors.actionOnPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
