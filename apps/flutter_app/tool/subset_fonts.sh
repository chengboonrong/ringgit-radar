#!/bin/sh
# Rebuilds assets/fonts/*.ttf from the full M PLUS Rounded 1c files in $1 (OFL, google/fonts repo).
# The subset is Latin and punctuation plus every other character that appears in the product titles,
# publishers and descriptions in the local eshop_radar database, so those never render as boxes.
# Characters the font itself lacks fall back to the platform font.
set -eu
src="${1:?usage: tool/subset_fonts.sh <dir with MPLUSRounded1c-*.ttf>}"
out="$(dirname "$0")/../assets/fonts"
chars="$(mktemp)"
psql -d "${DB:-eshop_radar}" -At -c "select title || ' ' || publisher || ' ' || coalesce(raw->>'text','') || ' ' || coalesce(raw->'hcopy'->>0,'') from products" > "$chars"
for w in Regular Medium Bold; do
  pyftsubset "$src/MPLUSRounded1c-$w.ttf" \
    --unicodes='U+0020-007E,U+00A0-024F,U+2010-2027,U+2030-205E,U+20AC,U+2122,U+2190-2193,U+25CF' \
    --text-file="$chars" --layout-features='*' --no-hinting --output-file="$out/MPLUSRounded1c-$w.ttf"
done
# the ellipsis is drawn at mid height in this font; put it on the baseline
python3 "$(dirname "$0")/lower_ellipsis.py" "$out"/MPLUSRounded1c-*.ttf
rm -f "$chars"
