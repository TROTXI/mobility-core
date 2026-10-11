import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/widgets/app_surfaces.dart';
import 'email_security_page.dart';
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
/// Session management uses `/v1/me/sessions`; account erasure uses
/// `DELETE /v1/me`.
class ProfileSecurityPage extends StatefulWidget {
  const ProfileSecurityPage({super.key, required this.client});

  final CommuterApi client;

  @override
  State<ProfileSecurityPage> createState() => _ProfileSecurityPageState();
}

class _ProfileSecurityPageState extends State<ProfileSecurityPage> {
  void _openEmailSecurity(EmailSecuritySection section) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EmailSecurityPage(client: widget.client, section: section),
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
      phone: 24.0,
      tabletPortrait: 24.0,
      tabletLandscape: 32.0,
    );

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(title: const Text('Security & sign-in')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
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
                  const AppPageHeading(
                    title: 'Keep your account secure.',
                    subtitle: 'Manage how you sign in and recover access.',
                  ),
                  const SizedBox(height: 24),
                  AppSettingsGroup(
                    children: [
                      AppSettingsRow(
                        title: 'Change password',
                        subtitle: 'Update your sign-in password',
                        icon: Icons.lock_outline_rounded,
                        onTap: () =>
                            _openEmailSecurity(EmailSecuritySection.password),
                      ),
                      AppSettingsRow(
                        title: 'Recovery email',
                        subtitle: 'Verify your contact email',
                        icon: Icons.mail_outline_rounded,
                        onTap: () =>
                            _openEmailSecurity(EmailSecuritySection.email),
                      ),
                      AppSettingsRow(
                        title: 'Manage signed-in devices',
                        subtitle: 'Review access to your account',
                        icon: Icons.devices_outlined,
                        onTap: _openSessions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Account access'),
                  const SizedBox(height: 12),
                  AppSettingsGroup(
                    children: [
                      AppSettingsRow(
                        title: 'Sign out on this device',
                        icon: Icons.logout_rounded,
                        onTap: _confirmSignOut,
                      ),
                      AppSettingsRow(
                        title: 'Delete account',
                        icon: Icons.delete_outline_rounded,
                        destructive: true,
                        onTap: _confirmDeleteAccount,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
      appBar: AppBar(title: const Text('Signed-in devices')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Review account access',
                    style: AppTypography.heading2.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign-ins are listed by date. Remove access from any session you don’t recognise.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: _buildBody(context)),
                ],
              ),
            ),
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
