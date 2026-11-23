# Landing page at ringgitradar.snitco.com

Project 2 of the roadmap in `2026-11-21-app-languages-design.md`. Agreed with the owner on 2026-11-22 and 2026-11-23, paused in between for the content clean-up (`2026-11-22-content-cleanup-design.md`).

## Why

The owner wants people who buy Switch games in Malaysia to find Ringgit Radar, understand what it does, trust it enough to try it, and open it or install it. The owner's five purposes, applied to this app:

1. **Discoverability.** Google, AI search and shared links find it, in English, Chinese and Malay.
2. **Value proposition.** It answers "is this a good price, or should I wait?" in ringgit: today's price, the lowest Ringgit Radar has seen, and when the sale ends.
3. **Credibility.** Real screenshots, true numbers, a plain unofficial statement, the open-source repository, the privacy and data pages.
4. **Conversion.** One tap opens the app; Android visitors download the APK; iPhone visitors add it to the home screen.
5. **Distribution.** The one address to share, and the honest list of where the app runs.

The audience is mostly on phones. The page is also the support and marketing address that `docs/store-listing.md` gives the App Store and Google Play listings, so App Review will read it.

## Goals

- `ringgitradar.snitco.com` shows the landing page; the web app moves to `ringgitradar.snitco.com/app/`.
- The page exists in English (`/`), Simplified Chinese (`/zh/`) and Malay (`/ms/`), each a real page with its own text, title, description and link-preview picture.
- The Android download page exists in the same three languages.
- Everything people already saved keeps working: old links to the web app, the APK download, and the Android app already installed, which talks to `ringgit-radar-mu.vercel.app`.

## Non-goals

- No store apps in this project, and no App Store or Google Play buttons until those apps exist.
- No change to the API, the database, the collector or the Android app.
- No new hosting, accounts or costs: the same Vercel project serves both addresses.
- The Android app keeps talking to the old address; moving it to the new one is a later app release.

## Anti-goals (failure even if it works)

- Anything that suggests the app is Nintendo's, or official: no Nintendo logos, fonts or screenshots of Nintendo's own screens, and no "official", "authorised" or "partner".
- Invented numbers or praise: no user counts, ratings, testimonials, "popular" or "best-selling" (`PRODUCT.md`). Every number on the page comes from the live data at build time.
- Promising what might not happen: store apps are "planned", never "coming soon".
- Visitor tracking or third-party requests that would make the privacy page untrue.
- A page that is slow on a phone, or that jumps to another language on its own.
- Returning visitors stuck on the old app because their browser kept an offline copy of it.

## Constraints found in the project

