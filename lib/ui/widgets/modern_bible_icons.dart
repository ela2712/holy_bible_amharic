import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Modern bespoke icon set inspired by high-end typography and mobile study bibles.
/// Replaces generic Material/Android Studio icons with custom, pixel-perfect vectors.

/// 1. Modern Open Bible Icon (Bible / ንባብ)
class ModernBibleIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isFilled;

  const ModernBibleIcon({
    super.key,
    this.size = 22,
    required this.color,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ModernBiblePainter(color: color, isFilled: isFilled),
    );
  }
}

class _ModernBiblePainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _ModernBiblePainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Left page
    path.moveTo(w * 0.5, h * 0.28);
    path.cubicTo(w * 0.38, h * 0.18, w * 0.22, h * 0.20, w * 0.10, h * 0.25);
    path.lineTo(w * 0.10, h * 0.77);
    path.cubicTo(w * 0.22, h * 0.73, w * 0.38, h * 0.73, w * 0.5, h * 0.82);

    // Right page
    path.cubicTo(w * 0.62, h * 0.73, w * 0.78, h * 0.73, w * 0.90, h * 0.77);
    path.lineTo(w * 0.90, h * 0.25);
    path.cubicTo(w * 0.78, h * 0.20, w * 0.62, h * 0.18, w * 0.5, h * 0.28);
    path.close();

    canvas.drawPath(path, strokePaint);

    // Spine center seam
    final spinePaint = Paint()
      ..color = isFilled ? (color.computeLuminance() > 0.5 ? Colors.black45 : Colors.white60) : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.5, h * 0.28), Offset(w * 0.5, h * 0.82), spinePaint);
  }

  @override
  bool shouldRepaint(covariant _ModernBiblePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

/// 2. Modern Library / Home Icon (መጻሕፍት / Library)
class ModernLibraryIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isFilled;

  const ModernLibraryIcon({
    super.key,
    this.size = 22,
    required this.color,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ModernLibraryPainter(color: color, isFilled: isFilled),
    );
  }
}

class _ModernLibraryPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _ModernLibraryPainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Bottom shelf line
    canvas.drawLine(Offset(w * 0.10, h * 0.86), Offset(w * 0.90, h * 0.86), linePaint);

    // Book 1 (Left upright)
    final b1 = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.16, h * 0.24, w * 0.34, h * 0.84),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(b1, paint);

    if (!isFilled) {
      canvas.drawLine(Offset(w * 0.16, h * 0.38), Offset(w * 0.34, h * 0.38), linePaint);
      canvas.drawLine(Offset(w * 0.16, h * 0.46), Offset(w * 0.34, h * 0.46), linePaint);
    }

    // Book 2 (Center taller upright)
    final b2 = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.38, h * 0.16, w * 0.56, h * 0.84),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(b2, paint);

    // Book 3 (Leaning right at natural angle)
    canvas.save();
    canvas.translate(w * 0.60, h * 0.84);
    canvas.rotate(0.24);
    final b3 = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, -h * 0.64, w * 0.18, 0),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(b3, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ModernLibraryPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

/// 3. Modern Lectionary / Reading Plans Icon (Calendar / ዕቅዶች)
class ModernLectionaryIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isFilled;

  const ModernLectionaryIcon({
    super.key,
    this.size = 22,
    required this.color,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ModernLectionaryPainter(color: color, isFilled: isFilled),
    );
  }
}

