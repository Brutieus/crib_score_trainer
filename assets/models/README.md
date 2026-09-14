# Card detection model

Files in this folder:

| File | Role |
| --- | --- |
| `cards.tflite` | On-device YOLOv8n detector (float32, ~12 MB), trained on a public 52-class playing-card set. |
| `class_names.txt` | One class per line, matching TFLite class index order (`10C`, `AH`, `KS`, …). |
| `train_and_export.md` | How to retrain / re-export if you want a different deck. |

## What is shipped

`cards.tflite` is a **real** network, not a placeholder. It is YOLOv8n fine-tuned on the public Roboflow / Kaggle-style 52-class playing-card detection set (same class order as [geaxgx-style](https://github.com/geaxgx/playing-card-detection) codes, uppercase). Source checkpoint: [mustafakemal0146/playing-cards-yolov8](https://huggingface.co/mustafakemal0146/playing-cards-yolov8) (YOLOv8n, 50 epochs, imgsz 640). Converted ONNX → TFLite with onnx2tf because Ultralytics LiteRT export is Linux/macOS-only.

The app **never downloads weights at runtime**. Airplane mode still applies.

## Licenses for the weights

- Dataset: public playing-cards object-detection sets (Roboflow Playing Cards / Kaggle CC0 geaxgx-style).
- Architecture / Ultralytics export tooling: AGPL-3.0 (Ultralytics). The Flutter app source remains MIT; if you redistribute the bundled `.tflite`, follow the weight/dataset licenses.
- There is **no API key** and no secret download URL.

## Runtime contract

- Input: RGB, resized to **640×640**, float32 0..1, typically NHWC `[1, 640, 640, 3]`.
- Output: YOLOv8 detect head `[1, 56, 8400]` or `[1, 8400, 56]` (4 box channels + 52 classes).
- Boxes: center-x, center-y, width, height — pixels in 640 space **or** normalized 0..1.
- Dart decoder: `lib/detection/yolo_decoder.dart` (confidence + NMS).

Detection can still miss overlapping cards or odd decks — **tap any wrong card to fix it**. Scoring is exact for the cards you confirm.

## Replacing the model

See `docs/TRAINING.md` and `train_and_export.md`. Overwrite `cards.tflite` and keep `class_names.txt` in the same order as the new head. Rebuild the app (assets are bundled at build time).
