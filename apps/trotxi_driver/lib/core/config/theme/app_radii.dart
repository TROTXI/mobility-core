import 'package:flutter/material.dart';

/// Corner radii used across the driver frames.
abstract final class AppRadii {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  /// Buttons other than the primary, and the manifest passenger row. The file
  /// is specific: only the primary action is a pill; secondary, quiet and
  /// destructive are rounded rectangles.
  static const double button = 14;

  /// Status chips, and the GPS indicator's own corner is 20.
  static const double chip = 16;
  static const double indicator = 20;

  static const double xl = 24;

  /// The Active Trip Hero's own corner. 22 in the file — between the 20 of a
  /// card and the 24 of an assignment card, and worth keeping exact because the
  /// hero is the largest surface on the screen.
  static const double hero = 22;

  /// The phone nav bar. 38 in the file — a stadium at its 76 height.
  static const double navBar = 38;

  /// The primary action's corner. 28 on a 56-high button is a stadium, which is
  /// what the file draws — and it draws it for the primary alone.
  static const double pill = 28;

  /// Fully round, for things whose height varies: the small status pills inside
  /// the GPS indicator and the hero's paired actions.
  static const double full = 999;

  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
}
