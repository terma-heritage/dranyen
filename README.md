<div align="center">
  <img src="assets/branding/icon.png" width="120" alt="Dramnyen Tuner icon" />
  <h1>Dramnyen Tuner</h1>
  <p><em>A professional listening tuner for the <strong>dramnyen</strong>, the Tibetan lute.</em></p>
  <p>A project of the <strong>Terma Heritage Foundation</strong>.</p>
</div>

---

The dramnyen is the heart of Tibetan folk music, but it is rarely taught with
written notation and almost never with modern tools. **Dramnyen Tuner** is the
first piece of a small ecosystem built to keep the instrument — and the music
made on it — alive and learnable, for seasoned players and complete beginners
alike.

This is a native iOS + Android app built to feel like a real instrument tuner:
fast, sensitive, and steady.

## What it does

- **Listens** through the microphone and shows the note you're playing — one of
  the seven dramnyen degrees (Do · Re · Mi · Fa · So · La · Ti) — on a smooth
  analog dial that turns **green with a haptic tick** when you're in tune.
- **Holds your last pluck** on screen for a moment so you can read it after the
  string fades.
- **Free mode** simply names the note; tap **La · Re · So** to lock onto a course
  and get *tighten / loosen* guidance toward it.
- **Calibration** — nudge concert pitch (432 · 440 · 442 and between), or
  *“tune to your own La”*: pluck the La you like and Re and So follow from it,
  the traditional by-ear way.

## The tuning

D major, A = 440 Hz, confirmed with a master player and verified against
recordings. The three open courses are **La · Re · So**; So and La are
*re-entrant* — they sound an octave below the rest.

| Degree | Solfège | Pitch | Open course |
|:------:|:-------:|:-----:|:-----------:|
| 1 | Do | D3 (146.83 Hz) | |
| 2 | Re | E3 (164.81 Hz) | ● |
| 3 | Mi | F♯3 (185.00 Hz) | |
| 4 | Fa | G3 (196.00 Hz) | |
| 5 | So | A2 (110.00 Hz) | ● *(re-entrant)* |
| 6 | La | B2 (123.47 Hz) | ● *(re-entrant)* |
| 7 | Ti | C♯3 (138.59 Hz) | |

## How it's built

- **Flutter** — one codebase → iOS + Android.
- Pitch detection: **YIN** (`lib/src/pitch_detector.dart`) — steady at the low
  So/La pitches and sensitive to soft playing.
- **One-Euro filter** — a needle that's snappy when moving and rock-steady when
  held; octave-guarded.
- Calibration is a single `tuningScale` factor on the engine (see
  `lib/src/tuner_engine.dart` / `tuner_controller.dart`).
- Mic capture via `record`; keep-awake via `wakelock_plus`.

## Develop

```sh
flutter pub get
flutter test       # engine + widget tests
flutter analyze
flutter run        # on a connected device
```

Brand assets (icon + splashes) are generated from the master render by
`assets/branding/build_brand.py`.

## Build & release

- **CI** (`.github/workflows/ci.yml`) analyzes, tests, and builds the Android
  APK on every push, and compiles the iOS app on a macOS runner.
- **iOS → TestFlight** (`.github/workflows/testflight.yml`, manual) signs and
  uploads a build for internal testing via the App Store Connect API.

## License & attribution

© Terma Heritage Foundation. The instrument artwork and tuning data are part of
the foundation's cultural-preservation work. All rights reserved unless noted
otherwise.
