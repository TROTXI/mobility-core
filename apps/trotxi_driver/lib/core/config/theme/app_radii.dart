import 'package:flutter/material.dart';

/// Corner radii used across the driver frames.
abstract final class AppRadii {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;

  /// Supporting buttons and passenger rows.
  static const double button = 14;

  /// Shared input corners.
  static const double field = 16;

  /// The quiet note card that carries a single explanatory line — the operator
  /// linking note under sign-in. 20 in the file.
  static const double note = 20;

  /// Status chips, and the GPS indicator's own corner is 20.
  static const double chip = 16;
  static const double indicator = 20;

  static const double xl = 24;

  /// The Active Trip Hero's own corner. 22 in the file — between the 20 of a
  /// card and the 24 of an assignment card, and worth keeping exact because the
  /// hero is the largest surface on the screen.
  static const double hero = 22;

  /// Rounded phone navigation surface.
  static const double navBar = 20;

  /// Primary actions use the commuter app's rounded rectangle shape.
  static const double pill = 16;

  /// Fully round, for things whose height varies: the small status pills inside
  /// the GPS indicator and the hero's paired actions.
  static const double full = 999;

  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
}
