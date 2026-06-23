import 'package:flutter/material.dart';

import 'arc_gauge.dart';
import 'notes.dart';
import 'tuner_controller.dart';
import 'tuner_engine.dart';

const _bg = Color(0xFF0F1117);
const _green = Color(0xFF34D399);
const _amber = Color(0xFFF0A93C);
const _red = Color(0xFFEF4444);
const _idle = Color(0xFF9AA0AB);
const _muted = Color(0xFF7C828E);

class TunerScreen extends StatefulWidget {
  const TunerScreen({super.key});
  @override
  State<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends State<TunerScreen> {
  final TunerController _c = TunerController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Color _stateColor(double? cents, bool hasReading, bool inTune) {
    if (!hasReading) return _idle;
    if (inTune) return _green;
    return cents!.abs() <= 15 ? _amber : _red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final r = _c.reading;
            final has = r != null;
            final color = _stateColor(r?.cents, has, _c.inTune);
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
              child: Column(
                children: [
                  _topBar(),
                  const Spacer(flex: 2),
                  _bigReadout(r, color),
                  const SizedBox(height: 6),
                  _centsLine(r),
                  const SizedBox(height: 14),
                  ArcGauge(cents: r?.cents ?? 0, color: color, active: has, inTune: _c.inTune),
                  const SizedBox(height: 10),
                  _status(r, color),
                  const Spacer(flex: 2),
                  _coursePills(r),
                  const SizedBox(height: 16),
                  if (_c.listening) _levelBar(),
                  const SizedBox(height: 12),
                  _micButton(),
                  if (_c.error != null) ...[
                    const SizedBox(height: 10),
                    Text(_c.error!, textAlign: TextAlign.center, style: const TextStyle(color: _red, fontSize: 12)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() {
    final locked = _c.locked;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _c.setLocked(null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(locked == null ? Icons.mic_none : Icons.lock_outline, size: 15, color: _muted),
              const SizedBox(width: 5),
              Text(locked == null ? 'Auto' : 'Locked: ${locked.solfege}', style: const TextStyle(color: _muted, fontSize: 12)),
            ]),
          ),
        ),
        const Text('A = 440 Hz', style: TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }

  Widget _bigReadout(TunerReading? r, Color color) {
    return Column(
      children: [
        Text(r?.note?.solfege ?? 'Tuner', style: const TextStyle(color: _muted, fontSize: 14, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(r?.note?.number ?? '—', style: TextStyle(color: color, fontSize: 86, fontWeight: FontWeight.w500, height: 1)),
            if (r?.note != null) ...[
              const SizedBox(width: 10),
              Text(r!.note!.pitch, style: const TextStyle(color: _idle, fontSize: 22)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _centsLine(TunerReading? r) {
    final text = r == null
        ? (_c.listening ? 'listening…' : '')
        : '${r.freq.toStringAsFixed(1)} Hz   ·   ${r.cents >= 0 ? '+' : ''}${r.cents.toStringAsFixed(0)} cents';
    return SizedBox(height: 18, child: Text(text, style: const TextStyle(color: _muted, fontSize: 13)));
  }

  Widget _status(TunerReading? r, Color color) {
    String text;
    if (!_c.listening) {
      text = 'Tap to start, then pluck a string';
    } else if (r == null) {
      text = 'Pluck a string…';
    } else if (_c.inTune) {
      text = '✓  In tune';
    } else {
      text = r.cents < 0 ? 'Too low — tighten the peg' : 'Too high — loosen the peg';
    }
    return SizedBox(
      height: 20,
      child: Text(text, style: TextStyle(color: r != null || !_c.listening ? color : _muted, fontSize: 15, fontWeight: FontWeight.w500)),
    );
  }

  Widget _coursePills(TunerReading? r) {
    return Row(
      children: openStrings.map((n) {
        final isLocked = _c.locked?.solfege == n.solfege;
        final isDetected = _c.locked == null && _c.listening && r?.note?.solfege == n.solfege;
        final highlight = isLocked || isDetected;
        final accent = _c.inTune && highlight ? _green : _amber;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => _c.setLocked(isLocked ? null : n),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: highlight ? accent.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: highlight ? accent : Colors.transparent, width: 1.5),
                ),
                child: Column(children: [
                  Text(n.solfege, style: TextStyle(color: highlight ? accent : const Color(0xFFB6BAC2), fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(n.pitch, style: const TextStyle(color: _muted, fontSize: 11)),
                ]),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _levelBar() {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: _c.level.clamp(0.0, 1.0),
          minHeight: 4,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          valueColor: AlwaysStoppedAnimation(_c.level > 0.02 ? _green : _muted),
        ),
      ),
      const SizedBox(height: 4),
      Text(_c.level > 0.02 ? 'Mic input' : 'No sound — move closer', style: const TextStyle(color: _muted, fontSize: 10)),
    ]);
  }

  Widget _micButton() {
    final on = _c.listening;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => on ? _c.stop() : _c.start(),
        style: FilledButton.styleFrom(
          backgroundColor: on ? _red : _amber,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(on ? 'Stop' : 'Start tuning', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
      ),
    );
  }
}
