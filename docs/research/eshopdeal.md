# eShopDeal: public-footprint reverse engineering

Studied 2026-11-01 for eShop Radar. Understanding only: no code, data or assets from the target go into our product.
Labels: **OBSERVED** (URL or Evidence ID), **INFERRED**, **UNKNOWN**.

**Evidence base.** Web only. About 12 page views of eshopdeal.kr, its 14 page-loaded JS chunks, robots, sitemap index, privacy policy, App Store listing. Browser capture `ev_c7e9faad931a16187f11c6c1cd33030cc892af3ed398f874421006540c42c2b6`. Sitemap shards were not fetched, to avoid enumerating the catalogue. No credentials or keys were seen; only public GA4 and AdSense IDs. No target text addressed instructions to us.

**APK: STILL NOT OBTAINED, so there is no code-level analysis of the app.** Every statement below is about the website or the app's published text; no web inference has been settled by code.

- apkpure.com `/download` and `d.apkpure.com` return 403 to plain clients, and a plain browser stopped at a Cloudflare "Verify you are human" checkbox (`ev_664ab97241e857868fabc6a4306a6c204a66054b2ce96d7c805048ca7ea4ac9c`). It was not clicked or bypassed. APKMirror has no listing under the package, app or developer name. No other mirrors were tried. The listing shows "Varies with device", no version, last updated Oct 28 2026.
- The file supplied by hand on 2026-11-02, `/Users/chrischeng/re/eshopdeal/apk/eshopdeal.apk` (SHA-256 `29817cb2…88c5658`), **is not eShopDeal**. OBSERVED (`aapt2 dump badging`, `apksigner verify`): package `com.okinc.okex.gp`, label OKX, version 6.187.1 (733378), signer `CN=OK inc.`, certificate SHA-256 `77b96749…510e9`. The size is explained by that: 56+ dex files and OKX native libraries. It was not decompiled, and nothing from it appears in this report. The APKPure listing page also carried an unrelated OKX ad download, the likely cause (INFERRED).

## 1. Data sources, sale detection, refresh

