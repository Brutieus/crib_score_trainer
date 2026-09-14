import 'package:crib_score_trainer/detection/yolo_decoder.dart';
import 'package:crib_score_trainer/models/playing_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const names = ['Ah', '5s', 'Js'];
  const decoder = YoloDecoder(confidenceThreshold: 0.4, iouThreshold: 0.45);

  test('decodes channels-first YOLO output', () {
    const preds = 2;
    const stride = 7; // 4 + 3 classes
    final output = List<double>.filled(stride * preds, 0);
    // prediction 0: box center 0.2,0.2 size 0.2, class Ah
    output[0 * preds + 0] = 0.2;
    output[1 * preds + 0] = 0.2;
    output[2 * preds + 0] = 0.2;
    output[3 * preds + 0] = 0.2;
    output[4 * preds + 0] = 0.9;
    // prediction 1: overlapping box, lower score — NMS should drop
    output[0 * preds + 1] = 0.21;
    output[1 * preds + 1] = 0.21;
    output[2 * preds + 1] = 0.2;
    output[3 * preds + 1] = 0.2;
    output[5 * preds + 1] = 0.5;

    final found = decoder.decode(
      output: output,
      shape: const [1, 7, 2],
      classNames: names,
    );
    expect(found, hasLength(1));
    expect(found.single.card, PlayingCard.parse('Ah'));
  });

  test('skips unknown class names', () {
    final output = <double>[0.5, 0.5, 0.2, 0.2, 0.9];
    final found = decoder.decode(
      output: output,
      shape: const [1, 1, 5],
      classNames: const ['joker'],
    );
    expect(found, isEmpty);
  });
}
