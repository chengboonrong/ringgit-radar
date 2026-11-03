# GameBox (遊戲箱子) reverse-engineering notes

Static analysis of the Android APK, 2026-11-02. It was never installed or run, and no backend or discovered endpoint was
contacted. Code shows what the app could do, not what ran. The live server is outside this evidence.
Tags: **[CHANGED]** replaces an earlier listing-based statement, **[NEW]** comes from code. Untagged items stand from the listing pass.

## Artifact (verified)

- OBSERVED: `twgamebox.apk`, 31,506,312 bytes, SHA-256 `db2f93df35b88cad21347ac96669ebf780e7680b47f6dfd89a9f3ad6339206f3`,
  matches the supplied hash. Package `tw.com.gamebox`, version 9.0.4, code 89, minSdk 21, targetSdk 33. [ev_2b06dfc9...]
- OBSERVED: apksigner verifies v1, v2, v3. Signer cert SHA-256 `5feddad9baf369340758d2273c4b9a536f953e7c32aec0cb1aa497118c1816e4`,
  RSA 4096, DN `CN=Android, O=Google Inc.`. Source Stamp timestamp 2024-01-11 06:21 UTC, the same day as the store's 9.0.4 date.
- INFERRED: a genuine Play build under Play App Signing. Play publishes no fingerprint to compare with, so this rests on the
  stamp and date. Store title is 遊戲箱子, developer -DeF Studio-, iOS seller YEN CHUN Liu.
- Method: REA manifest and Flutter checks (`ev_40aa61988583...`: no Flutter), then `hermes-dec` 0.1.8 on the bundle. Names below
  are recovered from `assets/index.android.bundle` unless noted. Pseudo-JS is decompiled, so details can be imperfect.

## Embedded credentials (existence only, all values redacted)

- `res/values/strings.xml`: Firebase API key, crash-reporting key, app ID, web client ID, database URL, bucket; Facebook app ID and client token.
- Manifest: AdMob application ID. Bundle config module: 53 AdMob unit ID occurrences.
- Bundle: hardcoded TripleDES literals (two pairs) in `encryptAppleLogin` and `encryptRestfulEncrypt`.
- Bundle: AES-built `tipin` request token. Its key source was not traced because nothing here needs it. None were used or tested.
- No embedded instructions were found in target content.

## 1. Data sources [CHANGED: was UNKNOWN]

- OBSERVED: the client talks to its own backend. Config module lists `ws.gamebox.cool/graphql` (Apollo, HTTP),
  `ws://ws.gamebox.cool/graphql` (live comments), REST `ws.gamebox.cool/api/app/{calculateCountryCoverage, mergeMyGameCollectionV2,
  verifyAppleID, isValidUser}`, one Cloud Function `GameBoxAnnouncement` on project `gamecollect-9a7fd`, and WebViews on `woo.gamebox.cool`.
- OBSERVED: no `api.ec.nintendo.com`, `search.nintendo.jp`, or any Nintendo price or search host in the bundle. The only
  Nintendo strings are a `my.nintendo.com` help link (`GoldCoinLists`, opens externally) and one sample image on `cdn01.nintendo-europe.com`.
- OBSERVED: no client scraping found. `injectJavaScript` appears only in WebView and YouTube player library code.
- OBSERVED: 64 GraphQL documents: 35 queries, 28 mutations, 1 subscription, in `out/graphql.txt`. Versioned by name (`...V800`, `...V900`).
- OBSERVED: GraphQL calls send headers `tipin` (AES-encrypted JSON built with currency and login token getters) and `version` (900).
- UNKNOWN: how the backend obtains Nintendo data. That step is invisible from this APK.

## 2. Sale and price logic [CHANGED: now server-side by evidence]

- OBSERVED: `fetchGamePriceTableV900` returns finished values per country: `usdPrice twPrice cuPrice usdDiscountPrice twDiscountPrice
  cuDiscountPrice localPrice isDiscount discountUntil supportZH coin lowestPrice isSalesTerminated discountPercentage historyPoints
  cuVisaPrice specialSaleStatus`, plus `lowestPriceCountryName lowestCUPrice lowestSelectedPriceCountryName lowestSelectedCUPrice`.
