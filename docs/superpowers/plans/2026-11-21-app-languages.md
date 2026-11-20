# Ringgit Radar in English, Chinese and Malay: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every piece of UI text the app writes is available in English, Simplified Chinese and Malay. The app follows the device language, a Settings override is available, and Chinese renders on the web.

**Architecture:** Flutter `gen-l10n` with three ARB files under `lib/l10n/`, read through a `context.l10n` extension. Formatters in `lib/core/format.dart` take an explicit locale code. API errors become structured values that the UI turns into text. A small subset Chinese font ships for the web.

**Tech Stack:** Flutter (Dart `^3.10.1`), `flutter_localizations` (SDK), `intl ^0.20.3` (already present), Riverpod 3, `shared_preferences`, `pyftsubset` (fontTools) for the font subset.

**Spec:** `docs/superpowers/specs/2026-11-21-app-languages-design.md`

All paths below are relative to `apps/flutter_app/` unless they start with `docs/`. Run every command from `apps/flutter_app/`.

## Global Constraints

- Locales: `en`, `zh` (Simplified, labelled 简体中文), `ms` (Bahasa Melayu as used in Malaysia). English is the template and the fallback.
- Any `zh` device locale, including `zh-Hant`, `zh-TW` and `zh-HK`, resolves to `zh`.
- "Ringgit Radar" is never translated and never goes in an ARB value as a translatable term. Sentences that mention it keep it in Latin letters.
- Game titles, publishers, descriptions and API genre values stay as the API sends them. Only the displayed genre label is translated, and an unknown genre shows as sent.
- Money is unchanged in every language: `plainMoney` and `splitMinor` output, `RM` plus a no-break space, integer sen.
- All shown times stay in Malaysia time (UTC+8) through `toMyt`, in every language.
- Honesty rules in every language: nothing called popular, best-selling or trending. "Observed low" only means our own history. Nothing implies official Nintendo.
- No new pub dependencies beyond `flutter_localizations` (SDK).
- Chinese font: an OFL Simplified Chinese font, subset to the characters in `app_zh.arb` only, each weight file well under 300 KB. It must not be a full CJK font.
- Every commit message ends with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Ringgit Radar PRs auto-merge on green CI (`gh pr merge <n> --auto --rebase --delete-branch`). All translation checks finish before the PR is opened.

## Review Focus

1. **The app is in Chinese and the device is Traditional Chinese (`zh_TW`).** Expected: Simplified UI, not English. Pinned in Task 1 (`resolveAppLocale`).
2. **A game title or genre the app hasn't seen, while in Chinese or Malay.** Expected: shown exactly as the API sends it, with no crash and no empty label. Pinned in Task 3 (`genreLabel` unknown case).
3. **A sale ending at 23:59 on 31 Dec, viewed on a device in another time zone, in Chinese.** Expected: "12月31日 23:59", Malaysia time. Pinned in Task 2 (`format_test` zh cases).
4. **Text scale 1.3 in Malay, whose labels are the longest.** Expected: no overflow on any main screen. Pinned in Task 6 (fit tests).
5. **Switching language in Settings while a list is loaded or showing an error.** Expected: every label, including the error text, changes immediately without refetching. Pinned in Task 2 (the error is stored as a value, not text) and Task 3 (switch test).

---

### Task 1: Localisation scaffolding and the language choice

