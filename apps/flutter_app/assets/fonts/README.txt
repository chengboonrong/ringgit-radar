M PLUS Rounded 1c, Regular, Medium and Bold, from github.com/google/fonts (ofl/mplusrounded1c).
Copyright 2016 The Rounded M+ Project Authors. SIL Open Font License 1.1, see OFL.txt.
The google/fonts repository ships no OFL.txt for this family, so OFL.txt is the licence text from the
sibling M+ family in the same repository with the copyright line taken from the font's own name table.
The files here are subsets made by tool/subset_fonts.sh; the full fonts are not bundled.
Digits are 620 units wide in every weight, so prices line up without a tnum feature (the font has none).

Modification: tool/lower_ellipsis.py moves the three dots of U+2026 from mid height down to the baseline,
because the font draws them at mid height for Japanese and Latin text wants them level with a period.
Nothing else in the outlines changes. The OFL permits modified versions; this copyright line names no
Reserved Font Name (OFL.txt only defines the term), so the font keeps its name. Regenerating with
tool/subset_fonts.sh repeats the change.

RinggitZh-Regular/Medium/Bold.ttf: subsets of Resource Han Rounded CN (Regular, Medium, Bold) v0.990, from
github.com/CyanoHao/Resource-Han-Rounded (release v0.990, RHR-CN-0.990.7z). Copyright 2018-2019 Cyano Hao,
portions Adobe. SIL Open Font License 1.1, see OFL-ResourceHanRounded.txt (Reserved Font Name 'Source').
Chosen because it is a rounded Simplified Chinese design (Source Han Sans with rounded ends), close to the
look of M PLUS Rounded 1c, and OFL. Static TTFs from v0.990 rather than the v1.910 CFF2 variable fonts,
so Flutter needs no variable-font support.
tool/subset_zh_font.sh <dir with ResourceHanRoundedCN-*.ttf> keeps exactly the non-ASCII characters of
lib/l10n/app_zh.arb (no Latin, no digits: those fall through to M PLUS Rounded 1c, so prices look the same
in every language), renames the family to RinggitZh because a subset is a modified font under the OFL,
and writes zh_chars.txt, the characters the subset maps. Rerun it after every change to app_zh.arb;
test/zh_font_test.dart fails when a character is missing.
