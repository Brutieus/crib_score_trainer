import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/detected_card.dart';
import 'card_detector.dart';
import 'yolo_decoder.dart';

const modelAssetPath = 'assets/models/cards.tflite';
const classNamesAssetPath = 'assets/models/class_names.txt';
const placeholderMagic = 'CSTF_PLACEHOLDER';

CardDetector createPlatformDetector() => TfliteCardDetector();

class TfliteCardDetector implements CardDetector {
  Interpreter? _interpreter;
  List<String> _classNames = const [];
  List<int> _inputShape = const [];
  List<int> _outputShape = const [];
  TensorType? _inputType;

  @override
  ModelStatus status = const ModelStatus(
    kind: ModelKind.missing,
    detail: 'Not loaded',
  );

  @override
  Future<void> load() async {
    try {
      final namesData = await rootBundle.loadString(classNamesAssetPath);
      _classNames = [
        for (final line in namesData.split(RegExp(r'\r?\n')))
          if (line.trim().isNotEmpty && !line.trim().startsWith('#'))
            line.trim(),
      ];
    } catch (e) {
      status = ModelStatus(
        kind: ModelKind.missing,
        detail: 'class_names.txt missing ($e)',
      );
      return;
    }

    ByteData data;
    try {
      data = await rootBundle.load(modelAssetPath);
    } catch (e) {
      status = ModelStatus(
        kind: ModelKind.missing,
        detail: 'cards.tflite missing ($e)',
        classNames: _classNames,
      );
      return;
    }

    final bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    if (_isPlaceholder(bytes)) {
      status = ModelStatus(
        kind: ModelKind.placeholder,
        detail:
            'assets/models/cards.tflite is the committed placeholder, not a real network.',
        classNames: _classNames,
      );
      return;
    }

    try {
      _interpreter = Interpreter.fromBuffer(bytes);
      _interpreter!.allocateTensors();
      final input = _interpreter!.getInputTensors().first;
      final output = _interpreter!.getOutputTensors().first;
      _inputShape = input.shape;
      _outputShape = output.shape;
      _inputType = input.type;
      status = ModelStatus(
        kind: ModelKind.ready,
        detail: 'Loaded ${bytes.length} byte TFLite model',
        classNames: _classNames,
      );
    } catch (e) {
      status = ModelStatus(
        kind: ModelKind.failed,
        detail: e.toString(),
        classNames: _classNames,
      );
    }
  }

  @override
  Future<DetectionResult> detect(Uint8List imageBytes) async {
    final interpreter = _interpreter;
    if (interpreter == null || !status.isUsable) {
      return DetectionResult(
        cards: const [],
        usedModel: false,
        message: status.banner,
      );
    }

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      return const DetectionResult(
        cards: [],
        usedModel: false,
        message:
            'Could not decode that image. Try another photo or enter cards.',
      );
    }

    final size = _spatialSize;
    final resized = img.copyResize(
      decoded,
      width: size,
      height: size,
      interpolation: img.Interpolation.linear,
    );

    try {
      final input = _buildInput(resized);
      final output = _zeroNested(_outputShape);
      interpreter.run(input, output);
      final flat = _flatten(output);
      final cards = YoloDecoder(inputSize: size).decode(
        output: flat,
        shape: _outputShape,
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
      return DetectionResult(
        cards: const [],
        usedModel: false,
        message: 'Detector failed ($e). Use tap-to-fix / Enter cards.',
      );
    }
  }

  int get _spatialSize {
    if (_inputShape.length >= 4) {
      // NHWC [1,H,W,3] or NCHW [1,3,H,W]
      if (_inputShape[1] == 3) return _inputShape[2];
      return _inputShape[1];
    }
    return 640;
  }

  bool get _isNhwc {
    if (_inputShape.length < 4) return true;
    return _inputShape.last == 3 || _inputShape.last == 1;
  }

  dynamic _buildInput(img.Image image) {
    final h = image.height;
    final w = image.width;
    final asUint8 = _inputType == TensorType.uint8;
    if (_isNhwc) {
      return [
        List.generate(h, (y) {
          return List.generate(w, (x) {
            final p = image.getPixel(x, y);
            if (asUint8) {
              return [p.r.toInt(), p.g.toInt(), p.b.toInt()];
            }
            return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
          });
        }),
      ];
    }
    List<List<dynamic>> planeFor(int Function(img.Pixel p) channel) {
      return List.generate(h, (y) {
        return List.generate(w, (x) {
          final p = image.getPixel(x, y);
          final v = channel(p);
          return asUint8 ? v.toInt() : v / 255.0;
        });
      });
    }

    return [
      [
        planeFor((p) => p.r.toInt()),
        planeFor((p) => p.g.toInt()),
        planeFor((p) => p.b.toInt()),
      ],
    ];
  }

  bool _isPlaceholder(Uint8List bytes) {
    if (bytes.length < 2048) return true;
    final head = String.fromCharCodes(
      bytes.take(placeholderMagic.length).toList(),
    );
    return head == placeholderMagic;
  }

  dynamic _zeroNested(List<int> shape) {
    if (shape.isEmpty) return 0.0;
    if (shape.length == 1) return List<double>.filled(shape[0], 0);
    return List.generate(shape[0], (_) => _zeroNested(shape.sublist(1)));
  }

  List<double> _flatten(dynamic value) {
    if (value is num) return [value.toDouble()];
    if (value is List) {
      return [for (final item in value) ..._flatten(item)];
    }
    return const [];
  }
}
