import 'card_detector.dart';
import 'tflite_detector_stub.dart'
    if (dart.library.io) 'tflite_detector_io.dart'
    if (dart.library.js_interop) 'onnx_detector_web.dart' as impl;

CardDetector createCardDetector() => impl.createPlatformDetector();
