"""
Fill car images to 1080x1920 portrait format.
- Resize to fit width (1080px), keep aspect ratio
- Fill top/bottom gaps with blurred+zoomed version of the image (Instagram Reels style)
- Save over original file
"""

import os
import glob
from PIL import Image, ImageFilter

TARGET_W, TARGET_H = 1080, 1920
BLUR_RADIUS = 40
ASSETS_DIR = r'C:\Users\ickmk\Desktop\pixreveal\mobile\assets\images'


def fill_portrait(path):
    img = Image.open(path).convert('RGB')
    src_w, src_h = img.size

    # Step 1: resize to width=1080, keep aspect ratio
    scale = TARGET_W / src_w
    new_h = int(src_h * scale)
    resized = img.resize((TARGET_W, new_h), Image.LANCZOS)

    if new_h >= TARGET_H:
        # Already tall enough — crop vertically centered
        top = (new_h - TARGET_H) // 2
        final = resized.crop((0, top, TARGET_W, top + TARGET_H))
        final.save(path, 'JPEG', quality=88, optimize=True)
        print(f'  cropped  {os.path.basename(path)}  {src_w}x{src_h} -> {TARGET_W}x{TARGET_H}')
        return

    # Step 2: create blurred background — scale image to fill 1080x1920
    bg_scale = max(TARGET_W / src_w, TARGET_H / src_h)
    bg_w = int(src_w * bg_scale)
    bg_h = int(src_h * bg_scale)
    bg = img.resize((bg_w, bg_h), Image.LANCZOS)

    # Crop bg to exact target size (centered)
    bx = (bg_w - TARGET_W) // 2
    by = (bg_h - TARGET_H) // 2
    bg = bg.crop((bx, by, bx + TARGET_W, by + TARGET_H))

    # Blur the background
    bg = bg.filter(ImageFilter.GaussianBlur(radius=BLUR_RADIUS))

    # Darken background slightly so main image stands out
    bg = bg.point(lambda p: int(p * 0.55))

    # Step 3: paste resized image centered on blurred bg
    canvas = bg.copy()
    paste_y = (TARGET_H - new_h) // 2
    canvas.paste(resized, (0, paste_y))

    canvas.save(path, 'JPEG', quality=88, optimize=True)
    kb = os.path.getsize(path) // 1024
    print(f'  filled   {os.path.basename(path)}  {src_w}x{src_h} -> 1080x{new_h} on 1080x1920  ({kb} KB)')


if __name__ == '__main__':
    pattern = os.path.join(ASSETS_DIR, 'cars_*.jpg')
    files = sorted(glob.glob(pattern))

    if not files:
        print(f'No cars_*.jpg found in {ASSETS_DIR}')
    else:
        print(f'Processing {len(files)} images...\n')
        for f in files:
            try:
                fill_portrait(f)
            except Exception as e:
                print(f'  ERROR {os.path.basename(f)}: {e}')
        print('\nDone.')
