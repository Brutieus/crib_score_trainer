import 'dart:math' as math;
import 'dart:ui';

import '../models/detected_card.dart';
import '../models/playing_card.dart';

/// Decodes YOLOv8-style TFLite output: either `[1, 4+nc, n]` or `[1, n, 4+nc]`.
class YoloDecoder {
  const YoloDecoder({
    this.confidenceThreshold = 0.35,
    this.iouThreshold = 0.45,
    this.inputSize = 640,
  });

  final double confidenceThreshold;
  final double iouThreshold;
  final int inputSize;

  List<DetectedCard> decode({
    required List<double> output,
    required List<int> shape,
    required List<String> classNames,
  }) {
    if (output.isEmpty || classNames.isEmpty) return const [];
    final layout = _inferLayout(shape, classNames.length, output.length);
    if (layout == null) return const [];

    final raw = <_Pred>[];
    for (var i = 0; i < layout.predictions; i++) {
      late final double x;
      late final double y;
      late final double w;
      late final double h;
      var best = 0;
      var bestScore = -1.0;
      if (layout.channelsFirst) {
        x = output[0 * layout.predictions + i];
        y = output[1 * layout.predictions + i];
        w = output[2 * layout.predictions + i];
        h = output[3 * layout.predictions + i];
        for (var c = 0; c < classNames.length; c++) {
          final score = output[(4 + c) * layout.predictions + i];
          if (score > bestScore) {
            bestScore = score;
            best = c;
          }
        }
      } else {
        final base = i * layout.stride;
        x = output[base];
        y = output[base + 1];
        w = output[base + 2];
        h = output[base + 3];
        for (var c = 0; c < classNames.length; c++) {
          final score = output[base + 4 + c];
          if (score > bestScore) {
            bestScore = score;
            best = c;
          }
        }
      }
      if (bestScore < confidenceThreshold) continue;
      if (best >= classNames.length) continue;
      PlayingCard card;
      try {
        card = PlayingCard.parse(classNames[best]);
      } on FormatException {
        continue;
      }
      raw.add(
        _Pred(
          card: card,
          score: bestScore,
          box: _xywhToNormRect(x, y, w, h),
        ),
      );
    }
    raw.sort((a, b) => b.score.compareTo(a.score));
    return _nms(raw);
  }

  _Layout? _inferLayout(List<int> shape, int nc, int length) {
    final stride = 4 + nc;
    final squeezed = [
      for (final d in shape)
        if (d != 1) d
    ];
    if (squeezed.length >= 2) {
      final a = squeezed[squeezed.length - 2];
      final b = squeezed[squeezed.length - 1];
      if (a == stride) {
        return _Layout(predictions: b, stride: stride, channelsFirst: true);
      }
      if (b == stride) {
        return _Layout(predictions: a, stride: stride, channelsFirst: false);
      }
    }
    if (length % stride != 0) return null;
    final predictions = length ~/ stride;
    // YOLOv8 TFLite export is usually (1, 4+nc, 8400).
    return _Layout(
      predictions: predictions,
      stride: stride,
      channelsFirst: true,
    );
  }

  Rect _xywhToNormRect(double x, double y, double w, double h) {
    // Values may be pixels (0..inputSize) or already normalized.
    final scale = (x > 1.5 || y > 1.5 || w > 1.5 || h > 1.5) ? inputSize : 1.0;
    final nx = (x / scale).clamp(0.0, 1.0);
    final ny = (y / scale).clamp(0.0, 1.0);
    final nw = (w / scale).clamp(0.0, 1.0);
    final nh = (h / scale).clamp(0.0, 1.0);
    final left = (nx - nw / 2).clamp(0.0, 1.0);
    final top = (ny - nh / 2).clamp(0.0, 1.0);
    final right = (nx + nw / 2).clamp(0.0, 1.0);
    final bottom = (ny + nh / 2).clamp(0.0, 1.0);
    return Rect.fromLTRB(left, top, right, bottom);
  }

  List<DetectedCard> _nms(List<_Pred> preds) {
    final keep = <DetectedCard>[];
    final suppressed = List<bool>.filled(preds.length, false);
    for (var i = 0; i < preds.length; i++) {
      if (suppressed[i]) continue;
      final a = preds[i];
      keep.add(
        DetectedCard(card: a.card, confidence: a.score, box: a.box),
      );
      for (var j = i + 1; j < preds.length; j++) {
        if (suppressed[j]) continue;
        if (_iou(a.box, preds[j].box) >= iouThreshold) {
          suppressed[j] = true;
        }
      }
    }
    keep.sort((a, b) => a.box.left.compareTo(b.box.left));
    return keep;
  }

  double _iou(Rect a, Rect b) {
    final left = math.max(a.left, b.left);
    final top = math.max(a.top, b.top);
    final right = math.min(a.right, b.right);
    final bottom = math.min(a.bottom, b.bottom);
    final w = math.max(0.0, right - left);
    final h = math.max(0.0, bottom - top);
    final inter = w * h;
    final union = a.width * a.height + b.width * b.height - inter;
    if (union <= 0) return 0;
    return inter / union;
  }
}

class _Pred {
  const _Pred({required this.card, required this.score, required this.box});
  final PlayingCard card;
  final double score;
  final Rect box;
}

class _Layout {
  const _Layout({
    required this.predictions,
    required this.stride,
    required this.channelsFirst,
  });
  final int predictions;
  final int stride;
  final bool channelsFirst;
}
