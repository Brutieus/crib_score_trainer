# Contributing to Crib Score Trainer

1. Fork the repo and open a pull request against `main`.
2. Keep the Dart package name `crib_score_trainer`. Display name is **Crib Score Trainer** (never “Cribbage Show”).
3. Format before you push:

   ```bash
   dart format .
   flutter analyze
   flutter test
   ```

4. **No new network calls.** Do not add `http`, `dio`, Firebase, analytics, crash reporters, or model-download URLs. The app must keep working in airplane mode with no API keys.
5. Scoring bugs: add a failing test in `test/scoring_test.dart` with the five cards, crib vs hand, expected total, then fix the engine.
6. Detection bugs: fix the decoder or document tap-to-fix; do not send photos to a server.

Issue templates: **wrong score** vs **bad detection**.
