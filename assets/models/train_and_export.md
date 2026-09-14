# Train and export `cards.tflite`

The repo already ships a public-dataset YOLOv8n TFLite. Use this if you want to retrain on your own deck.

Full notes: [`docs/TRAINING.md`](../../docs/TRAINING.md).

```bash
# 1. Python 3.10–3.12
pip install ultralytics onnx onnx2tf

# 2. data.yaml → 52-class public set (Roboflow / Kaggle / geaxgx-style)
yolo detect train model=yolov8n.pt data=data.yaml imgsz=640 epochs=80 batch=16

# 3. Export
# Linux/macOS:
yolo export model=runs/detect/train/weights/best.pt format=tflite imgsz=640
# Windows (LiteRT export is blocked):
yolo export model=runs/detect/train/weights/best.pt format=onnx imgsz=640
python -m onnx2tf -i best.onnx -o tflite_out

# 4. Copy float32 TFLite over the bundled file
cp tflite_out/*float32*.tflite assets/models/cards.tflite
# Rewrite class_names.txt if class order changed.

# 5. Rebuild
flutter pub get
flutter run
```

Do not add a runtime download or API token. Keep the app airplane-mode.
