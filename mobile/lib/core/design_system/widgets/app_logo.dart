import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../theme/app_colors.dart';

/// LanguagePlatform logo mark: a wireframe globe (the world's languages), two
/// speech bubbles ("A" for Latin script, "ض" for Arabic) and an open book
/// (learning). Drawn in code, so it is resolution independent, needs no
/// asset or package, and the same painter can render the launcher icon.
///
/// Designed on a 100 x 100 grid; the mark itself spans roughly x 6..94 and
/// y 8..92 so it keeps a safe margin inside an adaptive icon.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 120, this.glyphStyle});

  final double size;

  /// Optional text style override for the two glyphs (tests / icon export use
  /// it to select fonts). Colors and size are applied by the painter.
  final TextStyle? glyphStyle;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: LogoMarkPainter(
          glyphStyle: glyphStyle ?? Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class LogoMarkPainter extends CustomPainter {
  const LogoMarkPainter({this.glyphStyle, this.transparent = false});

  final TextStyle? glyphStyle;

  /// Skips the soft shadows (for flat icon export).
  final bool transparent;

  static const double _grid = 100;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / _grid;
    canvas
      ..save()
      ..scale(s);

    _globe(canvas);
    _bubbles(canvas);
    _book(canvas);

    canvas.restore();
  }

  // ------------------------------------------------------------- globe
  void _globe(Canvas canvas) {
    const center = Offset(50, 34);
    const radius = 28.0;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.brand;

    // Soft fill so the globe reads as a sphere, not just an outline.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFF1E9FC), Color(0xFFDCCBF6)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas
      ..save()
      ..clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      );
    line.strokeWidth = 1.7;
    // Meridians.
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 26, height: radius * 2),
      line,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      line,
    );
    // Parallels (arcs, flatter towards the poles).
    for (final dy in [-15.0, 0.0, 15.0]) {
      final w = 2 * math.sqrt(radius * radius - dy * dy);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + dy),
          width: w,
          height: 9,
        ),
        0,
        math.pi * 2,
        false,
        line,
      );
    }
    canvas.restore();

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = AppColors.brand,
    );
  }

  // ----------------------------------------------------------- bubbles
  void _bubbles(Canvas canvas) {
    // Left bubble: white with a lavender edge, Latin "A".
    final left = _bubblePath(
      const Rect.fromLTWH(11, 41, 35, 25),
      tailLeft: true,
    );
    if (!transparent) {
      canvas.drawShadow(left, const Color(0x663B1470), 3, false);
    }
    canvas
      ..drawPath(left, Paint()..color = Colors.white)
      ..drawPath(
        left,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = AppColors.brandLight,
      );
    _glyph(
      canvas,
      'A',
      const Rect.fromLTWH(11, 41, 35, 25),
      color: AppColors.brandDeep,
      fontSize: 22,
      weight: FontWeight.w800,
    );

    // Right bubble: deep purple, Arabic "ض".
    const rightRect = Rect.fromLTWH(52, 33, 37, 28);
    final right = _bubblePath(rightRect, tailLeft: false);
    if (!transparent) {
      canvas.drawShadow(right, const Color(0x883B1470), 4, false);
    }
    canvas.drawPath(
      right,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandMid, AppColors.brandDeep],
        ).createShader(rightRect),
    );
    _glyph(
      canvas,
      'ض',
      rightRect,
      color: Colors.white,
      fontSize: 24,
      weight: FontWeight.w700,
    );
  }

  Path _bubblePath(Rect r, {required bool tailLeft}) {
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(8)));
    final tail = Path();
    if (tailLeft) {
      tail
        ..moveTo(r.left + 7, r.bottom - 1)
        ..lineTo(r.left + 3, r.bottom + 8)
        ..lineTo(r.left + 16, r.bottom - 1)
        ..close();
    } else {
      tail
        ..moveTo(r.right - 7, r.bottom - 1)
        ..lineTo(r.right - 3, r.bottom + 8)
        ..lineTo(r.right - 16, r.bottom - 1)
        ..close();
    }
    return Path.combine(PathOperation.union, body, tail);
  }

  void _glyph(
    Canvas canvas,
    String text,
    Rect within, {
    required Color color,
    required double fontSize,
    required FontWeight weight,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: (glyphStyle ?? const TextStyle()).copyWith(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        within.center.dx - painter.width / 2,
        within.center.dy - painter.height / 2,
      ),
    );
  }

  // -------------------------------------------------------------- book
  void _book(Canvas canvas) {
    // Cover (deep purple), then lighter pages on top.
    final cover = Path()
      ..moveTo(50, 93)
      ..cubicTo(40, 85, 22, 81, 5, 84)
      ..lineTo(5, 68)
      ..cubicTo(22, 66, 40, 70, 50, 78)
      ..cubicTo(60, 70, 78, 66, 95, 68)
      ..lineTo(95, 84)
      ..cubicTo(78, 81, 60, 85, 50, 93)
      ..close();
    canvas.drawPath(
      cover,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.brandDeep, AppColors.brand, AppColors.brandDeep],
        ).createShader(const Rect.fromLTWH(5, 66, 90, 28)),
    );

    final pages = Path()
      ..moveTo(50, 87)
      ..cubicTo(41, 80, 24, 76.5, 9, 79)
      ..lineTo(9, 73)
      ..cubicTo(24, 71, 41, 74.5, 50, 82)
      ..cubicTo(59, 74.5, 76, 71, 91, 73)
      ..lineTo(91, 79)
      ..cubicTo(76, 76.5, 59, 80, 50, 87)
      ..close();
    canvas.drawPath(pages, Paint()..color = const Color(0xFFEFE6FB));

    // Spine highlight.
    canvas.drawLine(
      const Offset(50, 78),
      const Offset(50, 92),
      Paint()
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..color = AppColors.brandLight.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(LogoMarkPainter old) =>
      old.glyphStyle != glyphStyle || old.transparent != transparent;
}

/// "LanguagePlatform" word mark: "Language" in the deepest purple, "Platform"
/// in the lighter brand purple. The name is a brand, so it is not translated.
class LogoWordmark extends StatelessWidget {
  const LogoWordmark({super.key, this.fontSize = 28, this.style});

  final double fontSize;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = (style ?? Theme.of(context).textTheme.headlineMedium)
        ?.copyWith(fontSize: fontSize, height: 1.1, letterSpacing: -0.6);
    return Semantics(
      header: true,
      label: AppConfig.appName,
      child: ExcludeSemantics(
        child: Directionality(
          // The brand is Latin: it always reads left to right.
          textDirection: TextDirection.ltr,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Language',
                  style: base?.copyWith(
                    color: AppColors.brandDeep,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'Platform',
                  style: base?.copyWith(
                    color: AppColors.brandMid,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Mark + word mark (+ optional line below), the standard lockup.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.markSize = 120,
    this.wordSize = 28,
    this.tagline,
  });

  final double markSize;
  final double wordSize;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: markSize),
        SizedBox(height: wordSize * 0.35),
        LogoWordmark(fontSize: wordSize),
        if (tagline != null) ...[
          SizedBox(height: wordSize * 0.4),
          // The tagline sits between two thin lines (as in the design).
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TaglineRule(width: wordSize),
              SizedBox(width: wordSize * 0.3),
              Flexible(
                child: Text(
                  tagline!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.brand,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: wordSize * 0.3),
              _TaglineRule(width: wordSize),
            ],
          ),
        ],
      ],
    );
  }
}

class _TaglineRule extends StatelessWidget {
  const _TaglineRule({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 1.2,
    color: AppColors.brandMid.withValues(alpha: 0.6),
  );
}
