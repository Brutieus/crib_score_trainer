import 'card_detector.dart';

CardDetector createPlatformDetector() => ManualOnlyDetector(
    reason: 'TFLite card detection is not available on this platform.');