- **Hosting.** One Vercel project (account edger9chris, Hobby, region `sin1`) deploys `backend/` from this machine: `backend/public` is the static site and `api/index.go` serves `/v1/*` and `/healthz`. `backend/vercel.json` rewrites every other path to `/index.html`, the app. Hobby allows no ads or commercial use.
- **Build output.** `flutter build web --output ../../backend/public` empties `backend/public`. The APK is copied in afterwards (`/ringgit-radar.apk`).
- **App routing.** The app uses path URLs (`usePathUrlStrategy`); `web/index.html` already takes `$FLUTTER_BASE_HREF`, so `flutter build web --base-href /app/` serves it from `/app/`.
- **Language storage.** On the web the app stores its language in `localStorage` under `flutter.locale` as a JSON string (`"en"`, `"zh"`, `"ms"`); the landing page is on the same address, so it can set it.
- **Offline copy.** The current build ships Flutter's caching service worker at `/flutter_service_worker.js`, which caches `/` and the app's files. Browsers that visited `ringgit-radar-mu.vercel.app` hold it.
- **The old address must keep answering** `/v1/*`, `/healthz` and `/ringgit-radar.apk`: the installed Android app 1.0.2 reads prices from `https://ringgit-radar-mu.vercel.app`.
- **Fonts.** The app ships M PLUS Rounded 1c (Latin, 3 weights) and `RinggitZh`, a Chinese font subset to the characters the app uses (`assets/fonts/zh_chars.txt`, rebuilt by `tool/subset_zh_font.sh`). The web app blocks Google's font server on purpose; the landing page loads nothing from other sites either.
- **Domain.** `snitco.com` is on Cloudflare (DNS and email). `ringgitradar.snitco.com` has no record yet; the owner adds one record in Cloudflare.
- **Honesty and naming rules** in `PRODUCT.md` and `docs/store-listing.md` apply to every line, in every language.
- `PRODUCT.md` and `DESIGN.md` are not in this repository (they live, excluded, in the owner's main checkout), so the build and tests must not read them; the banned-word list is written out in this document.
- `PRODUCT.md` (2026-11-02) says no Google Play listing; the owner has since decided to aim for both stores (2026-11-22), so "Google Play: planned" is the owner's current position.

## Approaches

1. **Plain static pages from one shared template (chosen).** One HTML template and one text file per language; a small Go program run before deploy fills in the template and writes the pages into `backend/public`. Fast on phones, real text for search engines and link previews, no new toolchain, and a test can check every language has every line and no banned word.
2. **A static-site framework with built-in translation (Astro or Eleventy).** Ready-made language handling, but it brings npm and its dependencies into a Go and Flutter repository for three pages, and one more thing to keep updated.
3. **The landing page in Flutter, like the app.** Reuses the app's code, but a Flutter page is several MB before anything shows, and search engines and link previews see little real text. It works against discoverability and phone speed.

The owner picked 1 on 2026-11-22.

## What the owner decided

**Addresses.**
- `/`, `/zh/`, `/ms/`: the landing page.
- `/app/`: the web app, with all its routes under it (`/app/games/<id>`, `/app/data-sources`, …).
- The Android download page in three languages (owner agreed it should be translated).
- `ringgit-radar-mu.vercel.app` forwards to the new address once the new address works, except what the Android app needs (below).

**Layout A: classic app page,** top to bottom:

```
◎ Ringgit Radar                  EN · 中文 · BM
Is that Switch game a good price? Check in ringgit.
One-paragraph promise
[ Open Ringgit Radar ]            red, primary
( Download for Android )          or, on iPhone: ( Add to Home Screen )
APK, 55 MB · not on Google Play   (Android line only)
Independent and unofficial. Not affiliated with or endorsed by Nintendo.
[ one large screenshot of the app ]
8,141 products tracked · prices checked daily · history since 1 Nov 2026
What you get      (three short items)
Where it runs
Questions         (five)
GitHub · Privacy · Where our data comes from
```

The mock-up the owner chose is `.superpowers/brainstorm/6662-1795280917/content/layout.html` (option A; local only, not committed). Wording in this document is the starting English; the page copy is final when the translation check passes.

**Headline and promise.** "Is that Switch game a good price? Check in ringgit." Then: "Ringgit Radar keeps its own daily record of Malaysian eShop prices, so you can see today's price, the lowest we've seen, and when the sale ends."

**The unofficial line sits under the buttons**, not only in the footer, because App Review reads this page.

**Buttons by device.**
- Everyone: "Open Ringgit Radar" goes to `/app/` (in the page's language, below).
- Android phones: "Download for Android" becomes the red, first button, above "Open Ringgit Radar"; it links to that language's Android download page.
- iPhone and iPad: the second button is "Add to Home Screen". Tapping it shows three steps. **Builder-check call:** the steps start in the app, not on the landing page, so the icon opens the app and nothing inside the Flutter app changes: 1. in Safari, tap "Open Ringgit Radar"; 2. tap Share; 3. tap Add to Home Screen. The app then opens full-screen with its own icon (its web manifest and icons already exist). One line under the steps says a Wish List saved in Safari does not carry over to the home-screen app, because iOS keeps their storage apart.
- Other devices: "Download for Android" stays second.
- Without JavaScript, the page shows the desktop order, and every button still works.

**Language.**
- Each page is fixed to its language; nothing redirects by browser language. Each page tells search engines about the other two (`hreflang`), with English as the default.
- The EN · 中文 · BM switch links to the same page in the other language.
- Choosing a page's language carries into the app: tapping "Open Ringgit Radar" on `/zh/` opens the app in Chinese, by setting the app's stored language before following the link. **Builder-check call:** only a real choice is carried. `/zh/` and `/ms/` set their language, and `/` sets English only when the visitor reached it through the EN link in the switch. Simply arriving on `/` (most visitors from search and shared links) leaves the app's own setting alone, which is "follow the device" (`"system"`) by default, so a Chinese or Malay phone still gets its own language.

**Below the screenshot.**
- **Facts row:** products tracked, prices checked daily, and the date the history starts. They are read from the live API (`/v1/status/prices`) when the page is built and written into the HTML, so search engines and pages without JavaScript see true numbers; if the API cannot be read, the build fails. **Builder-check call:** deploys are run by hand, so the page also asks the same API (same address, no third party) for the current numbers when it loads and replaces the built ones, so the count follows each night's sweep and every removal without a redeploy.
- **What you get:** price history, sale end times in Malaysia time, a wish list.
- **Where it runs:** web, now; Android, now (APK from this site); iPhone, now, from the home screen. "App Store and Google Play apps are planned." No Mac line until something exists.
- **Questions:** Is it official? (No, and what that means.) Where do I buy games? (On your Switch; the app sells nothing.) Is it free? (Yes, no account, no ads.) Do I need an account? (No; the wish list stays on your device.) How do I get something removed? (Email `ringgitradar@snitco.com`; links to the app's "Where our data comes from" page.)
- **Footer:** the unofficial line again, GitHub (MIT), Privacy (`/app/privacy`), Where our data comes from (`/app/data-sources`).

**Being found and shared.**
- Per language: `<title>`, meta description, canonical URL, Open Graph and Twitter card tags, and a 1200×630 preview picture.
- **What the preview says (owner, 2026-11-23).** The title names "Switch" but not Nintendo: "Ringgit Radar · Switch game prices in ringgit". The description opens with the disclaimer, so Nintendo's name never travels without it: "An unofficial tracker of Malaysian Nintendo eShop prices in ringgit: today's price, the lowest we've seen, and when the sale ends. Not affiliated with Nintendo." The picture carries only the app's name, its tagline "Game prices in ringgit" and the app's own colours and a real screenshot: no Nintendo, Switch or eShop words, no game art filling it, no Nintendo marks. The banned-word test covers these head tags too, and checks that any head text naming Nintendo also says "unofficial" (or its translation).
- `sitemap.xml` listing the three landing pages and the three Android pages, and `robots.txt` pointing to it.
- Page text is real HTML text, not images.

**No visitor tracking.** No analytics, counters, pixels or third-party scripts. The owner accepts not knowing download numbers.

**The old address.**
- Keeps serving `/v1/*`, `/healthz` and `/ringgit-radar.apk` unchanged, forever or until a later Android release moves the app off it.
- Every other path forwards permanently to the new address: `/` → `/app/`, `/android.html` → `/android/`, and any app route `/x` → `/app/x` (so old shared links to a game page still open that game).
- The old offline copy is retired: `/flutter_service_worker.js` at the site root becomes a small worker that deletes its caches and unregisters itself, so a returning visitor's browser stops serving the old app and follows the forward. It must be served directly (a redirect is not allowed for a service worker script).

**Domain.** The owner adds one DNS record in Cloudflare for `ringgitradar` pointing at Vercel, not proxied through Cloudflare so Vercel can issue the certificate. The domain is added to the Vercel project from the CLI.

## Left to the builder

- The Go program's name and place (for example `backend/cmd/site`), the template engine (`html/template`), the text file format, and how the build steps are ordered so the Flutter build into `backend/public/app` and the landing pages into `backend/public` don't wipe each other. The README's deploy steps are updated to match.
- Vercel config for the new layout: host-based redirects for the old address, rewrites so `/app/*` falls back to `/app/index.html`, and keeping the current security headers on every page (the web app needs its cross-origin isolation headers).
- How device detection works (user-agent or feature checks), as long as the no-JavaScript page still works.
- The screenshot: a real phone-width capture of the app in each page's language, showing a game's price history and sale end rather than a page filled by game art (`docs/store-listing.md` rule), made with the existing Playwright screenshot approach.
- Fonts: the landing page uses the same fonts, self-hosted. The Chinese page needs its characters in a subset (extend the app's subset or build a separate one); measure page weight and keep the first load small on a phone.
- Light and dark themes following the device, as the app and the current Android page do.
- Translations: the same method as the app (`apps/flutter_app/l10n/glossary.md` terms, blind back-translation per language, recorded), and the same test style: every language has every key, banned words ("official", "popular", "best-selling", "coming soon", "authorised", "partner") never appear, no unofficial line missing.
- Checks before launch: every link on every page resolves; the pages pass an accessibility check (contrast, headings, focus, tap targets); the old address forwards and still serves the API and APK; an old shared game link opens the right game; a browser that had the old app is moved to the new one.

## Launch order

1. Owner adds the Cloudflare record; the domain is added to the Vercel project; `ringgitradar.snitco.com` serves the new build.
2. Check the new address end to end in all three languages.
3. Only then turn on the old address's forwarding and the retiring worker.
4. Update the README links and `docs/store-listing.md`'s support and marketing URLs.
