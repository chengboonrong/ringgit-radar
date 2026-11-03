"""Draws the Ringgit Radar app icon and writes every size the app ships.

The mark is the target from the red tag, two rings and a dot, with a radar sweep arm added so that it reads as a
radar and not as a plain bullseye. White on the brand red. It is drawn here from circles and one line, so this
script is the source of the icon; nothing is copied from anywhere else.
Run from apps/flutter_app:  python3 tool/make_icons.py   (needs Pillow)
Writes: web favicon and manifest icons, Android legacy and adaptive icons, the iOS AppIcon set.
"""
import json
import math
import os

from PIL import Image, ImageDraw

RED = (200, 16, 46)  # brand red #C8102E
WHITE = (255, 255, 255)
SS = 4  # supersampling for smooth edges


def mark(size, diameter, fg=WHITE):
    """Transparent canvas with the target centred; diameter is a fraction of the canvas."""
    big = size * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = big / 2
    unit = big * diameter / 2  # radius of the outer ring's outer edge
    for r_out, r_in in ((1.0, 0.80), (0.58, 0.38)):  # outer ring, inner ring
        d.ellipse([c - unit * r_out, c - unit * r_out, c + unit * r_out, c + unit * r_out], fill=fg)
        d.ellipse([c - unit * r_in, c - unit * r_in, c + unit * r_in, c + unit * r_in], fill=(0, 0, 0, 0))
    dot = unit * 0.2
    d.ellipse([c - dot, c - dot, c + dot, c + dot], fill=fg)
    # the sweep arm: from the centre to the outer ring, pointing up and to the right
    angle = math.radians(-42)
    end = (c + unit * 0.9 * math.cos(angle), c + unit * 0.9 * math.sin(angle))
    w = unit * 0.16
    d.line([(c, c), end], fill=fg, width=round(w))
    d.ellipse([end[0] - w / 2, end[1] - w / 2, end[0] + w / 2, end[1] + w / 2], fill=fg)
    return img


def tile(size, diameter, radius=0.0, bg=RED):
    """The mark on a red square; radius is the corner radius as a fraction of the side (0 = full bleed)."""
    big = size * SS
    base = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    ImageDraw.Draw(base).rounded_rectangle([0, 0, big - 1, big - 1], radius=big * radius, fill=bg + (255,))
    base.alpha_composite(mark(size, diameter))
    return base.resize((size, size), Image.LANCZOS)


def save(img, path, opaque=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if opaque:
        img = img.convert("RGB")
    img.save(path, optimize=True)


def main():
    # web: icons for the manifest, the touch icon and the tab. Maskable ones are full bleed, mark inside the safe zone.
    for s in (192, 512):
        save(tile(s, 0.62, radius=0.22), f"web/icons/Icon-{s}.png")
        save(tile(s, 0.46), f"web/icons/Icon-maskable-{s}.png")
    save(tile(48, 0.66, radius=0.2), "web/favicon.png")

    # android legacy launcher icons
    for dpi, s in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)):
        save(tile(s, 0.62, radius=0.22), f"android/app/src/main/res/mipmap-{dpi}/ic_launcher.png")
    # android adaptive icon: a 108dp canvas whose middle 66dp is always visible; the mark sits inside it
    res = "android/app/src/main/res"
    for dpi, s in (("mdpi", 108), ("hdpi", 162), ("xhdpi", 216), ("xxhdpi", 324), ("xxxhdpi", 432)):
        save(mark(s, 0.44), f"{res}/drawable-{dpi}/ic_launcher_foreground.png")
    os.makedirs(f"{res}/mipmap-anydpi-v26", exist_ok=True)
    with open(f"{res}/mipmap-anydpi-v26/ic_launcher.xml", "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@drawable/ic_launcher_foreground"/>\n'
            '    <monochrome android:drawable="@drawable/ic_launcher_foreground"/>\n'
            "</adaptive-icon>\n"
        )
    with open(f"{res}/values/ic_launcher_background.xml", "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
            '    <color name="ic_launcher_background">#C8102E</color>\n</resources>\n'
        )

    # iOS: every size in the existing set, opaque (the system rounds the corners)
    iconset = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.load(open(f"{iconset}/Contents.json"))
    for item in contents["images"]:
        px = round(float(item["size"].split("x")[0]) * int(item["scale"].rstrip("x")))
        save(tile(px, 0.62), f"{iconset}/{item['filename']}", opaque=True)
    print("icons written")


if __name__ == "__main__":
    main()
