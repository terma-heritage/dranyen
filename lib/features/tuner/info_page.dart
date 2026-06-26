import 'package:flutter/material.dart';

const _bg = Color(0xFF0F1117);
const _ink = Color(0xFFE8E6E1);
const _muted = Color(0xFF9AA0AB);
const _gold = Color(0xFFD4A853);

/// About / info screen. Placeholder copy for now — to be refined later.
class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _ink,
        title: const Text('About', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: const [
            Text('Dranyen Tuner',
                style: TextStyle(color: _ink, fontSize: 26, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('by Terma Heritage Foundation', style: TextStyle(color: _gold, fontSize: 14)),
            SizedBox(height: 18),
            _Credits(),
            SizedBox(height: 8),

            _H('What it is'),
            _P('A simple, accurate tuner for the dranyen — the traditional Tibetan lute. '
                'Pluck a string and the tuner tells you the note and how to adjust it, '
                'so your instrument is always in tune.'),

            _H('How to tune'),
            _P('Tap Start and allow the microphone, then pluck an open string. '
                'Tune the peg until the note turns green and the needle settles in the centre — '
                'that course is in tune.'),
            _P('The dranyen is tuned by its three open courses: La, Re and So. '
                'The tuner detects whichever note you play automatically; tap La, Re or So '
                'to lock onto one if you prefer.'),

            _H('The tuning'),
            _P('Dranyen Tuner uses the D-major tuning at A = 440 Hz, confirmed with a master '
                'player. So and La are re-entrant — they sound an octave below the other notes.'),

            _H('Calibration'),
            _P('Tap the “A = 440 Hz” chip to change the reference. Nudge concert pitch '
                '(432 · 440 · 442 and anything between), or choose “Tune to your own La”: '
                'pluck the La you like, capture it, and Re and So follow from that same '
                'reference — the way the dranyen is traditionally tuned by ear.'),

            _H('About the project'),
            _P('Terma Heritage Foundation preserves Tibetan and Himalayan cultural heritage '
                'through technology, arts, education, and community programs.'),

            SizedBox(height: 24),
            Text('Version 1.0', style: TextStyle(color: _muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String text;
  const _H(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 8),
        child: Text(text, style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w600)),
      );
}

class _P extends StatelessWidget {
  final String text;
  const _P(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(color: _muted, fontSize: 15, height: 1.5)),
      );
}

/// The team credit card near the top of the About page.
class _Credits extends StatelessWidget {
  const _Credits();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Credit('Lead developer', 'Thupten Chakrishar'),
          SizedBox(height: 13),
          _Credit('Sound recordings & collaboration', 'Tenzin Norbu (Tennor)'),
          SizedBox(height: 13),
          _Credit('With guidance from', 'Jhola Techung · Phurbu T. Namgyal · Karma Drukya'),
        ],
      ),
    );
  }
}

class _Credit extends StatelessWidget {
  final String role;
  final String name;
  const _Credit(this.role, this.name);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(role,
            style: const TextStyle(color: _gold, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 3),
        Text(name, style: const TextStyle(color: _ink, fontSize: 15.5, height: 1.3)),
      ],
    );
  }
}
