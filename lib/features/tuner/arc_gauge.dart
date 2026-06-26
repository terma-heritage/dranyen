import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// The analog arc/dial — red · amber · green · amber · red zones with a needle
/// that springs to the current cents value (a touch of overshoot, then settles,
/// like a real meter movement).
class ArcGauge extends StatefulWidget {
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
  State<ArcGauge> createState() => _ArcGaugeState();
}

class _ArcGaugeState extends State<ArcGauge> with SingleTickerProviderStateMixin {
  static const _spring = SpringDescription(mass: 1, stiffness: 180, damping: 20);
  late final AnimationController _ctrl;
  double _display = 0;

  @override
  void initState() {
    super.initState();
    _display = widget.cents.clamp(-50.0, 50.0);
    _ctrl = AnimationController.unbounded(vsync: this, value: _display)
      ..addListener(() => setState(() => _display = _ctrl.value));
  }

  @override
  void didUpdateWidget(ArcGauge old) {
    super.didUpdateWidget(old);
    final target = widget.cents.clamp(-50.0, 50.0);
    if (target != old.cents.clamp(-50.0, 50.0)) {
      _ctrl.animateWith(SpringSimulation(_spring, _ctrl.value, target, _ctrl.velocity));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.05,
      child: CustomPaint(
        painter: _GaugePainter(
          _display.clamp(-50.0, 50.0),
          widget.color,
          widget.active,
          widget.inTune,
        ),
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
    final r = math.min(size.width * 0.42, size.height * 0.86);
    final cy = size.height * 0.92;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final sw = size.width * 0.042;
    final start = _angle(-50);
    final sweep = _angle(50) - start;

    // Recessed groove under the dial — a machined, inset feel that also rounds
    // the two outer ends of the arc.
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw + 6
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF0B0B11),
    );

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
      final isEnd = i == 0 || i == zones.length - 1;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isGreen && inTune ? sw * 1.25 : sw
        // Round only the two extreme ends; inner joins stay flush.
        ..strokeCap = isEnd ? StrokeCap.round : StrokeCap.butt
        ..color = colors[i];
      canvas.drawArc(rect, a0, a1 - a0, false, paint);
    }

    // Soft green bloom over the in-tune zone when locked.
    if (inTune) {
      final g0 = _angle(-5);
      canvas.drawArc(
        rect,
        g0,
        _angle(5) - g0,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw * 1.7
          ..color = const Color(0xFF34D399)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }

    // Graduated ticks every 10 cents, just inside the ring; centre and extremes
    // read longer and brighter.
    for (var c = -50.0; c <= 50.0; c += 10.0) {
      final major = c == -50 || c == 0 || c == 50;
      final a = _angle(c);
      final inner = r - sw * 0.5 - (major ? size.width * 0.032 : size.width * 0.018);
      final outer = r - sw * 0.5 - size.width * 0.004;
      final p1 = Offset(cx + inner * math.cos(a), cy + inner * math.sin(a));
      final p2 = Offset(cx + outer * math.cos(a), cy + outer * math.sin(a));
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = Colors.white.withValues(alpha: major ? 0.5 : 0.22)
          ..strokeWidth = major ? 1.6 : 1.0,
      );
    }

    // ♭ / ♯ just outside the two ends — pulled in to stay within the canvas.
    _label(canvas, '♭', Offset(cx + (r + sw * 1.1) * math.cos(_angle(-50)), cy + (r + sw * 1.1) * math.sin(_angle(-50))));
    _label(canvas, '♯', Offset(cx + (r + sw * 1.1) * math.cos(_angle(50)), cy + (r + sw * 1.1) * math.sin(_angle(50))));

    // Needle — a tapered pointer with a counterweight tail and a soft halo.
    final a = _angle(cents.clamp(-50.0, 50.0));
    final needleColor = active ? color : const Color(0xFF4B5563);
    final tipLen = r - sw * 0.5;
    final tailLen = size.width * 0.06;
    final tip = Offset(cx + tipLen * math.cos(a), cy + tipLen * math.sin(a));
    final tail = Offset(cx - tailLen * math.cos(a), cy - tailLen * math.sin(a));
    final perp = a + math.pi / 2;
    final halfBase = math.max(2.0, size.width * 0.012);
    final b1 = Offset(cx + halfBase * math.cos(perp), cy + halfBase * math.sin(perp));
    final b2 = Offset(cx - halfBase * math.cos(perp), cy - halfBase * math.sin(perp));
    final needle = Path()
      ..moveTo(b1.dx, b1.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(b2.dx, b2.dy)
      ..close();
    final tailHalf = halfBase * 0.8;
    final t1 = Offset(cx + tailHalf * math.cos(perp), cy + tailHalf * math.sin(perp));
    final t2 = Offset(cx - tailHalf * math.cos(perp), cy - tailHalf * math.sin(perp));
    final tailPath = Path()
      ..moveTo(t1.dx, t1.dy)
      ..lineTo(tail.dx, tail.dy)
      ..lineTo(t2.dx, t2.dy)
      ..close();
    if (active) {
      canvas.drawPath(
        needle,
        Paint()
          ..color = needleColor.withValues(alpha: inTune ? 0.6 : 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawPath(tailPath, Paint()..color = const Color(0xFF3A3D48));
    canvas.drawPath(needle, Paint()..color = needleColor);

    // Brushed-metal centre cap.
    final capR = size.width * 0.03;
    final capRect = Rect.fromCircle(center: Offset(cx, cy), radius: capR);
    canvas.drawCircle(
      Offset(cx, cy),
      capR,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [Color(0xFF5A5E6B), Color(0xFF1C1E26)],
        ).createShader(capRect),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      capR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF0A0A10),
    );
    canvas.drawCircle(Offset(cx, cy), size.width * 0.011,
        Paint()..color = inTune ? const Color(0xFF34D399) : const Color(0xFF12121A));
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
