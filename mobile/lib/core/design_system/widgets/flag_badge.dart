import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Round flag badge of a language (as in the design): Turkish (`tr`),
/// British (`en`) and Saudi (`ar`) flags drawn in code, no image assets.
/// Decorative: the language name is always written next to it.
class FlagBadge extends StatelessWidget {
  const FlagBadge({super.key, required this.code, this.size = 40});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x1F000000), width: 0.8),
        ),
        child: ClipOval(
          child: CustomPaint(
            painter: FlagPainter(code),
            size: Size.square(size),
          ),
        ),
      ),
    );
  }
}

/// Paints a flag over the whole canvas (also used inside the pair
/// illustration).
class FlagPainter extends CustomPainter {
  const FlagPainter(this.code);

  final String code;

  @override
  void paint(Canvas canvas, Size size) {
    switch (code) {
      case 'tr':
        _turkey(canvas, size);
      case 'en':
        _britain(canvas, size);
      default:
        _saudi(canvas, size);
    }
  }

  void _turkey(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFE30A17));
    final white = Paint()..color = Colors.white;
    final c = Offset(s.width * 0.40, s.height * 0.5);
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: s.height * 0.25)),
      Path()..addOval(
        Rect.fromCircle(
          center: c.translate(s.height * 0.07, 0),
          radius: s.height * 0.20,
        ),
      ),
    );
    canvas.drawPath(moon, white);
    final star = Path();
    final sc = Offset(s.width * 0.60, s.height * 0.5);
    final outer = s.height * 0.12;
    final inner = outer * 0.4;
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5 + math.pi / 12;
      final p = sc + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(star..close(), white);
  }

  void _britain(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF012169));
    Paint line(Color color, double w) => Paint()
      ..color = color
      ..strokeWidth = w
      ..style = PaintingStyle.stroke;
    final a = Offset.zero;
    final b = Offset(s.width, s.height);
    final c = Offset(s.width, 0);
    final d = Offset(0, s.height);
    canvas
      ..drawLine(a, b, line(Colors.white, s.width * 0.2))
      ..drawLine(c, d, line(Colors.white, s.width * 0.2))
      ..drawLine(a, b, line(const Color(0xFFC8102E), s.width * 0.07))
      ..drawLine(c, d, line(const Color(0xFFC8102E), s.width * 0.07));
    final mid = Offset(s.width / 2, s.height / 2);
    canvas
      ..drawLine(
        Offset(mid.dx, 0),
        Offset(mid.dx, s.height),
        line(Colors.white, s.width * 0.34),
      )
      ..drawLine(
        Offset(0, mid.dy),
        Offset(s.width, mid.dy),
        line(Colors.white, s.height * 0.34),
      )
      ..drawLine(
        Offset(mid.dx, 0),
        Offset(mid.dx, s.height),
        line(const Color(0xFFC8102E), s.width * 0.2),
      )
      ..drawLine(
        Offset(0, mid.dy),
        Offset(s.width, mid.dy),
        line(const Color(0xFFC8102E), s.height * 0.2),
      );
  }

  /// Green field with an abstract white band and sword line (the script of
  /// the real flag is not reproduced).
  void _saudi(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF006C35));
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s.height * 0.06;
    final wave = Path()..moveTo(s.width * 0.2, s.height * 0.42);
    for (var i = 0; i < 6; i++) {
      final x = s.width * (0.2 + 0.1 * (i + 1));
      wave.quadraticBezierTo(
        x - s.width * 0.05,
        s.height * (i.isEven ? 0.30 : 0.54),
        x,
        s.height * 0.42,
      );
    }
    canvas
      ..drawPath(wave, stroke)
      ..drawLine(
        Offset(s.width * 0.22, s.height * 0.66),
        Offset(s.width * 0.78, s.height * 0.66),
        stroke..strokeWidth = s.height * 0.05,
      );
  }

  @override
  bool shouldRepaint(FlagPainter old) => old.code != code;
}
