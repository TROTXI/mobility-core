import 'package:flutter/material.dart';

/// The driver type scale.
///
/// Shares the commuter app's family and ramp, with one deliberate difference:
/// [runTitle] and [counter] exist because the active-trip frames lean on two
/// numbers a driver reads at a glance while moving — seats boarded against
/// capacity, and stop N of M. Those are not body text and should not inherit
/// body's line height.
abstract final class AppTypography {
  /// Bundled from assets/fonts (#236). Until it was, this named a face that did
  /// not ship, so every screen rendered in SF Pro or Roboto and only the sizes
  /// and weights below took effect — which is most of why the built screens did
  /// not look like the file.
  ///
  /// The commuter app still has that gap.
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

  /// A key on the boarding keypad, and the CLEAR beside it. 14/500 in the file
  /// for a key, 13/600 for CLEAR; one style covers both at this size.
  static const keyLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// BOARD. Heavier than the keys around it, because it is the one that acts.
  static const keyAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.4,
  );

  /// The stop name on the next-stop card. 18/700 in the file — heavier than
  /// [title] at the same sort of size, because it is the one word a driver
  /// reads while moving.
  static const stopName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 27 / 18,
  );

  /// The uppercase label inside a status chip. 11/600 at 0.44 letter spacing,
  /// straight off Components / Driver Status Chips.
  static const chipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 17 / 11,
    letterSpacing: 0.44,
  );

  /// The small uppercase heading above a number in a stat tile — "BOARDED",
  /// "STOP", "NEXT STOP". 10/600 in the file.
  static const tileLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 15 / 10,
    letterSpacing: 0.3,
  );

  /// The line under a stat tile's number — "7 remaining", "Shiashie next".
  static const tileCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 17 / 11,
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