- OBSERVED: list items carry `minUSDPrice minTWPrice minCUPrice minPriceCountryCode discountInfo{percentage...} isHistoryLowest isCountryLowest`.
- OBSERVED: the client only selects fields. `getCurrenctDiscountPriceInfo` picks `_price` and `_discount`. Local arithmetic is
  absent: `calculateDiscountPercentage` has no callers in this build, and cards read server `percentage`.
- INFERRED: conversion happens per request on the server, since `cu*` fields are returned and the token uses the chosen currency.
  `fetchCurrencyMap` supplies the picker. The FX source is UNKNOWN.
- OBSERVED: "near lowest" arrives as server booleans, with no threshold in the client. Labels are 近歷史低價 and 近最佳價格. Definition UNKNOWN.
- [CHANGED] Sparkline: `BezierLineChart` draws server `historyPoints` unchanged. Unit UNKNOWN. The earlier converted-price inference
  still fits the screenshots, but the conversion, if any, is server-side. The full chart is a WebView (`/GamePriceChart/`).
- [CHANGED] Argentina: the odd badge is explained by source, not formula. Badge is server `percentage`; prices are server `cu*`.
  `cuVisaPrice` is a separate value shown with an `MEP` tag linking to `/PriceNote/`. Its formula is UNKNOWN.
- [NEW] `localPrice` is a server-built display string. The client searches it for 未稅 (pre-tax) and then shows the price-note link.
- [NEW] `specialSaleStatus` is server text rendered as is. `isSalesTerminated` shows 已停售 (delisted).
- [CHANGED] Gold points are server field `coin`. The 5% rule from screenshots remains INFERRED.
- UNKNOWN: use of `api.ec.nintendo.com/v1/price` or `search.nintendo.jp` by the backend. The client neither calls nor names them.

## 3. Cross-region identity [CHANGED]

- OBSERVED: one `gameID` string keys every per-game call, and `priceList` holds a row per country. The string `nsuid` has zero hits
  in the bundle and no document requests it.
- OBSERVED: the sample record in the bundle has a 24-hex `id`. INFERRED: a backend-generated canonical ID, MongoDB ObjectId in shape.
- OBSERVED: the record folds regions into one: `enTitle jpTitle twTitle hkTitle`, `parentTitles{region value}`, `releaseDates{region value}`,
  `languages{region langs}`. Display regions are 日本, 香港, 歐洲, 美洲, 紐澳.
- OBSERVED: language is per country (`supportZH`) and crowd-sourced (`reportLanguage`, `fetchGameLanguageInfoV900` with `totalReportNum`).
- OBSERVED: users can correct data (`correctGameV900`), add tags (`addGameTags`) and vote on names (`voteGameName`).
- OBSERVED: bundles and DLC link through `isBundle isDLC hasDLC hasRelation`, `fetchDLCOfGameV900`, `fetchRelationOfGameV900`.
- UNKNOWN: the server's matching method, including how nsuids map to `gameID`.

## Regions and Malaysia [CHANGED: was UNKNOWN]

- OBSERVED: `CountryFlag` is a static map with no fallback, covering 45 codes: AR AT AU BE BG BR CA CH CL CO CY CZ DE DK EE ES FI FR
  GB GR HK HR HU IE IT JP KR LT LU LV MT MX NL NO NZ PE PL PT RO RU SE SI SK US ZA.
- OBSERVED: a 41-entry default list sits beside `LDBUserModel`: the same set minus BR, KR, RU, ZA.
- OBSERVED: **no MY in either list**, and no SG, TH, PH, ID, VN, IN or TW. "Malaysia" and "MYR" have zero hits in the bundle.
- Limit: live lists come from the server (`fetchAllCountryV900`), so the server could add a row, but this client has no flag for it.
  MYR in the currency picker stays UNKNOWN for the same reason.

## 4. Stack [CHANGED: was UNKNOWN]

- OBSERVED: React Native with Hermes (bytecode v89, RN version strings 0.70.10 and 0.72.3), entry `com.gameboxappv3.MainActivity`.
  Apollo Client with `InMemoryCache`, WebSocket link, a REST HTTP client (axios-like internals, name not present), Redux Toolkit
  slices, react-navigation, FastImage, AsyncStorage.
