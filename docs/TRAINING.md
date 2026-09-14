# Training a playing-card TFLite for Crib Score Trainer

Crib Score Trainer scores cribbage **on-device** from the five cards you confirm. The neural net only proposes those cards. This document retrains a **YOLOv8n** detector on **public** datasets and exports TensorFlow Lite.

There are **no API keys**. The repo already ships a public-dataset TFLite in `assets/models/cards.tflite`. Retrain only if you want a different deck or better accuracy on your table.

## Public datasets

Pick one (or mix them). Always read the license before redistributing weights.

| Source | Notes |
| --- | --- |
| [geaxgx/playing-card-detection](https://github.com/geaxgx/playing-card-detection) | MIT notebook that **generates** labeled scenes from photos of a real deck. Class codes look like `2s`, `Kh`. Corner-focused boxes — excellent for overlapping hands if you generate your own. |
| [Kaggle: Playing Cards Object Detection Dataset](https://www.kaggle.com/datasets/andy8744/playing-cards-object-detection-dataset) (Andy8744) | CC0. YOLO-ready 416×416 splits, geaxgx-inspired, DTD backgrounds. Download from Kaggle (free account). |
| [Roboflow Universe — playing cards](https://universe.roboflow.com/) | Search “playing cards yolo”. Several community sets export YOLO/YOLOv8. Check each project’s license (CC BY, CC BY-NC, etc.). Prefer 52-class rank+suit, not “card vs not-card”. |

**Class names:** this app’s default `assets/models/class_names.txt` is the 52-class geaxgx order:

```
10c 10d 10h 10s 2c … 9s Ac Ad Ah As Jc … Qs
```

If your `data.yaml` uses a different order or `10S` vs `10s`, rewrite `class_names.txt` so **index 0 in the file is class 0 in the model**. `PlayingCard.parse` accepts `Ah`, `10s`, `Kc`, `T♣`, and similar.

## Environment

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install ultralytics
```

GPU is optional. YOLOv8n on a few thousand 640×640 images is tractable on CPU overnight or on a laptop GPU in well under an hour.

## data.yaml

Example after unzipping a YOLO export:

```yaml
path: /absolute/path/to/dataset
train: train/images
val: valid/images
test: test/images

names:
  0: 10c
  1: 10d
  # … through 51, matching class_names.txt
```

## Train YOLOv8n

```bash
yolo detect train \
  model=yolov8n.pt \
  data=data.yaml \
  imgsz=640 \
  epochs=80 \
  batch=16 \
  patience=20
```

Tips for crib photos:

- Include **overlapping** cards, table felt, warm indoor light, and fingers.
- If the public set is mostly isolated cards, add 50–100 photos of *your* deck on *your* table (Roboflow’s free tier can label them).
- Start from `yolov8n.pt` (nano). Larger models are slower on phones and rarely worth it for 52 similar classes.

## Export TFLite

```bash
yolo export \
  model=runs/detect/train/weights/best.pt \
  format=tflite \
  imgsz=640
```

Ultralytics writes something like `best_saved_model/best_float32.tflite`. **Float32** is the format `tflite_flutter` loads most reliably. INT8 is smaller but needs a representative dataset and extra runtime ops.

Copy onto the placeholder:

```bash
cp runs/detect/train/weights/best_saved_model/best_float32.tflite \
   assets/models/cards.tflite
```

Then:

```bash
flutter pub get
flutter run
```

The home-screen banner should change from “Placeholder model only” to “On-device detector ready.”

## Output tensor the app expects

YOLOv8 detect TFLite is usually:

- Input `[1, 640, 640, 3]` (NHWC, RGB, 0..1) or `[1, 3, 640, 640]`
- Output `[1, 56, 8400]` for 52 classes (4 box channels + 52 scores), **or** `[1, 8400, 56]`

`lib/detection/yolo_decoder.dart` infers the layout, converts xywh to normalized boxes, thresholds confidence (default 0.35), and runs NMS (IoU 0.45). If your export includes an extra objectness channel, re-export with the stock Ultralytics detect head or adjust the decoder tests.

## What not to do

- Do not commit a pre-signed cloud URL, Hugging Face token, or Roboflow API key.
- Do not add `http` / `dio` to the Flutter app to download weights at runtime. Airplane-mode is a product requirement.
- Do not replace `class_names.txt` with 1-based labels or jokers unless you also change the parser.

## Git LFS (optional)

If you *do* commit a real `cards.tflite` larger than GitHub recommends:

```bash
git lfs install
git lfs track "assets/models/cards.tflite"
git add .gitattributes assets/models/cards.tflite
```

Tell clone users to run `git lfs pull` after `git clone`. This repository does not enable LFS while the file is a placeholder.
