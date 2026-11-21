# Content Clean-up Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Ringgit Radar plainly its own, unofficial app that says truthfully where its data comes from, can honour removal requests, and no longer shows titledb age ratings, then release it as 1.0.2.

**Architecture:** One migration recreates the `catalog` view without ratings and without any nsuid listed in a new `removed_products` table, so every API query that reads the view inherits the removal. The Flutter app gains a label in the wordmark, a one-time notice shown over the router's navigator, a publisher line on descriptions, and a `/data-sources` page; all copy is in the three ARB files.

**Tech Stack:** Go 1.x + chi + sqlc (pgx/v5) + PostgreSQL; Flutter (Riverpod, go_router, freezed, gen-l10n, shared_preferences).

**Spec:** `docs/superpowers/specs/2026-11-22-content-cleanup-design.md`

## Global Constraints

- Contact address, never translated: `ringgitradar@snitco.com`. The owner's personal address appears nowhere.
- "Ringgit Radar" is never translated.
- No wording implies Nintendo approval, partnership or official status, in any language (`test/arb_test.dart` forbidden list applies).
- No removal turnaround time is promised anywhere.
- Visible text is at least 12px and meets WCAG AA contrast; label text on `brandRed` is white.
- No new dependencies (links and addresses are shown as `SelectableText`; there is no `url_launcher`).
- After any change to `lib/l10n/app_zh.arb`: `flutter gen-l10n` and `tool/subset_zh_font.sh /private/tmp/claude-501/-Users-chrischeng-orca-workspaces-eshop-radar-app-languages/241f16b6-aee7-492f-b4c0-def91349e85f/scratchpad/rhr/x` (else `test/zh_font_test.dart` fails). Same after `app_en.arb`/`app_ms.arb` changes for `gen-l10n`.
- After any change to `models.dart`: `dart run build_runner build --delete-conflicting-outputs`.
- After any change to `backend/db/queries/*.sql` or migrations: `sqlc generate` in `backend/`.
- Backend tests: `TEST_DATABASE_URL=postgres:///eshop_radar_test go test ./...` in `backend/`. App checks: `flutter analyze && flutter test` in `apps/flutter_app/`.
- Every new ARB key has an `@key` description saying where it shows and how much room it has, like the existing keys.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Never bare `git stash`. Never commit `.superpowers/` or `key.properties`.

## Review Focus

1. **CDN cache after a removal.** `/v1/games*`, highlights, ranking and genres are cached up to 10 min + 30 min stale; a removed product can linger about 40 minutes. Expected: README's removal section says so. (Task 1, README step.)
2. **A wish list holding a removed nsuid.** Expected: the Wish List shows the remaining games and no error or blank card. Pinned by `TestRemovedProductHiddenEverywhere` (ids query) in Task 1.
3. **Old links with `?age=12`.** Expected: ignored, list returned, not a 400. Pinned in Task 1.
4. **Notice on a deep link and with Android back.** Expected: notice shows over `/games/:id`; back dismisses the notice (not the page) and counts as seen. Pinned in Task 3.
5. **Wordmark label in the narrowest sidebar (840px, Malay "Tidak rasmi").** Expected: name not truncated, label on its own line inside the 64px bar. Pinned in Task 4.

---

### Task 1: Backend — drop age ratings, add the removed-products list

**Files:**
- Create: `backend/db/migrations/0004_removed_products.sql`
- Modify: `backend/db/queries/catalog.sql` (ListGames `ages` filter and header comment; StatusPrices `product_count`)
- Delete: `backend/db/queries/ratings.sql`, `backend/internal/db/ratings.sql.go`, `backend/internal/ratings/` (whole package), `backend/cmd/importratings/`
- Modify: `backend/sqlc.yaml` (remove the `catalog.age` override)
- Modify: `backend/internal/api/server.go` (gameJSON `Age`/`AgeDescriptors` fields at ~102-104, `toGame` at ~156-160, `age` parsing at ~314-323)
- Regenerate: `backend/internal/db/*.go`
- Modify: `backend/internal/api/api_test.go` (delete `rate`, `TestAgeFilterKeepsUnratedGamesListed`, `TestSexualDescriptorsDoNotFlagAGame`, the `Age`/`AgeDesc` fields in test structs; add the new test)
- Modify: `README.md` (delete line 22, the import command; add "Removing a product")

