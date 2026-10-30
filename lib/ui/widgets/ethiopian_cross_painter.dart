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
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final secFillPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    // 1. Double Outer Frame (The Manuscript Border Margin)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(5, 5, w - 10, h - 10), const Radius.circular(16)),
      outerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(b + 2, b + 2, w - 2 * b - 4, h - 2 * b - 4), const Radius.circular(10)),
      secondaryPaint,
    );

    // 2. Corner Gondar/Axumite Cross Rosettes (የጥበብ መስቀል ቋጠሮ)
    final cornerOffsets = [
      Offset(b * 0.85, b * 0.85),
      Offset(w - b * 0.85, b * 0.85),
      Offset(b * 0.85, h - b * 0.85),
      Offset(w - b * 0.85, h - b * 0.85),
    ];

    for (final c in cornerOffsets) {
      final r = b * 0.58;
      canvas.drawCircle(c, r, fillPaint);
      canvas.drawCircle(c, r, outerPaint);
      canvas.drawCircle(c, r * 0.6, secFillPaint);
      canvas.drawCircle(c, r * 0.6, secondaryPaint);
      canvas.drawCircle(c, r * 0.22, Paint()..color = primaryColor..style = PaintingStyle.fill);

      // 4 tiny cross lobes around each corner rosette
      for (int i = 0; i < 4; i++) {
        final angle = i * math.pi / 2;
        final lx = c.dx + math.cos(angle) * (r + 3);
        final ly = c.dy + math.sin(angle) * (r + 3);
        canvas.drawCircle(Offset(lx, ly), 2.2, Paint()..color = secondaryColor..style = PaintingStyle.fill);
      }
    }

    // 3. Top Illuminated Headpiece (የራስጌ ሐረግ)
    final cx = w / 2;
    // Central headpiece arch / crown
    final crownPath = Path()
      ..moveTo(cx - 24, b + 2)
      ..cubicTo(cx - 16, b - 12, cx - 8, 4, cx, 3)
      ..cubicTo(cx + 8, 4, cx + 16, b - 12, cx + 24, b + 2)
      ..close();
    canvas.drawPath(crownPath, secFillPaint);
    canvas.drawPath(crownPath, outerPaint);

    // Apex Cross on Top Headpiece
    final apexCross = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx, 7)
      ..moveTo(cx - 3.5, 3.5)
      ..lineTo(cx + 3.5, 3.5);
    canvas.drawPath(apexCross, Paint()..color = secondaryColor..style = PaintingStyle.stroke..strokeWidth = 2);

    // 4. Interlaced Ribbon Guilloche / Straps along Top & Bottom Frames
    final step = 20.0;
    final margin = b + 18.0;
    final horizCount = ((w - 2 * margin) / step).floor();

    for (int i = 0; i < horizCount; i++) {
      final x = margin + i * step;

      // Skip under central headpiece
      if ((x - cx).abs() < 22) continue;

      // Top braided loop (ማዕበል ሐረግ)
      final topKnot = Path()
        ..moveTo(x, 6)
        ..quadraticBezierTo(x + step * 0.5, b, x + step, 6)
        ..quadraticBezierTo(x + step * 0.5, 3, x, 6);
      canvas.drawPath(topKnot, i % 2 == 0 ? fillPaint : secFillPaint);
      canvas.drawPath(topKnot, i % 2 == 0 ? outerPaint : secondaryPaint);

      // Bottom braided loop
      final bottomKnot = Path()
        ..moveTo(x, h - 6)
        ..quadraticBezierTo(x + step * 0.5, h - b, x + step, h - 6)
        ..quadraticBezierTo(x + step * 0.5, h - 3, x, h - 6);
      canvas.drawPath(bottomKnot, i % 2 == 0 ? fillPaint : secFillPaint);
      canvas.drawPath(bottomKnot, i % 2 == 0 ? outerPaint : secondaryPaint);
    }

    // 5. Vertical Side Braids (የጎን ሐረግ ሹሩባ)
    final vStep = 24.0;
    final vMargin = b + 16.0;
    final vertCount = ((h - 2 * vMargin) / vStep).floor();

    for (int i = 0; i < vertCount; i++) {
      final y = vMargin + i * vStep;

      // Left vertical diamond knot
      final leftKnot = Path()
        ..moveTo(6, y)
        ..lineTo(b - 2, y + vStep * 0.5)
        ..lineTo(6, y + vStep)
        ..lineTo(3, y + vStep * 0.5)
        ..close();
      canvas.drawPath(leftKnot, i % 2 == 0 ? fillPaint : secFillPaint);
      canvas.drawPath(leftKnot, i % 2 == 0 ? outerPaint : secondaryPaint);

      // Right vertical diamond knot
      final rightKnot = Path()
        ..moveTo(w - 6, y)
        ..lineTo(w - b + 2, y + vStep * 0.5)
        ..lineTo(w - 6, y + vStep)
        ..lineTo(w - 3, y + vStep * 0.5)
        ..close();
      canvas.drawPath(rightKnot, i % 2 == 0 ? fillPaint : secFillPaint);
      canvas.drawPath(rightKnot, i % 2 == 0 ? outerPaint : secondaryPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EthiopianHaragBorderPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}


/// Compact vector widget for rendering an authentic Ethiopian Orthodox cross anywhere in UI/text
class OrthodoxCrossIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final EthiopianCrossStyle style;

  const OrthodoxCrossIcon({
    super.key,
    this.size = 14.0,
    this.color,
    this.style = EthiopianCrossStyle.lalibela,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final effectiveStyle = style == EthiopianCrossStyle.none ? EthiopianCrossStyle.lalibela : style;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: EthiopianCrossPainter(
          style: effectiveStyle,
          color: effectiveColor,
          strokeWidth: size < 18 ? 1.4 : 2.0,
        ),
      ),
    );
  }
}