class _ModernLectionaryPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _ModernLectionaryPainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calendar main body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.14, h * 0.22, w * 0.86, h * 0.86),
      const Radius.circular(5.0),
    );
    canvas.drawRRect(body, strokePaint);

    // Top hanger hooks / loops
    final loopPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w * 0.34, h * 0.12), Offset(w * 0.34, h * 0.24), loopPaint);
    canvas.drawLine(Offset(w * 0.66, h * 0.12), Offset(w * 0.66, h * 0.24), loopPaint);

    // Header divider bar
    if (!isFilled) {
      canvas.drawLine(Offset(w * 0.14, h * 0.40), Offset(w * 0.86, h * 0.40), loopPaint);
    }

    // Grid dots: 3 columns x 2 rows
    final dotColor = isFilled
        ? (color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white)
        : color;
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dotXs = [w * 0.32, w * 0.50, w * 0.68];
    final dotYs = [h * 0.52, h * 0.68];

    for (final x in dotXs) {
      for (final y in dotYs) {
        canvas.drawCircle(Offset(x, y), 1.6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ModernLectionaryPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

/// 4. Modern Highlights / Saved Icon (Ribbon Bookmark / ማህደር)
class ModernHighlightsIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isFilled;

  const ModernHighlightsIcon({
    super.key,
    this.size = 22,
    required this.color,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ModernHighlightsPainter(color: color, isFilled: isFilled),
    );
  }
}

class _ModernHighlightsPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _ModernHighlightsPainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(w * 0.26, h * 0.84);
    path.lineTo(w * 0.26, h * 0.18);
    path.quadraticBezierTo(w * 0.26, h * 0.14, w * 0.30, h * 0.14);
    path.lineTo(w * 0.70, h * 0.14);
    path.quadraticBezierTo(w * 0.74, h * 0.14, w * 0.74, h * 0.18);
    path.lineTo(w * 0.74, h * 0.84);
    path.lineTo(w * 0.50, h * 0.68); // V-notch center
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ModernHighlightsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

/// 5. Modern Precision Search Lens Icon (ፍለጋ)
class ModernSearchIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ModernSearchIcon({
    super.key,
    this.size = 20,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ModernSearchPainter(color: color),
    );
  }
}

class _ModernSearchPainter extends CustomPainter {
  final Color color;

  _ModernSearchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final radius = w * 0.26;
    canvas.drawCircle(Offset(w * 0.42, h * 0.42), radius, paint);

    final startX = w * 0.42 + radius * 0.7071;
    final startY = h * 0.42 + radius * 0.7071;
    canvas.drawLine(Offset(startX, startY), Offset(w * 0.84, h * 0.84), paint);
  }

  @override
  bool shouldRepaint(covariant _ModernSearchPainter oldDelegate) => oldDelegate.color != color;
}

/// 6. Modern Settings Icon (ማስተካከያዎች / Settings)
class ModernSettingsIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isFilled;

  const ModernSettingsIcon({
    super.key,
    this.size = 22,
    required this.color,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ModernSettingsPainter(color: color, isFilled: isFilled),
    );
  }
}

