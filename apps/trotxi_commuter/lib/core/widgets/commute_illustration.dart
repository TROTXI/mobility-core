import 'package:flutter/material.dart';

/// Decorative route artwork, not a live map or an available service.
/// Vector drawing keeps onboarding small and works without a network request.
class CommuteIllustration extends StatelessWidget {
  const CommuteIllustration({super.key, this.height = 210});
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _CommutePainter()),
      ),
    ),
  );
}

class _CommutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 340, size.height / 210);
    final paint = Paint();
    void block(
      double x,
      double y,
      double w,
      double h,
      Color color, [
      double r = 5,
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
        paint
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    block(0, 0, 340, 210, const Color(0xFFE7EFD9), 0);
    canvas.drawCircle(
      const Offset(300, 15),
      94,
      paint..color = const Color(0xFFD9E7B9),
    );
    for (final b in [
      [18.0, 40.0, 23.0, 70.0],
      [48.0, 62.0, 36.0, 48.0],
      [91.0, 20.0, 18.0, 90.0],
      [248.0, 149.0, 34.0, 61.0],
      [291.0, 134.0, 27.0, 76.0],
    ]) {
      block(b[0], b[1], b[2], b[3], const Color(0xFFC2D0AA));
    }
    final road = Path()
      ..moveTo(-10, 148)
      ..lineTo(100, 148)
      ..quadraticBezierTo(130, 148, 130, 116)
      ..lineTo(130, 110)
      ..quadraticBezierTo(130, 75, 165, 75)
      ..lineTo(350, 75);
    canvas.drawPath(
      road,
      paint
        ..color = const Color(0xFFFAFBF1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32,
    );
    paint
      ..color = const Color(0xFF6C8F61)
      ..strokeWidth = 2;
    for (final metric in road.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
      }
    }
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(300, 75),
      8,
      paint..color = const Color(0xFFFCFAEC),
    );
    canvas.drawCircle(
      const Offset(300, 75),
      5,
      paint..color = const Color(0xFFC79B53),
    );
    block(160, 48, 64, 43, const Color(0xFF244B38), 12);
    block(169, 55, 43, 20, const Color(0xFFDDE8C8), 5);
    canvas.drawCircle(
      const Offset(174, 91),
      6,
      paint..color = const Color(0xFF244B38),
    );
    canvas.drawCircle(const Offset(211, 91), 6, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CommutePainter oldDelegate) => false;
}
