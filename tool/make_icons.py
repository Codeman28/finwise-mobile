"""
make_icons.py - Draws the FinWise launcher icons for Android and iOS.

Run from the project folder (needs Pillow:  pip install pillow):
    python tool/make_icons.py

Design: deep green (#005B4C) with a white "F" and a small coral (#FD7B64)
coin - the same mark as the in-app logo.
  * iOS icons are full squares with NO transparency (Apple rejects alpha);
    iOS rounds the corners itself.
  * Android legacy icons are circles on a transparent background.
"""

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
GREEN = (0, 91, 76, 255)
GREEN_LIGHT = (11, 122, 102, 255)
CORAL = (253, 123, 100, 255)
WHITE = (255, 255, 255, 255)
FONT = ROOT / "assets" / "fonts" / "BeVietnamPro-ExtraBold.ttf"

SIZE = 1024  # draw once at high resolution, then shrink


def draw_mark(canvas, box):
    """Draws the gradient background, the F and the coin inside `box`."""
    x0, y0, x1, y1 = box
    size = x1 - x0
    draw = ImageDraw.Draw(canvas)

    # Diagonal gradient: light green top-left -> deep green bottom-right.
    gradient = Image.new("RGBA", (size, size))
    gd = ImageDraw.Draw(gradient)
    for i in range(size * 2):
        t = i / (size * 2)
        color = tuple(int(GREEN_LIGHT[c] * (1 - t) + GREEN[c] * t) for c in range(4))
        gd.line([(i, 0), (0, i)], fill=color)
    return gradient, draw


def make_master(round_shape):
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gradient, _ = draw_mark(canvas, (0, 0, SIZE, SIZE))

    mask = Image.new("L", (SIZE, SIZE), 0)
    md = ImageDraw.Draw(mask)
    if round_shape:
        md.ellipse((8, 8, SIZE - 8, SIZE - 8), fill=255)
    else:
        md.rectangle((0, 0, SIZE, SIZE), fill=255)
    canvas.paste(gradient, (0, 0), mask)

    draw = ImageDraw.Draw(canvas)
    font = ImageFont.truetype(str(FONT), 600)
    draw.text((SIZE / 2 - 30, SIZE / 2 + 20), "F", font=font, fill=WHITE, anchor="mm")
    # Coral "coin" with a white ring, top-right of the F.
    draw.ellipse((620, 190, 800, 370), fill=CORAL, outline=WHITE, width=22)
    return canvas


def save(img, path, size, opaque):
    path.parent.mkdir(parents=True, exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS)
    if opaque:
        background = Image.new("RGB", out.size, GREEN[:3])
        background.paste(out, mask=out.split()[3])
        out = background
    out.save(path)


def main():
    round_icon = make_master(round_shape=True)
    square_icon = make_master(round_shape=False)

    # Android launcher icons (mipmap densities).
    android = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    res = ROOT / "android" / "app" / "src" / "main" / "res"
    for density, px in android.items():
        save(round_icon, res / f"mipmap-{density}" / "ic_launcher.png", px, opaque=False)

    # iOS: read the sizes Xcode expects from Contents.json.
    iconset = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    contents = json.loads((iconset / "Contents.json").read_text(encoding="utf-8"))
    for image in contents["images"]:
        points = float(image["size"].split("x")[0])
        scale = int(image["scale"].replace("x", ""))
        save(square_icon, iconset / image["filename"], round(points * scale), opaque=True)

    # A preview for the README.
    save(round_icon, ROOT / "assets" / "icon_preview.png", 256, opaque=False)
    print("Icons written for Android and iOS.")


if __name__ == "__main__":
    main()
