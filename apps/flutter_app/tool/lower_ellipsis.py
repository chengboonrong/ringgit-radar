"""Lowers U+2026 onto the baseline in the given font files.

M PLUS draws the horizontal ellipsis at mid height, as Japanese text expects. Latin text wants the dots
on the baseline, level with a period. Only the position of the dots changes, and only in the subset files
this repository ships. See assets/fonts/README.txt for why that is allowed.
"""
import sys

from fontTools.ttLib import TTFont

for path in sys.argv[1:]:
    font = TTFont(path)
    glyf = font["glyf"]
    name = font.getBestCmap()[0x2026]
    glyph = glyf[name]
    if glyph.yMin > 0:  # run twice and nothing happens the second time
        glyph.coordinates.translate((0, -glyph.yMin))
        glyph.recalcBounds(glyf)
        font["hmtx"][name] = (font["hmtx"][name][0], glyph.xMin)
        font.save(path)
    print(path, name, "yMin", glyf[name].yMin, "yMax", glyf[name].yMax)
