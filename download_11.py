"""
Download 11 portrait images per category.
Tries source.unsplash.com first, falls back to loremflickr.com.
Skips existing files. Verifies JPEG magic bytes.
"""

import urllib.request
import os
import time

ASSETS_DIR = r'C:\Users\ickmk\Desktop\pixreveal\mobile\assets\images'

CATEGORIES = {
    'cars':    ('sports,car,luxury',        'sportscar'),
    'space':   ('galaxy,nebula,stars',       'galaxy'),
    'animal':  ('wild,animal,portrait',      'wildanimal'),
    'glamour': ('fashion,model,portrait',    'beach'),
    'fitness': ('fitness,gym,workout',       'fitness'),
}

TARGET_W, TARGET_H = 1080, 1920

def is_valid_jpeg(path):
    try:
        with open(path, 'rb') as f:
            header = f.read(3)
        size = os.path.getsize(path)
        return header[:2] == b'\xff\xd8' and size > 10000
    except Exception:
        return False

def download_unsplash(cat, query_unsplash, i):
    url = f"https://source.unsplash.com/{TARGET_W}x{TARGET_H}/?{query_unsplash}&sig={cat}{i}"
    path = os.path.join(ASSETS_DIR, f'{cat}_{i}.jpg')
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=15) as r:
            data = r.read()
        if data[:2] == b'\xff\xd8' and len(data) > 10000:
            with open(path, 'wb') as f:
                f.write(data)
            return True
    except Exception:
        pass
    return False

def download_loremflickr(cat, query_flickr, i):
    lock = abs(hash(f'{cat}{i}')) % 9000 + 1000
    url = f"https://loremflickr.com/{TARGET_W}/{TARGET_H}/{query_flickr}?lock={lock}"
    path = os.path.join(ASSETS_DIR, f'{cat}_{i}.jpg')
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=30) as r:
            data = r.read()
        if data[:2] == b'\xff\xd8' and len(data) > 10000:
            with open(path, 'wb') as f:
                f.write(data)
            return True
    except Exception:
        pass
    return False

def main():
    os.makedirs(ASSETS_DIR, exist_ok=True)
    total_ok = 0
    total_skip = 0
    total_fail = 0

    for cat, (query_unsplash, query_flickr) in CATEGORIES.items():
        print(f'\n=== {cat.upper()} ===')
        for i in range(1, 12):
            path = os.path.join(ASSETS_DIR, f'{cat}_{i}.jpg')

            if os.path.exists(path) and is_valid_jpeg(path):
                kb = os.path.getsize(path) // 1024
                print(f'  SKIP  {cat}_{i}.jpg  ({kb} KB)')
                total_skip += 1
                continue

            print(f'  [{i}/11] {cat}_{i}.jpg ... ', end='', flush=True)

            # Try Unsplash first
            ok = download_unsplash(cat, query_unsplash, i)
            source = 'unsplash'

            if not ok:
                ok = download_loremflickr(cat, query_flickr, i)
                source = 'flickr'

            if ok and is_valid_jpeg(path):
                kb = os.path.getsize(path) // 1024
                print(f'OK ({source}, {kb} KB)')
                total_ok += 1
            else:
                print('FAIL')
                if os.path.exists(path):
                    os.remove(path)
                total_fail += 1

            time.sleep(0.5)

    print(f'\nDone. OK={total_ok}  SKIP={total_skip}  FAIL={total_fail}')

if __name__ == '__main__':
    main()
