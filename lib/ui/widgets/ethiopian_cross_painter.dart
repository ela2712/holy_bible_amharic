import 'dart:math' as math;
import 'package:flutter/material.dart';

enum EthiopianCrossStyle {
  lalibela,
  axum,
  gondar,
  none,
}

/// Custom painter for authentic Ethiopian Orthodox Crosses
class EthiopianCrossPainter extends CustomPainter {
  final EthiopianCrossStyle style;
  final Color color;
  final double strokeWidth;

  const EthiopianCrossPainter({
    required this.style,
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (style == EthiopianCrossStyle.none) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    switch (style) {
      case EthiopianCrossStyle.lalibela:
        _drawLalibelaCross(canvas, center, radius, paint, fillPaint);
        break;
      case EthiopianCrossStyle.axum:
        _drawAxumCross(canvas, center, radius, paint, fillPaint);
        break;
      case EthiopianCrossStyle.gondar:
        _drawGondarCross(canvas, center, radius, paint, fillPaint);
        break;
      case EthiopianCrossStyle.none:
        break;
    }
  }

  /// Authentic Lalibela Cross: Flared cross arms with nested diamond core and interlaced finials
  void _drawLalibelaCross(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    Paint fillPaint,
  ) {
    final cx = center.dx;
    final cy = center.dy;
    final r = radius * 0.9;
    final armW = r * 0.22;

    // 1. Central Diamond
    final diamondPath = Path()
      ..moveTo(cx, cy - armW * 1.5)
      ..lineTo(cx + armW * 1.5, cy)
      ..lineTo(cx, cy + armW * 1.5)
      ..lineTo(cx - armW * 1.5, cy)
      ..close();
    canvas.drawPath(diamondPath, fillPaint);
    canvas.drawPath(diamondPath, paint);

    // Inner diamond core
    final innerDiamond = Path()
      ..moveTo(cx, cy - armW * 0.7)
      ..lineTo(cx + armW * 0.7, cy)
      ..lineTo(cx, cy + armW * 0.7)
      ..lineTo(cx - armW * 0.7, cy)
      ..close();
    canvas.drawPath(innerDiamond, paint);

    // 2. Four Flared Arms
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(i * math.pi / 2);

      final armPath = Path()
        ..moveTo(-armW * 0.7, -armW * 1.2)
        ..lineTo(-armW * 0.9, -r * 0.7)
        ..lineTo(-armW * 1.6, -r * 0.85)
        ..lineTo(-armW * 0.8, -r)
        ..lineTo(0, -r * 0.9)
        ..lineTo(armW * 0.8, -r)
        ..lineTo(armW * 1.6, -r * 0.85)
        ..lineTo(armW * 0.9, -r * 0.7)
        ..lineTo(armW * 0.7, -armW * 1.2);

      canvas.drawPath(armPath, fillPaint);
      canvas.drawPath(armPath, paint);

      // Decorative finial loops
      canvas.drawCircle(Offset(0, -r * 0.65), armW * 0.35, paint);
      canvas.drawCircle(Offset(-armW * 0.9, -r * 0.82), armW * 0.25, paint);
      canvas.drawCircle(Offset(armW * 0.9, -r * 0.82), armW * 0.25, paint);

      canvas.restore();
    }
  }

  /// Authentic Axumite Cross: Circular halos and concentric geometric motifs
  void _drawAxumCross(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    Paint fillPaint,
  ) {
    final cx = center.dx;
    final cy = center.dy;
    final r = radius * 0.88;

    // Central concentric circles
    canvas.drawCircle(center, r * 0.28, fillPaint);
    canvas.drawCircle(center, r * 0.28, paint);
    canvas.drawCircle(center, r * 0.15, paint);
    canvas.drawCircle(center, r * 0.05, Paint()..color = color..style = PaintingStyle.fill);

    // Four primary cross arms extending from circle
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(i * math.pi / 2);

      final armPath = Path()
        ..moveTo(-r * 0.18, -r * 0.24)
        ..lineTo(-r * 0.14, -r * 0.7)
        ..lineTo(-r * 0.38, -r * 0.85)
        ..lineTo(-r * 0.38, -r)
        ..lineTo(r * 0.38, -r)
        ..lineTo(r * 0.38, -r * 0.85)
        ..lineTo(r * 0.14, -r * 0.7)
        ..lineTo(r * 0.18, -r * 0.24);

      canvas.drawPath(armPath, fillPaint);
      canvas.drawPath(armPath, paint);

      // Trefoil ends on arm tips
      canvas.drawCircle(Offset(0, -r * 0.9), r * 0.12, paint);
      canvas.drawCircle(Offset(-r * 0.24, -r * 0.9), r * 0.09, paint);
      canvas.drawCircle(Offset(r * 0.24, -r * 0.9), r * 0.09, paint);

      canvas.restore();
    }

