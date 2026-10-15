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
