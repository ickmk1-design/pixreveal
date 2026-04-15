import requests
import os
import time
from PIL import Image
from io import BytesIO

TARGET_DIR = r'C:\Users\ickmk\Desktop\pixreveal\mobile\assets\images'
TARGET_W, TARGET_H = 1080, 1920

CATEGORIES = [
    # (loremflickr_keyword, file_prefix, lock_start)
    ('sportscar',   'cars',    10),
    ('galaxy',      'space',   20),
    ('wildanimal',  'animal',  30),
    ('beach',       'glamour', 40),
    ('fitness',     'fitness', 50),
]

def download(keywords, prefix, start_sig):
    print(f'\n=== {prefix.upper()} ===')
    for i in range(1, 6):
        filename = f'{prefix}_{i}.jpg'
        filepath = os.path.join(TARGET_DIR, filename)
        lock = start_sig + i
        # loremflickr: free, no key, returns real photos by keyword
        url = f'https://loremflickr.com/{TARGET_W}/{TARGET_H}/{keywords}?lock={lock}'

        try:
            print(f'  [{i}/5] {filename} ... ', end='', flush=True)
            r = requests.get(url, timeout=40, allow_redirects=True)
            if r.status_code != 200:
                print(f'HTTP {r.status_code}')
                continue

            img = Image.open(BytesIO(r.content)).convert('RGB')

            # Resize with crop-to-fill so it's exactly 1080x1920
            src_w, src_h = img.size
            src_ratio = src_w / src_h
            tgt_ratio = TARGET_W / TARGET_H

            if src_ratio > tgt_ratio:
                # wider than target — crop sides
                new_h = src_h
                new_w = int(src_h * tgt_ratio)
            else:
                # taller than target — crop top/bottom
                new_w = src_w
                new_h = int(src_w / tgt_ratio)

            left = (src_w - new_w) // 2
            top  = (src_h - new_h) // 2
            img  = img.crop((left, top, left + new_w, top + new_h))
            img  = img.resize((TARGET_W, TARGET_H), Image.LANCZOS)

            img.save(filepath, 'JPEG', quality=88, optimize=True)
            size_kb = os.path.getsize(filepath) // 1024
            print(f'OK  ({size_kb} KB)')

        except Exception as e:
            print(f'ERROR: {e}')

        time.sleep(0.8)

if __name__ == '__main__':
    os.makedirs(TARGET_DIR, exist_ok=True)
    for keywords, prefix, start_sig in CATEGORIES:
        download(keywords, prefix, start_sig)
    print('\nDone.')
