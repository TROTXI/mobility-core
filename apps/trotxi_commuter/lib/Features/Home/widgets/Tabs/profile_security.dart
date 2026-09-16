import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

String _formatSessionDate(DateTime date) {
  return DateFormat('d MMM y, h:mm a').format(date.toLocal());
}

/// Full-page "Security & sign-in", pushed from ProfileTab's
/// "Security & sign-in" row.
///
/// Replacement session management uses `/v1/me/sessions`; account erasure
/// uses `DELETE /v1/me`. Provider credentials are not local passwords, and
/// unavailable biometric app-lock is labelled rather than pretending to enable it.
class ProfileSecurityPage extends StatefulWidget {
  const ProfileSecurityPage({super.key, required this.client});

  final CommuterApi client;

  @override
  State<ProfileSecurityPage> createState() => _ProfileSecurityPageState();
}

class _ProfileSecurityPageState extends State<ProfileSecurityPage> {
  final bool _biometricUnlock = false;

  void _onChangePasswordOrPin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sign-in credentials are managed by your identity provider.',
        ),
      ),
    );
  }

  void _onToggleBiometricUnlock(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometric app lock is not available in this build.'),
      ),
    );
  }

  void _openSessions() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _SessionsListPage(client: widget.client),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final generation = widget.client.sessionGeneration;
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
    if (confirmed == true &&
        mounted &&
        generation == widget.client.sessionGeneration) {
      await _signOut();
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.client.signOut();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not clear this device’s session. Please retry.'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final generation = widget.client.sessionGeneration;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This erases your account profile and revokes its sessions. Private-file '
          'cleanup may finish later; required accounting records are retained. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        mounted &&
        generation == widget.client.sessionGeneration) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await widget.client.eraseAccount();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is TrotxiException
                ? e.message
                : 'Could not delete your account. Try again.',
          ),
        ),
      );
      debugPrint('Account erasure error: ${e.runtimeType}');
    }
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

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Sign-in security'),
                  const SizedBox(height: 12),
                  _SecurityTile(
                    title: 'Change password / PIN',
                    subtitle: 'Managed by Google or Apple',
                    onTap: _onChangePasswordOrPin,
                  ),
                  const SizedBox(height: 8),
                  _SecuritySwitchTile(
                    title: 'Biometric unlock',
                    subtitle: 'Not available in this build',
                    value: _biometricUnlock,
                    onChanged: _onToggleBiometricUnlock,
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Devices & sessions'),
                  const SizedBox(height: 12),
                  _SecurityTile(
                    title: 'Manage signed-in devices',
                    subtitle: 'Review or revoke sessions on your account',
                    onTap: _openSessions,
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Account actions'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      border: Border.all(color: colors.borderSubtle),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SecurityTile(
                          title: 'Sign out on this device',
                          onTap: _confirmSignOut,
                          bordered: false,
                        ),
                        Divider(height: 1, color: colors.borderSubtle),
                        _SecurityTile(
                          title: 'Delete account',
                          titleColor: colors.error,
                          onTap: _confirmDeleteAccount,
                          bordered: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Back',
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Security & sign-in',
            style: AppTypography.title.copyWith(color: colors.textPrimary),
          ),
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

/// A standalone, individually-carded row with a title/subtitle and a
/// trailing chevron. Set [bordered] to false when the caller already draws
/// the surrounding card (e.g. grouped rows with a divider between them).
class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
    this.bordered = true,
  });

  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = Padding(
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
                    color: titleColor ?? colors.textPrimary,
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
          Icon(Icons.chevron_right_rounded, color: colors.iconSubtle),
        ],
      ),
    );

    if (!bordered) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: content),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class _SecuritySwitchTile extends StatelessWidget {
  const _SecuritySwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.actionPrimaryDefault,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sessions list — replacement GET /v1/me/sessions, revoke via
// DELETE /v1/me/sessions/{id}
// ---------------------------------------------------------------------

class _SessionsListPage extends StatefulWidget {
  const _SessionsListPage({required this.client});

  final CommuterApi client;

  @override
  State<_SessionsListPage> createState() => _SessionsListPageState();
}

class _SessionsListPageState extends State<_SessionsListPage> {
  bool _loading = true;
  Object? _error;
  List<Session> _sessions = const [];
  final Set<String> _revokingIds = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sessions = await widget.client.sessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
      debugPrint('Session list error: ${e.runtimeType}');
    }
  }

  Future<void> _confirmRevoke(Session session) async {
    final generation = widget.client.sessionGeneration;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revoke session'),
        content: const Text(
          "This signs that device out immediately. If it's the device "
          "you're using now, you'll be signed out too.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed == true &&
        mounted &&
        generation == widget.client.sessionGeneration) {
      await _revoke(session);
    }
  }

  Future<void> _revoke(Session session) async {
    setState(() => _revokingIds.add(session.id));
    try {
      await widget.client.revokeSession(session);
      if (!mounted) return;
      setState(() {
        _sessions = _sessions.where((s) => s.id != session.id).toList();
        _revokingIds.remove(session.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _revokingIds.remove(session.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is TrotxiException ? e.message : 'Could not revoke that session.',
          ),
        ),
      );
      debugPrint('Session revocation error: ${e.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Back',
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Signed-in devices',
                    style: AppTypography.title.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Sessions don't include device details yet, so these are "
                'shown by when they were created rather than device name.',
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.appColors;
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: colors.actionPrimaryDefault),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load your sessions",
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadSessions, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_sessions.isEmpty) {
      return Center(
        child: Text(
          'No active sessions.',
          style: AppTypography.bodySmall.copyWith(color: colors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: _sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final revoking = _revokingIds.contains(session.id);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.borderSubtle),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signed in ${_formatSessionDate(session.createdAt)}',
                      style: AppTypography.label.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Expires ${_formatSessionDate(session.expiresAt)}',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              revoking
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.error,
                      ),
                    )
                  : TextButton(
                      onPressed: () => _confirmRevoke(session),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                      ),
                      child: const Text('Revoke'),
                    ),
            ],
          ),
        );
      },
    );
  }
}
