#!/usr/bin/env python3
"""Menggambar ikon Nitip (tas belanja + pegangan "n" + gelembung chat) ke PNG.

Pemakaian: python3 tool/gen_icons.py <folder_output>
Menghasilkan: icon_customer.png, icon_courier.png, icon_fg.png (adaptif), favicon.png, Icon-192/512(.maskable).png
Geometri sama dengan lib/core/brand/logo.dart (kotak 100x100).
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ORANGE = (255, 106, 43, 255)
INK = (20, 17, 15, 255)
WHITE = (255, 255, 255, 255)


def bez(p0, p1, p2, n=24):
    return [((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0], (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]) for t in [i / n for i in range(n + 1)]]


def mark(d, k, ox, oy, ink, bubble, dots, speed_lines=False):
    """Gambar logo pada kanvas dengan skala k dan offset (ox, oy) (unit logo 100x100)."""
    def P(x, y):
        return (ox + x * k, oy + y * k)

    w = int(7 * k)
    # badan tas: trapesium (melebar ke bawah) bersudut bulat
    body = [P(26, 38), P(70, 38), P(77, 86), P(19, 86)]
    d.line(body + [body[0], body[1]], fill=ink, width=w, joint="curve")
    for p in body:
        d.ellipse([p[0] - w / 2, p[1] - w / 2, p[0] + w / 2, p[1] + w / 2], fill=ink)
    # pegangan "n": lengkung yang menembus ke dalam badan tas (bukan gembok)
    pts = [P(35, 54), P(35, 32)] + [P(*q) for q in bez((35, 32), (35, 14), (48, 14))] + [P(*q) for q in bez((48, 14), (61, 14), (61, 32))] + [P(61, 54)]
    d.line(pts, fill=ink, width=w, joint="curve")
    for p in (pts[0], pts[-1]):
        d.ellipse([p[0] - w / 2, p[1] - w / 2, p[0] + w / 2, p[1] + w / 2], fill=ink)
    # gelembung chat
    c = P(78, 22)
    r = 11 * k
    d.ellipse([c[0] - r, c[1] - r, c[0] + r, c[1] + r], fill=bubble)
    d.polygon([P(70, 28), P(66, 36), P(76, 31)], fill=bubble)
    for i in (-1, 0, 1):
        q = (c[0] + i * 4.6 * k, c[1])
        rr = 1.7 * k
        d.ellipse([q[0] - rr, q[1] - rr, q[0] + rr, q[1] + rr], fill=dots)
    if speed_lines:
        for y in (52, 62, 72):
            d.line([P(2, y), P(14, y)], fill=ink, width=int(4 * k))


def render(size, bg, ink, bubble, dots, scale_logo=0.62, speed=False, ss=4, transparent_bg=False):
    S = size * ss
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0) if transparent_bg else bg)
    d = ImageDraw.Draw(img)
    k = S * scale_logo / 100
    off = (S - 100 * k) / 2
    # logo secara visual sedikit ke kiri-bawah karena gelembung; geser agar seimbang
    mark(d, k, off - 2 * k, off + 3 * k, ink, bubble, dots, speed)
    return img.resize((size, size), Image.LANCZOS)


def main():
    out = Path(sys.argv[1])
    out.mkdir(parents=True, exist_ok=True)
    render(1024, ORANGE, INK, WHITE, INK).save(out / "icon_customer.png")
    render(1024, INK, ORANGE, ORANGE, INK, speed=True).save(out / "icon_courier.png")
    render(1024, None, INK, WHITE, INK, scale_logo=0.5, transparent_bg=True).save(out / "icon_fg.png")
    render(1024, None, INK, ORANGE, INK, scale_logo=0.5, transparent_bg=True).save(out / "splash_mark.png")
    render(32, ORANGE, INK, WHITE, INK, scale_logo=0.8).save(out / "favicon.png")
    render(192, ORANGE, INK, WHITE, INK).save(out / "Icon-192.png")
    render(512, ORANGE, INK, WHITE, INK).save(out / "Icon-512.png")
    render(192, ORANGE, INK, WHITE, INK, scale_logo=0.5).save(out / "Icon-maskable-192.png")
    render(512, ORANGE, INK, WHITE, INK, scale_logo=0.5).save(out / "Icon-maskable-512.png")
    print("ikon ditulis ke", out)


if __name__ == "__main__":
    main()
