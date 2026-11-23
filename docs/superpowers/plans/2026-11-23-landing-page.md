# Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `ringgitradar.snitco.com` serves a fast three-language landing page and Android page, the web app moves to `/app/`, and `ringgit-radar-mu.vercel.app` forwards there while still serving the API and the APK.

**Architecture:** A Go package `backend/site` embeds one set of `html/template` files, one JSON text file per language and static assets (subset fonts, screenshots, preview pictures). `go run ./cmd/site` reads live numbers from `/v1/status/prices`, then writes six pages, `sitemap.xml`, `robots.txt`, the assets and the APK into `backend/public`, next to the Flutter build in `backend/public/app`. `backend/vercel.json` gains `/app/*` rewrites, trailing-slash redirects and, after the new address is checked, host-scoped forwarding for the old address.

**Tech Stack:** Go 1.27 stdlib (`html/template`, `embed`, `net/http`), Flutter web 3.38 (`--base-href /app/`), Vercel static + one Go function, fontTools `pyftsubset` (woff2), Playwright (from `/Users/chrischeng/kl-rush/node_modules/playwright`), `cwebp`, axe-core 4.10.3 (downloaded at check time, not a repo dependency).

**Spec:** `docs/superpowers/specs/2026-11-23-landing-page-design.md`

## Global Constraints

