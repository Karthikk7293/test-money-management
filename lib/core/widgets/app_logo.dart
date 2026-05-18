import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 140});

  /// Width of the logo. Height is derived from the 1.26:1 source aspect ratio.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size / 1.26,
      child: CustomPaint(painter: _AppLogoPainter()),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  // Coordinates are normalized to the bounding box of the original artwork
  // (width:height ≈ 1.26:1). Both parallelograms share the same skew so that
  // the top-blue and bottom-indigo shapes read as one stacked logo.

  static const _blueQuad = [
    Offset(0.24, 0.07), // top-left
    Offset(0.84, 0.26), // top-right
    Offset(0.62, 0.60), // bottom-right
    Offset(0.02, 0.40), // bottom-left
  ];

  static const _indigoQuad = [
    Offset(0.40, 0.45),
    Offset(0.99, 0.64),
    Offset(0.78, 0.98),
    Offset(0.18, 0.79),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawQuad(canvas, size, _indigoQuad, AppColors.logoDark);
    _drawQuad(canvas, size, _blueQuad, AppColors.logoLight);
  }

  void _drawQuad(Canvas canvas, Size size, List<Offset> quad, Color color) {
    final path = Path()
      ..moveTo(size.width * quad[0].dx, size.height * quad[0].dy);
    for (int i = 1; i < quad.length; i++) {
      path.lineTo(size.width * quad[i].dx, size.height * quad[i].dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