    // Outer unifying circular halo ring
    canvas.drawCircle(
      center,
      r * 0.62,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.9,
    );
  }

  /// Authentic Gondar Cross: Flamboyant floral, heart and leaf filigree
  void _drawGondarCross(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    Paint fillPaint,
  ) {
    final cx = center.dx;
    final cy = center.dy;
    final r = radius * 0.88;

    // Center rosette
    canvas.drawCircle(center, r * 0.22, fillPaint);
    canvas.drawCircle(center, r * 0.22, paint);

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final px = cx + (r * 0.22) * math.cos(angle);
      final py = cy + (r * 0.22) * math.sin(angle);
      canvas.drawCircle(Offset(px, py), r * 0.06, paint);
    }

    // 4 Ornate arms with floral curls
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(i * math.pi / 2);

      final p = Path()
        ..moveTo(-r * 0.12, -r * 0.22)
        ..quadraticBezierTo(-r * 0.25, -r * 0.55, -r * 0.35, -r * 0.75)
        ..cubicTo(-r * 0.5, -r * 0.9, -r * 0.2, -r * 1.05, 0, -r)
        ..cubicTo(r * 0.2, -r * 1.05, r * 0.5, -r * 0.9, r * 0.35, -r * 0.75)
        ..quadraticBezierTo(r * 0.25, -r * 0.55, r * 0.12, -r * 0.22);

      canvas.drawPath(p, fillPaint);
      canvas.drawPath(p, paint);

      // Heart / petal internal cuts
      canvas.drawCircle(Offset(0, -r * 0.7), r * 0.12, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant EthiopianCrossPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Custom painter for traditional Ethiopian Illuminated Manuscript Haräg (ሐረግ) border
class EthiopianHaragBorderPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double borderWidth;

  const EthiopianHaragBorderPainter({
    required this.primaryColor,
    required this.secondaryColor,
    this.borderWidth = 14.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final b = borderWidth;

    final outerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final innerPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    // Draw outer boundary and inner boundary
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(4, 4, w - 8, h - 8), const Radius.circular(16)),
      outerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(b, b, w - 2 * b, h - 2 * b), const Radius.circular(10)),
      innerPaint,
    );

    // Decorative corner Haräg rosettes / cross knots
    final corners = [
      Offset(b * 0.8, b * 0.8),
      Offset(w - b * 0.8, b * 0.8),
      Offset(b * 0.8, h - b * 0.8),
      Offset(w - b * 0.8, h - b * 0.8),
    ];

    for (final c in corners) {
      canvas.drawCircle(c, b * 0.45, fillPaint);
      canvas.drawCircle(c, b * 0.45, outerPaint);
      canvas.drawCircle(c, b * 0.22, innerPaint);
      canvas.drawCircle(c, b * 0.08, Paint()..color = secondaryColor..style = PaintingStyle.fill);
    }

    // Interlaced diamond pattern along top and bottom edges
    final step = 22.0;
    final topCount = ((w - 2 * b - 20) / step).floor();
    for (int i = 0; i < topCount; i++) {
      final x = b + 15 + i * step;
      // Top Haräg knot
      final topKnot = Path()
        ..moveTo(x, 6)
        ..lineTo(x + step * 0.5, b - 2)
        ..lineTo(x + step, 6)
        ..lineTo(x + step * 0.5, 4)
        ..close();
      canvas.drawPath(topKnot, outerPaint);

      // Bottom Haräg knot
      final bottomKnot = Path()
        ..moveTo(x, h - 6)
        ..lineTo(x + step * 0.5, h - b + 2)
        ..lineTo(x + step, h - 6)
        ..lineTo(x + step * 0.5, h - 4)
        ..close();
      canvas.drawPath(bottomKnot, outerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EthiopianHaragBorderPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
