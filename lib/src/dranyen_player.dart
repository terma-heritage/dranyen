import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

/// Hidden, in-progress playable dranyen. Reached from the easter-egg dot on the
/// tuner screen. Three courses (La · Re · So); two fret bars lift La/Re to
/// ti/mi (×200¢) and do/fa (×300¢); So is a fretless drone. Strum-required —
/// fretting a ringing string bends its pitch live. Open samples are Tenzin
/// Norbu's recordings; fretted notes are pitch-shifted from the open string,
/// which is physically what fretting does.
class DranyenPlayerScreen extends StatefulWidget {
  const DranyenPlayerScreen({super.key});
  @override
  State<DranyenPlayerScreen> createState() => _DranyenPlayerScreenState();
}

class _Str {
  final String course;
  final double xFrac;
  final int side; // 0 or 1 (the two strings of a course)
  double amp0 = 0, t = 0, py = 0.6;
  bool active = false;
  _Str(this.course, this.xFrac, this.side);
}

class _DranyenPlayerScreenState extends State<DranyenPlayerScreen>
    with SingleTickerProviderStateMixin {
  static const Map<String, double> _courseX = {'la': 0.47, 're': 0.66, 'so': 0.85};
  static const double _pairGap = 12;
  static const List<double> _fretCents = [0, 200, 300]; // by fret level, for la & re

  Soundpool? _pool;
  final Map<String, int> _ids = {};            // open-sample id per course
  final Map<String, int?> _stream = {'la': null, 're': null, 'so': null};
  int _fret = 0;                               // 0 open · 1 ti/mi · 2 do/fa
  bool _ready = false;

  late final AnimationController _ctrl;
  final List<_Str> _strings = [];
  final Stopwatch _clock = Stopwatch();
  double _lastSec = 0;

  String? _lastC;
  double _lastX = 0;
  int _lastMs = 0;

  @override
  void initState() {
    super.initState();
    for (final c in ['la', 're', 'so']) {
      for (final side in [0, 1]) {
        _strings.add(_Str(c, _courseX[c]!, side));
      }
    }
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_tick)
      ..repeat();
    _clock.start();
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    final pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.music, maxStreams: 8),
    );
    for (final c in ['la', 're', 'so']) {
      _ids[c] = await pool.load(await rootBundle.load('assets/audio/$c.mp3'));
    }
    if (!mounted) {
      pool.dispose();
      return;
    }
    setState(() {
      _pool = pool;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pool?.dispose();
    super.dispose();
  }

  void _tick() {
    final s = _clock.elapsedMicroseconds / 1e6;
    double dt = s - _lastSec;
    _lastSec = s;
    if (dt > 0.05) dt = 0.05;
    for (final str in _strings) {
      if (!str.active) continue;
      str.t += dt;
      if (str.amp0 * math.exp(-str.t * 3.1) < 0.5) str.active = false;
    }
  }

  double _rate(String c) =>
      c == 'so' ? 1.0 : math.pow(2, _fretCents[_fret] / 1200).toDouble();

  Future<void> _pluck(String c, double strength, double py) async {
    final pool = _pool;
    if (pool == null) return;
    final old = _stream[c];
    if (old != null) pool.stop(old);
    _excite(c, strength, py);
    final sid = await pool.play(_ids[c]!, rate: _rate(c));
    _stream[c] = sid;
  }

  void _excite(String c, double strength, double py) {
    final amp = 13.0 * math.min(strength, 1.6);
    for (final str in _strings) {
      if (str.course != c) continue;
      str.amp0 = amp;
      str.t = 0;
      str.py = py;
      str.active = true;
    }
  }

  void _applyFret(int level) {
    setState(() => _fret = level);
    final pool = _pool;
    if (pool == null) return;
    for (final c in ['la', 're']) {
      final id = _stream[c];
      if (id != null) pool.setRate(streamId: id, playbackRate: _rate(c));
    }
  }

  String _courseAtX(double dx, double w) {
    final f = dx / w;
    return f < 0.565 ? 'la' : (f < 0.755 ? 're' : 'so');
  }

  void _sweep(Offset local, double w, double h, double zoneTop) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final speed =
        math.min((local.dx - _lastX).abs() / math.max(now - _lastMs, 1) * 6, 1.5) + 0.5;
    _lastX = local.dx;
    _lastMs = now;
    final c = _courseAtX(local.dx, w);
    if (c != _lastC) {
      _lastC = c;
      final py = ((zoneTop + local.dy) / h).clamp(0.45, 0.9).toDouble();
      _pluck(c, speed, py);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth, h = constraints.maxHeight;
          final zoneTop = h * 0.53;
          return Stack(
            children: [
              // warm wood
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1, -0.35),
                    end: Alignment(1, 0.35),
                    colors: [Color(0xFF7C4F17), Color(0xFF9C6A22), Color(0xFFAD7B2C), Color(0xFF925F1D)],
                    stops: [0, 0.34, 0.6, 1],
                  ),
                ),
              ),
              // vibrating strings
              Positioned.fill(
                child: CustomPaint(painter: _StringsPainter(_strings, _pairGap, _ctrl)),
              ),
              // fret bars
              _fretBar(w, h, 1, 'ti', 'mi', 0.21),
              _fretBar(w, h, 2, 'do', 'fa', 0.39),
              // open labels
              _label(w, h, 'la', 0.47),
              _label(w, h, 're', 0.66),
              _label(w, h, 'so', 0.85),
              // strum line + hint
              Positioned(
                left: 14, right: 14, top: zoneTop,
                child: SizedBox(height: 2, child: CustomPaint(painter: _DashedLine())),
              ),
              Positioned(
                left: 0, right: 0, top: zoneTop + 8,
                child: const Center(child: Text('strum below the line',
                    style: TextStyle(color: Color(0x8CFFF6E4), fontSize: 11))),
              ),
              // strum zone
              Positioned(
                left: 0, right: 0, top: zoneTop, bottom: 0,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) { _lastC = null; _lastX = e.localPosition.dx; _lastMs = DateTime.now().millisecondsSinceEpoch; _sweep(e.localPosition, w, h, zoneTop); },
                  onPointerMove: (e) => _sweep(e.localPosition, w, h, zoneTop),
                  onPointerUp: (_) => _lastC = null,
                  onPointerCancel: (_) => _lastC = null,
                ),
              ),
              // back arrow
              Positioned(
                top: MediaQuery.of(context).padding.top + 4, left: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xCCFFF6E4)),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              if (!_ready)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xCC140F09),
                    alignment: Alignment.center,
                    child: const Text('tuning the strings…',
                        style: TextStyle(color: Color(0xFFF7EAD2), fontSize: 16)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _fretBar(double w, double h, int level, String l, String r, double top) {
    final on = _fret == level;
    return Positioned(
      left: w * 0.41, width: w * 0.31, top: h * top, height: 64,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => _applyFret(level),
        onPointerUp: (_) { if (_fret == level) _applyFret(0); },
        onPointerCancel: (_) { if (_fret == level) _applyFret(0); },
        child: Container(
          decoration: BoxDecoration(
            color: on ? const Color(0xEAFFF7E6) : const Color(0x1FFFF6E4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? Colors.white : const Color(0x66FFF6E4), width: 1.5),
            boxShadow: on ? const [BoxShadow(color: Color(0x29FFF7E6), spreadRadius: 5)] : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l, style: TextStyle(fontSize: 14, letterSpacing: 0.5, color: on ? const Color(0xFF6A4408) : const Color(0xD9FFF6E4))),
              Text(r, style: TextStyle(fontSize: 14, letterSpacing: 0.5, color: on ? const Color(0xFF6A4408) : const Color(0xD9FFF6E4))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(double w, double h, String text, double frac) {
    return Positioned(
      left: w * frac - 8, top: h * 0.49 - 8,
      child: Text(text, style: const TextStyle(color: Color(0x8CFFF6E4), fontSize: 12)),
    );
  }
}

class _StringsPainter extends CustomPainter {
  final List<_Str> strings;
  final double pairGap;
  _StringsPainter(this.strings, this.pairGap, Listenable repaint) : super(repaint: repaint);

  double _shape(double yn, double py) =>
      math.sin(math.pi * yn) * (0.6 + 0.4 * math.exp(-math.pow((yn - py) * 3.2, 2)));

  @override
  void paint(Canvas canvas, Size size) {
    final H = size.height;
    const int N = 26;
    for (final s in strings) {
      final x = size.width * s.xFrac + (s.side == 1 ? pairGap : 0);
      if (s.active) {
        final amp = s.amp0 * math.exp(-s.t * 3.1);
        final osc = math.sin(s.t * 2 * math.pi * 9);
        final spindle = Path();
        for (int i = 0; i <= N; i++) {
          final yn = i / N, y = yn * H, d = amp * _shape(yn, s.py);
          i == 0 ? spindle.moveTo(x + d, y) : spindle.lineTo(x + d, y);
        }
        for (int i = N; i >= 0; i--) {
          final yn = i / N, y = yn * H, d = amp * _shape(yn, s.py);
          spindle.lineTo(x - d, y);
        }
        spindle.close();
        canvas.drawPath(spindle, Paint()..color = const Color(0x1AFFF6E4));
        final line = Path();
        for (int i = 0; i <= N; i++) {
          final yn = i / N, y = yn * H, d = amp * _shape(yn, s.py) * osc;
          i == 0 ? line.moveTo(x + d, y) : line.lineTo(x + d, y);
        }
        canvas.drawPath(line, Paint()
          ..color = const Color(0x40FFF8E8)..style = PaintingStyle.stroke..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawPath(line, Paint()
          ..color = const Color(0xF5FFF8E8)..style = PaintingStyle.stroke..strokeWidth = 2);
      } else {
        canvas.drawLine(Offset(x, 0), Offset(x, H), Paint()
          ..color = const Color(0xE6FFF8E8)..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StringsPainter oldDelegate) => true;
}

class _DashedLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x80FFF6E4)..strokeWidth = 2;
    const dash = 7.0, gap = 6.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + dash, size.width), 0), p);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
