"""Generate the Dramnyen Tuner brand assets (icon + circle-safe splashes) from
the master instrument render. Run:  python build_brand.py
Sources : splash.png (instrument isolated on transparency)
Outputs : icon.png, splash.png, splash_android12.png
"""
import numpy as np
from PIL import Image, ImageFilter, ImageDraw

SRC = Image.open("splash.png").convert("RGBA")

# --- palette (Terma Heritage warm-ink) ---
INK_CENTER = (42, 33, 26)   # warm centre
INK_EDGE = (16, 13, 11)     # deep edge
GOLD = (212, 168, 83)


def radial_bg(size, center=INK_CENTER, edge=INK_EDGE, falloff=1.15):
    """Warm radial gradient, lighter in the middle for depth."""
    n = size
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32)
    cx = cy = (n - 1) / 2
    d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / (n / 2)
    d = np.clip(d ** falloff, 0, 1)[..., None]
    c0 = np.array(center, np.float32)
    c1 = np.array(edge, np.float32)
    rgb = (c0 * (1 - d) + c1 * d).astype(np.uint8)
    a = np.full((n, n, 1), 255, np.uint8)
    return Image.fromarray(np.concatenate([rgb, a], 2), "RGBA")


def soft_glow(size, box, color, alpha, blur):
    """A blurred elliptical glow placed behind the instrument."""
    g = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(g)
    d.ellipse(box, fill=color + (alpha,))
    return g.filter(ImageFilter.GaussianBlur(blur))


def drop_shadow(sprite, size, offset, blur, alpha):
    """Silhouette shadow under the instrument for grounding."""
    sh = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    a = sprite.split()[3].point(lambda v: int(v * alpha / 255))
    black = Image.new("RGBA", sprite.size, (0, 0, 0, 255))
    black.putalpha(a)
    sh.alpha_composite(black, offset)
    return sh.filter(ImageFilter.GaussianBlur(blur))


def fit(sprite, target_h):
    w, h = sprite.size
    s = target_h / h
    return sprite.resize((max(1, round(w * s)), target_h), Image.LANCZOS)


def centered(canvas_size, sprite):
    c = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    w, h = sprite.size
    c.alpha_composite(sprite, ((canvas_size - w) // 2, (canvas_size - h) // 2))
    return c


# Tight content crops from the master render.
BODY = SRC.crop((456, 480, 743, 972))   # headstock + resonator (the icon mark)
FULL = SRC.crop(SRC.getchannel("A").getbbox())  # whole instrument


def build_icon(out="icon.png", N=1024):
    bg = radial_bg(N)
    inst = fit(BODY, int(N * 0.86))
    cx = (N - inst.size[0]) // 2
    cy = (N - inst.size[1]) // 2
    # glow halo behind the body
    bx0, by0 = cx + inst.size[0] * 0.10, cy + inst.size[1] * 0.30
    bx1, by1 = cx + inst.size[0] * 0.90, cy + inst.size[1] * 1.02
    bg.alpha_composite(soft_glow(N, (bx0, by0, bx1, by1), GOLD, 60, 90))
    # grounding shadow
    bg.alpha_composite(drop_shadow(centered(N, inst), N, (0, 16), 22, 150))
    bg.alpha_composite(inst, (cx, cy))
    # gentle vignette: darken corners with a radial black mask
    yy, xx = np.mgrid[0:N, 0:N].astype(np.float32)
    d = np.sqrt((xx - N / 2) ** 2 + (yy - N / 2) ** 2) / (N / 2)
    va = (np.clip((d - 0.55) / 0.55, 0, 1) ** 1.6 * 120).astype(np.uint8)
    vig = Image.fromarray(np.dstack([np.zeros((N, N, 3), np.uint8), va]), "RGBA")
    bg.alpha_composite(vig)
    bg.save(out)
    print("wrote", out, bg.size)


def build_splash(out="splash.png", N=1152, target_h=720, sprite=None):
    sprite = sprite if sprite is not None else FULL
    canvas = centered(N, fit(sprite, target_h))
    canvas.save(out)
    print("wrote", out, canvas.size, "content_h", target_h)


if __name__ == "__main__":
    build_icon()
    # iOS + Android<12: full instrument, comfortably inside the frame.
    build_splash("splash.png", 1152, 760, FULL)
    # Android 12+: masked to a circle → use the body mark, fits the 768 circle.
    build_splash("splash_android12.png", 1152, 600, BODY)
