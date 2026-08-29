import 'package:flutter/material.dart';

abstract final class AppRadii {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;

  /// Figma prototype shell references only. These do not clip app content.
  static const double phoneShell = 28;
  static const double tabletPortraitShell = 32;
  static const double tabletLandscapeShell = 28;

  static BorderRadius circular(double radius) => BorderRadius.circular(radius);
}