class _ModernSettingsPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _ModernSettingsPainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(w * 0.5, h * 0.5);
    final outerR = w * 0.42;
    final innerR = w * 0.30;
    final holeR = w * 0.14;

    final path = Path();
    const teeth = 6;
    for (int i = 0; i < teeth; i++) {
      final angle = (i * 2 * math.pi) / teeth;
      final halfStep = math.pi / teeth;
      final a1 = angle - halfStep * 0.35;
      final a2 = angle + halfStep * 0.35;
      final aNext = angle + halfStep;

      if (i == 0) {
        path.moveTo(center.dx + innerR * math.cos(a1), center.dy + innerR * math.sin(a1));
      } else {
        path.lineTo(center.dx + innerR * math.cos(a1), center.dy + innerR * math.sin(a1));
      }
      path.lineTo(center.dx + outerR * math.cos(a1), center.dy + outerR * math.sin(a1));
      path.lineTo(center.dx + outerR * math.cos(a2), center.dy + outerR * math.sin(a2));
      path.lineTo(center.dx + innerR * math.cos(a2), center.dy + innerR * math.sin(a2));
      path.lineTo(center.dx + innerR * math.cos(aNext), center.dy + innerR * math.sin(aNext));
    }
    path.close();
    canvas.drawPath(path, paint);

    if (isFilled) {
      final clearHolePaint = Paint()
        ..color = Colors.transparent
        ..blendMode = BlendMode.clear;
      canvas.drawCircle(center, holeR, clearHolePaint);
    } else {
      canvas.drawCircle(center, holeR, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ModernSettingsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

/// Bespoke Ethiopian Orthodox Tewahedo & illuminated-manuscript vector icon kinds.
enum OrthodoxIconKind {
  birannaCodex,
  geezScroll,
  orthodoxCross,
  censer,
  marianEmblem,
  sanctuaryLamp,
  begenaHarp,
  bethlehemStar,
  faithShield,
  prophecyScroll,
  vigilFlame,
}

/// Crisp, resolution-independent vector icon tailored to Ethiopian Orthodox scripture UX.
class OrthodoxVectorIcon extends StatelessWidget {
  final OrthodoxIconKind kind;
  final double size;
  final Color color;

  const OrthodoxVectorIcon({
    super.key,
    required this.kind,
    this.size = 22,
    required this.color,
  });

  /// Maps reading-plan `coverIcon` identifiers to bespoke Orthodox vectors.
  static OrthodoxIconKind kindForPlanCover(String name) {
    switch (name) {
      case 'church':
        return OrthodoxIconKind.orthodoxCross;
      case 'lightbulb':
        return OrthodoxIconKind.sanctuaryLamp;
      case 'music_note':
        return OrthodoxIconKind.begenaHarp;
      case 'spa':
        return OrthodoxIconKind.censer;
      case 'favorite':
        return OrthodoxIconKind.marianEmblem;
      case 'stars':
        return OrthodoxIconKind.bethlehemStar;
      case 'shield':
        return OrthodoxIconKind.faithShield;
      case 'visibility':
        return OrthodoxIconKind.prophecyScroll;
      case 'menu_book':
        return OrthodoxIconKind.geezScroll;
      case 'auto_stories':
      default:
        return OrthodoxIconKind.birannaCodex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _OrthodoxVectorPainter(kind: kind, color: color),
    );
  }
}

class _OrthodoxVectorPainter extends CustomPainter {
  final OrthodoxIconKind kind;
  final Color color;

  const _OrthodoxVectorPainter({required this.kind, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sw = (w * 0.082).clamp(1.25, 2.2);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final softFill = Paint()
      ..color = color.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final solidFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (kind) {
      case OrthodoxIconKind.birannaCodex:
        // Bound Biranna leather codex with spine clasps & embossed cross
        final cover = RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.22, h * 0.14, w * 0.80, h * 0.84),
          Radius.circular(w * 0.08),
        );
        canvas.drawRRect(cover, softFill);
        canvas.drawRRect(cover, stroke);
        // Spine crease & clasp ribs
        canvas.drawLine(Offset(w * 0.34, h * 0.14), Offset(w * 0.34, h * 0.84), stroke);
        canvas.drawLine(Offset(w * 0.17, h * 0.32), Offset(w * 0.25, h * 0.32), stroke);
        canvas.drawLine(Offset(w * 0.17, h * 0.66), Offset(w * 0.25, h * 0.66), stroke);
        // Cover cross emblem
        canvas.drawLine(Offset(w * 0.57, h * 0.33), Offset(w * 0.57, h * 0.61), stroke);
        canvas.drawLine(Offset(w * 0.45, h * 0.44), Offset(w * 0.69, h * 0.44), stroke);
        // Hanging bookmark ribbon
        final ribbon = Path()
          ..moveTo(w * 0.45, h * 0.84)
          ..lineTo(w * 0.45, h * 0.94)
          ..lineTo(w * 0.52, h * 0.89)
          ..lineTo(w * 0.59, h * 0.94)
          ..lineTo(w * 0.59, h * 0.84);
        canvas.drawPath(ribbon, stroke);
        break;

      case OrthodoxIconKind.geezScroll:
        // Vertical Ge'ez parchment scroll with rolled wood handles
        final body = Rect.fromLTRB(w * 0.25, h * 0.22, w * 0.75, h * 0.78);
        canvas.drawRect(body, softFill);
        canvas.drawLine(Offset(w * 0.25, h * 0.24), Offset(w * 0.25, h * 0.76), stroke);
        canvas.drawLine(Offset(w * 0.75, h * 0.24), Offset(w * 0.75, h * 0.76), stroke);
        // Top & bottom spindles
        final topRoll = RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.18, h * 0.14, w * 0.82, h * 0.25),
          Radius.circular(w * 0.06),
        );
        final botRoll = RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.18, h * 0.75, w * 0.82, h * 0.86),
          Radius.circular(w * 0.06),
        );
        canvas.drawRRect(topRoll, stroke);
        canvas.drawRRect(botRoll, stroke);
        // Script text rules
        canvas.drawLine(Offset(w * 0.36, h * 0.38), Offset(w * 0.64, h * 0.38), stroke);
        canvas.drawLine(Offset(w * 0.36, h * 0.50), Offset(w * 0.64, h * 0.50), stroke);
        canvas.drawLine(Offset(w * 0.36, h * 0.62), Offset(w * 0.55, h * 0.62), stroke);
        break;

      case OrthodoxIconKind.orthodoxCross:
        // Compact Ethiopian flared cross emblem with hollow diamond core
        final cx = w * 0.5;
        final cy = h * 0.5;
        final r = w * 0.39;
        final flare = w * 0.13;
        final neck = w * 0.055;
        final cross = Path();
        for (int i = 0; i < 4; i++) {
          final angle = i * math.pi / 2;
          final cosA = math.cos(angle);
          final sinA = math.sin(angle);
          Offset rot(double x, double y) => Offset(cx + x * cosA - y * sinA, cy + x * sinA + y * cosA);
          final p1 = rot(-neck, -neck);
          final p2 = rot(-flare, -r * 0.82);
          final p3 = rot(0, -r);
          final p4 = rot(flare, -r * 0.82);
          final p5 = rot(neck, -neck);
          if (i == 0) cross.moveTo(p1.dx, p1.dy);
          cross.lineTo(p2.dx, p2.dy);
          cross.lineTo(p3.dx, p3.dy);
          cross.lineTo(p4.dx, p4.dy);
          cross.lineTo(p5.dx, p5.dy);
        }
        cross.close();
        canvas.drawPath(cross, softFill);
        canvas.drawPath(cross, stroke);
        canvas.drawCircle(Offset(cx, cy), w * 0.055, solidFill);
        break;

      case OrthodoxIconKind.censer:
        // Liturgical brass incense censer (Tsina) with rising incense curl
        canvas.drawCircle(Offset(w * 0.5, h * 0.14), w * 0.05, stroke);
        // Suspension chains
        canvas.drawLine(Offset(w * 0.46, h * 0.18), Offset(w * 0.28, h * 0.50), stroke);
        canvas.drawLine(Offset(w * 0.54, h * 0.18), Offset(w * 0.72, h * 0.50), stroke);
        // Incense curl rising cleanly in center
        final smoke = Path()
          ..moveTo(w * 0.50, h * 0.48)
          ..cubicTo(w * 0.42, h * 0.39, w * 0.58, h * 0.33, w * 0.50, h * 0.25);
        canvas.drawPath(smoke, stroke);
        // Censer bowl & pedestal foot
        final bowl = Path()
          ..moveTo(w * 0.24, h * 0.50)
          ..lineTo(w * 0.76, h * 0.50)
          ..quadraticBezierTo(w * 0.72, h * 0.74, w * 0.50, h * 0.76)
          ..quadraticBezierTo(w * 0.28, h * 0.74, w * 0.24, h * 0.50)
          ..close();
        canvas.drawPath(bowl, softFill);
        canvas.drawPath(bowl, stroke);
        canvas.drawLine(Offset(w * 0.50, h * 0.76), Offset(w * 0.50, h * 0.86), stroke);
        canvas.drawLine(Offset(w * 0.34, h * 0.87), Offset(w * 0.66, h * 0.87), stroke);
        break;

      case OrthodoxIconKind.marianEmblem:
        // Crowned Marian rosette chalice emblem
        final center = Offset(w * 0.5, h * 0.54);
        // 3 sacred crown rays at top
        canvas.drawLine(Offset(w * 0.50, h * 0.13), Offset(w * 0.50, h * 0.24), stroke);
        canvas.drawLine(Offset(w * 0.34, h * 0.17), Offset(w * 0.40, h * 0.26), stroke);
        canvas.drawLine(Offset(w * 0.66, h * 0.17), Offset(w * 0.60, h * 0.26), stroke);
        // Concentric halo ring
        canvas.drawCircle(center, w * 0.26, softFill);
        canvas.drawCircle(center, w * 0.26, stroke);
        // Centered triple-petal lily inside medallion
        final lily = Path()
          ..moveTo(w * 0.50, h * 0.72)
          ..cubicTo(w * 0.36, h * 0.58, w * 0.39, h * 0.41, w * 0.50, h * 0.37)
          ..cubicTo(w * 0.61, h * 0.41, w * 0.64, h * 0.58, w * 0.50, h * 0.72)
          ..close();
        canvas.drawPath(lily, stroke);
        break;

      case OrthodoxIconKind.sanctuaryLamp:
        // Hanging Ethiopian oil lamp (Qendil) with glowing flame
        canvas.drawLine(Offset(w * 0.5, h * 0.10), Offset(w * 0.5, h * 0.20), stroke);
        // Glowing flame droplet
        final flame = Path()
          ..moveTo(w * 0.50, h * 0.22)
          ..cubicTo(w * 0.60, h * 0.34, w * 0.59, h * 0.46, w * 0.50, h * 0.46)
          ..cubicTo(w * 0.41, h * 0.46, w * 0.40, h * 0.34, w * 0.50, h * 0.22)
          ..close();
        canvas.drawPath(flame, softFill);
        canvas.drawPath(flame, stroke);
        // Oil lamp bowl & scalloped saucer
        final dish = Path()
          ..moveTo(w * 0.22, h * 0.52)
          ..lineTo(w * 0.78, h * 0.52)
          ..quadraticBezierTo(w * 0.70, h * 0.72, w * 0.50, h * 0.72)
          ..quadraticBezierTo(w * 0.30, h * 0.72, w * 0.22, h * 0.52)
          ..close();
        canvas.drawPath(dish, softFill);
        canvas.drawPath(dish, stroke);
        canvas.drawLine(Offset(w * 0.50, h * 0.72), Offset(w * 0.50, h * 0.85), stroke);
        canvas.drawLine(Offset(w * 0.32, h * 0.86), Offset(w * 0.68, h * 0.86), stroke);
        break;

      case OrthodoxIconKind.begenaHarp:
        // Authentic 10-string Begena (Harp of David) silhouette
        // Soundbox at bottom
        final box = Path()
          ..moveTo(w * 0.28, h * 0.56)
          ..lineTo(w * 0.72, h * 0.56)
          ..lineTo(w * 0.65, h * 0.85)
          ..lineTo(w * 0.35, h * 0.85)
          ..close();
        canvas.drawPath(box, softFill);
        canvas.drawPath(box, stroke);
        // Two tilted side pillars & top crossbar (Kenber)
        canvas.drawLine(Offset(w * 0.28, h * 0.56), Offset(w * 0.19, h * 0.20), stroke);
        canvas.drawLine(Offset(w * 0.72, h * 0.56), Offset(w * 0.81, h * 0.20), stroke);
        final topBar = Path()
          ..moveTo(w * 0.15, h * 0.20)
          ..quadraticBezierTo(w * 0.50, h * 0.14, w * 0.85, h * 0.20);
        canvas.drawPath(topBar, stroke);
        // Vertical harp strings
        for (final frac in [0.36, 0.45, 0.55, 0.64]) {
          canvas.drawLine(
            Offset(w * frac, h * 0.18),
            Offset(w * frac, h * 0.56),
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = (sw * 0.72).clamp(1.0, 1.5),
          );
        }
        break;

      case OrthodoxIconKind.bethlehemStar:
        // Eight-pointed Ethiopian illuminated star / Harege rosette
        final cx = w * 0.5;
        final cy = h * 0.5;
        final majorR = w * 0.40;
        final minorR = w * 0.26;
        final innerR = w * 0.12;
        final star = Path();
        for (int i = 0; i < 8; i++) {
          final aOuter = i * math.pi / 4 - math.pi / 2;
          final aInner = aOuter + math.pi / 8;
          final tipR = (i % 2 == 0) ? majorR : minorR;
          final outerPt = Offset(cx + tipR * math.cos(aOuter), cy + tipR * math.sin(aOuter));
          final innerPt = Offset(cx + innerR * math.cos(aInner), cy + innerR * math.sin(aInner));
          if (i == 0) {
            star.moveTo(outerPt.dx, outerPt.dy);
          } else {
            star.lineTo(outerPt.dx, outerPt.dy);
          }
          star.lineTo(innerPt.dx, innerPt.dy);
        }
        star.close();
        canvas.drawPath(star, softFill);
        canvas.drawPath(star, stroke);
        canvas.drawCircle(Offset(cx, cy), w * 0.045, solidFill);
        break;

      case OrthodoxIconKind.faithShield:
        // Traditional pointed Ethiopian heritage shield (Gasha) with central cross
        final shield = Path()
          ..moveTo(w * 0.50, h * 0.14)
          ..quadraticBezierTo(w * 0.76, h * 0.18, w * 0.80, h * 0.42)
          ..quadraticBezierTo(w * 0.80, h * 0.68, w * 0.50, h * 0.87)
          ..quadraticBezierTo(w * 0.20, h * 0.68, w * 0.20, h * 0.42)
          ..quadraticBezierTo(w * 0.24, h * 0.18, w * 0.50, h * 0.14)
          ..close();
        canvas.drawPath(shield, softFill);
        canvas.drawPath(shield, stroke);
        canvas.drawLine(Offset(w * 0.50, h * 0.30), Offset(w * 0.50, h * 0.68), stroke);
        canvas.drawLine(Offset(w * 0.35, h * 0.44), Offset(w * 0.65, h * 0.44), stroke);
        break;

      case OrthodoxIconKind.prophecyScroll:
        // Rising prophetic dawn rays over an open scripture scroll
        canvas.drawArc(
          Rect.fromCircle(center: Offset(w * 0.50, h * 0.48), radius: w * 0.18),
          math.pi,
          math.pi,
          false,
          stroke,
        );
        canvas.drawLine(Offset(w * 0.50, h * 0.15), Offset(w * 0.50, h * 0.24), stroke);
        canvas.drawLine(Offset(w * 0.28, h * 0.23), Offset(w * 0.34, h * 0.30), stroke);
        canvas.drawLine(Offset(w * 0.72, h * 0.23), Offset(w * 0.66, h * 0.30), stroke);
        // Horizontal open scroll banner
        final banner = RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.18, h * 0.52, w * 0.82, h * 0.78),
          Radius.circular(w * 0.08),
        );
        canvas.drawRRect(banner, softFill);
        canvas.drawRRect(banner, stroke);
        canvas.drawLine(Offset(w * 0.32, h * 0.65), Offset(w * 0.68, h * 0.65), stroke);
        break;

      case OrthodoxIconKind.vigilFlame:
        // Vigil taper candle (Tuwaf) in brass saucer replacing generic flame
        // Outer tear-drop flame
        final outerFlame = Path()
          ..moveTo(w * 0.50, h * 0.12)
          ..cubicTo(w * 0.66, h * 0.28, w * 0.62, h * 0.44, w * 0.50, h * 0.44)
          ..cubicTo(w * 0.38, h * 0.44, w * 0.34, h * 0.28, w * 0.50, h * 0.12)
          ..close();
        canvas.drawPath(outerFlame, softFill);
        canvas.drawPath(outerFlame, stroke);
        // Candle column
        final candle = RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.39, h * 0.47, w * 0.61, h * 0.78),
          Radius.circular(w * 0.04),
        );
        canvas.drawRRect(candle, softFill);
        canvas.drawRRect(candle, stroke);
        // Saucer tray & handle ring
        final tray = Path()
          ..moveTo(w * 0.22, h * 0.78)
          ..lineTo(w * 0.78, h * 0.78)
          ..quadraticBezierTo(w * 0.72, h * 0.88, w * 0.50, h * 0.88)
          ..quadraticBezierTo(w * 0.28, h * 0.88, w * 0.22, h * 0.78)
          ..close();
        canvas.drawPath(tray, stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _OrthodoxVectorPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.color != color;
}
