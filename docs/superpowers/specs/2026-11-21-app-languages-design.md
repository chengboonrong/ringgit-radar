# Ringgit Radar in English, Chinese and Malay

Date: 2026-11-21. Status: design, awaiting owner approval.

## Why

The owner wants Ringgit Radar known and shared among people in Malaysia, and Malaysians read English, Chinese and Malay. This is project 1 of 4, in the order the owner agreed:

1. The app in English, Simplified Chinese and Malay (this document).
2. A landing page at `ringgitradar.snitco.com`, in the same three languages.
3. A native macOS app, shipped as a notarized DMG outside the Mac App Store.
4. A native iOS app on the App Store, signed with team M3M48TK6VE. The owner accepts the risk that Apple review rejects it.

The landing page and both store listings will advertise the three languages, so the languages come first.

## Goals

- Every piece of UI text the app itself writes is in English, Simplified Chinese (`zh`, shown as 简体中文) or Malay (`ms`, Bahasa Melayu as used in Malaysia, not Indonesian).
- The app follows the device language when it is one of the three, and otherwise uses English. Any Chinese device locale, including Traditional (`zh-Hant`, `zh-TW`, `zh-HK`), gets Simplified Chinese, which those readers can follow more easily than English (builder-check call, see below). A Language row in Settings (System / English / 简体中文 / Bahasa Melayu) overrides it, stored on the device the same way the theme choice is.
- Chinese renders correctly on every platform, including the web build, which blocks Google's font server on purpose.
- No translation ships without the self-check below passing.

## Non-goals

- Game titles, publishers, descriptions and screenshots stay exactly as Nintendo's Malaysian catalogue gives them (English). Translating them would mean inventing text.
- No server-side language support. The API stays language-neutral.
- No Traditional Chinese, Tamil or any other language for now.
- The landing page, macOS and iOS work belong to their own designs.

## Anti-goals (would count as failure even if it works)

- Translations that read as machine output in the short labels the app lives on ("Sale ends …", "Lowest price seen", "% OFF").
- A translation that says more than the English does. `PRODUCT.md`'s honesty rules apply in every language: nothing called "popular" or "best-selling", "observed low" only means what our own history shows, and nothing suggests the app is official Nintendo.
- Chinese characters drawn as empty boxes, or a CJK font that makes the web app much slower to start.
- Prices or dates that read differently by language. Money stays `RM 64.80` (integer sen, no-break space) and all times stay in Malaysia time (UTC+8) in every language.

## Constraints found in the code

- **About 100 hard-coded strings** across 16 files under `apps/flutter_app/lib`, plus `lib/core/format.dart`, which hard-codes English dates (`DateFormat(..., 'en')`), `Sale ends …`, `% OFF` and `Items: …`. `main.dart` only calls `initializeDateFormatting('en')`.
- **Error messages are built from fragments:** `api_client.dart` composes `"Couldn't load $what. …"` with `what` values such as `'the list'` and `'Highlights'`. Fragments can't be translated (word order and grammar differ). Each one becomes a whole sentence per case.
- **The filter sheet** builds `'Show ${n} results'`, which is a plural and has to use the plural form.
- **Genres** come from the API as fixed English names (`Action`, `Adventure`, `Puzzle`, `RPG`, … from `/v1/genres`). They are also filter values sent back to the API, so the API value stays English and only the displayed label is translated, through a fixed lookup. An unknown genre is shown in English.
- **Fonts:** `assets/fonts/MPLUSRounded1c-*.ttf` are subsets made by `tool/subset_fonts.sh`, containing Latin plus characters from catalogue text. M PLUS Rounded 1c is a Japanese font and lacks Simplified-only characters such as 价. On Android, iOS and macOS the system font fills gaps. On the web (`--no-web-resources-cdn`) nothing does.
- **Settings:** theme and "show all" are Riverpod notifiers over `SharedPreferences` in `lib/core/storage/prefs.dart`. Their UI is in `lib/features/settings/about_page.dart`.

## Approaches considered

- **A. Flutter's built-in localisation (`flutter_localizations` + `gen-l10n`, ARB files). Chosen by the owner.** One ARB file per language, generated typed accessors, ICU plurals and placeholders, and a build failure when a key is missing in any language. `intl` is already a dependency and `flutter_localizations` ships with the SDK, so nothing new is installed.
- B. A package such as `slang`. Also type-safe and a little nicer to write, but it adds a dependency for what the SDK already does.
- C. A hand-written string table per language. Least setup, but plurals, date formatting and missing-key checks would all be reimplemented by hand.

## Decided

