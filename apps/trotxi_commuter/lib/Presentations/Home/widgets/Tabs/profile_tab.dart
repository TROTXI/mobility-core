import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/Presentations/Onboarding/pages/onboard_page.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.client});
  final TrotxiApiClient client;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  MeGet200Response? _user;
  bool _loading = true;
  Object? _error;

  // TODO: source these from widget.client instead of hardcoded values.
  bool _dailyAskEnabled = true;
  bool _notificationsEnabled = true;

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
      final response = await widget.client.getAuthApi().meGet();
      if (!mounted) return;
      setState(() {
        _user = response.data;
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
          _EditNameDialog(initialValue: user.displayName ?? ''),
    );

    final trimmed = newName?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == user.displayName) {
      return;
    }

    try {
      // Adjust method/parameter names to match your generated client.
      final response = await widget.client.getAuthApi().mePatch(
        mePatchRequest: MePatchRequest((b) => b..displayName = trimmed),
      );
      if (!mounted) return;
      setState(() => _user = response.data ?? _user);
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
    // Clear cached auth/session tokens on-device.
    // TODO: swap in the actual storage keys your auth layer writes under
    // (this assumes flutter_secure_storage with 'access_token' /
    // 'refresh_token' keys — adjust to match your real implementation).
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => OnBoardPage(client: widget.client),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.elevatedbackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 32),
            _SettingsSection(
              title: 'PREFERENCES',
              children: [
                _SettingsSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Daily Ask & Notifications',
                  subtitle: 'Alerts, routes, and payments',
                  value: _dailyAskEnabled && _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dailyAskEnabled = value;
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'ACCOUNT',
              children: [
                _SettingsTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Subscriptions & Payments',
                  subtitle: 'Manage your plan and payment methods',
                  onTap: () {
                    // TODO: navigate to subscriptions & payments screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'SUPPORT',
              children: [
                _SettingsTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Help & Contact',
                  subtitle: 'FAQs and direct chat support',
                  onTap: () {
                    // TODO: navigate to help & contact screen
                  },
                ),
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Legal & Privacy',
                  subtitle: 'Terms of service',
                  onTap: () {
                    // TODO: navigate to legal & privacy screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SignOutButton(onPressed: () => _confirmSignOut(context)),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Version 2.4.1 (Stable)\nHandcrafted for Ghana by Trotxi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0x993E4A41),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar (photo, or initials if none) + name + phone, with a tap-to-edit
/// affordance on the name/avatar.
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
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: onEdit,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: hasAvatar ? null : AppColors.primary,
                  border: Border.all(
                    width: 3,
                    color: AppColors.lightBackground,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: 'Hanken Grotesk',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: AppColors.elevatedbackground,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          (displayName == null || displayName!.trim().isEmpty)
              ? 'Add your name'
              : displayName!,
          style: const TextStyle(
            color: AppColors.dark,
            fontSize: 22,
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          (phone == null || phone!.trim().isEmpty)
              ? 'No phone number on file'
              : phone!,
          style: TextStyle(
            color: (phone == null || phone!.trim().isEmpty)
                ? AppColors.muted
                : AppColors.body,
            fontSize: 14,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderLoading extends StatelessWidget {
  const _ProfileHeaderLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 96 + 12 + 22 + 2 + 14,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProfileHeaderError extends StatelessWidget {
  const _ProfileHeaderError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 40,
          color: AppColors.muted,
        ),
        const SizedBox(height: 8),
        const Text(
          'Couldn\'t load your profile',
          style: TextStyle(
            color: AppColors.body,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Try Again'),
        ),
      ],
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

/// A titled card grouping a set of settings rows, with dividers between them.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.60,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0x4CBDCABE),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A tappable settings row with a leading icon, title/subtitle, and a
/// trailing chevron.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.dark,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.body,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/// Same layout as [_SettingsTile] but with a trailing Switch instead of a
/// chevron.
class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.dark,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.body,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFBA1A1A),
          side: const BorderSide(color: Color(0xFFBA1A1A)),
          backgroundColor: AppColors.lightBackground,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
