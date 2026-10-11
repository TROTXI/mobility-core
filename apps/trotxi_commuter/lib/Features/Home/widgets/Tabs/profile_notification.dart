import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_client/commuter_data_client.dart';
import 'package:trotxi_commuter/core/notifications/commuter_notifications.dart';

class ProfileNotificationsPage extends StatefulWidget {
  const ProfileNotificationsPage({super.key, required this.client});

  final CommuterApi client;

  @override
  State<ProfileNotificationsPage> createState() =>
      _ProfileNotificationsPageState();
}

class _ProfileNotificationsPageState extends State<ProfileNotificationsPage> {
  NotificationPreferencesSnapshot? _snapshot;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final generation = widget.client.sessionGeneration;
    try {
      final snapshot = await widget.client.notificationPreferences();
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() {
        _snapshot = snapshot;
        _error = null;
      });
    } catch (error) {
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() => _error = error);
    }
  }

  Future<void> _save({String? time, bool? optional}) async {
    final current = _snapshot;
    if (current == null || _saving) return;
    final generation = widget.client.sessionGeneration;
    setState(() => _saving = true);
    try {
      final input = NotificationPreferencesInput(
        (b) => b
          ..dailyAskTime = time ?? current.preferences.dailyAskTime
          ..optionalUpdatesEnabled =
              optional ?? current.preferences.optionalUpdatesEnabled,
      );
      final updated = await widget.client.updateNotificationPreferences(
        input,
        current.editToken,
      );
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() {
        _snapshot = updated;
        _error = null;
      });
    } catch (error) {
      if (!mounted || generation != widget.client.sessionGeneration) return;
      setState(() => _error = error);
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save. Your settings were refreshed.'),
          ),
        );
      }
    } finally {
      if (mounted && generation == widget.client.sessionGeneration) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _chooseDailyAskTime(String current) async {
    final parts = current.split(':');
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (!mounted || selected == null) return;
    if (selected.hour < 6 || selected.hour > 21) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a time between 6:00 AM and 9:59 PM.'),
        ),
      );
      return;
    }
    final value =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    if (value != current) await _save(time: value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final preferences = _snapshot?.preferences;
    final push = CommuterNotificationsScope.maybeOf(context);
    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTypography.title.copyWith(color: colors.textPrimary),
        ),
        backgroundColor: colors.backgroundDefault,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: preferences == null
              ? _error == null
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Could not load notification settings.'),
                          TextButton(
                            onPressed: _reload,
                            child: const Text('Retry'),
                          ),
                        ],
                      )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  children: [
                    Text(
                      'Stay in the loop',
                      style: AppTypography.heading2.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you hear about rides and when we ask about your next seat.',
                      style: AppTypography.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Ride alerts',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ride updates are always saved in your inbox.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (push != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated,
                          border: Border.all(color: colors.borderSubtle),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications_outlined,
                                    color: colors.actionPrimaryDefault,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Phone alerts',
                                    style: AppTypography.label.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                push.status,
                                style: AppTypography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                              if (!push.enabled) ...[
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: push.enable,
                                  icon: const Icon(
                                    Icons.notifications_active_outlined,
                                  ),
                                  label: const Text('Enable ride alerts'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    Text(
                      'When to ask about your next ride',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We’ll ask before your next commute. You can respond later from your inbox.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _saving
                          ? null
                          : () => _chooseDailyAskTime(preferences.dailyAskTime),
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        TimeOfDay(
                          hour: int.parse(
                            preferences.dailyAskTime.substring(0, 2),
                          ),
                          minute: int.parse(
                            preferences.dailyAskTime.substring(3, 5),
                          ),
                        ).format(context),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Other updates',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: colors.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: colors.borderSubtle),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          'News and promotions',
                          style: AppTypography.label.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Occasional Trotxi news. Trip and account messages still arrive when this is off.',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        value: preferences.optionalUpdatesEnabled,
                        onChanged: _saving
                            ? null
                            : (value) => _save(optional: value),
                      ),
                    ),
                    if (_saving) const LinearProgressIndicator(),
                  ],
                ),
        ),
      ),
    );
  }
}
