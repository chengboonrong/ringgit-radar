#!/bin/sh
# Rebuilds assets/fonts/RinggitZh-*.ttf from the full Resource Han Rounded CN files in $1 (OFL,
# github.com/CyanoHao/Resource-Han-Rounded, release v0.990, RHR-CN-0.990.7z). The subset holds exactly the
# non-ASCII characters in lib/l10n/app_zh.arb plus 年月日, which intl's Chinese date patterns add (lib/core/format.dart), so rerun this after every change to that file;
# test/zh_font_test.dart fails when a character is missing. It holds no Latin or digits on purpose: those
# fall through to M PLUS Rounded 1c, so prices and game titles look the same in every language.
set -eu
src="${1:?usage: tool/subset_zh_font.sh <dir with ResourceHanRoundedCN-*.ttf>}"
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/assets/fonts"
chars="$(mktemp)"
python3 -c '
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
print("".join(sorted({c for k, v in d.items() if not k.startswith("@") for c in v if ord(c) > 0x7E} | set("年月日"))))
' "$root/lib/l10n/app_zh.arb" > "$chars"
for w in Regular Medium Bold; do
  pyftsubset "$src/ResourceHanRoundedCN-$w.ttf" \
    --text-file="$chars" \
    --layout-features='*' --no-hinting --name-IDs='*' --output-file="$out/RinggitZh-$w.ttf"
done
# a subset is a modified font under the OFL, so it drops the upstream name (its licence reserves 'Source')
python3 -c '
import sys
from fontTools.ttLib import TTFont
for path in sys.argv[1:]:
    f = TTFont(path)
    weight = path.rsplit("-", 1)[1][:-4]
    for rec in f["name"].names:
        if rec.nameID in (1, 16): rec.string = "RinggitZh"
        elif rec.nameID == 4: rec.string = "RinggitZh " + weight
        elif rec.nameID == 6: rec.string = "RinggitZh-" + weight
        elif rec.nameID == 3: rec.string = "RinggitZh-" + weight + " subset"
    f.save(path)
' "$out"/RinggitZh-*.ttf
# the characters the subset really maps, which the test checks app_zh.arb against
python3 -c '
import sys
from fontTools.ttLib import TTFont
cmap = TTFont(sys.argv[1]).getBestCmap()
open(sys.argv[2], "w", encoding="utf-8").write("".join(chr(c) for c in sorted(cmap) if c > 0x7E) + "\n")
' "$out/RinggitZh-Regular.ttf" "$out/zh_chars.txt"
rm -f "$chars"
ls -l "$out"/RinggitZh-*.ttf
