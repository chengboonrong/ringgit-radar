# Content clean-up before the store apps

Date: 2026-11-22. Status: design, awaiting owner approval.

## Why

The owner wants Ringgit Radar on the App Store and Google Play as native apps. The biggest review risk is not the code but the content: the app shows Nintendo data, art and text with no licence, and it deliberately looks like the Switch 2 eShop. Apple's guideline 5.2.2 says an app that shows a third-party service's content must be permitted to and may be asked to prove it; 4.1 and 5.2.1 cover imitation and trademarks; Google Play's intellectual-property policy is the same in substance. Comparable trackers (NT Deals, eShopDeal, 遊戲箱子) are on the stores, so the risk is manageable, but only if the app is plainly its own, says truthfully where its data comes from, and gives rights holders a way to have content removed that actually works. This work comes first because it helps both stores and is cheap; the landing page, a Google Play account, price-drop alerts and the iOS build follow (see "Order of the wider work").

## What already holds (no change)

- The app shows descriptions as a quote, not a republication: `excerpt()` in `backend/internal/api/server.go` sends the first paragraph, cut to about 280 characters. (The database keeps the full catalogue entry; section 4 says so.)
- Pictures are not copied: art and screenshots load from `img-eshop.cdn.nintendo.net`; the server keeps none (`/v1/img/<hash>` only redirects). The privacy page says so.
- The name avoids Nintendo's trademarks. "Independent and unofficial. Not affiliated with or endorsed by Nintendo." already appears on the About screen, the privacy page and `android.html`.

## Goals

1. An "Unofficial" label beside the Ringgit Radar wordmark wherever the wordmark is drawn.
2. A one-time notice on first launch saying the app is independent and unofficial.
3. Game descriptions labelled as the publisher's text.
4. A new in-app page, "Where our data comes from", that states truthfully what is stored, with a public contact address for rights holders.
5. A removed-products list, so a removal request can be honoured everywhere the app shows a product.
6. Age ratings dropped, so the app no longer shows data taken from a third-party dataset (titledb).
7. A store-listing rulebook for the later App Store and Play listings.
8. All new text in English, Simplified Chinese and Malay, passing the same self-check as the languages project.
9. Released: web redeployed and a signed APK 1.0.2 published.

## Non-goals

