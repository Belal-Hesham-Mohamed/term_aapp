import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AppBackgroundPainter(),
      size: Size.infinite,
      child: child,
    );
  }
}

class _AppBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Light content background fills the whole canvas first.
    final backgroundPaint = Paint()..color = AppColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    // Blue region: deeper on the left, shallower on the right, with a smooth sweeping curve.
    final bluePath = Path();
    bluePath.moveTo(0, 0);
    bluePath.lineTo(width, 0);
    bluePath.lineTo(width, height * 0.12);
    bluePath.cubicTo(
      width * 0.7,
      height * 0.12 + height * 0.02,
      width * 0.3,
      height * 0.38 - height * 0.02,
      0,
      height * 0.38,
    );
    bluePath.close();

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [AppColors.darkBlue, AppColors.primary, AppColors.primary],
    ).createShader(Rect.fromLTWH(0, 0, width, height));

    final bluePaint = Paint()..shader = gradient;
    canvas.drawPath(bluePath, bluePaint);

    // Soften the curve edge with a subtle translucent stroke.
    final curvePath = Path();
    curvePath.moveTo(width, height * 0.12);
    curvePath.cubicTo(
      width * 0.7,
      height * 0.12 + height * 0.02,
      width * 0.3,
      height * 0.38 - height * 0.02,
      0,
      height * 0.38,
    );

    final featherPaint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = height * 0.04
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawPath(curvePath, featherPaint);

    // Subtle translucent wave accents in the lower right for gentle depth.
    final accentPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final accentPath1 = Path();
    final accentY1 = height * 0.84;
    final accentAmp1 = height * 0.025;
    accentPath1.moveTo(width * 0.55, height);
    accentPath1.cubicTo(
      width * 0.65,
      accentY1 - accentAmp1,
      width * 0.85,
      accentY1 - accentAmp1 * 1.2,
      width,
      accentY1 + accentAmp1 * 0.5,
    );
    accentPath1.lineTo(width, height);
    accentPath1.close();
    canvas.drawPath(accentPath1, accentPaint);

    final accentPath2 = Path();
    final accentY2 = height * 0.91;
    final accentAmp2 = height * 0.018;
    accentPath2.moveTo(width * 0.7, height);
    accentPath2.cubicTo(
      width * 0.78,
      accentY2 - accentAmp2,
      width * 0.92,
      accentY2 - accentAmp2,
      width,
      accentY2 + accentAmp2 * 0.8,
    );
    accentPath2.lineTo(width, height);
    accentPath2.close();
    canvas.drawPath(accentPath2, accentPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
