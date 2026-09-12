/// The 4pt spacing scale the driver frames are laid out on.
///
/// Same scale as the commuter app on purpose: the two apps differ in palette,
/// not in rhythm, and a shared scale is what lets a screenshot of one be read
/// against the other.
abstract final class AppSpacing {
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;

  /// Both odd numbers, and both straight out of the file: the GPS indicator
  /// pads 10 vertically, and every stat tile pads 14 all round.
  static const double space10 = 10;
  static const double space14 = 14;

  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;
}
