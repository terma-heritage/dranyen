import 'dart:math' as math;

/// One-Euro filter (Casiez et al., 2012) — adaptive smoothing for a noisy,
/// interactive signal. The trick a fixed low-pass can't do: it barely smooths
/// when the value is moving fast (so the needle *snaps* when you turn the peg)
/// and smooths hard when it's steady (so it sits rock-still when you hold a
/// note). This is what makes a tuner feel responsive AND stable at once.
class OneEuroFilter {
  double minCutoff;
  double beta;
  double dCutoff;

  double? _xPrev;
  double? _dxPrev;
  double? _tPrev;

  OneEuroFilter({this.minCutoff = 1.2, this.beta = 0.5, this.dCutoff = 1.0});

  double _alpha(double cutoff, double dt) {
    final tau = 1 / (2 * math.pi * cutoff);
    return 1 / (1 + tau / dt);
  }

  /// Feed a new sample [x] at time [tSeconds]; returns the smoothed value.
  double filter(double x, double tSeconds) {
    if (_tPrev == null) {
      _xPrev = x;
      _dxPrev = 0;
      _tPrev = tSeconds;
      return x;
    }
    final dt = (tSeconds - _tPrev!).clamp(1e-3, 1.0);
    final dx = (x - _xPrev!) / dt;
    final aD = _alpha(dCutoff, dt);
    final dxHat = aD * dx + (1 - aD) * _dxPrev!;
    final cutoff = minCutoff + beta * dxHat.abs();
    final a = _alpha(cutoff, dt);
    final xHat = a * x + (1 - a) * _xPrev!;
    _xPrev = xHat;
    _dxPrev = dxHat;
    _tPrev = tSeconds;
    return xHat;
  }

  void reset() {
    _xPrev = null;
    _dxPrev = null;
    _tPrev = null;
  }
}