- OBSERVED: `_getPhoneID` stores a generated UUID. Local favourites and offline action logs merge through `mergeMyGameCollectionV2`.
- OBSERVED: Firebase Analytics, Crashlytics, Messaging and Auth; Google and Apple sign-in. The Facebook SDK remains although login was
  removed in favour of `transferFBAccount`.
- OBSERVED: AdMob banner, interstitial and other ad formats with consent support. Images are `imgUrl` values from the API, so the CDN is server-chosen.
- OBSERVED push: `changeNotifySetting` with `deviceToken`, and `isNotifyFavoritedOnSaleGame`. Send logic is server-side.

## 5. UI, curation and shovelware [CHANGED]

- OBSERVED: tabs Sale, Browse, Favourites, Search, Settings.
- OBSERVED Sale tab, in order: 接近最佳與歷史低價 (`HistoryLowest`, 9 cards), 關注排行 TOP 50 (`DailyLeader`, ranked), 限時特價 (preview `Hot`).
- OBSERVED Browse: 熱門推薦 `Hot`, 近期發布 `RecentReleased`, 派對遊戲 `PartyGame`, 精選 DLC `DLC`, plus NSO and name voting.
- [CHANGED] `MostDiscount` is defined in `GQGameSearchType` but referenced by no screen in this build. The store text still promises it.
- OBSERVED Sale sort: Hot first, then RatingScore, DiscountPercentage, Price, OnSaleStart, OnSaleEnd. Discount is opt-in.
- OBSERVED Browse sort: Hot, RatingScore, DiscussScore, FavoritedScore, PurchasedScore. Search sort: Hot, RatingScore, Price, ReleaseDate.
- OBSERVED Search filters: `isOnsale discountType isAvaliable isSupportTwLang playerNum categories gameType discountCountry`.
- OBSERVED: `fetchFamiListV900` joins Famitsu sales ranks to games through `connectGame`, an outside popularity signal.
- OBSERVED: country choice is stored per user (`changeFilterCountries`). `fetchCountrySettingInfo` returns `allGameNum`, `coverNum` per country and
  `defaultCountries`; the REST coverage call returns `coverageRate`, shown as 價格顯示涵蓋率.
- [CHANGED] Adult and shovelware: zero hits for adult, nsfw, shovel, blacklist, blocklist or a hidden flag. `ageRating` is display-only (`fetchGameInfo`).
- INFERRED: the visible defence is ordering by interest, ratings and near-low flags. `Hot` and `DailyLeader` formulas are UNKNOWN, and the
  server may filter without the client knowing. Whether shovelware reaches live lists is unverified.

## What eShop Radar should copy

Design suggestions based on the findings. Understanding only: no code or assets taken.

1. Remove biggest discount as a default list. GameBox's main lists do not use it, and discount is a sort the user chooses.
2. Compute prices, lows and flags on the backend. Ship `isHistoryLowest` and `isCountryLowest` style fields, and keep clients simple.
3. Keep the two-lows model: all countries, and the user's selected countries.
4. Key everything on your own canonical game ID, with region titles, dates and languages under it. Treat nsuids as per-region attributes.
5. Add coverage: for a chosen country set, show what share of the catalogue has a price.
6. Model edge states as data: delisted, pre-tax price, card-rate price, sale end, per-country language.
7. Add a quality signal that needs no user base: external review score or a sales chart joined to your IDs, as Fami is here.
8. Ship 30 days of points with the price table and load full history on demand.

## What to avoid

- Assuming a discount-only ranking can be saved by near-low alone: permanently discounted titles also sit near their low.
- Using GameBox's API as a source: it is private and token-guarded, and it was not tested.
- Hardcoding crypto secrets in a client. Anything shipped there is readable, as this review shows.
- Static region data that needs an app release, such as a flag map with no fallback.
- Plain `ws://` for live data, and any dependence on crowd data a private tool cannot gather.
- Treating GameBox as a Malaysia reference. It offers no regional model for you to borrow.

## Open questions

- How the backend gets Nintendo data, and whether it uses the Nintendo price and search APIs.
- FX source and rate timing; `cuVisaPrice`, `coin` and `historyPoints` definitions; near-low thresholds; `Hot` and `DailyLeader` formulas.
- Server-side matching of regional titles, and any server-side adult or shovelware filter.
- Whether the live server now returns extra countries or MYR, and whether it is still running. Answering this needs running the app, which was out of scope.
