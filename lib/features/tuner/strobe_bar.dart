import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A Peterson-style strobe band: the stripes drift left or right at a speed set
/// by how far off pitch you are (flat drifts one way, sharp the other) and
/// freeze dead-still the moment you're in tune. The classic "pro hardware" cue.
class StrobeBar extends StatefulWidget {
  final double cents;
  final bool active;
  final bool inTune;
  final Color color;

  const StrobeBar({
    super.key,
    required this.cents,
    required this.active,
    required this.inTune,
    required this.color,
  });

  @override
  State<StrobeBar> createState() => _StrobeBarState();
}

class _StrobeBarState extends State<StrobeBar> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _phase = 0;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration now) {
    final dt = _last == Duration.zero ? 0.0 : (now - _last).inMicroseconds / 1e6;
    _last = now;
    final c = widget.cents.clamp(-50.0, 50.0);
    // px/sec — zero when in tune (frozen) or idle.
    final vel = (!widget.active || widget.inTune) ? 0.0 : (c / 50.0) * 90.0;
    if (vel != 0.0) setState(() => _phase += vel * dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 16,
        width: double.infinity,
        child: CustomPaint(
          painter: _StrobePainter(_phase, widget.active, widget.inTune, widget.color),
        ),
      ),
    );
  }
}

class _StrobePainter extends CustomPainter {
  final double phase;
  final bool active;
  final bool inTune;
  final Color color;
  _StrobePainter(this.phase, this.active, this.inTune, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Recessed track; the gaps between stripes show this through.
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF14141C));

    const stripe = 14.0;
    const period = stripe * 2;
    final lit = inTune
        ? color
        : (active ? color.withValues(alpha: 0.85) : const Color(0xFF2B2E3A));
    final paint = Paint()..color = lit;
    var x = -(phase % period) - period;
    while (x < size.width) {
      canvas.drawRect(Rect.fromLTWH(x, 0, stripe, size.height), paint);
      x += period;
    }

    // Faint top sheen so the band reads like glass over the strobe.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.35),
      Paint()..color = Colors.white.withValues(alpha: 0.05),
    );
  }

  @override
  bool shouldRepaint(_StrobePainter old) =>
      old.phase != phase || old.active != active || old.inTune != inTune || old.color != color;
}
