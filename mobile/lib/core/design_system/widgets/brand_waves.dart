import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Soft layered waves used as the background of the first three screens.
/// Purely decorative (excluded from semantics) and mirrored in RTL so the
/// composition follows the reading direction.
class BrandWaves extends StatelessWidget {
  const BrandWaves({
    super.key,
    this.bottomHeight = 150,
    this.topCorner = false,
    this.soft = false,
  });

  /// Height of the wave band at the bottom (logical pixels).
  final double bottomHeight;

  /// Adds the light corner wave at the top (used by the splash).
  final bool topCorner;

  /// Only the two light lavender layers (no dark front band). Used behind
  /// the content screens so cards and text stay the focus.
  final bool soft;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          size: Size.infinite,
          painter: _WavesPainter(
            bottomHeight: bottomHeight,
            topCorner: topCorner,
            soft: soft,
            mirror: rtl,
          ),
        ),
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  const _WavesPainter({
    required this.bottomHeight,
    required this.topCorner,
    required this.soft,
    required this.mirror,
  });

  final double bottomHeight;
  final bool topCorner;
  final bool soft;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    if (mirror) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    final w = size.width;
    final h = size.height;

    if (soft) {
      _band(
        canvas,
        w,
        h,
        bottomHeight,
        0.0,
        AppColors.brandLight.withValues(alpha: 0.5),
      );
      _band(
        canvas,
        w,
        h,
        bottomHeight * 0.74,
        1.2,
        AppColors.brandMid.withValues(alpha: 0.32),
      );
      final edge = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.brandMid.withValues(alpha: 0.55),
            AppColors.brand.withValues(alpha: 0.9),
          ],
        ).createShader(Rect.fromLTWH(0, h - bottomHeight, w, bottomHeight));
      _band(canvas, w, h, bottomHeight * 0.4, 2.4, edge);
      return;
    }

    // Bottom: three layers, lightest at the back.
    _band(
      canvas,
      w,
      h,
      bottomHeight * 1.00,
      0.0,
      AppColors.brandLight.withValues(alpha: 0.55),
    );
    _band(
      canvas,
      w,
      h,
      bottomHeight * 0.78,
      1.2,
      AppColors.brandMid.withValues(alpha: 0.55),
    );
    final front = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.brand, AppColors.brandDeep],
      ).createShader(Rect.fromLTWH(0, h - bottomHeight, w, bottomHeight));
    _band(canvas, w, h, bottomHeight * 0.52, 2.4, front);

    if (topCorner) {
      final top = Path()
        ..moveTo(0, 0)
        ..lineTo(w, 0)
        ..lineTo(w, h * 0.04)
        ..cubicTo(w * 0.70, h * 0.13, w * 0.40, h * 0.04, w * 0.12, h * 0.17)
        ..cubicTo(w * 0.06, h * 0.20, w * 0.02, h * 0.22, 0, h * 0.235)
        ..close();
      canvas.drawPath(
        top,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brand,
              AppColors.brandMid.withValues(alpha: 0.55),
              AppColors.brandLight.withValues(alpha: 0.0),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromLTWH(0, 0, w, h * 0.25)),
      );
    }
  }

  void _band(
    Canvas canvas,
    double w,
    double h,
    double band,
    double phase,
    Object fill,
  ) {
    final path = Path()..moveTo(0, h);
    final top = h - band;
    path.lineTo(0, top + band * 0.18 * math.sin(phase));
    for (double x = 0; x <= w; x += 4) {
      final t = x / w;
      final y =
          top +
          band * 0.22 * math.sin(t * math.pi * 1.6 + phase) +
          band * 0.10 * math.sin(t * math.pi * 3.1 + phase * 1.7);
      path.lineTo(x, y);
    }
    path
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      path,
      fill is Paint ? fill : (Paint()..color = fill as Color),
    );
  }

  @override
  bool shouldRepaint(_WavesPainter old) =>
      old.bottomHeight != bottomHeight ||
      old.topCorner != topCorner ||
      old.soft != soft ||
      old.mirror != mirror;
}
