import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'flag_badge.dart';

/// Decorative illustrations of screens 4-7, drawn in code (no assets).
/// Each one excludes itself from semantics.
class _Art extends StatelessWidget {
  const _Art({required this.size, required this.painter});

  final Size size;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: size, painter: painter),
  );
}

/// Screen 4: a Turkish-flag bubble and an Arabic "ض" bubble with exchange
/// arrows.
class LanguagePairHero extends StatelessWidget {
  const LanguagePairHero({super.key});

  @override
  Widget build(BuildContext context) => _Art(
    size: const Size(168, 112),
    painter: _PairPainter(
      Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontSize: 44,
        height: 1,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// Screen 5: soft mosque skyline with a crescent. Mirrors in RTL.
class MosqueHero extends StatelessWidget {
  const MosqueHero({super.key});

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return LayoutBuilder(
      builder: (context, box) => _Art(
        size: Size(box.maxWidth, 112),
        painter: _MosquePainter(mirror: rtl),
      ),
    );
  }
}

/// Screen 6: ascending bars crowned by a graduation cap.
class LevelsHero extends StatelessWidget {
  const LevelsHero({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Art(size: Size(124, 92), painter: _LevelsPainter());
}

/// Screen 7: an open book with a play button.
class LessonsHero extends StatelessWidget {
  const LessonsHero({super.key});

  @override
  Widget build(BuildContext context) =>
      const _Art(size: Size(132, 92), painter: _BookPainter());
}

Paint _fill(Color c) => Paint()..color = c;

Paint _stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _arrowHead(Canvas canvas, Offset tip, double angle, Paint paint) {
  const len = 9.0;
  final p = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(
      tip.dx - len * math.cos(angle - 0.5),
      tip.dy - len * math.sin(angle - 0.5),
    )
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(
      tip.dx - len * math.cos(angle + 0.5),
      tip.dy - len * math.sin(angle + 0.5),
    );
  canvas.drawPath(p, paint);
}

class _PairPainter extends CustomPainter {
  const _PairPainter(this.glyphStyle);

  final TextStyle? glyphStyle;

  @override
  void paint(Canvas canvas, Size size) {
    // Left bubble: Turkish flag.
    final left = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 30, 72, 58),
      const Radius.circular(22),
    );
    final leftTail = Path()
      ..moveTo(24, 84)
      ..lineTo(16, 104)
      ..lineTo(46, 88)
      ..close();
    canvas.save();
    canvas.clipPath(
      Path.combine(PathOperation.union, Path()..addRRect(left), leftTail),
    );
    canvas.translate(6, 30);
    const FlagPainter('tr').paint(canvas, const Size(72, 76));
    canvas.restore();

    // Right bubble: purple with the Arabic letter.
    final right = RRect.fromRectAndRadius(
      const Rect.fromLTWH(86, 38, 76, 60),
      const Radius.circular(22),
    );
    final rightTail = Path()
      ..moveTo(138, 94)
      ..lineTo(150, 110)
      ..lineTo(122, 96)
      ..close();
    final purple = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.brandMid, AppColors.brandDeep],
      ).createShader(const Rect.fromLTWH(86, 38, 76, 72));
    canvas
      ..drawRRect(right, purple)
      ..drawPath(rightTail, purple);
    final tp = TextPainter(
      text: TextSpan(text: 'ض', style: glyphStyle),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, Offset(124 - tp.width / 2, 68 - tp.height / 2));

    // Exchange arrows.
    final arrow = _stroke(AppColors.brand, 3.6);
    final top = Path()
      ..moveTo(40, 26)
      ..quadraticBezierTo(90, -6, 124, 30);
    canvas.drawPath(top, arrow);
    _arrowHead(canvas, const Offset(124, 30), math.pi * 0.42, arrow);
    final bottom = Path()
      ..moveTo(130, 106)
      ..quadraticBezierTo(96, 116, 62, 96);
    canvas.drawPath(bottom, _stroke(AppColors.brandMid, 3.6));
    _arrowHead(
      canvas,
      const Offset(62, 96),
      math.pi * 0.85,
      _stroke(AppColors.brandMid, 3.6),
    );
  }

  @override
  bool shouldRepaint(_PairPainter old) => old.glyphStyle != glyphStyle;
}

