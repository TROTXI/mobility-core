import 'package:flutter/material.dart';

/// Corner radii used across the driver frames.
abstract final class AppRadii {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Pills: status chips ("Location sharing live"), and the primary buttons on
  /// the boarding screens.
  static const double full = 999;

  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
}
