import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trotxi_api_client/trotxi_api_client.dart';
import 'package:trotxi_commuter/Features/Home/pages/home_page_provider.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Full-page "Commute preferences", pushed from ProfileTab's
/// "Commute preferences" row.
///
/// The route comes from the rider's membership (GET /v1/me/membership) and
/// is read-only here. Commute times and the "Quiet ride" toggle are still
/// local-only preferences: there's no endpoint yet to save them.
///
/// Requires `membershipProvider` (see home_page_provider.dart):
///
/// final membershipProvider = FutureProvider.autoDispose<Membership>((ref) async {
///   final api = ref.watch(trotxiClientProvider).getRiderOwnApi();
///   final meta = ref.watch(clientMetadataProvider);
///   final response = await api.getMembership(
///     xTrotxiClient: meta.client,
///     xTrotxiBuild: meta.build,
///     xTrotxiPlatform: meta.platform,
///   );
///   final membership = response.data?.data;
///   if (membership == null) throw StateError('Empty membership response');
///   return membership;
/// });
class CommutePreferencesPage extends ConsumerStatefulWidget {
  const CommutePreferencesPage({super.key});

  @override
  ConsumerState<CommutePreferencesPage> createState() =>
      _CommutePreferencesPageState();
}

class _CommutePreferencesPageState
    extends ConsumerState<CommutePreferencesPage> {
  bool _quietRide = false;

  void _onSavePreferences() {
    // TODO: submit these preferences once there's a backend endpoint for
    // commute preferences. Held locally for now.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved on this device.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final layout = ResponsiveLayoutInfo.of(context);
    final membership = ref.watch(membershipProvider);
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
                  _buildSectionTitle(context, 'Your route'),
                  const SizedBox(height: 12),
                  membership.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => _RouteError(
                      onRetry: () => ref.invalidate(membershipProvider),
                    ),
                    data: (m) => _buildRouteCard(context, m.commute),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Ride preferences'),
                  const SizedBox(height: 12),
                  _RidePreferenceTile(
                    title: 'Quiet ride',
                    subtitle: 'Reduce non-essential notifications during trip',
                    value: _quietRide,
                    onChanged: (value) => setState(() => _quietRide = value),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: colors.actionPrimaryDefault,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: _onSavePreferences,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Save preferences',
                              style: AppTypography.buttonAction.copyWith(
                                color: colors.actionOnPrimary,
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
              'Commute preferences',
              style: AppTypography.title.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Set defaults for your regular work journey.',
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

  /// Read-only route card driven by the membership's commute.
  Widget _buildRouteCard(BuildContext context, MembershipCommute? commute) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      child: commute == null
          ? Text(
              'No commute route assigned yet.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commute.routeName,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  commute.effectiveTo == null
                      ? 'Since ${commute.effectiveFrom}'
                      : '${commute.effectiveFrom} to ${commute.effectiveTo}',
                  style: AppTypography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (commute.legs.isNotEmpty) const SizedBox(height: 12),
                for (final leg in commute.legs) _LegTile(leg: leg),
              ],
            ),
    );
  }
}

/// One leg of the commute: direction, departure time, pickup and drop-off.
class _LegTile extends StatelessWidget {
  const _LegTile({required this.leg});

  final CommuteLegView leg;

  /// "06:30" -> "6:30 AM" (or 24h, following the device setting).
  String _formatDeparture(BuildContext context, String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return raw;
    return TimeOfDay(hour: h, minute: m).format(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // Wire values are "outbound" / "return"; the generated enum names them
    // outbound / return_, so compare by name to stay independent of the type.
    final isOutbound = leg.direction.name == 'outbound';
    final label = isOutbound ? 'Morning' : 'Evening';
    final departure = _formatDeparture(context, '${leg.localDeparture}');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.backgroundDefault,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                departure,
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _StopRow(
            icon: Icons.trip_origin_rounded,
            caption: 'Pickup',
            name: '${leg.pickupName}',
          ),
          const SizedBox(height: 8),
          _StopRow(
            icon: Icons.location_on_rounded,
            caption: 'Drop-off',
            name: '${leg.dropoffName}',
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.icon,
    required this.caption,
    required this.name,
  });

  final IconData icon;
  final String caption;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.iconSubtle),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteError extends StatelessWidget {
  const _RouteError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Couldn't load your route",
            style: AppTypography.label.copyWith(color: colors.textSecondary),
          ),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

/// A pill-shaped switch row under "Ride preferences".
class _RidePreferenceTile extends StatelessWidget {
  const _RidePreferenceTile({
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(20),
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
