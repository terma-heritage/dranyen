/// The dramnyen's tuning (A = 440 Hz), D major. So (A2) and La (B2) are
/// re-entrant — they sound an octave below the rest. Confirmed with a master
/// player and verified against Tenzin Norbu's recordings.
class DramnyenNote {
  final String number; // '1'..'7'
  final String solfege; // Do, Re, Mi, Fa, So, La, Ti
  final String pitch; // display name, e.g. 'F♯3'
  final double hz;
  final bool low; // re-entrant (octave-down) note
  final bool openString; // one of the three tuned courses (La · Re · So)

  const DramnyenNote(this.number, this.solfege, this.pitch, this.hz, {this.low = false, this.openString = false});
}

const List<DramnyenNote> tuning = [
  DramnyenNote('1', 'Do', 'D3', 146.83),
  DramnyenNote('2', 'Re', 'E3', 164.81, openString: true),
  DramnyenNote('3', 'Mi', 'F♯3', 185.00),
  DramnyenNote('4', 'Fa', 'G3', 196.00),
  DramnyenNote('5', 'So', 'A2', 110.00, low: true, openString: true),
  DramnyenNote('6', 'La', 'B2', 123.47, low: true, openString: true),
  DramnyenNote('7', 'Ti', 'C♯3', 138.59),
];

/// The three open courses the player actually tunes, in spoken order.
final List<DramnyenNote> openStrings = ['La', 'Re', 'So']
    .map((s) => tuning.firstWhere((n) => n.solfege == s))
    .toList(growable: false);
