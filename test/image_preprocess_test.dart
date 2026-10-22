import 'dart:typed_data';

import 'package:crib_score_trainer/detection/image_preprocess.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('nchw preprocess stretches and scales channels to 0..1', () {
    final image = img.Image(width: 2, height: 2, numChannels: 3);
    img.fill(image, color: img.ColorRgb8(255, 0, 128));
    final bytes = Uint8List.fromList(img.encodePng(image));

    final out = nchwFromEncodedImage(bytes, size: 2);

    expect(out, isNotNull);
    expect(out!.length, 3 * 2 * 2);
    for (var i = 0; i < 4; i++) {
      expect(out[i], closeTo(1, 0.01));
      expect(out[4 + i], closeTo(0, 0.01));
      expect(out[8 + i], closeTo(128 / 255, 0.01));
    }
  });

  test('nchw preprocess rejects bytes that are not an image', () {
    expect(nchwFromEncodedImage(Uint8List.fromList([1, 2, 3, 4])), isNull);
  });
}
