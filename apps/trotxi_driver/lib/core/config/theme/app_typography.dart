import 'package:flutter/material.dart';

/// The driver type scale.
///
/// Shares the commuter app's brand display face, while supporting text uses
/// the platform's native face for clarity at small sizes. One difference:
/// [runTitle] and [counter] exist because the active-trip frames lean on two
/// numbers a driver reads at a glance while moving — seats boarded against
/// capacity, and stop N of M. Those are not body text and should not inherit
/// body's line height.
abstract final class AppTypography {
  /// A null family lets body text use the platform's native UI face.
  static const String? fontFamily = null;

  /// Bundled brand face, reserved for short display text and glanceable values.
  static const String displayFontFamily = 'Poppins';

  static const heading1 = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.2,
  );

  static const heading2 = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: -0.1,
  );

  static const heading3 = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  static const title = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  /// "7:40 Medina · Circle" — the run identity, on every trip screen.
  static const runTitle = TextStyle(
    fontFamily: displayFontFamily,
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
    fontFamily: displayFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 27 / 18,
  );

  /// The uppercase label inside a status chip, raised for legibility.
  static const chipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 18 / 12,
    letterSpacing: 0.44,
  );

  /// The small uppercase heading above a number in a stat tile.
  static const tileLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 18 / 12,
    letterSpacing: 0.3,
  );

  /// The line under a stat tile's number, such as "7 remaining".
  static const tileCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 19 / 13,
  );

  /// "11 / 18" and "3 of 11". Tabular so the layout does not jump as riders
  /// board and the digits change width.
  static const counter = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 32 / 28,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// One small scale shared by the sign-in, account and device-readiness
  /// screens (pages 05 and 06). Before these existed each screen borrowed
  /// whichever trip-screen token was nearest, so the same kind of line was 10px
  /// on one screen and 24px on the next.
  ///
  /// The question above a pair of choices: "Is this your account?". 14/600 in
  /// the file; one step up so it reads as the prompt it is.
  static const authQuestion = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 22 / 15,
  );

  /// The driver's name on an identity card. 18/600.
  static const authName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 27 / 18,
  );

  /// The first line of a card row: "Location", "Driver ID" value side.
  static const authRowTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  /// The second line of a card row, and a detail label, kept readable on a
  /// phone clamped to a windscreen.
  static const authRowDetail = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  /// A detail value beside [authRowDetail].
  static const authRowValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  /// The one line of small print under a screen's actions.
  static const authCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
  );

  /// The centred title on a full-screen auth or readiness frame. 26/600 in the
  /// file, deliberately smaller than [heading1]: these screens lead with the
  /// wordmark, so the title sits under a logo rather than carrying the page.
  static const screenTitle = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 39 / 26,
  );

  /// The one explanatory line under [screenTitle].
  static const screenContext = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  /// The label above an input, and inline links at this size.
  static const fieldLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );

  /// What a driver types, and the placeholder before they do. The file draws
  /// the placeholder at 400 and the entered value at 500.
  static const fieldText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 21 / 14,
  );

  /// The label on the primary action. 16/700, heavier than [label].
  static const actionLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
  );

  /// The smallest type in the app: notes and inline field errors.
  static const footnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
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
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 18 / 13,
    letterSpacing: 0.2,
  );

  /// The boarding code as the rider shows it and the driver retypes it.
  /// Monospaced-by-feature so four characters stay evenly spaced.
  static const boardingCode = TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: 8,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
