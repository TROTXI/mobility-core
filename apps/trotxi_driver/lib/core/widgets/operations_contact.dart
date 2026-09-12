import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/data/config_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// Place a call to operations.
///
/// Returns false when the handset refuses — a tablet with no dialler, or a
/// permission the OS declined. The caller shows the number as text in that
/// case, because a driver who cannot tap it can still read it to someone.
///
/// @param phone - the number, in E.164.
/// @returns whether the dialler opened.
Future<bool> dialOperations(String phone) async {
  // Strip the separators a human might have typed into the dashboard. `tel:`
  // tolerates most of them, but not all diallers do.
  final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
  try {
    return await launchUrl(Uri(scheme: 'tel', path: digits));
  } on Exception {
    return false;
  }
}

/// How to reach operations, or an honest statement that we do not know.
///
/// The second state is the reason this is one widget rather than a number
/// printed on three screens. When no contact is configured it says so plainly
/// instead of showing a dead button, and the copy never promises that details
/// will arrive later — the old screen did, and nothing kept that promise.
class OperationsContactCard extends StatelessWidget {
  const OperationsContactCard({
    super.key,
    required this.contact,
    required this.isLoaded,
    this.title = 'Operations',
    this.emptyDetail,
  });

  final OperationsContact contact;

  /// Whether the config fetch has finished. Before it has, the card says it is
  /// still loading rather than claiming there is no number.
  final bool isLoaded;

  final String title;

  /// What to say when there is no number. Defaults to something generic; the
  /// recovery screen overrides it, because a driver who cannot sign in needs a
  /// different next step from one reporting a broken door.
  final String? emptyDetail;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.circular(AppRadii.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space8),
          if (!isLoaded)
            Text(
              'Loading contact details…',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            )
          else if (!contact.hasAny)
            Text(
              emptyDetail ??
                  'Your operator has not published contact details. Ask at the '
                      'depot office.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            )
          else ...[
            if (contact.phone != null) ...[
              Text(
                contact.phone!,
                style: AppTypography.title.copyWith(color: colors.textPrimary),
              ),
              if (contact.hours != null) ...[
                const SizedBox(height: AppSpacing.space4),
                Text(
                  contact.hours!,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.space12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _call(context, contact.phone!),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call operations'),
                ),
              ),
            ],
            if (contact.whatsapp != null) ...[
              const SizedBox(height: AppSpacing.space8),
              Text(
                'WhatsApp ${contact.whatsapp}',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
            if (contact.email != null) ...[
              const SizedBox(height: AppSpacing.space4),
              Text(
                contact.email!,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// Dial, and fall back to showing the number when the handset will not.
  ///
  /// @param context - for the fallback message.
  /// @param phone - the number to dial.
  Future<void> _call(BuildContext context, String phone) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await dialOperations(phone);
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text('Dial $phone')));
    }
  }
}
