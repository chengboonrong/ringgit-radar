#!/bin/sh
# Rebuilds the landing pages' fonts in static/fonts: M PLUS Rounded 1c (OFL, the app's own files) cut to
# Latin and common punctuation, as woff2. latin_chars.txt lists what the subset really maps, and
# site_test.go checks every page text against it, so rerun this after adding a character outside it.
set -eu
site="$(cd "$(dirname "$0")/.." && pwd)"
app="$site/../../apps/flutter_app/assets/fonts"
out="$site/static/fonts"
mkdir -p "$out"
for w in Regular Bold; do
  pyftsubset "$app/MPLUSRounded1c-$w.ttf" --flavor=woff2 \
    --unicodes='U+0020-007E,U+00A0-00FF,U+2010-2027' \
    --layout-features='*' --no-hinting --output-file="$out/MPLUSRounded1c-$w.woff2"
done
cp "$app/OFL.txt" "$out/OFL.txt"
python3 -c '
import sys
from fontTools.ttLib import TTFont
cmap = TTFont(sys.argv[1]).getBestCmap()
open(sys.argv[2], "w", encoding="utf-8").write("".join(chr(c) for c in sorted(cmap) if c >= 0x20) + "\n")
' "$out/MPLUSRounded1c-Regular.woff2" "$out/latin_chars.txt"
ls -l "$out"
