import 'package:flutter/material.dart';

/// Temporary placeholder logo for TERM.
///
/// This draws a simple white graduation-cap shape using CustomPainter.
/// It is intentionally isolated so it can be replaced later with an
/// official SVG/PNG asset without refactoring the header.
class TermLogo extends StatelessWidget {
  final double size;

  const TermLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TermLogoPainter(), size: Size(size, size)),
    );
  }
}

class _TermLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = height / 2;
    final double capSize = width * 0.55;
    final double top = centerY - capSize * 0.35;
    final double bottom = centerY + capSize * 0.45;

    // Graduation cap top triangle.
    final trianglePath = Path()
      ..moveTo(centerX - capSize * 0.55, top + capSize * 0.35)
      ..lineTo(centerX, top)
      ..lineTo(centerX + capSize * 0.55, top + capSize * 0.35)
      ..close();
    canvas.drawPath(trianglePath, paint);

    // Cap base rectangle.
    final baseRect = Rect.fromLTWH(
      centerX - capSize * 0.7,
      top + capSize * 0.35,
      capSize * 1.4,
      capSize * 0.28,
    );
    canvas.drawRect(baseRect, paint);

    // Tassel line and dot.
    final tasselCenter = Offset(centerX + capSize * 0.55, bottom);
    canvas.drawLine(
      Offset(centerX + capSize * 0.55, top + capSize * 0.35),
      tasselCenter,
      paint,
    );
    canvas.drawCircle(tasselCenter, width * 0.06, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