**Files:**
- Modify: `pubspec.yaml` (add `flutter_localizations: sdk: flutter` under dependencies, and `generate: true` under `flutter:`)
- Create: `l10n.yaml`
- Create: `lib/l10n/app_en.arb` (seed with `appLanguageSystem`, `languageHeading`)
- Create: `lib/l10n/app_zh.arb`, `lib/l10n/app_ms.arb` (the same keys with the English values copied verbatim until Task 5; Task 5's "differs from English" check catches anything left untranslated)
- Create: `lib/l10n/l10n.dart`
- Create: `lib/l10n/html_lang.dart`, `lib/l10n/html_lang_web.dart`, `lib/l10n/html_lang_stub.dart`
- Modify: `lib/core/storage/prefs.dart`
- Modify: `lib/main.dart`
- Test: `test/locale_test.dart`

**Interfaces:**
- Produces:
  - `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`, `nullable-getter: false`. The generated `AppLocalizations` is imported from `package:ringgit_radar/l10n/app_localizations.dart`.
  - `extension L10nX on BuildContext { AppLocalizations get l10n; }` in `lib/l10n/l10n.dart`
  - `const appLocales = [Locale('en'), Locale('zh'), Locale('ms')];` in `lib/l10n/l10n.dart`
  - `Locale resolveAppLocale(List<Locale>? device)` in `lib/l10n/l10n.dart`: the first device locale whose `languageCode` is `en`, `zh` or `ms` wins, otherwise `Locale('en')`
  - `const localeKey = 'locale';` and `class LocaleNotifier extends Notifier<Locale?>` with `Future<void> set(Locale? locale)` (null means System, stored as `'system'`), `final localeProvider` in `prefs.dart`
  - `void setHtmlLang(String code)` from `lib/l10n/html_lang.dart` (a conditional export: web sets `document.documentElement.lang` through `dart:js_interop`, other platforms do nothing)

- [ ] **Step 1: Write the failing tests** in `test/locale_test.dart`

```dart
test('device locales resolve to one of the three, Chinese of any script to zh', () {
  expect(resolveAppLocale([const Locale('ms', 'MY')]), const Locale('ms'));
  expect(resolveAppLocale([const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW')]), const Locale('zh'));
  expect(resolveAppLocale([const Locale('zh', 'HK')]), const Locale('zh'));
  expect(resolveAppLocale([const Locale('ta', 'MY'), const Locale('ms')]), const Locale('ms'));
  expect(resolveAppLocale([const Locale('fr')]), const Locale('en'));
  expect(resolveAppLocale(null), const Locale('en'));
});

test('the language choice is stored and read back, System as null', () async {
  SharedPreferences.setMockInitialValues({});
  final c = container(await SharedPreferences.getInstance()); // same helper shape as wishlist_test.dart
  expect(c.read(localeProvider), isNull);
  await c.read(localeProvider.notifier).set(const Locale('zh'));
  expect(c.read(sharedPreferencesProvider).getString(localeKey), 'zh');
  await c.read(localeProvider.notifier).set(null);
  expect(c.read(sharedPreferencesProvider).getString(localeKey), 'system');
});

testWidgets('the app shows the stored language', (t) async {
  SharedPreferences.setMockInitialValues({localeKey: 'ms'});
  // pump RinggitRadarApp under a ProviderScope with the prefs override and a fake ApiClient that never answers
  // expect: Localizations.localeOf(<any context below MaterialApp>) == const Locale('ms')
});
```

- [ ] **Step 2: Run them to make sure they fail**

Run: `flutter test test/locale_test.dart`
Expected: compile errors: `resolveAppLocale`, `localeProvider`, `localeKey` not defined.

- [ ] **Step 3: Implement** the files above. In `main.dart`: `initializeDateFormatting()` with no argument (all locales), and `MaterialApp.router` gets `locale: ref.watch(localeProvider)`, `supportedLocales: appLocales`, `localizationsDelegates: AppLocalizations.localizationsDelegates`, `localeListResolutionCallback: (device, _) => resolveAppLocale(device)`. Call `setHtmlLang` with the resolved language code from inside `builder:` (read `Localizations.localeOf(context)`). `title` stays `'Ringgit Radar'`.

- [ ] **Step 4: Run the tests and make sure they pass**

Run: `flutter test test/locale_test.dart && flutter analyze`
Expected: all pass, no analyzer issues.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml l10n.yaml lib/l10n lib/core/storage/prefs.dart lib/main.dart test/locale_test.dart
git commit -m "Add localisation scaffolding and a stored language choice"
```

---

### Task 2: Locale-aware formatting and errors as values

**Files:**
- Modify: `lib/core/format.dart`
- Modify: `lib/core/api/api_client.dart`
- Modify: `lib/core/widgets/error_view.dart`
- Modify: `lib/features/lists/list_controller.dart` (`String? error` becomes `Object? error`)
- Modify: every caller of the changed functions (`game_x.dart`, `price_text.dart`, `game_card.dart`, `game_list_view.dart`, `price_history_chart.dart`, `game_page.dart`, `about_page.dart`, and the `ErrorView` callers in `ranking_page.dart`, `filter_sheet.dart`, `highlights_page.dart`, `wishlist_page.dart`)
- Modify: `lib/l10n/app_en.arb` (+ the same keys copied into `app_zh.arb`, `app_ms.arb`)
- Test: `test/format_test.dart`, `test/api_error_test.dart`

**Interfaces:**
- Consumes: `context.l10n`, `AppLocalizations` (Task 1)
- Produces, in `format.dart` (each takes the locale code, e.g. `context.l10n.localeName`):
  - `String shortDateMyt(DateTime instant, String locale)`: en `'d MMM'` → `16 Dec`, zh `DateFormat.MMMd` → `12月16日`, ms `'d MMM'` → `16 Dis`
  - `String longDateMyt(DateTime instant, String locale)`: en `16 Dec 2026`, zh `2026年12月16日`, ms `16 Dis 2026`
  - `String dateTimeMyt(DateTime instant, String locale)` and `String longDateTimeMyt(DateTime instant, String locale)`: the date as above plus the clock. en `h:mm a` lowercased (`11:59 pm`), zh and ms 24-hour `HH:mm` (`23:59`). The en separator in the long form stays `, `. zh joins with a space (`2026年12月16日 23:59`), ms with `, `.
  - `String releaseDateLabel(String isoDate, String locale)`: as `longDateMyt` but with no zone shift (calendar date)
  - `String groupedCount(int n, String locale)`: `NumberFormat.decimalPattern(locale)`
  - Removed from `format.dart`: `saleEndsMyt`, `percentOffLabel`, `itemsLabel`. Their text moves to ARB keys `saleEnds(dateTime)`, `percentOff(percent)`, `itemsCount(count)`, with the caller passing the formatted pieces.
  - `plainMoney`, `splitMinor`, `toMyt`, `todayMyt` unchanged.
- Produces, in `api_client.dart`:
  - `enum ApiWhat { list, highlights, ranking, genres, status, game }`
  - `enum ApiFailure { status, unreachable, badShape }`
  - `class ApiException implements Exception { final ApiWhat what; final ApiFailure failure; final int? status; }`
- Produces, in `error_view.dart`:
  - `String errorText(AppLocalizations l, Object error)`: an `ApiException` becomes `l.couldNotLoad(what.name)` + `' '` + one of `l.serverAnswered(status)` / `l.serverUnreachable` / `l.unexpectedAnswer`. Anything else becomes `l.somethingWentWrong`.
  - `ErrorView({required Object error, required VoidCallback onRetry})` (was `message: String`)
- ARB: `couldNotLoad` uses an ICU `select` over `list|highlights|ranking|genres|status|game|other`, so each language builds the whole first sentence itself. English values reproduce today's wording exactly ("Couldn't load the list.", "Couldn't load Highlights.", "The server answered 503.", "The Ringgit Radar server can't be reached.", "The answer was not in the expected shape.").

- [ ] **Step 1: Write the failing tests.** In `format_test.dart` replace the English-only date expectations with per-locale ones, and `setUpAll` initialises all three locales:

```dart
final end = DateTime.utc(2026, 12, 31, 15, 59); // 23:59 on 31 Dec in Malaysia
expect(shortDateMyt(end, 'en'), '31 Dec');
expect(shortDateMyt(end, 'zh'), '12月31日');
expect(shortDateMyt(end, 'ms'), '31 Dis');
expect(longDateTimeMyt(end, 'en'), '31 Dec 2026, 11:59 pm');
expect(longDateTimeMyt(end, 'zh'), '2026年12月31日 23:59');
expect(longDateTimeMyt(end, 'ms'), '31 Dis 2026, 23:59');
expect(releaseDateLabel('2027-03-08', 'zh'), '2027年3月8日');
expect(groupedCount(7827, 'ms'), '7,827');
```

`api_error_test.dart`: a `Dio` whose adapter throws a connection error makes `ApiClient().highlights()` throw `ApiException` with `what == ApiWhat.highlights` and `failure == ApiFailure.unreachable`. A 503 response gives `failure == ApiFailure.status, status == 503`. `errorText(lookupAppLocalizations(const Locale('en')), thatException)` equals `"Couldn't load Highlights. The Ringgit Radar server can't be reached."`.

- [ ] **Step 2: Run them to make sure they fail**

Run: `flutter test test/format_test.dart test/api_error_test.dart`
Expected: compile errors (the new signatures and `ApiWhat` don't exist).

- [ ] **Step 3: Implement** the interfaces and update every caller to pass `context.l10n.localeName` and use the new ARB keys. `GameListController` stores the caught error object and the list view passes it to `ErrorView(error: …)`. Update `price_text_test.dart` and `game_card_test.dart` to wrap their hosts with `localizationsDelegates`/`supportedLocales` and `locale: Locale('en')`.

- [ ] **Step 4: Run all tests**

Run: `flutter test && flutter analyze`
Expected: all pass, and the English UI text is byte-for-byte what it was.

- [ ] **Step 5: Commit** — `git commit -am "Format dates per language and keep API errors as values"` (add the new test file first).

---

### Task 3: Every remaining UI string into the ARB files, plus the Language row

**Files:**
- Modify: `lib/app/shell.dart`, `lib/app/router.dart`, `lib/core/game_x.dart`, `lib/core/widgets/game_card.dart`, `lib/core/widgets/price_text.dart`, `lib/features/**` (every file that still has a user-visible English literal, including `Semantics` labels, tooltips and the privacy and about prose)
- Create: `lib/l10n/genres.dart`
- Modify: `lib/l10n/app_en.arb` (+ the same keys copied into `app_zh.arb`, `app_ms.arb`)
- Modify: `test/privacy_page_test.dart`
- Test: `test/l10n_coverage_test.dart`, `test/language_switch_test.dart`

**Interfaces:**
- Consumes: Task 1 (`context.l10n`, `localeProvider`), Task 2 (formatters)
- Produces:
  - `String genreLabel(AppLocalizations l, String apiName)` in `lib/l10n/genres.dart`: a `switch` over the API genre names (fetch the current list from `https://ringgit-radar-nine.vercel.app/v1/genres` once when writing it; one ARB key per name, `genreAction` …). The default returns `apiName` unchanged. Filter values sent to the API stay `apiName`.
  - `game_x.dart`: `noPriceLabel(DateTime now, AppLocalizations l)`, `kindLabel(AppLocalizations l)`, `platformLabel` unchanged (`Switch 2` / `Switch` are product names)
  - ARB plurals: `showResults(count)` with `=0`/`=1`/`other`, `itemsCount(count)`, and any "N days" text.
  - New ARB keys `privacyEnglishPrevails` (empty string in `app_en.arb`, a sentence in zh/ms, rendered only when non-empty) and `languageHeading`, plus the four option labels. The option labels are written in their own language in every ARB: `English`, `简体中文`, `Bahasa Melayu`. Only "System" is translated.
  - The Language row sits in `about_page.dart` under its own `SectionHeading`, built like the Appearance chips with `OutlineChip`.

- [ ] **Step 1: Write the failing tests**

`l10n_coverage_test.dart`: walk `lib/` (skip `lib/l10n/` and `*.g.dart`/`*.freezed.dart`) and fail on any string literal inside `Text(`, `label:`, `tooltip:`, `semanticsLabel:`, `title:` or `Semantics(label:` that contains a letter. An allow-list holds `'Ringgit Radar'`, `'Switch 2'`, `'Switch'`, `'RM'` and URL or host strings. The test prints each offending `file:line`.

`language_switch_test.dart`: pump `AboutPage` in the full app shell with a fake `ApiClient` (returns a fixed `PriceStatus`). Tap the `简体中文` chip and expect `find.text(lookupAppLocalizations(const Locale('zh')).languageHeading)` to be found. Then tap `Bahasa Melayu` and expect the ms heading. The stored pref is `'ms'`.

`genreLabel`: `genreLabel(en, 'Action') == en.genreAction`, `genreLabel(zh, 'Visual Novel Deluxe') == 'Visual Novel Deluxe'`.

`privacy_page_test.dart`: pump with `locale: Locale('en')` and delegates. The existing must/mustNot lists stay as they are (English is the definitive version).

- [ ] **Step 2: Run them to make sure they fail**

Run: `flutter test test/l10n_coverage_test.dart test/language_switch_test.dart`
Expected: the coverage test lists the hard-coded literals. The switch test fails to find the chips.

- [ ] **Step 3: Move every listed literal** to `app_en.arb` with an `@key` description saying where it shows and roughly how much room it has (for example "chip on a game card, about 10 characters"). Add the Language row and `genres.dart`. Copy the new keys with English values into `app_zh.arb` and `app_ms.arb`.

- [ ] **Step 4: Run all tests**

Run: `flutter test && flutter analyze`
Expected: all pass. The coverage test reports nothing.

- [ ] **Step 5: Commit** — `git commit -m "Move all UI text into ARB files and add a Language setting"`

---

### Task 4: Chinese font for the web

**Files:**
- Create: `tool/subset_zh_font.sh`
- Create: `assets/fonts/<ChosenFont>-<Weight>.ttf` (subset), `assets/fonts/zh_chars.txt` (the characters the subset actually maps, written by the script from the font's cmap)
- Modify: `assets/fonts/README.txt` (font name, source URL, licence, how to regenerate), `assets/fonts/OFL.txt` (or add the chosen font's own licence file)
- Modify: `pubspec.yaml` (register the family, `RinggitZh`, with the weights you ship)
- Modify: `lib/app/theme.dart`, `lib/features/game/price_history_chart.dart`
- Test: `test/zh_font_test.dart`

**Interfaces:**
- Produces:
  - `ThemeData buildTheme(Brightness brightness, {String languageCode = 'en'})`. For `zh` every text style uses `fontFamily: 'RinggitZh'` with `fontFamilyFallback: ['MPlusRounded1c']`. For `en`/`ms` the font is `MPlusRounded1c` as now. `main.dart` passes the resolved language code. The explicit `fontFamily:` uses in `theme.dart`'s `s()` helper and in `price_history_chart.dart` follow the same rule (read it from the theme instead of the constant).
  - `tool/subset_zh_font.sh <dir with the full font files>`: collects every character in `lib/l10n/app_zh.arb` values plus ASCII, subsets with `pyftsubset --text-file … --layout-features='*' --no-hinting`, then writes `zh_chars.txt` from the output font's cmap (`python3 -c` with `fontTools.ttLib`).
- Pick an OFL Simplified Chinese font with a rounded look close to M PLUS Rounded 1c (for example Resource Han Rounded SC). Record the choice and the reason in `README.txt`.

- [ ] **Step 1: Write the failing test** `zh_font_test.dart`: (a) every non-ASCII character in the values of `lib/l10n/app_zh.arb` (ignore `@` keys and ICU syntax) appears in `assets/fonts/zh_chars.txt`, with any missing characters listed. (b) each `assets/fonts/RinggitZh*.ttf` (the shipped files) is under 300 KB. (c) `buildTheme(Brightness.light, languageCode: 'zh').textTheme.bodyMedium!.fontFamily == 'RinggitZh'` and `.fontFamilyFallback` contains `'MPlusRounded1c'`.

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/zh_font_test.dart`
Expected: FAIL: `zh_chars.txt` missing, and the theme has no `languageCode`.

- [ ] **Step 3: Implement** the script, the theme change and the pubspec entry. Run the script once against the downloaded full font. (Rerun it after Task 5 changes `app_zh.arb`.)

- [ ] **Step 4: Run all tests**

Run: `flutter test && flutter analyze`
Expected: all pass.

- [ ] **Step 5: Commit** — `git commit -m "Ship a subset Chinese font and use it first in Chinese"`

---

### Task 5: Glossary, translations and the blind back-translation

**Files:**
- Create: `l10n/glossary.md`
- Modify: `lib/l10n/app_zh.arb`, `lib/l10n/app_ms.arb`
- Create: `l10n/backtranslation-2026-11-21.md` (the record of step 3)
- Test: `test/arb_test.dart`

**Interfaces:**
- Consumes: the complete `app_en.arb` from Task 3, and `tool/subset_zh_font.sh` from Task 4

- [ ] **Step 1: Write the failing test** `arb_test.dart`, reading the three files as JSON:
  - The same non-`@` keys in all three files.
  - For each key, the same set of `{placeholder}` names, with the ICU `plural`/`select` cases present in every language (`other` is always present).
  - Every value in `app_zh.arb` and `app_ms.arb` differs from the English one, except the keys on an allow-list in the test: the language option labels, and any key whose English is only a placeholder or a product name.
  - Forbidden words, case-insensitive. **en:** `popular`, `best-selling`, `bestseller`, `best seller`, `top-selling`, `trending`, and `official` unless it's preceded by `un`. **zh:** `热门`, `最受欢迎`, `畅销`, `人气`, and `官方` unless it's preceded by `非`. **ms:** `popular`, `terlaris`, `paling laris`, `trending`, and `rasmi` unless it's preceded by `tidak `.
  - `Ringgit Radar` appears unchanged in any value whose English value contains it.

- [ ] **Step 2: Run it to make sure it fails**

Run: `flutter test test/arb_test.dart`
Expected: FAIL on "differs from English" for every zh/ms key.

- [ ] **Step 3: Write `l10n/glossary.md`.** One row per concept: sale, regular price, observed low / lowest price seen, price history, wish list, ranking, ringgit saved, highlights, sale ends, release date, coming soon, add-on, bundle, unofficial, retry. Each row has the zh term, the ms term, and one line on why (what the Malaysian Nintendo eShop or Malaysian shopping sites call it, and which alternative was rejected). Malay follows Malaysian usage (for example "Senarai Hajat", not an Indonesian form). Chinese uses Malaysian Simplified usage (`令吉` only where ringgit is a word in a sentence, never in a price).

- [ ] **Step 4: Translate** every key in `app_zh.arb` and `app_ms.arb` against the glossary and each `@key` description. Keep the length within the room the description gives.

- [ ] **Step 5: Blind back-translation.** Dispatch one fresh subagent per language. Give it only the zh (or ms) ARB values with their `@key` descriptions, and never the English. Ask for a plain English rendering of each value. Compare each with `app_en.arb` and record in `l10n/backtranslation-2026-11-21.md` every key where meaning drifted: an added claim, a lost qualifier (especially "observed", "we've seen", "since"), or a changed number, date or condition. Fix those keys and back-translate the fixed ones again with a fresh agent, until nothing drifts. The record lists key, back-translation, problem and fix.

- [ ] **Step 6: Regenerate the Chinese font subset** with `tool/subset_zh_font.sh` (Task 4).

- [ ] **Step 7: Run all tests**

Run: `flutter test && flutter analyze`
Expected: all pass, including `arb_test.dart` and `zh_font_test.dart`.

- [ ] **Step 8: Commit** — `git commit -m "Translate the app into Chinese and Malay"`

---

### Task 6: Fit check, final review, docs and PR

**Files:**
- Create: `test/support/fake_api.dart` (`class FakeApiClient extends ApiClient` returning fixed fixtures for every method, used through `apiClientProvider.overrideWithValue`)
- Create: `test/support/fixtures.dart` (a few games whose English titles are as long as the longest real ones, a game on sale ending 31 Dec at 23:59, a game with no price, a ranking, genres, a price history)
- Create: `test/fit_test.dart`
- Modify: `README.md` (repo root: a short "Languages" paragraph covering the ARB files, the glossary, regenerating the Chinese font after editing `app_zh.arb`, and that "Ringgit Radar" is never translated)

**Interfaces:**
- Consumes: everything above, and `FakeApiClient` (defined here)

- [ ] **Step 1: Write `fit_test.dart`.** For each locale in `['en', 'zh', 'ms']` × text scale `[1.0, 1.3]` × screen in Highlights, Sale, Ranking, the game page (the on-sale fixture), the filter sheet (open) and Settings (`AboutPage`): pump the app at a 390×844 logical phone size, settle, and `expect(t.takeException(), isNull)`, which catches RenderFlex overflow. One `testWidgets` per combination, named `'<screen> <locale> x<scale>'`.

- [ ] **Step 2: Run it**

Run: `flutter test test/fit_test.dart`
Expected: any overflow fails with the screen, locale and scale in the test name. Fix by shortening the translation (preferred, within the glossary) or by letting the widget wrap. Never shrink the font. Rerun until it passes.

- [ ] **Step 3: Look at the screens.** Build the web app (`flutter build web --wasm --no-web-resources-cdn --dart-define=API_BASE=https://ringgit-radar-nine.vercel.app --output <a scratch directory>` per the README; note that the live API answers same-origin only if CORS allows it, so otherwise run `cmd/api` locally with `WEB_DIR`). Take phone-width screenshots of the 6 screens in all 3 languages (18) and check each one: no empty boxes in Chinese, no clipped text, prices and dates read naturally, and the "unofficial" note is present. Note any fix, go back to Task 5's files for it, and rerun `flutter test`.

- [ ] **Step 4: Translation review.** Run the `translation-review` skill over `app_zh.arb` and `app_ms.arb` with the glossary as reference. Apply the findings that hold up, back-translate any changed key once more (Task 5 Step 5), regenerate the font subset if `app_zh.arb` changed, and rerun `flutter test`.

- [ ] **Step 5: Write the README paragraph and run the full check**

Run: `flutter analyze && flutter test` here, and `TEST_DATABASE_URL=postgres:///eshop_radar_test go test ./...` in `backend/` (unchanged, but CI runs it)
Expected: all pass.

- [ ] **Step 6: Commit, push and open the PR**

```bash
git add -A test README.md && git commit -m "Check every main screen fits in all three languages"
git push -u origin app-languages
gh pr create --title "The app in English, Chinese and Malay" --body "<summary, link to the spec and plan, the back-translation record, and the screenshot check result>"
gh pr merge <n> --auto --rebase --delete-branch
```

Expected: CI `go` and `flutter` jobs green, then auto-merge. Deploying the new web build to Vercel is a separate step that needs the owner's go-ahead.
