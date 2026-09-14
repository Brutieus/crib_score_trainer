import 'dart:ui';

import 'playing_card.dart';

class DetectedCard {
  const DetectedCard({
    required this.card,
    required this.confidence,
    required this.box,
  });

  final PlayingCard card;
  final double confidence;

  /// Normalized image coordinates, origin top-left, values in 0..1.
  final Rect box;
}

class DetectionResult {
  const DetectionResult({
    required this.cards,
    required this.usedModel,
    this.message,
  });

  final List<DetectedCard> cards;
  final bool usedModel;
  final String? message;

  static const emptyPlaceholder = DetectionResult(
    cards: [],
    usedModel: false,
    message:
        'No trained card model is installed. Enter cards by hand, or drop a TFLite detector into assets/models/ (see docs/TRAINING.md).',
  );
}

enum ModelKind { missing, placeholder, ready, failed }

class ModelStatus {
  const ModelStatus({
    required this.kind,
    required this.detail,
    this.classNames = const [],
  });

  final ModelKind kind;
  final String detail;
  final List<String> classNames;

  bool get isUsable => kind == ModelKind.ready;

  String get banner {
    switch (kind) {
      case ModelKind.missing:
        return 'Card model not found — use Enter cards.';
      case ModelKind.placeholder:
        return 'Placeholder model only — detection is off. Train a public-dataset TFLite and replace assets/models/cards.tflite.';
      case ModelKind.failed:
        return 'Could not load the card model — use tap-to-fix / Enter cards. $detail';
      case ModelKind.ready:
        return 'On-device detector ready. Wrong card? Tap it to fix.';
    }
  }
}
