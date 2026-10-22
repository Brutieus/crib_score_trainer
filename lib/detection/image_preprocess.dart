import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Square size the YOLOv8n card model was exported with.
const kDetectSize = 640;

/// Stretch [bytes] to [size]×[size] and pack NCHW float32 in 0..1.
///
/// Matches the phone detector, which also stretches instead of letterboxing.
/// Returns null when the bytes are not a decodable image.
Float32List? nchwFromEncodedImage(Uint8List bytes, {int size = kDetectSize}) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    return null;
  }
  if (decoded == null) return null;
  final resized = img.copyResize(
    decoded,
    width: size,
    height: size,
    interpolation: img.Interpolation.linear,
  );
  final plane = size * size;
  final out = Float32List(3 * plane);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final p = resized.getPixel(x, y);
      final i = y * size + x;
      out[i] = p.r / 255.0;
      out[plane + i] = p.g / 255.0;
      out[2 * plane + i] = p.b / 255.0;
    }
  }
  return out;
}
