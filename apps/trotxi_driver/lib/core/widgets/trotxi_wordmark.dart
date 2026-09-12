import 'package:flutter/material.dart';

/// The Trotxi wordmark, in the variant the current theme needs.
///
/// Two PNGs rather than one tinted asset: the mark is not monochrome. The
/// arrow keeps its off-blue and the green accent stays green in both themes,
/// so only the lettering changes, and a single asset under a colour filter
/// would flatten the parts that are meant to stay put.
///
/// Exported from the design file at 4x, which is what the densest phone this
/// app is likely to meet will ask for.
class TrotxiWordmark extends StatelessWidget {
  const TrotxiWordmark({super.key, this.height = 51});

  /// The file draws it at 51 on sign-in and 42 on the screens that also carry
  /// a back control.
  final double height;

  @override
  Widget build(BuildContext context) {
    final asset = Theme.of(context).brightness == Brightness.dark
        ? 'assets/brand/trotxi-wordmark-dark.png'
        : 'assets/brand/trotxi-wordmark-light.png';
    return Image.asset(
      asset,
      height: height,
      // The mark is decorative here: every frame that shows it also carries the
      // screen title as text, so announcing it twice would only slow a reader
      // down.
      excludeFromSemantics: true,
    );
  }
}
