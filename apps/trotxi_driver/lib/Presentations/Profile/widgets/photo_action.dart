import 'package:flutter/material.dart';
import 'package:trotxi_driver/core/config/theme/app_colors.dart';
import 'package:trotxi_driver/core/config/theme/app_typography.dart';

/// The control that changes the driver's photo.
///
/// A real button, not a tappable label. A GestureDetector around a bare Text
/// defers hit testing to the child, and a Text does not hit test itself, so
/// the first version of this looked exactly right and did nothing at all. A
/// button also gives the control the tap target and the semantics a label
/// never had.
class PhotoAction extends StatelessWidget {
  const PhotoAction({
    super.key,
    required this.hasPhoto,
    required this.busy,
    required this.onPressed,
  });

  final bool hasPhoto;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.driverColors;
    return TextButton(
      onPressed: busy ? null : onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        minimumSize: const Size(0, 44),
        foregroundColor: colors.action,
        disabledForegroundColor: colors.textSecondary,
      ),
      child: Text(
        busy
            ? 'Uploading…'
            : hasPhoto
            ? 'Change photo'
            : 'Add a photo',
        style: AppTypography.label,
      ),
    );
  }
}
