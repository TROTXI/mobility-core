import 'package:flutter/material.dart';

import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/commuter_preference.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/personal_info.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_notification.dart';
import 'package:trotxi_commuter/Features/Home/widgets/Tabs/profile_security.dart';
import 'package:trotxi_commuter/Features/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/core/config/client_metadata.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme_controller.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_commuter/core/Tokens/token_storage.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Account? _user;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await widget.client.getSelfApi().getAccount(
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
      );
      if (!mounted) return;
      setState(() {
        _user = response.data?.data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> _editDisplayName() async {
    final user = _user;
    if (user == null) return;

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _EditNameDialog(initialValue: user.displayName),
    );

    final trimmed = newName?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == user.displayName) {
      return;
    }

    try {
      // A fresh key per distinct name: the API scopes an Idempotency-Key to
      // caller + operation + payload and answers 409 if the same key comes
      // back carrying something different.
      final response = await widget.client.getSelfApi().updateAccount(
        idempotencyKey: newIdempotencyKey(),
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
        profileUpdate: ProfileUpdate((b) => b..displayName = trimmed),
      );
      if (!mounted) return;
      setState(() => _user = response.data?.data ?? _user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update name. Try again.')),
      );
      debugPrint('Error updating display name: $e');
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _signOut();
    }
  }

  Future<void> _signOut() async {
    final refreshToken = await TokenStorage.instance.getRefreshToken();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await widget.client
            .getPublicApi()
            .logoutSession(
              xTrotxiClient: commuterMetadata.client,
              xTrotxiBuild: commuterMetadata.build,
              xTrotxiPlatform: commuterMetadata.platform,
              refreshInput: RefreshInput((b) => b..refreshToken = refreshToken),
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Best effort: /v1/auth/logout is idempotent and outside the auth
        // guard, so this only fails on things like a dead network — in
        // which case we still clear locally so the rider isn't stuck.
      }
    }

    await TokenStorage.instance.clearTokens();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => OnBoardPage(client: widget.client),
      ),
      (route) => false,
    );
  }

  Future<void> _openPersonalInfo() async {
    final user = _user;
    if (user == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PersonalInfoPage(client: widget.client, initialUser: user),
      ),
    );

    // The name may have changed on that screen — refresh so this tab and
    // the shared Navbar (which also reads displayName) stay in sync.
    if (!mounted) return;
    _fetchUser();
  }

  /// The redesigned "Appearance" row has no inline switch (per the new
  /// layout), so light/dark/system selection now lives behind this sheet —
  /// keeps the working theme toggle without reintroducing a switch tile.
  void _showAppearanceSheet(BuildContext context) {
    final themeController = AppThemeControllerScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.appColors.surfaceElevated,
      builder: (sheetContext) => _AppearanceSheet(controller: themeController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final layout = ResponsiveLayoutInfo.of(context);
    final maxContentWidth = layout.select(
      phone: 520.0,
      tabletPortrait: 680.0,
      tabletLandscape: 960.0,
    );
    final horizontalPadding = layout.select(
      phone: 16.0,
      tabletPortrait: 24.0,
      tabletLandscape: 32.0,
    );

    return Container(
      color: colors.backgroundDefault,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              24,
              horizontalPadding,
              80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                if (_loading && _user == null)
                  const _ProfileHeaderLoading()
                else if (_error != null && _user == null)
                  _ProfileHeaderError(onRetry: _fetchUser)
                else
                  _ProfileHeader(
                    displayName: _user?.displayName,
                    phone: _user?.phone,
                    avatarUrl: _user?.avatarUrl,
                    onEdit: _editDisplayName,
                  ),
                const SizedBox(height: 28),
                _buildSectionTitle(context, 'Account'),
                const SizedBox(height: 12),
                _SettingsCardTile(
                  title: 'Personal information',
                  subtitle: 'Name, phone and contact details',
                  onTap: _user == null ? null : () => _openPersonalInfo(),
                ),
                const SizedBox(height: 8),
                _SettingsCardTile(
                  title: 'Commute preferences',
                  subtitle: 'Pickup, destination and travel preferences',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          CommutePreferencesPage(client: widget.client),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsCardTile(
                  title: 'Notifications',
                  subtitle: 'Ride alerts, reminders and updates',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileNotificationsPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsCardTile(
                  title: 'Appearance',
                  subtitle: 'Light, dark and system theme',
                  onTap: () => _showAppearanceSheet(context),
                ),
                const SizedBox(height: 28),
                _buildSectionTitle(context, 'Support & security'),
                const SizedBox(height: 12),
                _SettingsCardTile(
                  title: 'Security & sign-in',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileSecurityPage(client: widget.client),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsCardTile(
                  title: 'Help, support & legal',
                  onTap: () {
                    // TODO: navigate to help, support & legal screen
                  },
                ),
                const SizedBox(height: 28),
                // Not part of the new layout's captured frame, but kept —
                // it's the only way to sign out of the app.
                _SignOutButton(onPressed: () => _confirmSignOut(context)),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Version 2.4.1 (Stable)\nHandcrafted for Ghana by Trotxi',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: AppTypography.heading2.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your Trotxi account and preferences.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colors = context.appColors;
    return Text(
      title,
      style: AppTypography.label.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Avatar (photo, or initials if none) + name + phone, with a tap-to-edit
/// "Edit profile" link underneath.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.phone,
    required this.avatarUrl,
    required this.onEdit,
  });

  final String? displayName;
  final String? phone;
  final String? avatarUrl;
  final VoidCallback onEdit;

  String get _initials {
    final trimmed = displayName?.trim() ?? '';
    if (trimmed.isEmpty) return '?';

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      final word = parts.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: hasAvatar ? null : colors.actionPrimaryDefault,
              shape: BoxShape.circle,
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasAvatar
                ? null
                : Center(
                    child: Text(
                      _initials,
                      style: AppTypography.title.copyWith(
                        color: colors.actionOnPrimary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (displayName == null || displayName!.trim().isEmpty)
                      ? 'Add your name'
                      : displayName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (phone == null || phone!.trim().isEmpty)
                      ? 'No phone number on file'
                      : phone!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: (phone == null || phone!.trim().isEmpty)
                        ? colors.textTertiary
                        : colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    'Edit profile',
                    style: AppTypography.buttonAction.copyWith(
                      color: colors.actionPrimaryDefault,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderLoading extends StatelessWidget {
  const _ProfileHeaderLoading();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 112,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
    );
  }
}

class _ProfileHeaderError extends StatelessWidget {
  const _ProfileHeaderError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 28, color: colors.iconSubtle),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Couldn't load your profile",
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Simple text-field dialog used to edit the display name.
class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialValue});
  final String initialValue;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Your name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// A standalone, individually-carded settings row with a title/subtitle and
/// a trailing chevron — each row is its own card, not grouped with dividers.
class _SettingsCardTile extends StatelessWidget {
  const _SettingsCardTile({required this.title, this.subtitle, this.onTap});

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.label.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded, color: colors.iconSubtle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet behind the "Appearance" row — light/dark/system selection,
/// wired straight to the shared [AppThemeController].
class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet({required this.controller});

  final AppThemeController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: AppTypography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how Trotxi looks on this device.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _option(context, label: 'Light', mode: ThemeMode.light),
                _option(context, label: 'Dark', mode: ThemeMode.dark),
                _option(
                  context,
                  label: 'System default',
                  mode: ThemeMode.system,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _option(
    BuildContext context, {
    required String label,
    required ThemeMode mode,
  }) {
    final colors = context.appColors;
    final selected = controller.themeMode == mode;
    return InkWell(
      onTap: () => controller.setThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? colors.actionPrimaryDefault : colors.iconSubtle,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sign-out action. Kept visually calmer than a destructive "Delete
/// Account" button would be, since signing out isn't destructive.
class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error),
          backgroundColor: colors.surfaceElevated,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.buttonAction,
        ),
      ),
    );
  }
}
