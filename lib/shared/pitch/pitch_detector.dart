import 'dart:math' as math;
import 'dart:typed_data';

/// Result of a pitch-detection pass.
class PitchResult {
  /// Fundamental frequency in Hz, or -1 if none was found.
  final double freq;

  /// 0..1 — how periodic the signal is. Higher = more confident.
  final double clarity;

  const PitchResult(this.freq, this.clarity);

  bool get found => freq > 0;
}

/// YIN pitch detector (de Cheveigné & Kawahara, 2002).
///
/// Chosen over plain autocorrelation because its decision is based on a
/// *normalised* difference, so it stays steady at the dramnyen's low pitches
/// (So 110 Hz, La 123 Hz) and detects soft/distant plucks above the noise floor
/// — the two things the web tuner struggled with.
PitchResult detectPitch(Float32List buf, double sampleRate, {double threshold = 0.12}) {
  final n = buf.length;
  final w = n >> 1; // integration window / max lag
  final tauMax = math.min(w - 1, (sampleRate / 70).floor()); // lowest pitch ~70 Hz
  if (tauMax < 2) return const PitchResult(-1, 0);
  final yin = Float64List(tauMax + 1);

  // 1. Difference function.
  for (var tau = 1; tau <= tauMax; tau++) {
    var sum = 0.0;
    for (var j = 0; j < w; j++) {
      final d = buf[j] - buf[j + tau];
      sum += d * d;
    }
    yin[tau] = sum;
  }

  // 2. Cumulative mean normalised difference.
  yin[0] = 1;
  var running = 0.0;
  for (var tau = 1; tau <= tauMax; tau++) {
    running += yin[tau];
    yin[tau] = running > 0 ? yin[tau] * tau / running : 1;
  }

  // 3. Absolute threshold — first dip below threshold, descended to its local min.
  var tau = -1;
  for (var t = 2; t <= tauMax; t++) {
    if (yin[t] < threshold) {
      while (t + 1 <= tauMax && yin[t + 1] < yin[t]) {
        t++;
      }
      tau = t;
      break;
    }
  }
  if (tau == -1) {
    var mn = double.infinity;
    for (var t = 2; t <= tauMax; t++) {
      if (yin[t] < mn) {
        mn = yin[t];
        tau = t;
      }
    }
    if (tau == -1) return const PitchResult(-1, 0);
  }

  // 4. Parabolic interpolation around the chosen lag.
  var betterTau = tau.toDouble();
  if (tau > 1 && tau < tauMax) {
    final s0 = yin[tau - 1];
    final s1 = yin[tau];
    final s2 = yin[tau + 1];
    final denom = 2 * (2 * s1 - s2 - s0);
    if (denom != 0) betterTau = tau + (s2 - s0) / denom;
  }

  final freq = sampleRate / betterTau;
  final clarity = math.max(0.0, 1 - yin[tau]);
  if (freq < 70 || freq > 700) return PitchResult(-1, clarity);
  return PitchResult(freq, clarity);
}

/// Cents between [freq] and [targetHz], folding [freq] into the target's octave
/// first so an octave-harmonic misread doesn't throw off the reading.
double centsFromTarget(double freq, double targetHz) {
  var f = freq;
  while (f < targetHz / math.sqrt2) {
    f *= 2;
  }
  while (f > targetHz * math.sqrt2) {
    f /= 2;
  }
  return 1200 * (math.log(f / targetHz) / math.ln2);
}
