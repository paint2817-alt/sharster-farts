"""Prepare the illustrated backgrounds. Requires Pillow only when re-cropping art."""
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
destination = root / "browser" / "scenes"
destination.mkdir(exist_ok=True)

def crop(source, scenes):
    with Image.open(root / "art" / source) as sheet:
        for name, box in scenes.items():
            sheet.crop(box).convert("RGB").save(destination / (name + ".jpg"), quality=92)

crop("sharster-farts-field-guide.png", {"lot": (0, 0, 1536, 688)})
crop("the-cone-is-due.png", {
    "watch": (10, 120, 713, 707), "away": (733, 120, 1431, 707),
    "commuter": (1458, 120, 2161, 707),
})
crop("pool-beneath-the-pool.png", {
    "pool": (0, 110, 1672, 941), "ledge": (736, 108, 1460, 500),
})
