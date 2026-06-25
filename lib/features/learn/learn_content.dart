import 'package:flutter/material.dart';

/// Learn-section content, condensed from the Terma Heritage knowledge base and
/// faithful to its cited scholarship (principally Tashi Tenzin, *Dranyen: A
/// Study in Tibetan Identity*, Tibet Policy Institute). Plain data so it works
/// fully offline.

sealed class Block {
  const Block();
}

class H extends Block {
  final String text;
  const H(this.text);
}

class P extends Block {
  final String text;
  const P(this.text);
}

class Bul extends Block {
  final List<String> items;
  const Bul(this.items);
}

class Quote extends Block {
  final String text;
  final String? attribution;
  const Quote(this.text, [this.attribution]);
}

class Tbl extends Block {
  final List<String> headers;
  final List<List<String>> rows;
  const Tbl(this.headers, this.rows);
}

class Note extends Block {
  final String text;
  const Note(this.text);
}

class Article {
  final String title;
  final String summary;
  final IconData icon;
  final List<Block> blocks;
  const Article({required this.title, required this.summary, required this.icon, required this.blocks});
}

const List<Article> learnArticles = [
  Article(
    title: 'History & origins',
    summary: 'A thousand years, from 7th-century Tibet to survival in exile.',
    icon: Icons.history_edu,
    blocks: [
      P('For roughly a thousand years the dranyen has been the foundation of Tibetan traditional music — believed to have been created on the Tibetan plateau, yet woven from threads that reach across Central Asia.'),
      H('The name'),
      P('Dranyen (Tibetan སྒྲ་སྙན་, Wylie sgra-snyan) joins two syllables — dra (tune) and nyen (melody) — and is best rendered "the instrument of melodious sound." By the 17th century it was widely known as the Ngari dranyen, after the region of its prominence. In Tibetan tradition it is grouped, unexpectedly, with percussion; Western organology files it under strings.'),
      H('Origins in the 7th century'),
      P('Most accounts place its emergence around the 7th century, during the reign of King Songtsen Gampo (c. 617–649 CE) — read from murals at Samye Monastery, the Jokhang, and the Potala Palace, which show the king entertained by court minstrels. Chronicles record the dranyen at the royal receptions for his Nepali (634 CE) and Chinese (641 CE) queens.'),
      H('Where did it come from?'),
      P('Because the earliest history survives mostly as oral tradition, several theories coexist:'),
      Bul([
        'Central Asian lutes — ethnomusicologist Ian Collinge traces roots to short-necked lutes like the Tajik Kashgar rubab and Uyghur Pamir robab; the horse-head finial echoes Eurasian horse cultures.',
        'The sarod / rubab line — adapted from the Indian sarod (itself from the Afghan rubab), carried by Kashmiri Muslim (Khache) communities.',
        'The Saraswati legend — tied to the goddess Saraswati (Tibetan Lhamo Yangchenma), patron of music and learning.',
        "Kongpo's forests — shaped in southern Tibet's forested Kongpo region, prized for its dense timber.",
      ]),
      P('The consensus in the source literature is that, whatever its inspirations, the instrument as it exists today was creatively developed within Tibet and resembles no other instrument now in use.'),
      H('The golden age: the Fifth Dalai Lama'),
      P('After the Great Fifth Dalai Lama established the Ganden Phodrang government in 1642, his regent Desi Sangye Gyatso invited the master musician Tashi to Lhasa to set down the instrument\'s root text, and the classical genre Nangma-Toeshey was composed for the first time. Lyrics from this courtly tradition still circulate — including the famous quatrain attributed to the Sixth Dalai Lama, foretelling his own rebirth:'),
      Quote('White crane! Lend me your wings,\nI will not fly far —\nfrom Lithang, I shall return.', 'attributed to the Sixth Dalai Lama'),
      P('In the late 18th century the musician Doring Tenzin Paljor brought the hammered dulcimer and the erhu from China to accompany the dranyen, and introduced Chinese phuzi notation — opening an era of ensemble music.'),
      H('Rupture and survival after 1959'),
      P('Following the occupation of Tibet, traditional genres were banned outright during the Cultural Revolution (1966–1976). In exile, the Tibetan Institute of Performing Arts (TIPA) — founded on 11 August 1959, based in Dharamsala under the patronage of the 14th Dalai Lama — became the heart of preservation, training hundreds of artists and music teachers and, in 1993, publishing the first songbook of Nangma-Toeshey with lyrics and notation.'),
      P('That lineage runs directly into this app: among TIPA\'s leading 21st-century performers is Tenzin Norbu ("Tenor"), who trained under master Gonpo Dorjee — the musician whose recordings give this app its sound.'),
      Note('Summarised from Tashi Tenzin, Dranyen: A Study in Tibetan Identity (Tibet Policy Institute), with Ian Collinge and Melvyn C. Goldstein. See Sources.'),
    ],
  ),
  Article(
    title: 'The instrument',
    summary: 'A fretless lute: six strings in three courses, and its La·Re·So tuning.',
    icon: Icons.music_note,
    blocks: [
      P('The dranyen is a long-necked, fretless plucked lute — warm, resonant, and unmistakably Tibetan in silhouette, from its waisted body to the carved head crowning its neck.'),
      H('Body & construction'),
      P('A long-necked, two-waisted, fretless lute, usually hollowed from a single piece of wood and ranging from roughly 60 to 120 cm long. Instead of a round sound-hole, the soundboard carries rosette-shaped openings in the manner of old European lutes; the lower bout is often closed with a stretched skin membrane, giving the body its warm, slightly boxy voice.'),
      H('The head & pegs'),
      P('The neck ends in a carved finial — most often a horse\'s head, and in Amdo a dragon\'s head (drug-go). The tuning pegs are traditionally said to take the shape of the phurba, the Tibetan ritual dagger.'),
      H('Strings & courses'),
      P('The classic Tibetan dranyen carries six strings arranged in three double courses — three pairs, each tuned in unison. Strings were originally animal gut, today commonly nylon. It is played by strumming, finger-picking and plucking.'),
      H('Tuning — the open courses'),
      P('The instrument is tuned by its three open courses, not note by note. In the tuning documented for this project — confirmed with a master player and verified against the recordings — the courses are La · Re · So, in D major (A = 440 Hz). Two of the seven degrees are re-entrant: So and La sound an octave below the rest.'),
      Tbl(
        ['Course', 'Solfège', 'Pitch', 'Frequency'],
        [
          ['1st (open)', 'La', 'B2', '123.47 Hz'],
          ['2nd (open)', 'Re', 'E3', '164.81 Hz'],
          ['3rd (open)', 'So', 'A2', '110.00 Hz'],
        ],
      ),
      Note('Full scale, low to high: So (A2) · La (B2) · Ti (C♯3) · Do (D3) · Re (E3) · Mi (F♯3) · Fa (G3). The two strings of each course sit a few cents apart (~2–7¢), so they gently beat against one another — a shimmer natural to the instrument.'),
      H('A note on classification'),
      P('Curiously, Tibetan tradition classifies the dranyen within the percussion family, whereas Western organology places it among chordophones (strings) — a small reminder that instruments carry the worldview of the culture that names them.'),
      Note('Sources: Tashi Tenzin (Tibet Policy Institute); "Dramyin" (Wikipedia); the La-re-so solfège study. See Sources.'),
    ],
  ),
  Article(
    title: 'Notation',
    summary: 'From a scale named for animal cries to today\'s numbers 1–7.',
    icon: Icons.format_list_numbered,
    blocks: [
      P('Over the centuries the dranyen has been written in several systems — from ancient Tibetan scales, to a seven-note scale named for animal cries, to today\'s numbers. They describe the same tones in different hands.'),
      H('The earliest systems'),
      P('Tibet notated monastic and ritual instruments before lay ones, each Buddhist sect — and the indigenous Bön tradition — using its own signs. The earliest dranyen notations (Phothong, Mothong, Bhartong) are described as having fifteen notes, prevailing until about the 8th century before a system adapted from Indian sargam took over.'),
      H('The seven notes — named for animals'),
      P('The Great Dungkar Dictionary records a seven-note scale in which each degree is named for the voice of an animal — a poetic naming of the solfège:'),
      Tbl(
        ['№', 'Sol-Fa', 'Sargam', 'Phu-zi', 'Tibetan', 'Animal voice'],
        [
          ['1', 'Do', 'Sa', 'Rhang', 'Druk-kye', 'Cry of the peacock'],
          ['2', 'Re', 'Re', 'Tre', 'Drang-song', 'Lowing of the bull'],
          ['3', 'Mi', 'Ga', 'Kung', 'Sa-zin', 'Bleating of a goat'],
          ['4', 'Fa', 'Ma', 'Phen', 'Bhar-ma', 'Call of the heron'],
          ['5', 'So', 'Pa', "Li'u", 'Nga-dhen', 'Call of the cuckoo'],
          ['6', 'La', 'Dha', "U'u", 'Los-sel', 'Neighing of the horse'],
          ['7', 'Ti', 'Ni', 'Yee', 'Khor-nyen', 'Trumpeting of the elephant'],
        ],
      ),
      H('Phuzi, Sol-Fa & numbers'),
      P('In 1793 Doring Tenzin Paljor, after studying in China, introduced Chinese phuzi notation, used for Nangma-Toeshey into the early 1980s. It was then largely replaced by numbered notation — the Chevé (Galin-Paris-Chevé) system, read aloud in Sol-Fa syllables but written in numerals, and known to Western scholars as "Asian numbered notation."'),
      H('The system used here'),
      P('This project uses the living numbered notation: digits 1–7 for the scale degrees, with rhythm shown by underlines and dashes, and 0 for a rest. Because So (5) and La (6) are re-entrant (sounding an octave low), they carry a dot beneath the number — exactly as in the master player\'s hand. Since every number maps to a known pitch, a piece can also be rendered as Western staff notation.'),
      Note('Sources: Tashi Tenzin (Tibet Policy Institute); Dungkar Losang Thinley, Dungkar Tibetological Great Dictionary (2002).'),
    ],
  ),
  Article(
    title: 'Music & genres',
    summary: 'Courtly Gharlu, the classical Nangma-Toeshey, and folk songs.',
    icon: Icons.library_music,
    blocks: [
      P('From the courts of the Dalai Lamas to circle-dances after the harvest, the dranyen has carried many kinds of music. Its classical heart is the genre known as Nangma-Toeshey.'),
      H('Gharlu — the court music'),
      P('Gharlu is courtly music, said to comprise 74 compositions performed especially for the Dalai Lamas and heard at the banquets of the Lhasa nobility. It predates Nangma-Toeshey and differs from it in length and form.'),
      H('Nangma'),
      P('Nangma — literally "inner" — is the elegant, leisurely classical song-form that rose to prominence under the Fifth Dalai Lama in the 17th century. Its verses are typically four six-syllable lines, ornamented with vocables such as la ni, so ni and ya la, and it unfolds in three parts: an instrumental introduction, sung arias, and quick steps at the close.'),
      H('Toeshey'),
      P('Toeshey takes its name from the Toe region of western Tibet, where people performed circle-dances at harvests, weddings and gatherings. Nangma and Toeshey are close cousins; the chief difference is tempo — Nangma leisurely, Toeshey a touch brisker — and together, as Nangma-Toeshey, they form the central pillar of Tibetan classical music.'),
      H('Folk & street songs'),
      P('Beyond the court, folk songs accompanied farming, herding and daily life. In early-20th-century Lhasa, a tradition of street songs served as political satire and public commentary — a rare voice for ordinary, often illiterate citizens — documented by Melvyn C. Goldstein.'),
      H('Voices that carried the tradition'),
      P('The blind master Acho Namgyal renewed Tibetan classical music in the era of the 13th Dalai Lama. In Amdo, the physician-musician Palden Gonpo ("Palgon") made the dranyen central to Amdo music; his song Akhu Pema became beloved across the Tibetan world. In exile, TIPA\'s master Lutsa (1915–1983) carried the repertoire to a new generation, and players such as Tenzin Norbu ("Tenor") became leading 21st-century performers.'),
      Note('Sources: Tashi Tenzin (Tibet Policy Institute); Goldstein, "Lhasa Street Songs."'),
    ],
  ),
  Article(
    title: 'Sources',
    summary: 'The published scholarship behind this Learn section.',
    icon: Icons.menu_book,
    blocks: [
      P('This app\'s Learn content is built on published scholarship. The principal sources:'),
      Bul([
        'Tashi Tenzin — Dranyen: A Study in Tibetan Identity. Tibet Policy Institute, Central Tibetan Administration (the principal source). tibetpolicy.net',
        'Ian Collinge — "The Dra-nyen (The Himalayan Lute): An Emblem of Tibetan Culture," Chime Journal 6 (1993); and Asian Music XXVIII/1 (1996/97).',
        'Melvyn C. Goldstein — "Lhasa Street Songs: Political and Social Satire in Traditional Tibet."',
        'Dungkar Losang Thinley — Dungkar Tibetological Great Dictionary (2002), source of the seven animal-voice note names.',
        'Tibetan Institute of Performing Arts (TIPA), Dharamsala — tipa.asia',
        '"Dramyin" — Wikipedia: construction, dimensions, strings, Himalayan distribution.',
        '"La-re-so: Teaching the Tibetan Dranyen through Solfège" — Journal of the Vernacular Music Center.',
      ]),
      Note('The dranyen\'s early history survives largely through oral tradition, so some dates and origins are debated among Tibetan musicians and historians. Where sources differ, this archive presents the range of views. Corrections from scholars and tradition-holders are warmly welcomed — this is a living document.'),
    ],
  ),
];