**Interfaces:**
- Produces: table `removed_products (nsuid text PRIMARY KEY, removed_at timestamptz NOT NULL DEFAULT now(), note text NOT NULL DEFAULT '')`, no foreign key. The `catalog` view has no `age`/`age_descriptors` columns and no rows for removed nsuids. API JSON for games and game detail has no `age` or `age_descriptors` keys. `/v1/status/prices` `product_count` excludes removed products.

- [ ] **Step 1: Write the failing test** in `backend/internal/api/api_test.go`

```go
func TestRemovedProductHiddenEverywhere(t *testing.T) {
	e := newEnv(t)
	today := time.Now().In(time.FixedZone("MYT", 8*3600)).Format("2006-01-02")
	// "1" (to be removed) and "3" (kept) are alike: on sale since yesterday, ending in 2 days, released
	// today, genre Action, each with the DLC "2" (also removed). Different publishers, so no cap applies.
	for _, g := range []struct{ id, pub string }{{"1", "A"}, {"3", "B"}} {
		s := onSale(10000, 5000, 2)
		s.nsuid, s.title, s.publisher = g.id, "Game "+g.id, g.pub
		s.raw = map[string]any{"genre": []string{"Action"}, "dsdate": today, "cnsuid": []string{"2"}}
		e.add(s)
	}
	e.add(game{nsuid: "2", title: "Game 2 DLC", publisher: "A", sctg: "aoc", regular: 500})
	if _, err := e.pool.Exec(context.Background(), `INSERT INTO removed_products (nsuid, note) VALUES ('1','test'),('2','test')`); err != nil {
		t.Fatal(err)
	}
	hidden := func(where string, ids []string) {
		t.Helper()
		for _, id := range ids {
			if id == "1" || id == "2" {
				t.Errorf("%s still shows removed product %s: %v", where, id, ids)
			}
		}
	}
	for _, path := range []string{"/v1/games", "/v1/games?sale=true", "/v1/games?q=game", "/v1/games?ids=1,2,3",
		"/v1/games?type=addon", "/v1/games?release=recent", "/v1/games?genre=Action", "/v1/games?age=12"} {
		var l listResp
		if code := e.get(path, &l); code != http.StatusOK { // ?age= from old links is ignored, not a 400
			t.Fatalf("%s = %d", path, code)
		}
		hidden(path, l.ids())
		if path == "/v1/games" && !has(l.ids(), "3") {
			t.Fatalf("the kept game is missing, so the test proves nothing: %v", l.ids())
		}
	}
	var rails map[string][]struct{ Nsuid string `json:"nsuid"` }
	e.get("/v1/highlights", &rails)
	for name, items := range rails {
		var ids []string
		for _, it := range items { ids = append(ids, it.Nsuid) }
		hidden("highlights "+name, ids)
	}
	var rank listResp
	e.get("/v1/ranking", &rank)
	hidden("ranking", rank.ids())
	var genres struct{ Items []struct{ Name string `json:"name"`; Count int `json:"count"` } `json:"items"` }
	e.get("/v1/genres", &genres)
	for _, g := range genres.Items {
		if g.Name == "Action" && g.Count != 1 { t.Errorf("Action counts %d games, want 1", g.Count) }
	}
	var st struct{ ProductCount int `json:"product_count"` }
	e.get("/v1/status/prices", &st)
	if st.ProductCount != 1 { t.Errorf("product_count = %d, want 1", st.ProductCount) }
	if code := e.get("/v1/games/1", nil); code != http.StatusNotFound { t.Errorf("removed game page = %d, want 404", code) }
	var d struct{ Addons []struct{ Nsuid string `json:"nsuid"` } `json:"addons"` }
	e.get("/v1/games/3", &d)
	if len(d.Addons) != 0 { t.Errorf("a removed DLC is still listed: %+v", d.Addons) }
}
```

