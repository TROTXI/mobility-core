import 'package:flutter/material.dart';

class MinimumTouchTarget extends StatelessWidget {
  const MinimumTouchTarget({
    super.key,
    required this.child,
    this.minimumSize = const Size.square(44),
    this.alignment = Alignment.center,
  });

  final Widget child;
  final Size minimumSize;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minimumSize.width,
        minHeight: minimumSize.height,
      ),
      child: Align(
        alignment: alignment,
        widthFactor: 1,
        heightFactor: 1,
        child: child,
      ),
    );
  }
}
