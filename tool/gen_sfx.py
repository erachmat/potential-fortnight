#!/usr/bin/env python3
"""Sintesis SFX Nitip (WAV mono 22.05 kHz) — dibuat sendiri, bebas lisensi.

Pemakaian: python3 tool/gen_sfx.py [folder_output]   (default: assets/sfx)
"""
import math
import struct
import sys
import wave
from pathlib import Path

RATE = 22050


def tone(freq, dur, vol=0.5, attack=0.005, decay=None, harmonics=((1, 1.0),)):
    n = int(RATE * dur)
    decay = decay if decay is not None else dur
    out = []
    for i in range(n):
        t = i / RATE
        env = min(1.0, t / attack) * math.exp(-3.0 * t / decay)
        s = sum(a * math.sin(2 * math.pi * freq * h * t) for h, a in harmonics)
        out.append(vol * env * s / sum(a for _, a in harmonics))
    return out


def silence(dur):
    return [0.0] * int(RATE * dur)


def mix(*tracks):
    n = max(len(t) for t in tracks)
    out = [0.0] * n
    for t in tracks:
        for i, v in enumerate(t):
            out[i] += v
    peak = max(1e-9, max(abs(v) for v in out))
    return [v / peak * 0.85 for v in out] if peak > 0.85 else out


def seq(*parts):
    out = []
    for p in parts:
        out += p
    return out


def offset(track, dur):
    return silence(dur) + track


def write(path, samples):
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, v)) * 32767)) for v in samples))


H = ((1, 1.0), (2, 0.35), (3, 0.15))


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "assets/sfx")
    out.mkdir(parents=True, exist_ok=True)
    # order_ding: dua nada naik, cerah
    write(out / "order_ding.wav", seq(tone(880, 0.16, .6, harmonics=H), tone(1318.5, 0.42, .6, decay=.4, harmonics=H)))
    # success_chime: arpeggio mayor C-E-G
    write(out / "success_chime.wav", seq(tone(523.25, .11, .5, harmonics=H), tone(659.25, .11, .5, harmonics=H), tone(783.99, .4, .55, decay=.35, harmonics=H)))
    # coin: nada tinggi pendek + kilau
    write(out / "coin.wav", mix(seq(tone(987.77, .07, .5, harmonics=H), tone(1318.5, .35, .5, decay=.3, harmonics=H)), offset(tone(2637, .25, .15, decay=.2), .07)))
    # tick: klik lembut
    write(out / "tick.wav", tone(1800, 0.05, .45, attack=.001, decay=.03))
    # pop: pop sangat pendek (frekuensi turun cepat)
    n = int(RATE * 0.09)
    pop = [0.55 * math.exp(-35 * (i / RATE)) * math.sin(2 * math.pi * (700 - 5000 * (i / RATE)) * (i / RATE)) for i in range(n)]
    write(out / "pop.wav", pop)
    print("SFX ditulis ke", out)


if __name__ == "__main__":
    main()
