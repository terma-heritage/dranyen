# Dramnyen Tuner

A native (iOS + Android) chromatic tuner for the **dramnyen**, the Tibetan lute —
built to feel like a professional instrument tuner. A project of the
**Terma Heritage Foundation**.

## What it does

- **Listens** to the microphone and shows the note you're playing — one of the
  seven dramnyen degrees (Do · Re · Mi · Fa · So · La · Ti) — with cents off.
- You tune the three open courses to **La · Re · So** (D-major, re-entrant
  tuning, A = 440 Hz). Auto-detect by default; tap a course to lock onto it.
- A smooth analog dial that locks **green + a haptic tick** when in tune.

## How it's built

- **Flutter** (one codebase → iOS + Android).
- Pitch detection: **YIN** (`lib/src/pitch_detector.dart`) — steady at the low
  So/La pitches and sensitive to soft playing.
- **One-Euro filter** for a needle that's snappy when moving and rock-steady
  when held; octave-guarded.
- Mic capture via `record`; keep-awake via `wakelock_plus`.

## Develop

```
flutter pub get
flutter test       # engine + widget tests
flutter analyze
flutter run        # on a connected device
```

## Build

CI (GitHub Actions, `.github/workflows/ci.yml`) analyzes, tests, and builds the
Android APK on every push, and compiles the iOS app on a macOS runner. iOS
distribution (TestFlight / App Store) requires an Apple Developer account and
signing secrets, added to CI when ready.
