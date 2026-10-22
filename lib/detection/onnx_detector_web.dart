import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../models/detected_card.dart';
import 'card_detector.dart';
import 'image_preprocess.dart';
import 'yolo_decoder.dart';

const _classNamesAssetPath = 'assets/models/class_names.txt';

@JS('cribDetect.detectCards')
external JSPromise<_DetectResult> _detectCards(JSFloat32Array input);

extension type _DetectResult._(JSObject _) implements JSObject {
  external JSFloat32Array get data;
  external String get dims;
}

CardDetector createPlatformDetector() => OnnxWebCardDetector();

/// Runs the same YOLOv8n network as the phone build, through ONNX Runtime Web.
/// The runtime and `web/models/cards.onnx` load on the first [detect] call.
class OnnxWebCardDetector implements CardDetector {
  List<String> _classNames = const [];

  @override
  ModelStatus status = const ModelStatus(
    kind: ModelKind.browser,
    detail: 'Browser detector downloads on first photo',
  );

  @override
  Future<void> load() async {
    try {
      final namesData = await rootBundle.loadString(_classNamesAssetPath);
      _classNames = [
        for (final line in namesData.split(RegExp(r'\r?\n')))
          if (line.trim().isNotEmpty && !line.trim().startsWith('#'))
            line.trim(),
      ];
      if (status.kind != ModelKind.ready) {
        status = const ModelStatus(
          kind: ModelKind.browser,
          detail: 'Browser detector downloads on first photo',
        );
      }
    } catch (e) {
      status = ModelStatus(
        kind: ModelKind.missing,
        detail: 'class_names.txt missing ($e)',
      );
    }
  }

  @override
  Future<DetectionResult> detect(Uint8List imageBytes) async {
    if (_classNames.isEmpty) await load();
    if (_classNames.isEmpty) {
      return DetectionResult(
        cards: const [],
        usedModel: false,
        message: status.banner,
      );
    }

    final nchw = nchwFromEncodedImage(imageBytes);
    if (nchw == null) {
      return const DetectionResult(
        cards: [],
        usedModel: false,
        message:
            'Could not decode that image. Try another photo or enter cards.',
      );
    }

    try {
      final result = await _detectCards(nchw.toJS).toDart;
      final shape = [
        for (final part in result.dims.split(','))
          if (part.trim().isNotEmpty) int.parse(part.trim()),
      ];
      final cards = const YoloDecoder().decode(
        output: Float32List.fromList(result.data.toDart),
        shape: shape,
        classNames: _classNames,
      );
      status = ModelStatus(
        kind: ModelKind.ready,
        detail: 'Browser detector ready',
        classNames: _classNames,
      );
      return DetectionResult(
        cards: cards,
        usedModel: true,
        message: cards.isEmpty
            ? 'No cards found. Try better light, less overlap, or tap to enter cards.'
            : null,
      );
    } catch (e) {
      status = ModelStatus(
        kind: ModelKind.failed,
        detail: e.toString(),
        classNames: _classNames,
      );
      return DetectionResult(
        cards: const [],
        usedModel: false,
        message: 'Detector failed ($e). Use tap-to-fix / Enter cards.',
      );
    }
  }
}