If `/v1/highlights` also returns non-array keys, decode into `map[string]json.RawMessage` and unmarshal only the four rails `top_savings`, `ending_soon`, `new_sales`, `recent`.

- [ ] **Step 2: Run it to see it fail**

Run: `cd backend && TEST_DATABASE_URL=postgres:///eshop_radar_test go test ./internal/api -run TestRemovedProductHiddenEverywhere -v`
Expected: FAIL, `relation "removed_products" does not exist`.

- [ ] **Step 3: Write `0004_removed_products.sql`**

Create `removed_products` as above; `DROP VIEW catalog;` then `CREATE VIEW catalog` as in `0003_title_ratings.sql` with three changes: drop the `x.age`/`x.age_descriptors` output columns and the `tr.age`/`tr.descriptors` inner columns, drop the `LEFT JOIN title_ratings`, and add `WHERE NOT EXISTS (SELECT 1 FROM removed_products r WHERE r.nsuid = p.nsuid)` to the inner select. Then `DROP TABLE title_ratings;`. Start with a comment: removal hides a product everywhere the API reads `catalog`; the sweep still stores it; delete the row to undo.

- [ ] **Step 4: Update queries and code**

In `catalog.sql`: delete the `ages` line and "ages (PEGI)" / "A game with no rating..." from the ListGames comment; StatusPrices `product_count` becomes `(SELECT count(*) FROM products p WHERE NOT EXISTS (SELECT 1 FROM removed_products r WHERE r.nsuid = p.nsuid))`. Delete `ratings.sql`, `internal/ratings`, `cmd/importratings`, the `catalog.age` override in `sqlc.yaml`. Run `sqlc generate` (this deletes `ratings.sql.go`'s content; remove the file if it remains). In `server.go` remove the `Age`/`AgeDescriptors` fields and their comment, the `toGame` block, and the `age` parsing block (an `age` parameter is then simply unread). Delete the ratings tests and fields listed under Files.

- [ ] **Step 5: Run the backend suite**

Run: `cd backend && go vet ./... && TEST_DATABASE_URL=postgres:///eshop_radar_test go test ./...`
Expected: PASS, including `TestRemovedProductHiddenEverywhere`. `grep -rn 'title_ratings\|importratings\|AgeDescriptors' backend` prints only `0003_title_ratings.sql` and `0004`.

- [ ] **Step 6: README**

Delete the "Age ratings (one shot...)" line. Add a section "Removing a product" after the public-release section: when a rights holder asks, run in the Supabase SQL editor `INSERT INTO removed_products (nsuid, note) VALUES ('<nsuid>', 'request from <who> on <date>');`; undo with `DELETE FROM removed_products WHERE nsuid = '<nsuid>';`; the product disappears from every screen and the API at once, except that cached API answers can show it for up to about 40 minutes; the sweep keeps storing it. Also update the local setup line if it lists migrations by name (it globs, so likely no change).

- [ ] **Step 7: Commit**

```bash
git add -A backend README.md
git commit -m "Hide removed products everywhere and drop the titledb age ratings"
```

---

### Task 2: App — drop age ratings

**Files:**
- Modify: `apps/flutter_app/lib/core/api/models.dart` (remove `age`, `ageDescriptors` from `Game` ~40-41, `GameDetail` ~119-120, the copy at ~181-182; remove `ages` from `ListQuery` ~152); regenerate `models.freezed.dart`, `models.g.dart`
- Modify: `lib/core/api/api_client.dart:68`, `lib/features/lists/list_spec.dart:56`, `lib/features/lists/filter_sheet.dart` (`_ages`, the `'age'` row/case, `ageNote`), `lib/features/game/game_page.dart` (`_Details`: the rating `Text` and descriptors block after the heading, ~720-735)
- Modify: `lib/l10n/app_en.arb`, `app_zh.arb`, `app_ms.arb` (delete `ageRating`, `noAgeRating`, `filterAge`, `ageN`, `ageNote` and their `@` entries); regenerate localisations; rerun the zh font subset
- Modify: `apps/flutter_app/l10n/glossary.md` (delete the "Age rating (UK PEGI)" row)
- Modify: `test/api_models_test.dart:22`, `test/support/fixtures.dart:59-60`

**Interfaces:**
- Consumes: Task 1's API (no `age` keys).
- Produces: `ListQuery` without `ages`; `Game`/`GameDetail` without `age`/`ageDescriptors`.

- [ ] **Step 1: Write the failing test** in `test/api_models_test.dart` (replace the `ages` assertion)

```dart
test('a list request never sends an age filter', () {
  expect(api.params(const ListQuery(), showAll: false).containsKey('age'), isFalse);
});
```

and in `test/fit_test.dart`: in the `'Game page'` entry, after opening, `expect(find.textContaining('PEGI'), findsNothing);`; in the `'Filter sheet'` entry, after the sheet opens, `expect(find.textContaining(RegExp(r'\bAge\b|年龄|umur', caseSensitive: false)), findsNothing);`.

- [ ] **Step 2: Run to see it fail**

Run: `cd apps/flutter_app && flutter test test/fit_test.dart --plain-name "Game page en x1.0"`
Expected: FAIL (the PEGI line is shown; fixture has `age: 12`).

- [ ] **Step 3: Remove ratings** as listed under Files, regenerate freezed and l10n, rerun the font subset.

- [ ] **Step 4: Run the app checks**

Run: `flutter analyze && flutter test`
Expected: No issues; all tests pass. `grep -rn 'PEGI\|ageRating\|ageDescriptors\|ages' lib --include='*.dart' | grep -v 'l10n/app_localizations'` prints nothing relevant to ratings.

- [ ] **Step 5: Commit**

```bash
git add -A apps/flutter_app
git commit -m "Stop showing age ratings and drop the age filter"
```

---

### Task 3: First-launch notice

**Files:**
- Modify: `lib/core/storage/prefs.dart` (add key and notifier)
- Create: `lib/app/first_launch_notice.dart`
- Modify: `lib/main.dart` (`_RinggitRadarAppState`)
- Modify: ARB files (new keys below)
- Modify: tests that pump `RinggitRadarApp` with mock prefs (`fit_test.dart:55`, `locale_test.dart:43,56`, `language_switch_test.dart:37,70`, any in `wishlist_test.dart`/`game_card_test.dart` that pump the app): add `noticeSeenKey: true` to their initial values
- Test: `test/first_launch_notice_test.dart`

**Interfaces:**
- Produces: `const noticeSeenKey = 'notice_seen';` and `final noticeSeenProvider = NotifierProvider<NoticeSeenNotifier, bool>(...)` with `Future<void> markSeen()`, built like `ShowAllNotifier`. `Future<void> showFirstLaunchNotice(BuildContext navigatorContext, {required VoidCallback onDataSources})` in `first_launch_notice.dart`. ARB keys: `noticeTitle`, `noticeBody`, `noticeOk`, `dataSourcesTitle` (Task 6 reuses `dataSourcesTitle` as the page title and About chip).
- English copy (spec section 2): `noticeTitle` "An independent app"; `noticeBody` "Ringgit Radar is independent and unofficial. It is not affiliated with or endorsed by Nintendo. It keeps its own record of Malaysian eShop prices; to buy a game, use your Switch."; `noticeOk` "OK"; `dataSourcesTitle` "Where our data comes from". zh/ms drafts follow the glossary; Task 7 checks them.

- [ ] **Step 1: Write the failing tests** in `test/first_launch_notice_test.dart`, pumping `RinggitRadarApp` with `FakeApiClient` as `fit_test.dart` does:

```dart
testWidgets('a fresh install shows the notice once', ...) // prefs {} → find.text(en.noticeTitle) findsOneWidget; tap OK; prefs.getBool(noticeSeenKey) == true; pump a new app with the same prefs → findsNothing
testWidgets('an existing install sees it after updating and keeps its settings', ...) // prefs {wishlistKey: ['70010000000001'], themeKey: 'dark', showAllKey: true, localeKey: 'ms'} → notice shown in Malay; after OK those four values are unchanged
testWidgets('a deep link to a game shows the notice over the game page', ...) // t.platformDispatcher.defaultRouteNameTestValue = '/games/${fx.onSaleGame.nsuid}' before pumping (GoRouter starts there); addTearDown(t.platformDispatcher.clearDefaultRouteNameTestValue) → notice and the game title both present
testWidgets('back dismisses the notice, not the page, and counts as seen', ...) // tester.binding.handlePopRoute() → notice gone, game page still shown, notice_seen true
testWidgets('the data link closes the notice and opens /data-sources', ...) // tap en.dataSourcesTitle → notice gone, notice_seen true, router location /data-sources (Task 6 adds the page; until then assert the location only)
```

- [ ] **Step 2: Run to see them fail**

Run: `flutter test test/first_launch_notice_test.dart`
Expected: FAIL (`noticeSeenKey` undefined).

- [ ] **Step 3: Implement**

`NoticeSeenNotifier` in `prefs.dart`. `showFirstLaunchNotice` shows an `AlertDialog` (title, body, a text button `dataSourcesTitle` under the body, and `noticeOk`) with `showDialog(barrierDismissible: true)`. In `_RinggitRadarAppState.initState`, after the first frame, if `!ref.read(noticeSeenProvider)`: call `showFirstLaunchNotice(_router.routerDelegate.navigatorKey.currentContext!, onDataSources: () => _router.go('/data-sources'))`; it returns when the dialog closes by any means (OK, barrier, back, or the link, which pops the dialog and then calls `onDataSources`), and the caller then calls `markSeen()`. The dialog sits on the root navigator, so it shows over shell routes and `/games/:id` alike, and back pops the dialog first. Add the four keys to all three ARB files, gen-l10n, font subset. Add `noticeSeenKey: true` to the other app-pumping tests.

- [ ] **Step 4: Run the app checks**

Run: `flutter analyze && flutter test`
Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add -A apps/flutter_app
git commit -m "Say once, on first launch, that the app is independent and unofficial"
```

---

### Task 4: "Unofficial" label in the wordmark

**Files:**
- Modify: `lib/app/shell.dart` (`_Wordmark` ~60-73; header pill ~123-131; sidebar ~261-264)
- Modify: ARB files (`unofficialLabel`, `wordmarkSemantics`)
- Modify: `test/fit_test.dart`

**Interfaces:**
- Produces: `_Wordmark({double size = 18, bool stacked = false})`. ARB: `unofficialLabel` en "Unofficial", zh "非官方", ms "Tidak rasmi"; `wordmarkSemantics` en "Ringgit Radar, unofficial", zh "Ringgit Radar，非官方", ms "Ringgit Radar, tidak rasmi".

- [ ] **Step 1: Write the failing tests** in `test/fit_test.dart`

In every screen case (all three languages, both scales): `expect(find.text(l.unofficialLabel), findsOneWidget);` and `expect(find.bySemanticsLabel(l.wordmarkSemantics), findsOneWidget);` (enable semantics with `t.ensureSemantics()`), and the existing `t.takeException()` check covers overflow at 390px. Add a sidebar case at `Size(840, 900)` for each language and scale: the label is found, `tester.getRect(find.text('Ringgit Radar'))` and the label's rect both lie inside the 64px red bar, the label's top is below the name's bottom, and the name's `RenderParagraph.didExceedMaxLines` is false.

- [ ] **Step 2: Run to see them fail**

Run: `flutter test test/fit_test.dart`
Expected: FAIL (`unofficialLabel` undefined).

- [ ] **Step 3: Implement**

`_Wordmark` wraps its content in `Semantics(label: l.wordmarkSemantics, excludeSemantics: true, ...)`. Unstacked (phone pill): the label follows the name in the row. Stacked (sidebar): the label is a second line under the name, left-aligned with the name's text. Label style: white, `fontSize: 12` minimum, `FontWeight.w500`, either plain or inside a thin white outline chip; exact styling within DESIGN.md. The sidebar passes `stacked: true`. Keep the pill height 44 and the bar 64.

- [ ] **Step 4: Run the app checks** — `flutter analyze && flutter test`, all pass.

- [ ] **Step 5: Commit** — `git commit -am "Label the wordmark unofficial on every screen"` (after `git add` of the ARB and generated files).

---

### Task 5: Publisher label on descriptions

**Files:**
- Modify: `lib/features/game/game_page.dart` (`_Description`, ~562-600)
- Modify: ARB files (`descriptionSource`: en "From the publisher's store listing"; zh/ms drafts)
- Test: `test/fit_test.dart` 'Game page' case

- [ ] **Step 1: Failing test** — in the 'Game page' case: `expect(find.text(l.descriptionSource), findsOneWidget);` and the label's rendered font size ≥ 12: `expect(t.renderObject<RenderParagraph>(find.text(l.descriptionSource)).text.style!.fontSize, greaterThanOrEqualTo(12));`.
- [ ] **Step 2: Run** `flutter test test/fit_test.dart --plain-name "Game page"` — Expected: FAIL.
- [ ] **Step 3: Implement** — one `Text(l.descriptionSource)` under the heading, before the tagline: `fontSize: 13`, `color: tk.hint` (check `tk.hint` on the page background meets 4.5:1 in light and dark; if not, use `tk.text` at reduced weight). ARB keys, gen-l10n, font subset.
- [ ] **Step 4: Run** `flutter analyze && flutter test` — all pass.
- [ ] **Step 5: Commit** — "Mark game descriptions as the publisher's text".

---

### Task 6: "Where our data comes from" page, privacy contact line, store-listing rulebook

**Files:**
- Create: `lib/features/settings/data_sources_page.dart`
- Modify: `lib/app/router.dart:31-32` (add `/data-sources` inside the shell, like `/privacy`)
- Modify: `lib/features/settings/about_page.dart:42` (a `Wrap` of two `OutlineChip`s: Privacy, then `dataSourcesTitle` → `context.go('/data-sources')`)
- Modify: `lib/features/settings/privacy_page.dart` (`sections`: Not Nintendo body takes the email)
- Modify: ARB files
- Modify: `test/privacy_page_test.dart`
- Create: `test/data_sources_page_test.dart`
- Create: `docs/store-listing.md`

**Interfaces:**
- Consumes: `dataSourcesTitle` (Task 3).
- Produces: `const contactEmail = 'ringgitradar@snitco.com';` and `const sourceCodeUrl = 'https://github.com/chengboonrong/ringgit-radar';` in `data_sources_page.dart`; `class DataSourcesPage` with `static List<(String, String)> sections(AppLocalizations l)` like `PrivacyPage.sections`.
- ARB keys and English copy (each body must stay true of the code):
  - `dataFromTitle` "Where from" / `dataFromBody` "Collected from the Malaysian Nintendo eShop once a day. Our own price history starts on 1 November 2026."
  - `dataKeptTitle` "What we keep" / `dataKeptBody` "Each game's catalogue entry as the eShop publishes it (title, publisher, release date, genres, description and picture addresses), and every price and sale we record. The app shows only the first part of each description."
  - `dataNotKeptTitle` "What we don't keep" / `dataNotKeptBody` "Copies of pictures: they load from Nintendo's image server. We sell nothing and there is no Buy button; games are bought on the Switch."
  - `dataRightsTitle` "Rights holders" / `dataRightsBody(email)` "If you own content shown here and want it removed or corrected, email {email} and we will remove it from Ringgit Radar."
  - `dataSourceCodeTitle` "Source code" / `dataSourceCodeBody` "The app and its server are open source:" followed on the page by `SelectableText(sourceCodeUrl)`.
  - `privacyNotNintendoBody` gains an `{email}` placeholder and two sentences at the end: "To ask for content to be removed or corrected, email {email}. Emails to that address are forwarded by Cloudflare to our Google mail inbox."

- [ ] **Step 1: Failing tests**

`test/data_sources_page_test.dart` (pattern of `privacy_page_test.dart`, en): the page contains "Malaysian Nintendo eShop", "1 November 2026", "full" is absent but "only the first part" present, "Nintendo's image server", `contactEmail`, `sourceCodeUrl`; no text contains "within", "days", "hours" (no turnaround promise) or "official" without "un". A second test pumps the app (with `noticeSeenKey: true`), opens `/about`, taps the `dataSourcesTitle` chip and finds the page title. Add a fit case `'Data sources': (t, l) async => go(t, '/data-sources')` to `fit_test.dart`.

`test/privacy_page_test.dart`: add `contactEmail` and 'forwarded by Cloudflare' to the must list; keep 'Cloudflare' and 'Google' forbidden on every text except the Not Nintendo body:

```dart
final notNintendo = l.privacyNotNintendoBody(contactEmail);
final rest = all.replaceAll(notNintendo, '');
for (final mustNot in ['private', 'personal', 'we never', 'anonymous', 'cloudflare', 'gstatic', 'google']) {
  expect(rest.toLowerCase(), isNot(contains(mustNot)), reason: mustNot);
}
for (final mustNot in ['private', 'personal', 'we never', 'anonymous', 'gstatic']) {
  expect(notNintendo.toLowerCase(), isNot(contains(mustNot)), reason: mustNot);
}
```

- [ ] **Step 2: Run** `flutter test test/data_sources_page_test.dart test/privacy_page_test.dart` — Expected: FAIL.
- [ ] **Step 3: Implement** the page (same layout as `PrivacyPage`: `PageTitle(l.dataSourcesTitle)`, titled blocks, the address and URL as `SelectableText`, a "Back to About" chip), the route, the About chips, the privacy change, the ARB keys (three languages), gen-l10n, font subset.
- [ ] **Step 4: Write `docs/store-listing.md`** with the rules in spec section 7, verbatim in substance: name, subtitle (draft "Game prices in ringgit"), keywords, long description rule, screenshots rule, URLs and contact, and the App Review 5.2.2 reply template (what we show, where from, pictures hot-linked from Nintendo's image server, contact address, the removed-products list that hides a product everywhere at once).
- [ ] **Step 5: Run** `flutter analyze && flutter test` — all pass.
- [ ] **Step 6: Commit** — "Add a page on where the data comes from, with a removal contact".

---

### Task 7: Translation self-check

**Files:**
- Modify: `apps/flutter_app/l10n/glossary.md` (rows: Unofficial 非官方 / tidak rasmi; publisher's store listing; rights holder; independent app; Where our data comes from)
- Create: `apps/flutter_app/l10n/backtranslation-2026-11-22.md`
- Modify: zh/ms ARB values if the round finds problems

**Interfaces:**
- Consumes: every key added in Tasks 3-6: `noticeTitle`, `noticeBody`, `noticeOk`, `dataSourcesTitle`, `unofficialLabel`, `wordmarkSemantics`, `descriptionSource`, `dataFromTitle`, `dataFromBody`, `dataKeptTitle`, `dataKeptBody`, `dataNotKeptTitle`, `dataNotKeptBody`, `dataRightsTitle`, `dataRightsBody`, `dataSourceCodeTitle`, `dataSourceCodeBody`, `privacyNotNintendoBody`.

- [ ] **Step 1:** Add the glossary rows with the reasoning column filled, as the existing rows do.
- [ ] **Step 2:** Back-translate: dispatch two fresh agents (one zh, one ms) that see only the translated values and the key descriptions, never the English, and ask each for an English back-translation. Compare with the English; any meaning drift (especially anything that reads as official, a promise, or "we don't store descriptions") is a fix. Record keys, back-translations, verdicts and fixes in `backtranslation-2026-11-22.md`, in the format of `backtranslation-2026-11-21.md`.
- [ ] **Step 3:** After fixes: gen-l10n, font subset, `flutter analyze && flutter test`. Expected: all pass, including `arb_test`, `l10n_coverage_test`, `fit_test`, `zh_font_test`.
- [ ] **Step 4:** Screenshots: run the web build locally against the fake or live API and capture, at 390px in en/zh/ms, the notice, the Highlights header (label), a game page (publisher line, no rating), the filter sheet (no age section), `/data-sources`, and `/privacy`; and the sidebar at 840px. Check each by eye; save them under the plan workspace, not in git.
- [ ] **Step 5: Commit** — "Check the new text in Chinese and Malay".

---

### Task 8: Release 1.0.2

Stops for the owner where marked. Everything else runs without asking.

**Files:**
- Modify: `apps/flutter_app/pubspec.yaml:19` → `version: 1.0.2+3`

- [ ] **Step 1:** Bump the version; `flutter test` passes; commit "Release 1.0.2". Push the branch, open a PR, queue it with `gh pr merge <n> --auto --rebase --delete-branch`.
- [ ] **Step 2: Deploy the API and web first.** (Ruling against the spec's "migration first": the new code reads only columns the old view also has, so it runs on either view, while the live old code breaks on the new view. Deploying first means no downtime.) From the repo root: `cd apps/flutter_app && flutter build web --wasm --no-web-resources-cdn --dart-define=API_BASE= --output ../../backend/public`.
- [ ] **Step 3: Build the APK.** Copy `/Users/chrischeng/eshop-radar/apps/flutter_app/android/key.properties` into this worktree's `apps/flutter_app/android/`, run `flutter build apk --release --dart-define=API_BASE=https://ringgit-radar-mu.vercel.app`, delete the copied `key.properties` straight after. Check `apksigner verify --print-certs` (or `keytool -printcert -jarfile`) shows SHA-256 starting `258177d4` and ending `387e94`. Copy the APK to `backend/public/ringgit-radar.apk`.
- [ ] **Step 4:** `cd backend && npx vercel deploy --prod --yes`. Expected: production URL aliased to https://ringgit-radar-mu.vercel.app; `/healthz` 200; `/v1/games?limit=1` 200 with no `age` key.
- [ ] **Step 5 (owner):** Ask the owner to run `0004_removed_products.sql` in the Supabase SQL editor, wrapped in `BEGIN;` … `COMMIT;`. After: `/v1/games?limit=1` still 200 and `/v1/status/prices` 200.
- [ ] **Step 6: Live check.** In en, zh and ms at phone width: label, notice once, publisher line, no rating, no age filter, `/data-sources`, privacy line, APK download is 1.0.2. Test removal: ask the owner to insert one test nsuid (a low-interest DLC), confirm its game page 404s (bypass the CDN with a fresh query string), then delete the row.
- [ ] **Step 7 (owner):** Remind the owner to turn on Cloudflare Email Routing for `ringgitradar@snitco.com` and send a test email; the release is not done until it arrives.
