# Back-translation check: landing and Android pages, 2026-11-23

Method as in `apps/flutter_app/l10n/backtranslation-2026-11-22.md`. A fresh checker was given only
`zh.json` and `ms.json`, never the English, and translated every value back. It flagged anything unnatural,
ambiguous, Indonesian, overclaiming, or out of line with what iOS shows. Terms follow
`apps/flutter_app/l10n/glossary.md`.

**Result.** No line overclaims. Both languages carry the unofficial line and "not endorsed" throughout, and
store apps are "planned" (计划中 / dirancang), never "coming soon". The Malay never reads as a sale already
over: it uses "sehingga bila … berlangsung" and "tarikh akhir". No word is Indonesian.

**iOS labels** match iOS in each language: 共享 and 添加到主屏幕; Kongsi and Tambah ke Skrin Utama. The
checker confirmed them, and so do third-party guides: WidgetClub (ms,
https://widget-club.com/ms/article/safari-add-homescreen) for the Malay labels, and Apeaksoft (zh-CN,
https://www.apeaksoft.com/zh-CN/ios-tips/add-safari-to-iphone-home-screen/) for 添加到主屏幕. No guide we
found shows 共享 on its own; that label rests on the checker's knowledge of iOS. No Apple support page in
Malay or Simplified Chinese came up in search.

## Fixed after the check

| key | before | back-translated as | after |
|---|---|---|---|
| zh promise | 每天自己记录 | "records by itself" (could mean automatically) | 每天自行记录 |
| ms promise | rekod harian harga eShop Malaysia sendiri | "Malaysia's own eShop" | rekod hariannya sendiri bagi harga eShop Malaysia; "supaya anda boleh melihat" |
| ms get2 | dalam waktu Malaysia | "within a period" reading | mengikut waktu Malaysia |
| ms get3 | yang mana dalam promosi | loose tense | yang mana sedang dalam promosi |
| ms runsWeb/Android/Iphone | sekarang | clipped "now" | tersedia sekarang |
| ms faqTitle | Soalan | "Questions" | Soalan Lazim (the usual heading) |
| ms faqOfficialA | Ia projek … harga awam | casual; "public price" odd | Ia merupakan projek … harga … yang terbuka kepada umum |
| ms faqRemoveA | E-mel {email}. | terse command | Hantar e-mel ke {email}. |
| all iphoneStep2 | Tap Share. | the checker noted that newer iOS Safari can put Share behind the ••• button | adds "if you don't see it, tap ••• first" in each language |

## Kept on purpose

- ms "tidak diiktiraf oleh Nintendo" (the checker suggested "disokong/direstui"). This is the glossary's
  fixed wording for the unofficial line, the same as in the app.
- ms "Dari mana data kami datang" (the checker called it a calque). It is the app's own title for that page,
  and the link names that page. Changing it belongs in the app's ARB first.
- zh 账号: the app's own word, widely understood in Malaysia.
- ms "Penjejak tidak rasmi …" in the meta description: slightly stilted, but moving "tidak rasmi" later
  would make it seem to modify "ringgit".
