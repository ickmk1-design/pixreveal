"""Generate simple placeholder WAV sound effects for PixReveal."""
import wave
import struct
import math
import os

OUT_DIR = "assets/audio"
SAMPLE_RATE = 44100

def save_wav(filename, samples):
    path = os.path.join(OUT_DIR, filename)
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        for s in samples:
            v = max(-32767, min(32767, int(s * 32767)))
            w.writeframes(struct.pack('<h', v))
    print(f'wrote {path} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)')

def envelope(t, duration, attack=0.01, release=0.1):
    """ADSR-ish envelope"""
    if t < attack:
        return t / attack
    if t > duration - release:
        return max(0, (duration - t) / release)
    return 1.0

def tone(freq, duration, shape='sine', vol=0.5):
    samples = []
    total = int(duration * SAMPLE_RATE)
    for i in range(total):
        t = i / SAMPLE_RATE
        if shape == 'sine':
            s = math.sin(2 * math.pi * freq * t)
        elif shape == 'square':
            s = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
        elif shape == 'saw':
            s = 2 * (freq * t - math.floor(freq * t + 0.5))
        elif shape == 'noise':
            import random
            s = random.uniform(-1, 1)
        e = envelope(t, duration)
        samples.append(s * e * vol)
    return samples

def sweep(f1, f2, duration, shape='sine', vol=0.5):
    samples = []
    total = int(duration * SAMPLE_RATE)
    for i in range(total):
        t = i / SAMPLE_RATE
        p = i / total
        freq = f1 + (f2 - f1) * p
        s = math.sin(2 * math.pi * freq * t)
        e = envelope(t, duration)
        samples.append(s * e * vol)
    return samples

def mix(*sample_lists):
    max_len = max(len(s) for s in sample_lists)
    out = [0.0] * max_len
    for s in sample_lists:
        for i, v in enumerate(s):
            out[i] += v
    # normalize
    peak = max(abs(v) for v in out)
    if peak > 0:
        out = [v / peak * 0.8 for v in out]
    return out

os.makedirs(OUT_DIR, exist_ok=True)

# trail_draw — short electronic tick (looping)
save_wav('trail_draw.wav', tone(880, 0.05, 'square', 0.3))

# capture — satisfying rising swoosh + chord
capture = mix(
    sweep(200, 800, 0.3, vol=0.4),
    tone(440, 0.3, 'sine', 0.3),
    tone(660, 0.3, 'sine', 0.25),
    tone(880, 0.3, 'sine', 0.2),
)
save_wav('capture.wav', capture)

# die — descending zap
save_wav('die.wav', sweep(600, 100, 0.4, vol=0.6))

# level_complete — ascending fanfare
lc = mix(
    sweep(262, 523, 0.15, vol=0.4),  # C4 -> C5
    sweep(330, 659, 0.15, vol=0.3),  # E -> E
    tone(523, 0.25, 'sine', 0.4),
    tone(659, 0.25, 'sine', 0.3),
    tone(784, 0.35, 'sine', 0.5),    # G5
)
save_wav('level_complete.wav', lc)

# token_insert — metallic coin click
ti = mix(
    tone(1200, 0.05, 'square', 0.4),
    tone(800, 0.08, 'square', 0.3),
    tone(1600, 0.1, 'sine', 0.2),
)
save_wav('token_insert.wav', ti)

# button_click — short blip
save_wav('button_click.wav', tone(1500, 0.04, 'square', 0.3))

print('DONE')