- No redesign away from the eShop layout and behaviour (PRODUCT.md's brand commitment stands).
- No change to how often data is collected, to the collector, or to the description excerpt length. The daily sweep may keep storing removed products; removal hides them (section 5).
- No proxying or caching of Nintendo images.
- No admin screen for removals; a row is added by SQL (section 5).
- No store submission, developer accounts, alerts or iOS build here.
- The landing page is a separate design (paused, to resume after this).

## Anti-goals (failure even if it works)

- Any wording that implies Nintendo approval, partnership or official status, in any language.
- A promise the owner cannot keep, such as a fixed removal turnaround time, or "we don't store X" when the database does.
- A removed product still reachable anywhere in the app or API (a list, search, a highlight, the ranking, the wish list, a DLC list, its game page, or a count).
- Hiding the notice or label so it is technically present but easy to miss (for example, hint-grey text under 12px).
- The owner's personal email address appearing anywhere public.

## Approaches considered

**How far the app keeps looking like the eShop** (owner asked for Claude's pick, B):
- A. Keep everything; rely on existing notices and careful listing wording. Free, but leaves the imitation risk untouched.
- B. **Chosen.** Keep layout and behaviour; make the app's own identity obvious (label, first-launch notice, captioned store screenshots). Users still feel at home; a reviewer cannot mistake it for Nintendo's.
- C. Redesign to look clearly different. Safest for review, but reverses the owner's brand commitment and costs a large rework.

**Contact for rights holders** (owner asked for Claude's pick, A):
- A. **Chosen.** `ringgitradar@snitco.com`, forwarded to the owner's inbox by Cloudflare Email Routing (free). Keeps the personal address private; can be redirected or turned off later.
- B. An existing personal address. Nothing to set up, but it becomes public for good.
- C. GitHub issues only. No email, but both stores expect a support contact and rights holders rarely file issues.

**How a removal is honoured** (owner asked for Claude's pick, A):
- A. **Chosen.** A `removed_products` table that the API checks everywhere. One SQL insert removes a product from every screen on every platform at once, with no app release, and survives the daily sweep.
- B. Delete the product's rows. The next sweep puts them straight back, and the schema promises products are never deleted.
- C. Promise only to "look into" requests. Nothing to build, but a reviewer or rights holder reads it as no removal at all.

**Age ratings** (owner asked for Claude's pick, drop):
- Drop. Ratings come from the community titledb dataset matched by title, which is a second unlicensed source, a UK rating shown in Malaysia, and a match that can be wrong. Keeping them means naming titledb on the data page and defending it at review. Dropping costs one filter section and one line on the game page.
- Keep and name titledb. More honest than today, but adds review surface for little user value.

**Where the data-sources page lives** (Claude's call): in the app, as a Settings page beside Privacy, built like `privacy_page.dart`. Reviewers see the app, not the website; the app is already in three languages; on the web it is reachable by URL. The landing page will link to it later.

## Design

### 1. "Unofficial" label

- `_Wordmark` in `apps/flutter_app/lib/app/shell.dart` is drawn in two places: the phone header pill and the wide-screen sidebar. Both get the label.
- Phone header: the label sits after "Ringgit Radar" inside the red pill. Wide sidebar (840 to 1400px, where the sidebar is narrow): the label sits on its own line under the wordmark, so it never truncates the name. White text, smaller than the wordmark but at least 12px, in a lighter weight or a thin white outline chip. Exact styling is the builder's, within DESIGN.md and WCAG AA contrast on `brandRed`.
- Text: en "Unofficial", zh 非官方, ms "Tidak rasmi" (final wording through the glossary and back-translation).
- The wordmark's semantics label becomes "Ringgit Radar, unofficial" in each language so screen readers say it too.
- The game page (`/games/:id`) has no wordmark today; it stays that way (Claude's call: it is reached from screens that carry the label, and the first-launch notice covers direct links).
- Fit: the label must not push the avatar or wrap at 390px, text scale 1.0 and 1.3, in all three languages, nor truncate the name in the sidebar at 840px. Extend `test/fit_test.dart` to assert it.

### 2. First-launch notice

- Shown once, on every platform (web, Android, later iOS and macOS), the first time the app opens after this change, including for existing users.
- A modal sheet or dialog over the first screen. Content, en draft: title "An independent app"; body "Ringgit Radar is independent and unofficial. It is not affiliated with or endorsed by Nintendo. It keeps its own record of Malaysian eShop prices; to buy a game, use your Switch."; one button "OK". A link to "Where our data comes from" under the body.
- Dismissing (button, tap outside or back) counts as seen. Store a boolean under a new prefs key `notice_seen` in `core/storage/prefs.dart`, the same way `theme_mode` is stored. Never shown again on that device.
- Must not block deep links: if the first launch opens `/games/:id`, the notice shows over that page.
- Existing installs: tested by a widget test that starts from prefs holding only the old keys (`wishlist`, `theme_mode`, `show_all`, `locale`) and expects the notice, keeping those values intact.

### 3. Description label

- In `_Description` (`features/game/game_page.dart`), under the "Description" heading, one hint-style line: en "From the publisher's store listing". Hint style must still meet the 12px floor and AA contrast.

### 4. "Where our data comes from" page

- New route `/data-sources` inside the shell, page `features/settings/data_sources_page.dart`, linked from About with an `OutlineChip` next to the Privacy chip.
- Content in short titled blocks, same pattern as the privacy page. Every sentence must be true of the code and database as shipped:
  - **Where from.** Collected from the Malaysian Nintendo eShop once a day. Our own price history starts on 1 November 2026.
  - **What we keep.** Each game's catalogue entry as the eShop publishes it (title, publisher, release date, genres, description, picture addresses), and every price and sale we record. The app shows only the first part of each description.
  - **What we don't keep.** Copies of pictures: they load from Nintendo's image server. We sell nothing and there is no Buy button; games are bought on the Switch.
  - **Rights holders.** "If you own content shown here and want it removed or corrected, email ringgitradar@snitco.com and we will remove it from Ringgit Radar." No turnaround promise.
  - **Source code.** Link to https://github.com/chengboonrong/ringgit-radar.
- The privacy page's "Not Nintendo" block gains the same contact line, and one sentence that is true of the routing: emails to that address are forwarded by Cloudflare to our Google mail inbox. `test/privacy_page_test.dart` forbids the words "Cloudflare" and "Google"; the test changes to allow them in that sentence only (or the forbidden list moves those two words to a check that they appear only there). The builder picks which, keeping the test's purpose of catching untrue claims.
- The address is a constant (like the app name), not translated.

### 5. Removed-products list

- New migration `backend/db/migrations/0004_removed_products.sql`: table `removed_products (nsuid text PRIMARY KEY, removed_at timestamptz NOT NULL DEFAULT now(), note text NOT NULL DEFAULT '')`. No foreign key to `products`, so a row can be added for an nsuid before or after the sweep sees it.
- The `catalog` view (or every query that reads products for the app) excludes nsuids in `removed_products`. Doing it once in the view is preferred, so new queries inherit it; any query that reads `products` or `prices` directly also excludes them. Covered: list pages and filters, search, highlights, ranking, recent, coming soon, wish-list ids, DLC of a game, the stats count, and `/v1/games/<id>` (404, the same as an unknown id).
- The collector is unchanged; it may keep collecting a removed product. Removal is reversible by deleting the row.
- README gains a short "Removing a product" section: the SQL to run in the Supabase SQL editor (`INSERT INTO removed_products (nsuid, note) VALUES ('…', 'request from … on …');`) and how to undo it.
- Go test: a removed product is absent from each covered endpoint and its game page returns 404.

### 6. Dropping age ratings

- Remove the rating from the API response, the `catalog` view, the `age` filter parameter in the list endpoint and `catalog.sql`, `backend/db/queries/ratings.sql` and its generated code, `backend/internal/ratings`, and `backend/cmd/importratings`.
- Migration `0004` (the same file as section 5, or `0005`; the builder's choice) recreates the `catalog` view without the rating and drops `title_ratings`.
- App: remove the rating line on the game page, the age section of the filter sheet, `ages` from `ListQuery` and the API client, the rating fields from the models (regenerate freezed), and the ARB keys for the rating line and the age filter in all three languages (regenerate localisations).
- Docs: remove the README's import line and the ratings mentions in `l10n/glossary.md`; leave dated research and back-translation records as they are.
- Old links with `?age=` are ignored, not an error.

### 7. Store-listing rulebook

New `docs/store-listing.md`, written in English, for the later store work:
- Name: "Ringgit Radar" in every language.
- Subtitle / short description: no "Nintendo", "Switch", "eShop" or "Joy-Con"; draft en "Game prices in ringgit".
- Keywords: no Nintendo trademarks.
- Long description: may name "Nintendo Switch" at most once to say what the prices are for, always next to the unofficial sentence.
- Screenshots: our own caption on each; no game art filling the frame; no Nintendo logos.
- Support URL, marketing URL (landing page once live) and privacy URL; contact ringgitradar@snitco.com.
- A short reply template for App Review if 5.2.2 authorisation is requested: what we show, where from, that pictures are hot-linked, the removal contact and the removed-products list.

### 8. Translations

All new strings go in the ARB files and pass the languages project's self-check: glossary entries (Unofficial, publisher's store listing, rights holder), blind back-translation by fresh agents with the round recorded, `arb_test`, `l10n_coverage_test`, fit tests, and screenshots of the changed screens in all three languages.

### 9. Release

- Bump the app to 1.0.2+3.
- Run the migration on Supabase before deploying the API (the new code reads `removed_products`).
- Redeploy web and API to https://ringgit-radar-mu.vercel.app: build web into `backend/public` as before, copy the new APK in, `npx vercel deploy --prod --yes` from `backend/`.
- Rebuild the APK with the existing upload key: copy `key.properties` from the main checkout for the build and delete it afterwards; confirm the signing certificate's SHA-256 is still `258177d4…387e94`.
- Check the live site in three languages: label, notice, data page, no rating line, and a test removal (add a row, see the product gone, delete the row).

## Owner actions (outside the code)

- Turn on Cloudflare Email Routing for snitco.com and route `ringgitradar@snitco.com` to the owner's inbox (or give Claude access to do it). Send a test email before release.
- Approve running migration 0004 on the live Supabase database (Claude runs it with the stored DATABASE_URL, never printing it).

## Acceptance

- The label shows in both wordmark places in all three languages, fits at 390px and 1.3 text scale, does not truncate the name at 840px, and is read by screen readers.
- A fresh install, and an existing install after updating, shows the notice once; it never shows again after dismissal.
- Every game description carries the publisher label.
- `/data-sources` exists, is linked from About, shows the contact address, and every statement on it matches the code; the privacy page shows the address and the forwarding sentence.
- A product in `removed_products` is absent from every covered endpoint and screen, and its game page is a 404.
- No age rating appears anywhere in the app or API; `title_ratings`, `cmd/importratings` and `internal/ratings` are gone.
- `docs/store-listing.md` exists with the rules above.
- `flutter analyze` clean, all Flutter and Go tests pass, translation self-check passes.
- Live site and APK 1.0.2 released, APK signed with the same key.
- A test email to ringgitradar@snitco.com arrives in the owner's inbox.

## Left to the builder

- Exact visual styling of the label and the notice within DESIGN.md.
- Final wording of drafts after the translation self-check, keeping their meaning.
- One migration or two for sections 5 and 6.
- How the privacy test allows the forwarding sentence.
- Test structure.

## Order of the wider work (for reference, not built here)

1. This clean-up. 2. The landing page (supplies the support and marketing URLs). 3. Start a separate Google Play developer account and its 12-tester, 14-day closed test early; enrol with the existing upload key so APK users can update through Play. 4. Wish-list price-drop alerts (needs its own design; changes the privacy page). 5. iOS build and both submissions.
