import 'package:flutter/material.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_client/commuter_data_client.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final preferences = _snapshot?.preferences;
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
          constraints: const BoxConstraints(maxWidth: 640),
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
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Ride notifications',
                      style: AppTypography.title.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seat confirmations, trip changes, boarding receipts and cancellations are always on so you do not miss a ride.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Preferred daily seat-ask time',
                      style: AppTypography.label.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: preferences.dailyAskTime,
                      items: [
                        for (var hour = 6; hour <= 21; hour++)
                          DropdownMenuItem(
                            value: '${hour.toString().padLeft(2, '0')}:00',
                            child: Text(
                              TimeOfDay(hour: hour, minute: 0).format(context),
                            ),
                          ),
                      ],
                      onChanged: _saving
                          ? null
                          : (time) {
                              if (time != null) _save(time: time);
                            },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saved for scheduled dispatch in Ghana time. During the pilot, seat asks are run manually, so this does not schedule delivery yet.',
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Optional updates'),
                      subtitle: const Text(
                        'Product news and non-essential messages',
                      ),
                      value: preferences.optionalUpdatesEnabled,
                      onChanged: _saving
                          ? null
                          : (value) => _save(optional: value),
                    ),
                    if (_saving) const LinearProgressIndicator(),
                  ],
                ),
        ),
      ),
    );
  }
}
