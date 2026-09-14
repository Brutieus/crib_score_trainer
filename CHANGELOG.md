# Changelog

All notable changes to Crib Score Trainer are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] — 2026-09-14

### Added

- Bundled on-device YOLOv8n TFLite trained on a public 52-class playing-card dataset (Roboflow / geaxgx-style labels). Photo detection no longer requires a placeholder swap.

## [0.1.0] — 2026-09-14

### Added

- Offline cribbage **hand** and **crib** show scorer (fifteens, pairs, runs, flush, nobs).
- Manual card entry with tap-to-fix review.
- Optional on-device YOLO/TFLite photo detection (`assets/models/cards.tflite`).
- Placeholder TFLite so clones run without a trained network or download URL.
- Rules reference and practice trainer (guess the show).
- Android camera + photo permissions; iOS `NSCameraUsageDescription` / `NSPhotoLibraryUsageDescription`.
- GitHub Actions CI: `flutter pub get`, `analyze`, `test` (no signing).
