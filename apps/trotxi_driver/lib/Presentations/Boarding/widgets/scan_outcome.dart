import 'package:flutter/material.dart';
import 'package:trotxi_driver/Presentations/Boarding/models/scan_result.dart';
import 'package:trotxi_driver/core/config/corridor_time.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_radii.dart';
import 'package:trotxi_driver/core/config/theme/app_spacing.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';
import 'package:trotxi_driver/core/state/run_controller.dart';

/// What the scan card shows once an attempt has an answer (design page 11).
///
/// Five frames in the file, one widget here: an accepted pass shows the rider,
/// and everything else shows the exception. The wording comes from
/// [BoardingResult], which keeps twelve outcomes apart where the file draws
/// three — a forged QR, a code nobody holds and a dead session all look the
/// same on a screenshot and mean entirely different things at a door.
class ScanOutcome extends StatelessWidget {
  const ScanOutcome({
    super.key,
    required this.result,
    required this.data,
    required this.tone,
  });

  final BoardingResult result;

  /// The run and its manifest, for the photo, the position and the stop. Null
  /// while the run has not loaded, which the panel renders around rather than
  /// waiting for: the boarding already happened.
  final RunDetail? data;

  final Color tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        color: result.isAccepted ? colors.field : colors.surface,
        borderRadius: AppRadii.circular(AppRadii.xl),
        border: Border.all(color: tone, width: 2),
      ),
      child: result.isAccepted
          ? _Accepted(result: result, data: data, colors: colors, tone: tone)
          : _Exception(result: result, colors: colors, tone: tone),
    );
  }
}

/// An accepted pass: who it was, and what it cost them.
///
/// The photo is the point of a photo-pass (#41) — it is the server's copy, not
/// the rider's, so a driver who looks at it is checking a face against a record
/// the rider cannot edit. It comes from the manifest rather than the boarding
/// response, which carries a name and an id but no image.
class _Accepted extends StatelessWidget {
  const _Accepted({
    required this.result,
    required this.data,
    required this.colors,
    required this.tone,
  });

  final BoardingResult result;
  final RunDetail? data;
  final AppColors colors;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final riders = data?.riders ?? const [];
    final index = riders.indexWhere(
      (r) => r.reservationId == result.reservationId,
    );
    final rider = index >= 0 ? riders[index] : null;
    final run = data?.run;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Photo(url: rider?.avatarUrl, colors: colors),
            const SizedBox(width: AppSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.riderName ?? rider?.name ?? 'Rider',
                    style: AppTypography.heading3.copyWith(
                      fontSize: 22,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  if (index >= 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space12,
                        vertical: AppSpacing.space4,
                      ),
                      decoration: BoxDecoration(
                        color: tone,
                        borderRadius: AppRadii.circular(AppRadii.chip),
                      ),
                      // The file prints "SEAT 12A". Trotros do not assign
                      // seats (#229), so this is the rider's place on the
                      // manifest — the same "#3" the list shows, so a driver
                      // checking one against the other sees one number.
                      child: Text(
                        '#${index + 1}',
                        style: AppTypography.chipLabel.copyWith(
                          color: colors.textInverse,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'PASS ACCEPTED · BOARDED',
                    style: AppTypography.tileLabel.copyWith(color: tone),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space20),
        if (run != null) ...[
          Text(
            '${CorridorTime.hhmm(run.scheduledAt)} ${run.routeName}',
            style: AppTypography.label.copyWith(
              fontSize: 16,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            data?.currentStopName == null
                ? 'Boarded on ${run.routeName}'
                : 'Boarded at ${data!.currentStopName} · Stop '
                      '${data!.currentStopNumber} of ${data!.stops.length}',
            style: AppTypography.tileCaption.copyWith(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.space16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.space12),
          decoration: BoxDecoration(
            color: colors.surfaceStrong,
            borderRadius: AppRadii.circular(AppRadii.field),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _Detail(
                    label: 'RIDE',
                    value: result.deducted ? '1 deducted' : 'None deducted',
                    colors: colors,
                  ),
                  _Detail(
                    label: 'PASS',
                    value: 'Valid',
                    colors: colors,
                    tone: tone,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space8),
              Row(
                children: [
                  _Detail(
                    label: 'TYPE',
                    value: rider == null
                        ? 'Manifest'
                        : _sentence(rider.direction),
                    colors: colors,
                  ),
                  _Detail(
                    label: 'VEHICLE',
                    // Dropped rather than invented, the same rule the hero's
                    // second line follows.
                    value: data?.vehicleRegistration ?? 'Not assigned',
                    colors: colors,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "morning" as the file sets it: "Morning".
///
/// @param word - the API's lower-case value.
/// @returns the word with its first letter capitalised.
String _sentence(String word) =>
    word.isEmpty ? word : word[0].toUpperCase() + word.substring(1);

/// One label-over-value pair in the accepted panel's detail strip.
class _Detail extends StatelessWidget {
  const _Detail({
    required this.label,
    required this.value,
    required this.colors,
    this.tone,
  });

  final String label;
  final String value;
  final AppColors colors;
  final Color? tone;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.tileLabel.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          value,
          style: AppTypography.fieldText.copyWith(
            fontWeight: FontWeight.w600,
            color: tone ?? colors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

/// Everything that is not an accepted pass.
///
/// One shape for all of them, because the driver's job is the same in each
/// case: read what happened, read what to do, get back to the queue. The
/// wording is [BoardingResult]'s, which keeps twelve outcomes apart where the
/// file draws three.
class _Exception extends StatelessWidget {
  const _Exception({
    required this.result,
    required this.colors,
    required this.tone,
  });

  final BoardingResult result;
  final AppColors colors;
  final Color tone;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        child: Icon(
          switch (result.outcome) {
            BoardingOutcome.alreadyBoarded => Icons.check,
            BoardingOutcome.offline => Icons.wifi_off,
            _ => Icons.priority_high,
          },
          size: 40,
          color: colors.textInverse,
        ),
      ),
      const SizedBox(height: AppSpacing.space24),
      Text(
        result.title,
        textAlign: TextAlign.center,
        style: AppTypography.heading3.copyWith(
          fontSize: 22,
          color: colors.textPrimary,
        ),
      ),
      const SizedBox(height: AppSpacing.space12),
      Text(
        result.detail,
        textAlign: TextAlign.center,
        style: AppTypography.screenContext.copyWith(
          fontSize: 13,
          color: colors.textSecondary,
        ),
      ),
    ],
  );
}

/// The rider's photo, or the placeholder the file draws when there is none.
class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.colors});

  final String? url;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => Container(
    width: 116,
    height: 146,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: colors.surfaceStrong,
      borderRadius: AppRadii.circular(AppRadii.field),
      border: Border.all(color: colors.border),
    ),
    child: url == null
        ? Center(
            child: Text(
              'NO PHOTO',
              style: AppTypography.tileLabel.copyWith(
                color: colors.textSecondary,
              ),
            ),
          )
        : Image.network(
            url!,
            fit: BoxFit.cover,
            // A photo that will not load must not blank the panel: the
            // boarding still happened and the driver still needs the rest.
            errorBuilder: (_, _, _) => Center(
              child: Text(
                'NO PHOTO',
                style: AppTypography.tileLabel.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
  );
}
