"""Batch convert PNG/JPG assets to WebP (lossy q=85) alongside originals.

Keeps originals in place; .webp sibling is written next to each source.
Skips files for which a .webp sibling already exists and is newer.
"""
from __future__ import annotations

import sys
from pathlib import Path
from PIL import Image

QUALITY = 85
METHOD = 6

# Convert all PNG/JPG under these dirs. Originals are kept (not deleted).
TARGET_DIRS = [
    Path("assets/images"),
    Path("assets/ui"),
]

# Do NOT convert these (used by launcher_icons / native_splash which read PNG):
SKIP_FILES = {
    Path("assets/icon/app_icon.png"),
}


def should_convert(src: Path) -> bool:
    if src in SKIP_FILES:
        return False
    if src.suffix.lower() not in {".png", ".jpg", ".jpeg"}:
        return False
    return True


def convert_one(src: Path) -> tuple[int, int]:
    """Returns (src_bytes, webp_bytes)."""
    dst = src.with_suffix(".webp")
    src_bytes = src.stat().st_size
    if dst.exists() and dst.stat().st_mtime >= src.stat().st_mtime:
        return src_bytes, dst.stat().st_size

    img = Image.open(src)
    # For JPEGs (RGB), save as lossy WebP; for PNG with alpha, still lossy q=85 keeps alpha.
    save_kwargs = {"quality": QUALITY, "method": METHOD}
    # Pillow writes alpha automatically when image mode has alpha.
    if img.mode not in ("RGB", "RGBA"):
        # Palette/LA → convert to RGBA to preserve possible alpha
        if "A" in img.mode or img.mode == "P":
            img = img.convert("RGBA")
        else:
            img = img.convert("RGB")
    img.save(dst, "WEBP", **save_kwargs)
    return src_bytes, dst.stat().st_size


def main() -> int:
    root = Path(__file__).resolve().parent.parent  # mobile/
    total_src = 0
    total_dst = 0
    count = 0
    for tdir in TARGET_DIRS:
        base = root / tdir
        if not base.exists():
            print(f"[skip] not found: {base}")
            continue
        for src in sorted(base.rglob("*")):
            if not src.is_file():
                continue
            rel = src.relative_to(root)
            if not should_convert(rel):
                continue
            try:
                s, d = convert_one(src)
            except Exception as e:
                print(f"[FAIL] {rel}: {e}")
                continue
            total_src += s
            total_dst += d
            count += 1
            ratio = (1 - d / s) * 100 if s else 0
            print(f"[ok] {rel} {s/1024:.1f}KB -> {d/1024:.1f}KB  (-{ratio:.1f}%)")
    print()
    print(f"Converted {count} files")
    print(f"Source  total: {total_src/1024/1024:.2f} MB")
    print(f"WebP    total: {total_dst/1024/1024:.2f} MB")
    saved = total_src - total_dst
    if total_src:
        print(f"Saved:         {saved/1024/1024:.2f} MB ({saved/total_src*100:.1f}%)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
