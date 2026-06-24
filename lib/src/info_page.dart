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
            Text('Dramnyen Tuner',
                style: TextStyle(color: _ink, fontSize: 26, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('by Terma Heritage Foundation', style: TextStyle(color: _gold, fontSize: 14)),
            SizedBox(height: 22),

            _H('What it is'),
            _P('A simple, accurate tuner for the dramnyen — the traditional Tibetan lute. '
                'Pluck a string and the tuner tells you the note and how to adjust it, '
                'so your instrument is always in tune.'),

            _H('How to tune'),
            _P('Tap Start and allow the microphone, then pluck an open string. '
                'Tune the peg until the note turns green and the needle settles in the centre — '
                'that course is in tune.'),
            _P('The dramnyen is tuned by its three open courses: La, Re and So. '
                'The tuner detects whichever note you play automatically; tap La, Re or So '
                'to lock onto one if you prefer.'),

            _H('The tuning'),
            _P('Dramnyen Tuner uses the D-major tuning at A = 440 Hz, confirmed with a master '
                'player. So and La are re-entrant — they sound an octave below the other notes.'),

            _H('About the project'),
            _P('The Terma Heritage Foundation builds tools to preserve and share the living '
                'traditions of Tibetan music. This is placeholder text and will be expanded — '
                'more about the foundation, the instrument and its makers is coming soon.'),

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
