import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The analog arc/dial — red · amber · green · amber · red zones with a needle
/// that eases to the current cents value.
class ArcGauge extends StatelessWidget {
  final double cents; // clamped to ±50
  final Color color;
  final bool active;
  final bool inTune;

  const ArcGauge({
    super.key,
    required this.cents,
    required this.color,
    required this.active,
    required this.inTune,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.05,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: cents.clamp(-50.0, 50.0)),
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        builder: (_, c, _) => CustomPaint(painter: _GaugePainter(c, color, active, inTune)),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double cents;
  final Color color;
  final bool active;
  final bool inTune;
  _GaugePainter(this.cents, this.color, this.active, this.inTune);

  // cents (−50..50) → Flutter arc angle along the top semicircle (π..2π).
  double _angle(double c) => math.pi + (c + 50) * math.pi / 100;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.95;
    final r = math.min(size.width * 0.46, size.height * 0.92);
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final sw = size.width * 0.045;

    final zones = <List<double>>[
      [-50, -15], [-15, -5], [-5, 5], [5, 15], [15, 50],
    ];
    final colors = <Color>[
      const Color(0xFF6E2A2A),
      const Color(0xFF8A6B1A),
      inTune ? const Color(0xFF34D399) : const Color(0xFF2C6B52),
      const Color(0xFF8A6B1A),
      const Color(0xFF6E2A2A),
    ];
    for (var i = 0; i < zones.length; i++) {
      final a0 = _angle(zones[i][0]);
      final a1 = _angle(zones[i][1]);
      final isGreen = i == 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isGreen && inTune ? sw * 1.25 : sw
        ..color = colors[i];
      canvas.drawArc(rect, a0, a1 - a0, false, paint);
    }

    // Ticks at −50, 0, +50.
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1.4;
    for (final c in [-50.0, 0.0, 50.0]) {
      final a = _angle(c);
      final p1 = Offset(cx + (r + sw * 0.7) * math.cos(a), cy + (r + sw * 0.7) * math.sin(a));
      final p2 = Offset(cx + (r + sw * 1.5) * math.cos(a), cy + (r + sw * 1.5) * math.sin(a));
      canvas.drawLine(p1, p2, tickPaint);
    }
    _label(canvas, '♭', Offset(cx + (r + sw * 2.4) * math.cos(_angle(-50)), cy + (r + sw * 2.4) * math.sin(_angle(-50))));
    _label(canvas, '♯', Offset(cx + (r + sw * 2.4) * math.cos(_angle(50)), cy + (r + sw * 2.4) * math.sin(_angle(50))));

    // Needle.
    final a = _angle(cents.clamp(-50.0, 50.0));
    final tip = Offset(cx + (r - sw * 0.5) * math.cos(a), cy + (r - sw * 0.5) * math.sin(a));
    final needleColor = active ? color : const Color(0xFF4B5563);
    canvas.drawLine(
      Offset(cx, cy),
      tip,
      Paint()
        ..color = needleColor
        ..strokeWidth = math.max(3.0, size.width * 0.013)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, cy), size.width * 0.026, Paint()..color = needleColor);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.011, Paint()..color = const Color(0xFF0F1117));
  }

  void _label(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.cents != cents || old.color != color || old.active != active || old.inTune != inTune;
}