class _MosquePainter extends CustomPainter {
  const _MosquePainter({required this.mirror});

  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 360;
    canvas.save();
    if (mirror) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    canvas.scale(scale, size.height / 120);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.brandMid.withValues(alpha: 0.78),
          AppColors.brandLight.withValues(alpha: 0.35),
        ],
      ).createShader(const Rect.fromLTWH(0, 0, 360, 120));

    final s = Path();
    // Central dome and body.
    s
      ..moveTo(215, 120)
      ..lineTo(215, 80)
      ..cubicTo(215, 52, 235, 40, 255, 40)
      ..cubicTo(275, 40, 295, 52, 295, 80)
      ..lineTo(295, 120)
      ..close()
      ..addRect(const Rect.fromLTWH(253.5, 24, 3, 18))
      ..addOval(Rect.fromCircle(center: const Offset(255, 22), radius: 3.5));
    // Small side domes.
    for (final cx in [197.0, 313.0]) {
      s
        ..moveTo(cx - 18, 120)
        ..lineTo(cx - 18, 97)
        ..arcToPoint(
          Offset(cx + 18, 97),
          radius: const Radius.circular(18),
          clockwise: true,
        )
        ..lineTo(cx + 18, 120)
        ..close();
    }
    // Minarets.
    for (final (x, top) in [(345.0, 40.0), (162.0, 56.0)]) {
      s
        ..addRect(Rect.fromLTWH(x - 4.5, top, 9, 120 - top))
        ..addRect(Rect.fromLTWH(x - 7, top + 22, 14, 4))
        ..moveTo(x - 6, top)
        ..lineTo(x + 6, top)
        ..lineTo(x, top - 20)
        ..close();
    }
    canvas.drawPath(s, paint);

    // Crescent moon.
    final moon = Path.combine(
      PathOperation.difference,
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(96, 38), radius: 16)),
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(103, 33), radius: 14)),
    );
    canvas
      ..drawPath(moon, _fill(AppColors.brandMid.withValues(alpha: 0.7)))
      ..restore();
  }

  @override
  bool shouldRepaint(_MosquePainter old) => old.mirror != mirror;
}

class _LevelsPainter extends CustomPainter {
  const _LevelsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      AppColors.brandMid,
      Color(0xFF6D3FD0),
      Color(0xFF5B2DB8),
      AppColors.brandDeep,
    ];
    final heights = [20.0, 36.0, 52.0, 68.0];
    for (var i = 0; i < 4; i++) {
      final x = 8 + i * 22.0;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 90 - heights[i], 17, heights[i]),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[i].withValues(alpha: 0.75), colors[i]],
          ).createShader(r.outerRect),
      );
    }
    // Graduation cap on the tallest bar.
    const cx = 85.0;
    const y = 4.0;
    final base = Path()
      ..moveTo(cx - 14, y + 16)
      ..lineTo(cx - 14, y + 28)
      ..quadraticBezierTo(cx, y + 38, cx + 14, y + 28)
      ..lineTo(cx + 14, y + 16)
      ..close();
    canvas.drawPath(base, _fill(AppColors.brand));
    final top = Path()
      ..moveTo(cx, y)
      ..lineTo(cx + 26, y + 11)
      ..lineTo(cx, y + 22)
      ..lineTo(cx - 26, y + 11)
      ..close();
    canvas
      ..drawPath(top, _fill(AppColors.brandDeep))
      ..drawLine(
        const Offset(cx + 22, y + 13),
        const Offset(cx + 22, y + 32),
        _stroke(AppColors.accent, 2.4),
      );
  }

  @override
  bool shouldRepaint(_LevelsPainter old) => false;
}

class _BookPainter extends CustomPainter {
  const _BookPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outline = _stroke(AppColors.brandDeep, 3.4);
    final page = _fill(AppColors.brandLight.withValues(alpha: 0.7));
    final leftPage = Path()
      ..moveTo(66, 22)
      ..cubicTo(50, 10, 24, 10, 6, 16)
      ..lineTo(6, 70)
      ..cubicTo(24, 64, 50, 64, 66, 76)
      ..close();
    final rightPage = Path()
      ..moveTo(66, 22)
      ..cubicTo(82, 10, 108, 10, 126, 16)
      ..lineTo(126, 70)
      ..cubicTo(108, 64, 82, 64, 66, 76)
      ..close();
    canvas
      ..drawPath(leftPage, page)
      ..drawPath(rightPage, page)
      ..drawPath(leftPage, outline)
      ..drawPath(rightPage, outline)
      ..drawLine(const Offset(66, 22), const Offset(66, 76), outline)
      // Cover edge.
      ..drawPath(
        Path()
          ..moveTo(6, 74)
          ..cubicTo(24, 68, 50, 68, 66, 82)
          ..cubicTo(82, 68, 108, 68, 126, 74),
        _stroke(AppColors.brand, 3.4),
      );
    // Play button on the right page.
    const c = Offset(96, 40);
    canvas.drawCircle(c, 17, _fill(AppColors.brand));
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 5, c.dy - 8)
        ..lineTo(c.dx + 9, c.dy)
        ..lineTo(c.dx - 5, c.dy + 8)
        ..close(),
      _fill(Colors.white),
    );
  }

  @override
  bool shouldRepaint(_BookPainter old) => false;
}
