import 'package:flutter/material.dart';

/// Trotxi's platform-aware production scroll behavior.
///
/// Android's Material 3 default uses a stretching overscroll indicator. That
/// effect deforms large commuter surfaces, so Android uses clamping without an
/// overscroll decoration while other platforms retain their native behavior.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return const ClampingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return child;
    }
    return super.buildOverscrollIndicator(context, child, details);
  }
}