- The new origin: `https://ringgitradar.snitco.com`. The old one, still serving the API and APK: `https://ringgit-radar-mu.vercel.app`.
- Page addresses: landing pages at `/`, `/zh/` and `/ms/`; Android pages at `/android/`, `/zh/android/` and `/ms/android/`; the app at `/app/` (links go to `/app/privacy` and `/app/data-sources`); the APK at `/ringgit-radar.apk` on both hosts.
- No visitor tracking. No analytics, counters, pixels, third-party scripts, or requests to any other site from the six pages.
- Nothing redirects by browser language. Choosing a language carries into the app only on a real choice: `/zh/` and `/ms/` set it, and `/` sets English only after the visitor used the EN switch link.
- Every number comes from live data at build time. If `/v1/status/prices` can't be read, the build fails. The APK size is measured from the file.
- Banned words, in every language: "official" (except within "unofficial"), "popular", "best-selling", "coming soon", "authorised"/"authorized", "partner", plus their zh/ms forms (Task 1 lists them). The unofficial line appears under the buttons and again in the footer. Any head text naming Nintendo also says "unofficial" (zh 非官方, ms tidak rasmi).
- Store apps are "planned", never "coming soon". There's no Mac line. There's no App Store or Google Play button.
- Copy rules come from `apps/flutter_app/l10n/glossary.md`. "Ringgit Radar" is never translated. Money is `RM 64.80`, and times are Malaysia time.
- The build and tests never read `PRODUCT.md` or `DESIGN.md`; they aren't in this repo.
- Owner rules:
  - push, deploy, DNS, Vercel domain and merge are outward actions; confirm each with the owner first;
  - never use bare `git stash`;
  - don't commit `.superpowers/`;
  - commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`;
  - Vite+ is not adopted here.
- Every user-facing page is HTML text (not images), follows the device's light/dark setting, and has no horizontal scroll at 320 px width.

## Review Focus

1. **Storage blocked** (`localStorage.setItem` throws). Tapping "Open Ringgit Radar" still opens `/app/`. Test: the `storage-blocked` case in `check.js` (Task 5).
2. **The API is down or slow when the page loads.** The built count stays, with no uncaught error and no layout jump. Test: the `status-down` case in `check.js` (Task 5).
3. **iPadOS Safari reports a Mac user agent.** It still gets "Add to Home Screen", detected by `maxTouchPoints > 1`. Test: the `ipad` case in `check.js` (Task 5).
4. **Addresses without the trailing slash** (`/zh`, `/ms`, `/android`, `/zh/android`, `/ms/android`, `/app`). Each reaches its page. Test: the slash redirects in `vercel.json` (Task 5), checked live by `check.js` (Task 6).
5. **The old address with query strings.** `/v1/games?q=…` is never forwarded, and an old `/games/<id>` link lands on that game. Test: the curl matrix in Task 7.

---

## File Structure

| Path | Responsibility |
|---|---|
| `backend/site/site.go` | `Build`, `Options`, `Langs`, `Origin`, template data, writing pages/sitemap/robots/assets/APK |
| `backend/site/status.go` | `Status`, `FetchStatus`, `formatCount`, `formatDate`, `apkMB` |
| `backend/site/text.go` | loading `text/<lang>.json`, placeholder rendering, banned-word lists |
| `backend/site/templates/{base,landing,android}.html.tmpl` | shared head/header/footer/CSS/JS; the two page bodies |
| `backend/site/text/{en,zh,ms}.json` | flat key → string; placeholders `{name}` |
| `backend/site/text/backtranslation-2026-11-23.md` | translation check record |
| `backend/site/static/fonts/*` | woff2 subsets, `latin_chars.txt`, `zh_chars.txt`, OFL texts |
| `backend/site/static/{shot,og}-<lang>.{webp,png}`, `icon-192.png` | screenshot, 1200×630 preview, brand icon |
| `backend/site/root/flutter_service_worker.js` | retiring worker, copied to the site root (Task 7) |
| `backend/site/tool/subset_fonts.sh` | rebuilds the font subsets and char lists |
| `backend/site/tool/shoot.js` | captures screenshots and preview pictures |
| `backend/site/tool/serve.py` | local server mimicking Vercel: static files, `/app/*` fallback, slash redirects, `/v1` proxy, the security headers |
| `backend/site/tool/check.js` | browser checks against a base URL: links, device order, language carry-over, a11y, no third-party requests, 320 px overflow |
| `backend/site/site_test.go` | Go tests for all of the above that don't need a browser |
| `backend/cmd/site/main.go` | flags → `FetchStatus` → `Build` |
| `backend/vercel.json` | rewrites, redirects, headers |
| `apps/flutter_app/web/flutter_bootstrap.js` | relative font fallback URL, no service worker |
| `apps/flutter_app/web/android.html` | deleted (replaced by the generated pages) |
| `README.md`, `docs/store-listing.md` | build/deploy steps and URLs |

Tests command for the package (no database needed): `cd backend && go test ./site/ ./cmd/site/`.

---

### Task 1: Site generator and the English landing page

**Files:**
- Create:
  - `backend/site/{site.go,status.go,text.go,site_test.go}`
  - `backend/site/templates/{base,landing}.html.tmpl`
  - `backend/site/text/en.json`
  - `backend/site/static/icon-192.png` (copy of `apps/flutter_app/web/icons/Icon-192.png`)
  - `backend/site/static/favicon.png` (copy of `apps/flutter_app/web/favicon.png`)
  - `backend/site/static/fonts/` (via the script)
  - `backend/site/tool/subset_fonts.sh`
  - `backend/cmd/site/main.go`

**Interfaces (Produces):**
```go
package site
const Origin = "https://ringgitradar.snitco.com"
type Lang struct{ Code, HTMLLang, Prefix string } // Prefix: "" for en, "/zh", "/ms"
var Langs = []Lang{{"en", "en", ""}, {"zh", "zh-Hans", "/zh"}, {"ms", "ms", "/ms"}}
type Status struct {
    ProductCount int64     `json:"product_count"`
    HistorySince time.Time `json:"history_since"`
}
func FetchStatus(ctx context.Context, apiBase string) (Status, error)
type Options struct{ Out, APKPath string; Status Status }
func Build(o Options) error // writes into o.Out; never deletes anything there
func formatCount(n int64) string
func formatDate(t time.Time, lang string) string // Malaysia time, fixed UTC+8 zone
func apkMB(size int64) int64                     // decimal MB, rounded to nearest
func loadText(code string) (map[string]string, error)
func render(s string, args map[string]template.HTML) template.HTML // escape s, then replace {name} with args
var forbidden map[string][]string // per language; checked after removing allowed phrases (below)
```
`cmd/site` flags:
- `-api` (default `https://ringgit-radar-mu.vercel.app`);
- `-apk` (required);
- `-out` (default `public`).

It exits non-zero on any error.

- [ ] **Step 1: Write the failing tests in `backend/site/site_test.go`**

```go
func TestFetchStatus(t *testing.T)  // httptest: {"product_count":8141,"history_since":"2026-11-01T15:29:05Z"} → Status{8141, that time}; also 500 → error, {"product_count":0,...} → error, zero history_since → error, closed server → error
func TestFormatCount(t *testing.T)  // 999→"999", 8141→"8,141", 1234567→"1,234,567"
func TestFormatDate(t *testing.T)   // en 2026-11-01T15:29Z→"1 Nov 2026"; en 2026-10-31T16:30Z→"1 Nov 2026" (MYT); ms 2026-08-05T00:00Z→"5 Ogo 2026"; zh 2026-11-01T15:29Z→"2026年11月1日"
func TestApkMB(t *testing.T)        // 54_600_000→55, 54_400_000→54, 2_600_000→3
func TestBuildRefusesWithoutApp(t *testing.T) // no out/app/index.html → error containing "app/index.html"; app/index.html with <base href="/"> → error containing "/app/"
func TestBuildRefusesWithoutAPK(t *testing.T)
func TestBuildLanding(t *testing.T) // fixture: out/app/index.html containing <base href="/app/">; APK made with f.Truncate(2_600_000); Status{8141, 2026-11-01T15:29:05Z}
// asserts on out/index.html: `<html lang="en">`; the headline; `<span data-count>8,141</span>`; "1 Nov 2026";
// strings.Count(unofficialLine) >= 2; `href="/app/"`; `href="/android/"`; "APK, 3 MB"; no `http://` or `https://` in any src= attribute;
// out/ringgit-radar.apk is 2_600_000 bytes; out/site/fonts/MPLUSRounded1c-Regular.woff2 exists
func TestTextRules(t *testing.T)    // for every text/*.json: same key set as en; same {placeholder} set per key as en; no forbidden word; key "unofficial" present
func TestFontsCoverText(t *testing.T) // every rune of every en/ms value, and every rune <= 0x7E of zh values, is in static/fonts/latin_chars.txt
```

`forbidden` lists, matched case-insensitively after removing the allowed phrases (`unofficial`; `非官方`; `tidak rasmi` and `tidak diiktiraf`):

- en: `official`, `popular`, `best-selling`, `bestseller`, `best seller`, `top-selling`, `trending`, `coming soon`, `authorised`, `authorized`, `partner`.
- zh: `官方`, `热门`, `最受欢迎`, `畅销`, `人气`, `即将`, `敬请期待`, `授权`, `合作伙伴`.
- ms: `rasmi`, `popular`, `terlaris`, `paling laris`, `trending`, `akan datang`, `tidak lama lagi`, `bertauliah`, `rakan kongsi`, `diiktiraf`.

- [ ] **Step 2: Run them to see them fail**

Run: `cd backend && go test ./site/`
Expected: FAIL (undefined: FetchStatus, …).

- [ ] **Step 3: Write `text/en.json`** with these keys and this starting English. The spec fixes the head, headline, promise and unofficial lines word for word.

| key | English |
|---|---|
| `metaTitle` | Ringgit Radar · Switch game prices in ringgit |
| `metaDescription` | An unofficial tracker of Malaysian Nintendo eShop prices in ringgit: today's price, the lowest we've seen, and when the sale ends. Not affiliated with Nintendo. |
| `ogTagline` | Game prices in ringgit |
| `headline` | Is that Switch game a good price? Check in ringgit. |
| `promise` | Ringgit Radar keeps its own daily record of Malaysian eShop prices, so you can see today's price, the lowest we've seen, and when the sale ends. |
| `open` | Open Ringgit Radar |
| `android` | Download for Android |
| `androidNote` | APK, {size} MB · not on Google Play |
| `iphone` | Add to Home Screen |
| `iphoneStep1` / `2` / `3` | In Safari, tap "Open Ringgit Radar". / Tap Share. / Tap Add to Home Screen. |
| `iphoneNote` | A Wish List saved in Safari doesn't carry over to the Home Screen app, because iPhone keeps their storage apart. |
| `unofficial` | Independent and unofficial. Not affiliated with or endorsed by Nintendo. |
| `shotAlt` | Ringgit Radar on a phone: a game's price in ringgit, its price history and when the sale ends |
| `facts` | {count} products tracked · prices checked daily · history since {date} |
| `getTitle` | What you get |
| `get1Title` / `get1` | Price history / Every price we've recorded for a game, and the lowest we've seen. |
| `get2Title` / `get2` | Sale end times / When each sale ends, in Malaysia time. |
| `get3Title` / `get3` | A Wish List / Save games and see which are on sale. It stays on your device. |
| `runsTitle` | Where it runs |
| `runsWeb` / `runsAndroid` / `runsIphone` | Web: now, in any browser. / Android: now, as an APK from this site. / iPhone and iPad: now, from your Home Screen. |
| `runsStores` | App Store and Google Play apps are planned. |
| `faqTitle` | Questions |
| `faqOfficialQ` / `A` | Is Ringgit Radar from Nintendo? / No. It's an independent, unofficial project that reads Nintendo's public eShop prices for Malaysia. It is not affiliated with or endorsed by Nintendo. |
| `faqBuyQ` / `A` | Where do I buy games? / On your Switch, in the Nintendo eShop. Ringgit Radar sells nothing and takes no payments. |
| `faqFreeQ` / `A` | Is it free? / Yes. No account, no ads. |
| `faqAccountQ` / `A` | Do I need an account? / No. Your Wish List stays on your device. |
| `faqRemoveQ` / `A` | How do I get something removed? / Email {email}. Our page on {dataPage} explains what we show and why. |
| `dataPageLink` | where our data comes from |
| `footerGitHub` / `footerPrivacy` / `footerData` | Source code on GitHub (MIT) / Privacy / Where our data comes from |
| `langLabel` | Language |

Ruling, already made: the spec's question "Is it official?" contains a banned word, so it reads "Is Ringgit Radar from Nintendo?" (same meaning).

- [ ] **Step 4: Write `tool/subset_fonts.sh`.** It makes Regular and Bold woff2 files from `apps/flutter_app/assets/fonts/MPLUSRounded1c-{Regular,Bold}.ttf`:
  - `pyftsubset --flavor=woff2 --unicodes=U+0020-007E,U+00A0-00FF,U+2010-2027 --layout-features='*' --no-hinting`;
  - output to `static/fonts/MPLUSRounded1c-{Regular,Bold}.woff2`;
  - copy `OFL.txt` alongside;
  - write `static/fonts/latin_chars.txt` from the Regular subset's cmap, the same way `apps/flutter_app/tool/subset_zh_font.sh` writes `zh_chars.txt`.

  Run it.

- [ ] **Step 5: Implement `status.go`, `text.go`, `site.go`, `templates/base.html.tmpl`, `templates/landing.html.tmpl` and `cmd/site/main.go`.** The layout follows spec "Layout A". Decisions:
  - Everything is embedded with `//go:embed templates text static`. Static files are written to `out/site/…`. Every URL in pages is root-absolute (`/site/fonts/…`, `/app/`).
  - CSS and JS are inline in `base.html.tmpl`:
    - one `@font-face` per weight (400 and 700) with `font-display: swap`;
    - a `<link rel="preload">` for the Regular file;
    - `body` font stack `"M PLUS Rounded 1c", system-ui, sans-serif`;
    - colours: red `#C8102E` (white text), light bg `#EAEAEA`, dark bg `#1b1b1d`, by `prefers-color-scheme`;
    - `:focus-visible` outline `3px solid #5a6bff`;
    - buttons at least 48 px high.
  - The header holds the icon, "Ringgit Radar" and the switch `EN · 中文 · BM`. The switch is constant template text, links to the same page kind in each language, and every switch link gets `class="sw"` with `font-family: system-ui, sans-serif`, so "中文" never pulls in the Chinese font on the en and ms pages.
  - Button group, in no-JS order:
    1. Open, red, `href="/app/"`;
    2. Android, `href="{prefix}/android/"`, with `androidNote` under it;
    3. a `<details id="iphone" hidden>` whose `<summary>` is `iphone`, holding the three steps and `iphoneNote`.

    The `unofficial` line follows, then the screenshot's place (Task 4 adds the `<img>` and its files), then `facts`.
  - Placeholders are rendered with `render`:
    - `{count}` → `<span data-count>8,141</span>`;
    - `{date}` → `formatDate`;
    - `{size}` → `apkMB`;
    - `{email}` → `<a href="mailto:ringgitradar@snitco.com">ringgitradar@snitco.com</a>`;
    - `{dataPage}` → `<a href="/app/data-sources">` + `dataPageLink` + `</a>`.
  - Footer: `unofficial`, then `https://github.com/chengboonrong/ringgit-radar`, `/app/privacy` and `/app/data-sources`.
  - Inline script (about 30 lines, every storage access in try/catch):
    - **Device.** Android = `/Android/i` on the user agent. iOS = `/iPhone|iPad|iPod/` or (`/Macintosh/` and `navigator.maxTouchPoints > 1`).
      - On Android, move the Android button first and give it the red style, leaving Open second and not red.
      - On iOS, hide the Android button and its note, and unhide `#iphone`.
    - **Language.** Switch links set `sessionStorage['rr.lang']` to their code on click. A click on any `a[href^="/app/"]` sets `localStorage['flutter.locale'] = JSON.stringify(code)`, where `code` is the page language on zh and ms, or `'en'` on en pages only when `sessionStorage['rr.lang'] === 'en'`. Otherwise it writes nothing.
    - **Count.** `fetch('/v1/status/prices')`. If `product_count` is a positive integer, set `[data-count]` text to `n.toLocaleString('en-US')`. On any failure, keep the built text.
  - `Build`:
    - checks that `out/app/index.html` exists and contains `<base href="/app/">`, and that the APK exists (wrapped errors naming the path);
    - copies the APK to `out/ringgit-radar.apk`;
    - writes the pages and `out/site/…`.

- [ ] **Step 6: Run the tests to see them pass**

Run: `cd backend && gofmt -l site cmd/site && go vet ./site/ ./cmd/site/ && go test ./site/ ./cmd/site/`
Expected: no gofmt output; `ok eshop-radar/backend/site`.

- [ ] **Step 7: Commit**

```bash
git add backend/site backend/cmd/site
git commit -m "Generate the English landing page from a Go template and live numbers"
```

### Task 2: The Android download page

**Files:**
- Create: `backend/site/templates/android.html.tmpl`
- Modify:
  - `backend/site/site.go`
  - `backend/site/text/en.json`
  - `backend/site/site_test.go`
- Delete: `apps/flutter_app/web/android.html`

**Interfaces:**
- Consumes: Task 1's `Build`, `render`, `apkMB` and `Langs`.
- Produces: the pages `out/android/index.html` (and `out<prefix>/android/index.html` per language, once Task 3 adds files).

- [ ] **Step 1: Write the failing test `TestBuildAndroid`.** It uses the Task 1 fixture and checks `out/android/index.html` for:
  - `<html lang="en">`;
  - `href="/ringgit-radar.apk" download`;
  - "APK file, 3 MB";
  - `href="/app/"` and `href="/app/privacy"`;
  - the unofficial line;
  - switch links to `/zh/android/` and `/ms/android/`;
  - no `href="/privacy"` and no `href="/"` used as a "website" link.

- [ ] **Step 2: Run it.** `go test ./site/ -run TestBuildAndroid` → FAIL (file missing).

- [ ] **Step 3: Add the keys to `en.json`**, with wording from the current `web/android.html`, which the new page replaces:

| key | English |
|---|---|
| `androidTitle` | Ringgit Radar for Android |
| `androidMetaDescription` | Download Ringgit Radar for Android: Malaysian eShop prices in ringgit. Unofficial, not affiliated with Nintendo. |
| `androidLead` | Malaysian eShop prices in ringgit, with price history and sale end dates. |
| `androidDownload` | Download the app |
| `androidFileNote` | APK file, {size} MB. This app is not on Google Play. |
| `installTitle` | How to install |
| `install1` | Download the file, then open it from your notifications or Downloads. |
| `install2` | If Android blocks it, allow installs from your browser when asked. |
| `install3` | Tap Install, then Open. |
| `androidWeb` | On iPhone or a computer, use the {web}. It has everything the app has. Read our {privacy}. |
| `webLink` | web app |
| `privacyLink` | privacy page |

  Implement `android.html.tmpl` on `base`. The same script also carries the language when `/app/` links are tapped. Delete `apps/flutter_app/web/android.html`.

- [ ] **Step 4: Run all package tests.** `go test ./site/ ./cmd/site/` → ok. Then `grep -rn "android.html" apps/flutter_app README.md`, and record any hit for Task 5/8.

- [ ] **Step 5: Commit** with the message "Generate the Android download page and drop the old one from the app build".

### Task 3: Chinese and Malay

**Files:**
- Create:
  - `backend/site/text/{zh,ms}.json`
  - `backend/site/text/backtranslation-2026-11-23.md`
  - `backend/site/static/fonts/RinggitZh-{Regular,Bold}.woff2`
  - `backend/site/static/fonts/zh_chars.txt`
  - `backend/site/static/fonts/OFL-ResourceHanRounded.txt`
- Modify:
  - `backend/site/tool/subset_fonts.sh`
  - `backend/site/templates/base.html.tmpl`
  - `backend/site/site_test.go`

**Interfaces:**
- Consumes: Task 1's `Langs`, `loadText` and `TestTextRules`.
- Produces: pages under `out/zh/` and `out/ms/`.

- [ ] **Step 1: Write the failing tests.**

  `TestBuildAllLanguages` checks:
  - `out/zh/index.html` has `<html lang="zh-Hans">`, zh `headline`, `href="/zh/android/"` and `href="/app/"`;
  - `out/ms/index.html` likewise;
  - every page of the 6 has switch links to its counterparts (landing↔landing, android↔android).

  Extend `TestFontsCoverText`: every rune > 0x7E in zh values is in `static/fonts/zh_chars.txt`.

- [ ] **Step 2: Run them.** FAIL (no zh.json).

- [ ] **Step 3: Write `zh.json` and `ms.json`** with the glossary terms. Two of them:
  - Wish List is 愿望单 / Senarai Hajat.
  - The unofficial line uses 非官方 / tidak rasmi and the glossary's full "not affiliated" forms.

  The iPhone steps must use iOS's own UI labels in that language:
  - zh 共享 and 添加到主屏幕;
  - ms Kongsi and Tambah ke Skrin Utama.

  Check both against Apple's support pages in that language (support.apple.com/zh-cn, support.apple.com/ms-my) and record the URLs.

  `ogTagline` has no Nintendo, Switch or eShop. "Planned" is zh 计划中 and ms dirancang.

- [ ] **Step 4: Blind back-translation.** A fresh subagent, given only `zh.json` and `ms.json` (not en), translates each value back to English. Compare against en. Fix every meaning drift, re-run until clean, and record the table and fixes in `backtranslation-2026-11-23.md`, in the style of `apps/flutter_app/l10n/backtranslation-2026-11-22.md`.

- [ ] **Step 5: Fonts.**
  1. Extend `subset_fonts.sh`. It takes `$1` = a dir with `ResourceHanRoundedCN-{Regular,Bold}.ttf` (v0.990; today at `<scratchpad>/rhr/x`) and builds `RinggitZh-{Regular,Bold}.woff2`:
     - characters: the non-ASCII characters of `text/zh.json` values;
     - renamed to RinggitZh the same way the app's script does;
     - plus `zh_chars.txt` and the OFL text.
  2. In `base.html.tmpl`, add the two RinggitZh `@font-face`s with `unicode-range: U+2E80-9FFF, U+FF00-FFEF, U+3000-303F`. Set the stack on `html[lang=zh-Hans] body` only, as `"M PLUS Rounded 1c", RinggitZh, system-ui, sans-serif`, and preload the RinggitZh Regular file on zh pages only.

- [ ] **Step 6: Run the tests.** `go test ./site/ ./cmd/site/` → ok. The zh and ms files pass `TestTextRules` (keys, placeholders, banned words) and `TestFontsCoverText`.

- [ ] **Step 7: Commit** with the message "Add the Chinese and Malay landing and Android pages".

### Task 4: Search, sharing and page weight

**Files:**
- Create:
  - `backend/site/tool/shoot.js`
  - `backend/site/static/shot-{en,zh,ms}.webp`
  - `backend/site/static/og-{en,zh,ms}.png`
- Modify:
  - `backend/site/templates/base.html.tmpl`
  - `backend/site/site.go`
  - `backend/site/site_test.go`

**Interfaces:**
- Consumes: the pages from Tasks 1 to 3.
- Produces: `out/sitemap.xml` and `out/robots.txt`.

- [ ] **Step 1: Write the failing tests.**

  `TestHead` checks each of the 6 pages for:
  - exactly one `<link rel="canonical" href="` + Origin + path + `">`;
  - `hreflang` alternates `en` → `Origin+"/"…`, `zh-Hans`, `ms` and `x-default` (= en), pointing at the same page kind;
  - `og:title` equal to `<title>`;
  - `og:description`;
  - `og:image` = `Origin+"/site/og-<lang>.png"`, with that file existing in `out/site/`;
  - `og:url` = canonical;
  - `og:locale` (`en_MY`, `zh_CN`, `ms_MY`);
  - `twitter:card` = `summary_large_image`;
  - the rule that any of title, description and `og:*`/`twitter:*` content containing "Nintendo" or "任天堂" also contains `unofficial`, `非官方` or `tidak rasmi`.

  `TestSitemap` checks that `out/sitemap.xml` has exactly 6 `<loc>` entries, each Origin + a page path, and that `out/robots.txt` contains `Sitemap: https://ringgitradar.snitco.com/sitemap.xml`.

  `TestPageWeight` builds, then for each landing page sums the HTML plus every `/site/` file it references in `src=`, preloads or `url(`. Fonts count only for the page's language: the latin faces on every page, RinggitZh on zh. The og image and the APK don't count. Budgets: en and ms ≤ 250 000 bytes, zh ≤ 400 000 bytes. Print the sums with `t.Logf`.

- [ ] **Step 2: Run them.** FAIL.

- [ ] **Step 3: Screenshots and preview pictures with `tool/shoot.js <appBase> <nsuid>`.** Today `<appBase>` is `https://ringgit-radar-mu.vercel.app`, the live app at the root. Pick a game that is on sale now and has at least two price-history points, and record its nsuid in the ledger. For each language:
  1. Use a 390×844 viewport at deviceScaleFactor 2, with init script `flutter.locale` = `JSON.stringify(lang)` and `flutter.notice_seen` = `'true'`.
  2. Open `<appBase>/games/<nsuid>`, scroll until the price, the sale end and the price-history chart fill the frame, wait for the chart to settle, and screenshot to a PNG in the scratchpad.
  3. Convert with `cwebp -q 80 -resize 780 0` → `static/shot-<lang>.webp`.
  4. Make the preview picture by rendering an inline HTML page at 1200×630 with Playwright. It holds only the icon, "Ringgit Radar", `ogTagline` from `text/<lang>.json`, the app's red and light background, and a crop of the price-history chart from that screenshot. The fonts come from `static/fonts` via `file://`. Save it as `static/og-<lang>.png`.

  Look at all six images. They must have no Nintendo, Switch or eShop words, no Nintendo marks, and no game art filling the frame. Re-crop if any appear.

- [ ] **Step 4: Implement the head tags, sitemap and robots.** Put the head tags in `base.html.tmpl`. Add the screenshot `<img src="/site/shot-<lang>.webp" alt=shotAlt>` to `landing.html.tmpl`, with `width`/`height` from the image's real pixel size. `sitemap.xml` and `robots.txt` are written by `Build`, with no `lastmod`.

- [ ] **Step 5: Run the tests.** `go test ./site/ ./cmd/site/ -v -run 'TestHead|TestSitemap|TestPageWeight'` → PASS, with the weights logged. If a budget fails, shrink the screenshot (quality, then width) before touching fonts, and ledger the ruling.

- [ ] **Step 6: Commit** with the message "Add link previews, hreflang, sitemap and real screenshots to the pages".

### Task 5: The app at /app/, the Vercel config and the local end-to-end check

**Files:**
- Modify:
  - `apps/flutter_app/web/flutter_bootstrap.js`
  - `backend/vercel.json`
  - `README.md` (deploy steps 2 and 4, and the local web build line)
- Create:
  - `backend/site/tool/serve.py`
  - `backend/site/tool/check.js`

**Interfaces:**
- Consumes: `go run ./cmd/site` from Task 1.
- Produces: `check.js <base> [--live]`, used again in Tasks 6 and 7. It exits non-zero on any failed case and prints one line per case.

- [ ] **Step 1: Back up the current build before anything wipes it.** Run `cp -R backend/public <scratchpad>/public-old`. It holds the old app and the released APK. Confirm the APK is 1.0.2 with `$ANDROID_HOME/build-tools/<latest>/aapt2 dump badging <scratchpad>/public-old/ringgit-radar.apk | grep versionName` → `versionName='1.0.2'`.

- [ ] **Step 2: Write `check.js` first.** Its cases, against `<base>`:
  - `pages`: the 6 pages return 200.
  - `links`: every `href` on them resolves (same-origin: status < 400 after redirects; mailto skipped; GitHub fetched once).
  - `no-third-party`: zero requests to any other origin from the 6 pages.
  - `no-console-errors`.
  - `desktop-order` (Chromium default UA): Open is first and red, Android is second, `#iphone` is hidden.
  - `android-order` (Pixel UA): Android is first and red.
  - `iphone` (iPhone UA): `#iphone` is visible, the Android button is hidden, and its summary opens the three steps.
  - `ipad`: a Macintosh Safari UA with `hasTouch` and `maxTouchPoints` 5 behaves like iPhone.
  - `no-js` (`javaScriptEnabled:false`): desktop order, and every button's href resolves.
  - `lang-carry`:
    - Open on `/zh/` → `localStorage['flutter.locale'] === '"zh"'`;
    - straight to `/` then Open → key absent;
    - `/zh/` → EN switch → Open → `'"en"'`.
  - `storage-blocked`: an init script makes `Storage.prototype.setItem` throw; Open on `/zh/` still reaches `/app/`.
  - `status-down`: route `/v1/status/prices` aborted; `[data-count]` keeps its built text and no page error fires.
  - `overflow-320`: at width 320, `scrollWidth <= innerWidth` on all 6 pages.
  - `a11y`: axe-core 4.10.3 (from `npm pack axe-core@4.10.3` into the scratchpad, injected with `addScriptTag`) with tags `wcag2a`, `wcag2aa`, `wcag21aa` and `wcag22aa`, in light and dark (`colorScheme`), on all 6 pages → zero violations.
  - `app`: `/app/` and `/app/games/<nsuid>` load. The second makes a `/v1/games/<nsuid>` request that returns 200. Neither has a failed request.
  - `slashes`: `/zh`, `/ms`, `/android`, `/zh/android`, `/ms/android` and `/app` end on the slash form with 200.

- [ ] **Step 3: Write `serve.py <dir> <port> <apiBase>`** (stdlib). It:
  - serves static files from `<dir>`, with a directory serving its `index.html`;
  - falls back `/app/*` misses to `/app/index.html`;
  - redirects the slash-less paths above with 308;
  - proxies `/v1/*` and `/healthz` to `<apiBase>`;
  - adds the five security headers from `vercel.json` to every response.

- [ ] **Step 4: Run check.js before the change to see it fail.**
  1. `rm -rf backend/public`.
  2. Build the app into `backend/public/app` with the current bootstrap (Step 6's command), run `go run ./cmd/site …` (Step 6), and serve with `python3 backend/site/tool/serve.py backend/public 8099 https://ringgit-radar-mu.vercel.app`.
  3. Run `node backend/site/tool/check.js http://127.0.0.1:8099`.

  Expected: `app` FAIL, with a 404 on `/assets/assets/gfonts/…` (the absolute `fontFallbackBaseUrl`), or record what fails instead.

- [ ] **Step 5: Change `flutter_bootstrap.js` and `vercel.json`.**
  - **`flutter_bootstrap.js`:**
    - set `fontFallbackBaseUrl: "assets/assets/gfonts/"`, relative, resolved against `<base href>`;
    - delete `serviceWorkerSettings`.

    Ruling, already made: under `/app/`, Flutter's worker computes its cache keys from the origin root, so it would never serve anything. Removing it means the new app can't go stale offline (spec anti-goal). Neither Android nor iOS needs a worker for the home screen.
  - **`vercel.json`:**
    - Replace the catch-all rewrite with `{ "source": "/app/:path*", "destination": "/app/index.html" }`.
    - Add `"redirects": [{ "source": "/:p(zh|ms|app|android|zh/android|ms/android)", "destination": "/:p/", "permanent": true }]`.
    - Keep the `/v1` and `/healthz` rewrites, the `headers` block and everything else unchanged.

- [ ] **Step 6: Rebuild and rerun to see it pass.**
  ```
  rm -rf backend/public
  (cd apps/flutter_app && flutter build web --wasm --no-web-resources-cdn --dart-define=API_BASE= --base-href /app/ --output ../../backend/public/app)
  (cd backend && go run ./cmd/site -apk <scratchpad>/public-old/ringgit-radar.apk -out public)
  python3 backend/site/tool/serve.py backend/public 8099 https://ringgit-radar-mu.vercel.app &
  node backend/site/tool/check.js http://127.0.0.1:8099
  ```
  Expected: every case PASS. Then `(cd backend && npx vercel build)` → "Build Completed" (this validates `vercel.json`). Finally `(cd apps/flutter_app && flutter analyze && flutter test)` → all pass.

- [ ] **Step 7: Update the README.**
  - Deploy step 2 becomes the four build lines of Step 6, then `npx vercel deploy --prod`.
  - Step 4: the APK goes in with `-apk`, and the Android page is `/android/` (generated).
  - The local web build line says `--base-href` defaults to `/` for local serving.
  - Add one line on `backend/site` (what it is, `tool/subset_fonts.sh` after editing `text/zh.json`, `tool/check.js`).

- [ ] **Step 8: Commit** with the message "Serve the app from /app/ and check the whole site in a browser before deploy".

### Task 6: Launch the new address (owner + Claude, outward actions)

**Files:** none (operations); ledger only.

- [ ] **Step 1: Save a browser profile that holds the old offline app** before anything is deployed. A Playwright `launchPersistentContext('<scratchpad>/old-sw-profile')` visits `https://ringgit-radar-mu.vercel.app/` and waits 10 s. Expected: `navigator.serviceWorker.getRegistrations()` returns 1 with scope `https://ringgit-radar-mu.vercel.app/`, and `caches.keys()` includes `flutter-app-cache`. Close the profile and don't open it again until Task 7.

- [ ] **Step 2: Domain, after the owner confirms.** From `backend/`, run `npx vercel domains add ringgitradar.snitco.com`. Give the owner the exact record it prints: Cloudflare → snitco.com → DNS → Add record, Type `CNAME`, Name `ringgitradar`, Target as printed, Proxy status **DNS only** (grey cloud), TTL Auto. Wait for `npx vercel domains inspect ringgitradar.snitco.com` to report it configured. Expected: `curl -s https://ringgitradar.snitco.com/healthz` → `ok`, served by the current build with a valid certificate.

- [ ] **Step 3: Deploy A, after the owner confirms.** Run the Task 5 Step 6 build lines from the branch head, then `(cd backend && npx vercel deploy --prod)`. Expected: the deploy's URL prints, then `curl -sI https://ringgitradar.snitco.com/` → 200 `text/html`.

- [ ] **Step 4: Live check.**
  - Run `node backend/site/tool/check.js https://ringgitradar.snitco.com` → every case PASS, in all three languages.
  - The old host still serves the API and APK:
    - `curl -s https://ringgit-radar-mu.vercel.app/v1/status/prices` → JSON with `product_count`;
    - `curl -sI https://ringgit-radar-mu.vercel.app/ringgit-radar.apk` → 200 with the APK's length;
    - `/healthz` → `ok`.
  - Look at the three landing pages on a phone-width screenshot, light and dark.
  - Ledger the results. If anything fails, `npx vercel rollback` and fix before Task 7.

### Task 7: Forward the old address and retire its offline copy

**Files:**
- Create: `backend/site/root/flutter_service_worker.js`
- Modify:
  - `backend/site/site.go` (embed `root`, copy it to `out/`)
  - `backend/site/site_test.go`
  - `backend/vercel.json`

**Interfaces:**
- Consumes: `Build` from Task 1 and `check.js` from Task 5.

- [ ] **Step 1: Write the failing test `TestBuildRetiringWorker`.** It checks that `out/flutter_service_worker.js` exists and contains `registration.unregister()`, `caches.delete` and `skipWaiting`, and that `out/app/` is untouched by it.

- [ ] **Step 2: Run it.** FAIL.

- [ ] **Step 3: Write the retiring worker** (about 10 lines):
  - `install` → `skipWaiting()`;
  - `activate` → `waitUntil`: delete every key in `caches.keys()`, `self.registration.unregister()`, then `client.navigate(client.url)` for each window client;
  - no `fetch` handler.

  Embed `root` and copy it to `out/` in `Build`.

- [ ] **Step 4: Add the host-scoped forwarding to `vercel.json`** `redirects`, before the slash rule, each with `"has": [{ "type": "host", "value": "ringgit-radar-mu.vercel.app" }]` and `"permanent": true`:
  1. `/android.html` → `https://ringgitradar.snitco.com/android/`
  2. `/:path((?!v1/|healthz$|ringgit-radar\\.apk$|flutter_service_worker\\.js$|api/).*)` → `https://ringgitradar.snitco.com/app/:path`

  The empty path covers `/` → `/app/`.

- [ ] **Step 5: Run the tests.** `go test ./site/ ./cmd/site/` → ok, then `(cd backend && npx vercel build)` → Build Completed.

- [ ] **Step 6: Commit** with the message "Forward the old address to the new one and retire its offline app".

- [ ] **Step 7: Deploy B, after the owner confirms.** Rebuild as in Task 5 Step 6 and run `npx vercel deploy --prod`. Then the curl matrix (`-s -o /dev/null -w '%{http_code} %{redirect_url}'`) against the old host:

| path | expected |
|---|---|
| `/` | `308 https://ringgitradar.snitco.com/app/` |
| `/games/70010000108276` | `308 https://ringgitradar.snitco.com/app/games/70010000108276` |
| `/android.html` | `308 https://ringgitradar.snitco.com/android/` |
| `/v1/status/prices` | `200` |
| `/v1/games?q=mario` | `200` |
| `/healthz` | `200` |
| `/ringgit-radar.apk` | `200` |
| `/flutter_service_worker.js` | `200`, body contains `unregister` |

  The same paths on the new host must not redirect: `/` → 200 landing page.

- [ ] **Step 8: Check the old offline copy is retired.** Open `<scratchpad>/old-sw-profile` and visit `https://ringgit-radar-mu.vercel.app/`, then wait 15 s and reload once. Expected:
  - the page URL starts with `https://ringgitradar.snitco.com/app/`;
  - back on an old-host page, `getRegistrations()` returns 0 for the old scope and `caches.keys()` is empty.

  Also, opening `https://ringgit-radar-mu.vercel.app/games/<nsuid>` in a fresh context shows the game (its `/v1/games/<nsuid>` request returns 200). Rerun `check.js https://ringgitradar.snitco.com` → all PASS.

### Task 8: Point the docs at the new address

**Files:**
- Modify:
  - `README.md` (the "Try it" line, Android link)
  - `docs/store-listing.md` (support and marketing URLs)

- [ ] **Step 1:** `grep -rn "ringgit-radar-mu.vercel.app\|android.html" README.md docs/store-listing.md`, and record the hits.
- [ ] **Step 2: Update the user-facing links.**
  - "Try it" points to `https://ringgitradar.snitco.com` and Android to `https://ringgitradar.snitco.com/android/`.
  - The store listing's support and marketing URLs become `https://ringgitradar.snitco.com/`.
  - Keep the old host wherever the text means the API the Android app calls (README deploy step 4's `API_BASE`).
- [ ] **Step 3:** Re-run the grep. Every remaining hit is an API reference, and each is listed in the ledger.
- [ ] **Step 4: Commit** with the message "Point the README and store listing at ringgitradar.snitco.com". Then run the whole suite: `cd backend && TEST_DATABASE_URL=postgres:///eshop_radar_test go test ./...` and `cd apps/flutter_app && flutter analyze && flutter test` → all pass.