- OBSERVED: prices are "collected from each country's eShop", once a day at dawn; a sale starting in the daytime appears after the next run (https://eshopdeal.kr/blog/about-eshopdeal-data). The figure was 22 countries on 2026-09-08; it is 27 now.
- OBSERVED: page assets come from `assets.nintendo.com/image/fetch` wrapping `atum-img-lp1.cdn.nintendo.net`, `img-eshop.cdn.nintendo.net` (screenshots) and `store.nintendo.co.kr/media/catalog/product` (fallback image). Buy links are `ec.nintendo.com/{CC}/{lang}/titles/{nsuid}`.
- OBSERVED: the article names further inputs, the Korean store's product pages and search, plus "European eShop catalogue" and "Japanese eShop catalogue" language lists.
- OBSERVED: sale end `le` looks like `2026-11-05T07:59:59Z`, the same form as `end_datetime` in our `/v1/price` test fixture (`2026-12-16T15:59:59Z`). 102 of 2,900 US deals end at `15:59:59Z`.
- INFERRED (medium): prices come from `api.ec.nintendo.com/v1/price`, the only multi-country price source with this shape. INFERRED (medium): "Japanese catalogue" is `search.nintendo.jp` or similar. No target hostname for either appears in anything we saw: the collector is server-side.
- OBSERVED: exchange rates credit exchangerate-api.com, taken at collection time; card fees and taxes are excluded. Argentina is dropped because its listed price differs from the charged amount.
- OBSERVED: US snapshot `builtAt` was 08:05:54 UTC (01:05 PT), 7.5 hours old at page view; page says "As of 11/1 01:05". One data point only.
- OBSERVED: `/en-us/new` splits "Found on 11/1: 203" from "Started in the last 7 days: 902"; `lsd` (sale start date) reaches 2026-09-05, before US tracking began on 9/7. INFERRED (weak, 2 rows): `lsd` is Nintendo's start date, not first-seen.
- UNKNOWN: which exact endpoints, how the catalogue is discovered, whether MY uses the same path as US.
- OBSERVED incident: for games released after late 2022, prices for US, CA, MX, BR, CL, CO and PE were missing until 2026-09-17 because "the collection path stopped at the old product list", and it went unnoticed because the total count barely changed.

## 2. Observable architecture

- OBSERVED: Next.js App Router with RSC and Turbopack on Vercel (`x-vercel-id: sin1::icn1::…`, so Singapore edge, Seoul function). Same app serves several hosts via rewrites (`x-matched-path: /eshop-zh/[locale]/game/[id]`, `x-nextjs-rewritten-query: host=eshopdeal.kr`). Previously `solruna.com/eshop`.
- OBSERVED: home is prerendered and revalidated (`x-nextjs-prerender: 1`, `x-vercel-cache: REVALIDATED`, stale-time 300). Game pages are dynamic: `cache-control: private, no-cache, no-store`, `MISS`.
- OBSERVED: **no JSON API on the web.** Across 181 requests the only same-origin fetches were `?_rsc=` navigations (`ev_c7e9…`). All 2,900 deals are inlined in a 1.5 MB home page and filtered in the browser, 60 at a time.
- OBSERVED: `/en-us/search` is a plain GET form (`q`, `genre`, `price`, `sale`, `sort`, `page`) over 19,783 games. Robots comments say about 25,000 games.
- OBSERVED: `eshopdeal.pages.dev` is Cloudflare, used for the privacy page and promo images. Web analytics and ads are GA4 and AdSense.
- OBSERVED (privacy policy): the app uses Firebase Auth, Firestore, Cloud Messaging, Analytics, Crashlytics, App Check and AdMob, plus Sign in with Apple, App Attest, Play Integrity and Coupang Partners. Wishlists stay on device unless signed in.
- OBSERVED: robots.txt carries the operator's own notes: per-request OG images cost 261–883 ms and dominated CPU; crawlers including AhrefsBot and ClaudeBot drove function bills; `_rsc=` URLs are disallowed. It says `Claude-User` is not blocked.
- OBSERVED: Android launched first on 2026-07-29, web alongside, iOS later; MY prices arrived in iOS 1.10.1 on 2026-10-17. One-person company. A Telegram channel posts new Korean sales each morning.
- UNKNOWN: how the app gets prices (Firestore, a Next route, or static files), and what triggers pushes.

## 3. Cross-country matching, history, lowest price

- OBSERVED: game ID is `{kr|eu|na|jp}-{nsuid}`, independent of storefront: the US list has 1,389 `kr`, 835 `eu`, 640 `na`, 36 `jp`. For `kr-70010000045187` the US buy link is nsuid `70010000045295` and HK is `70010000045188`, so a per-country nsuid map exists server-side.
- INFERRED: the prefix is the entity's source catalogue, likely preferring KR, then EU, NA, JP.
- OBSERVED (operator's own error list): similarly named products can be wrongly merged (bundle vs single, Switch 1 vs Switch 2 edition); Mario Kart World failed to pair because the Korean store gives only a Korean name.
- INFERRED (medium): matching is substantially title-based rather than a shared Nintendo ID. Exact rules are UNKNOWN. The data model has `sub` (alternate title) and a locale flag `koPairs`.
- OBSERVED: US pages show zh-Hant titles for some games (e.g. `百英雄傳`), with English only in `sub`. The en-us site runs in the `eshop-zh` route tree.
- OBSERVED: country table covers only countries with a matched price: 23 for Melty Blood, 10 for the Monster Hunter bundle. **Neither shows Malaysia, Singapore or Thailand.** There is no MY web locale: only ko, zh-tw, zh-hk, en-us, ja-jp.
- OBSERVED: history stores change points only: "We only log days when the price changed." Melty Blood has 4 rows since 9/7, drawn as a server-rendered step chart with a change list.
- OBSERVED: "observed low" means lowest since tracking began (2026-07-19 for Korea, 2026-09-07 for US), and the operator refuses the term "all-time low". Pages state the start date. A new match resets it: the MH bundle reads "since we started tracking on 10/31".
- OBSERVED: `cheaperAbroad` is the percent below local price at the best country (Melty: Chile $14.47 vs $20.99 = 31). Values run 5 to 88 across 2,643 deals. INFERRED: a 5% minimum.
- OBSERVED list fields: `id, title, sub, dc, lp, lb, img, img2, le, lsd, hwTag, zh, cheaperAbroad`.

## 4. Ranking, adult and shovelware filtering, ratings

**Ranking is what protects the list; no content filter is visible.**

- OBSERVED: default sort is absolute savings `lb − lp`. All 2,900 rows are in that exact order, pre-sorted by the server (`sortList` returns the list unchanged for `saved`). Weekly says "ranked by how much you save (regular price − sale price), not by percentage."
- OBSERVED: other sorts are discount %, lowest price, newest. Filters: on sale, new (`lsd` within 6 days), local language, ending in 0–3 days, cheaper abroad, 90%+. Device filter: all, Switch 2, Switch 1 playable. Search adds genre and price bands.
- OBSERVED: the first 60 cards have list prices of $34.99 or more; none of the top 200 lists at $9.99 or less. 15 suggestive-titled deals rank from 1220 to 2891 of 2,900, median 1977 (corrected: an earlier draft quoted only the three lowest).
- OBSERVED: weekly Top 20 allows "up to 3 games per publisher and one edition per game". "Finally on sale" needs 3 or more people waiting. "Most wanted" ranks by wishlists, then fills with most-viewed. "We don't accept paid placements."
- OBSERVED: keyword search of the 14 minified chunks found no `adult`, `nsfw`, `mature` or `shovel`; one `hide` hit was not read (corrected: an earlier draft called it unrelated). The deal list's filter code, which was read, has no content rule. Suggestive titles are present on home (e.g. "Virtual Girlfriend Dating Simulator", "Hot Spring Beauties Japanese Inn Date Memory", "A Tempting Life with My Neighbor").
- OBSERVED: of the 52 deals at 90%+, the lowest list price is $18.99. Of the top 100 by %, none list under $10. Of 472 deals at 80%+, 99 list at $9.99 or less.
- UNKNOWN: whether a server-side exclusion exists. That 90%+ floor could be a rule or just the US market; the payload cannot distinguish. Whether the app filters differently is also UNKNOWN.
- **Caveat, INFERRED:** savings sort defeats low list prices, not inflated ones. OBSERVED scale: an 87%-off $14.99 anime puzzle saves $13 and ranks 502 of 2,900, well above its peers but outside the first 60 cards. So a higher inflated list price would rise further; no such case was found on page one.
- OBSERVED ratings: "ESRB T · PEGI 12" on the US page, "PEGI 12 · ESRB T" on HK, with `conf.rating` set per locale: `esrbFirst`, `asIs`, `none` (Japan). The MH bundle page showed no rating row.
- INFERRED (medium): the answer to our empty `iarc`/`cero`: ratings are not from the Asian catalogue. ESRB likely comes from Nintendo's US data and PEGI from the European catalogue, joined through the cross-country entity. Exact source UNKNOWN. No CERO, GRAC or IARC appeared.
- OBSERVED: no critic scores (Metacritic, OpenCritic) on any page viewed. The privacy policy shows the app gathers its own signals: price polls ("Buy now", "If cheaper", "Not buying") and recommendations ("recommend", "not for me") with an "Owned" flag. Whether these feed ranking is UNKNOWN.

## 5. UX worth learning from

- OBSERVED nav: Deals, Weekly Top 20, New deals, Ending soon, All games.
- OBSERVED card: art with hardware badge, title, `-70%`, price, struck list price, then tags: amount saved, language, "N% cheaper abroad", and an end label stepping from date to "N days left" to "1 day left" to "Ends today".
- OBSERVED game page order: back and share; hero; facts (players, size, rating, developer, languages); price block with end date; plain-sentence verdict; data-range caveat; step chart and change list; country table, cheapest first, 5 rows then expand; description with a link to Nintendo's listing; screenshots; related games with reason labels ("Other edition", "Same genre"); prices-as-of date.
- OBSERVED list grouping: New deals is split by today and last 7 days, each by savings. Ending soon is by soonest end. iOS 1.10.5 groups by date, then publisher.
- OBSERVED copy: "We haven't been tracking for long, so this doesn't mean the price has never been lower."
- OBSERVED alerts claimed: 30/50/70% thresholds, sale start, lowest price, daily digest (App Store).

## What eShop Radar should copy

Ideas only, not code or data.

1. Make absolute MYR saved the default sort, with discount % as an opt-in.
2. For any curated list: cap per publisher and show one edition per game.
3. Store price history as change points and draw a step chart.
4. Keep the "observed low since {date}" wording, and restate the start date on the page.
5. Lead the game page with one plain sentence answering the buying question.
6. Label why a related game appears; label sale end in days as it nears.
7. Group "new" lists by found-today vs this week.
8. Monitor coverage per source and region, not just totals: their NA gap hid behind a healthy total.
9. Add our own gate they appear not to have: exclude low-trust rows from % ranking, e.g. a historical-price check for inflated list prices.

## What to avoid

- Title-only matching across regions without checks; wrong merges show another product's price.
- Letting a regional title leak into another locale's page.
- Sending the entire deal list to every client (1.5 MB), or rendering every game page uncached.
- Assuming savings sort removes shovelware by itself; see the caveat in section 4.
- Treating a single daily sweep as live: they state a lag and so should we.

## Open questions

1. **APK:** the real file must report package `com.solruna.eshopdeal` (`aapt2 dump badging`) before analysis. It would answer exact hostnames, the app's price path, app-side filtering and push logic. It may be served as `.xapk`, since the listing says "Varies with device".
2. Do our 94%-off adult titles have low or inflated MYR list prices? Query our own data. Low means savings sort fixes them; inflated means we need the gate in item 9.
3. Should we add a non-Malaysian lookup for ratings? It would need the same data-permission thinking as the rest of the sweep.
4. Is a server-side exclusion list in use? Not determinable from public pages.
5. Does their MY list match our 7,827 products? Unknown, since MY data is app-only.
