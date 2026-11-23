#!/bin/sh
# Rebuilds the landing pages' fonts in static/fonts: M PLUS Rounded 1c (OFL, the app's own files) cut to
# Latin and common punctuation, as woff2. latin_chars.txt lists what the subset really maps, and
# site_test.go checks every page text against it, so rerun this after adding a character outside it.
# $1 is a dir with the full Resource Han Rounded CN fonts (OFL, github.com/CyanoHao/Resource-Han-Rounded,
# release v0.990): RinggitZh-*.woff2 holds exactly the non-ASCII characters of text/zh.json, so rerun this
# after every change to that file; zh_chars.txt lists them and site_test.go checks it.
set -eu
rhr="${1:?usage: tool/subset_fonts.sh <dir with ResourceHanRoundedCN-*.ttf>}"
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
chars="$(mktemp)"
python3 -c '
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
print("".join(sorted({c for v in d.values() for c in v if ord(c) > 0x7E})))
' "$site/text/zh.json" > "$chars"
for w in Regular Bold; do
  pyftsubset "$rhr/ResourceHanRoundedCN-$w.ttf" --flavor=woff2 --text-file="$chars" \
    --layout-features='*' --no-hinting --name-IDs='*' --output-file="$out/RinggitZh-$w.woff2"
done
rm -f "$chars"
cp "$app/OFL-ResourceHanRounded.txt" "$out/OFL-ResourceHanRounded.txt"
# a subset is a modified font under the OFL, so it drops the upstream name (its licence reserves 'Source')
python3 -c '
import sys
from fontTools.ttLib import TTFont
for path in sys.argv[1:]:
    f = TTFont(path)
    weight = path.rsplit("-", 1)[1].split(".")[0]
    for rec in f["name"].names:
        if rec.nameID in (1, 16): rec.string = "RinggitZh"
        elif rec.nameID == 4: rec.string = "RinggitZh " + weight
        elif rec.nameID == 6: rec.string = "RinggitZh-" + weight
        elif rec.nameID == 3: rec.string = "RinggitZh-" + weight + " subset"
    f.flavor = "woff2"
    f.save(path)
' "$out"/RinggitZh-*.woff2
python3 -c '
import sys
from fontTools.ttLib import TTFont
cmap = TTFont(sys.argv[1]).getBestCmap()
open(sys.argv[2], "w", encoding="utf-8").write("".join(chr(c) for c in sorted(cmap) if c > 0x7E) + "\n")
' "$out/RinggitZh-Regular.woff2" "$out/zh_chars.txt"
ls -l "$out"
