import 'dart:typed_data';

import '../models/detected_card.dart';

abstract class CardDetector {
  ModelStatus get status;

  Future<void> load();

  Future<DetectionResult> detect(Uint8List imageBytes);
}

class ManualOnlyDetector implements CardDetector {
  ManualOnlyDetector({this.reason});

  final String? reason;

  @override
  ModelStatus status = const ModelStatus(
    kind: ModelKind.placeholder,
    detail: 'Manual entry only',
  );

  @override
  Future<void> load() async {
    status = ModelStatus(
      kind: ModelKind.placeholder,
      detail: reason ?? 'Placeholder or unsupported platform',
    );
  }

  @override
  Future<DetectionResult> detect(Uint8List imageBytes) async {
    return DetectionResult(
      cards: const [],
      usedModel: false,
      message: status.banner,
    );
  }
}
