import 'package:flutter/material.dart';

/// The driver type scale.
///
/// Shares the commuter app's family and ramp, with one deliberate difference:
/// [runTitle] and [counter] exist because the active-trip frames lean on two
/// numbers a driver reads at a glance while moving — seats boarded against
/// capacity, and stop N of M. Those are not body text and should not inherit
/// body's line height.
abstract final class AppTypography {
  /// NOT BUNDLED YET. No Poppins asset ships with either app, so Flutter falls
  /// back to the platform face and only the sizes, weights and line heights
  /// below take effect. Naming it anyway keeps the switch to one line once the
  /// TTFs land in pubspec. The commuter app has the same gap.
  static const String fontFamily = 'Poppins';

  static const heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.2,
  );

  static const heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: -0.1,
  );

  static const heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  /// "7:40 Medina · Circle" — the run identity, on every trip screen.
  static const runTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 26 / 20,
  );

  /// "11 / 18" and "3 of 11". Tabular so the layout does not jump as riders
  /// board and the digits change width.
  static const counter = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 32 / 28,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );

  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  /// Status chips and the small caps above a value.
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.2,
  );

  /// The boarding code as the rider shows it and the driver retypes it.
  /// Monospaced-by-feature so four characters stay evenly spaced.
  static const boardingCode = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: 8,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
