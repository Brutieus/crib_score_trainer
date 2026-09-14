"""Export a public YOLOv8 playing-card checkpoint to TFLite.

Usage:
  python tool/export_cards_tflite.py
"""

from __future__ import annotations

from pathlib import Path
import shutil

from ultralytics import YOLO

ROOT = Path(__file__).resolve().parents[1]
PT = ROOT / "tool" / "card_model" / "playing_cards_yolov8n.pt"
OUT_DIR = ROOT / "assets" / "models"
CLASS_NAMES = OUT_DIR / "class_names.txt"
TFLITE = OUT_DIR / "cards.tflite"


def main() -> None:
    if not PT.exists():
        raise SystemExit(f"Missing checkpoint: {PT}")

    model = YOLO(str(PT))
    names = [model.names[i] for i in range(len(model.names))]
    CLASS_NAMES.write_text("\n".join(names) + "\n", encoding="utf-8")
    print(f"Wrote {len(names)} class names to {CLASS_NAMES}")
    for i, n in enumerate(names):
        print(f"  {i:02d} {n}")

    exported = model.export(format="tflite", imgsz=640, keras=False)
    exported_path = Path(str(exported))
    print(f"Export reported: {exported_path}")

    candidates = []
    if exported_path.suffix == ".tflite":
        candidates.append(exported_path)
    parent = exported_path if exported_path.is_dir() else exported_path.parent
    candidates.extend(parent.glob("**/*float32*.tflite"))
    candidates.extend(parent.glob("**/*.tflite"))

    chosen = None
    for c in candidates:
        if c.is_file() and "int8" not in c.name.lower() and "float16" not in c.name.lower():
            chosen = c
            break
    if chosen is None:
        for c in candidates:
            if c.is_file():
                chosen = c
                break
    if chosen is None:
        raise SystemExit("No TFLite file found after export")

    shutil.copy2(chosen, TFLITE)
    print(f"Copied {chosen} -> {TFLITE} ({TFLITE.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