- Approach A, with `app_en.arb` as the template and `app_zh.arb` and `app_ms.arb` beside it.
- Supported locales: `en`, `zh`, `ms`. Chinese is Simplified.
- The order is device language, then the Settings override, with English as the fallback.
- Game data stays in English (see Non-goals).
- The name "Ringgit Radar" is never translated. It stays a constant outside the ARB files (wordmark, `MaterialApp.title`, web `<title>`, home-screen labels), and translated sentences that mention it keep it in Latin letters. Projects 2 to 4 use the same name.
- The address for the later landing page is `ringgitradar.snitco.com` (recorded here for project 2).
- No human translator. Quality comes from the self-check below.

## Design

### Strings

- Every user-visible string in `lib/` moves to the ARB files, including `format.dart`'s labels, error messages, empty states, the About and Privacy pages, semantics labels and tooltips. Code reads them through the generated `AppLocalizations`.
- Placeholders and ICU plurals are used for counts ("Show {count} results", days left), never string concatenation.
- Each ARB entry carries an `@key` description saying where it appears and how much room it has. The self-check reads these.
- The Privacy page is translated, with one added line in each non-English version saying the English version applies if they differ.

### Dates and numbers

- Format with the active locale (`DateFormat(pattern, locale)`) and keep the Malaysia-time conversion exactly as it is. Initialise date symbols for all three locales at start-up.
- Money keeps the `plainMoney` and `splitMinor` output unchanged in every language. `RM` is not translated.

### Language setting

- A `LocaleNotifier` in `prefs.dart`, built like `ThemeModeNotifier`, under the key `locale` (`system` | `en` | `zh` | `ms`). `MaterialApp.router` gets `locale`, `supportedLocales` and the localisation delegates.
- A Language row in Settings, next to the theme choice. Each option is written in its own language.
- On the web, `<html lang>` follows the active language.

### Chinese on the web

- Bundle a subset of an OFL Simplified Chinese font covering exactly the characters in `app_zh.arb`, made by `tool/subset_fonts.sh` (or a sibling script) and used for the theme's text styles. When the app is in Chinese, the Chinese font comes first and M PLUS Rounded 1c second: the current subset already holds about 45 kanji in Japanese style (日, 本, 用, 会, 能 …), and with the Chinese font only as a fallback, Chinese labels would mix two styles of character. Because game text stays English, this is a few hundred glyphs, and the target is a small file (well under 300 KB per weight). It must not be a full CJK font. The builder picks the font and the weights, keeping the look close to M PLUS Rounded 1c and recording the choice and licence in `assets/fonts/README.txt`.
- Regenerating the subset after changing `app_zh.arb` becomes a documented step, and a test (below) catches a missing character.

### The stricter self-check (in place of a human reviewer)

1. **Glossary first.** Before translating, write `apps/flutter_app/l10n/glossary.md`, fixing one term per language for each recurring concept: sale, regular price, observed low / lowest price seen, price history, wish list, ranking, ringgit saved, highlights, sale ends, release date, unofficial. Use the words Malaysian Switch players see in the eShop and on Malaysian shopping sites (for example 心愿单 vs 愿望清单, "Jualan" vs "Promosi"), and record the reason for each choice.
2. **Translate against the glossary** with each ARB description as context.
3. **Blind back-translation.** A separate agent that never sees the English translates `zh` and `ms` back into English. Every string whose meaning drifts (adds a claim, loses a qualifier such as "observed", changes a number or date) gets fixed and checked again.
4. **Automated checks** in `flutter test`: all three ARB files have the same keys and the same placeholders. No translation contains words the honesty rules forbid (a per-language list such as 最受欢迎 / paling popular / official / 官方). Every character in `app_zh.arb` exists in the bundled Chinese subset.
5. **Fit check.** Golden or widget tests render the main screens (Highlights, Sale, Ranking, game page, filter sheet, Settings) at phone width in all three languages, at text scale 1.0 and 1.3, with no overflow. Claude also looks at screenshots of each (6 screens × 3 languages) before opening the PR.
6. **Translation review pass** using the `translation-review` skill over the final ARB files, before opening the PR.

Steps 3, 5 and 6 happen before the PR is opened. After that the PR follows the repo's normal rule and auto-merges once CI is green. The owner chose a self-check with no human reviewer, so nothing waits on a person.

### Tests and CI

- Update the existing tests that assert English text (`format_test.dart`, `privacy_page_test.dart`, `game_card_test.dart` and others) to pump with an explicit locale, and add `zh` and `ms` cases for the formatters.
- CI (`flutter analyze`, `flutter test`) covers the checks above with no new CI jobs.

## Calls made after the builder check (owner, check these)

- Traditional Chinese device locales get Simplified Chinese, not English.
- The screenshot and translation review is done by Claude before the PR. The PR then auto-merges on green CI like every other Ringgit Radar PR.
- When the app is in Chinese, the Chinese font comes before M PLUS Rounded 1c.

## Left to the builder

- Key names and how strings are grouped in the ARB files.
- Which Simplified Chinese OFL font, which weights, and how the fallback is registered.
- Whether the fit checks are goldens or overflow-only widget tests.
- The exact Settings layout of the Language row, within `DESIGN.md`.
