// Captures the landing pages' phone screenshots and link-preview pictures from the live app.
// usage: PLAYWRIGHT=<path to playwright> node tool/shoot.js <app base URL> <nsuid> [scroll px]
// Writes static/shot-<lang>.webp (needs cwebp) and static/og-<lang>.png for en, zh, ms. Pick a game that is
// on sale and has some price history, and look at every image: no Nintendo, Switch or eShop words, no
// Nintendo marks, no game art filling the frame.
const { chromium } = require(process.env.PLAYWRIGHT || 'playwright');
const { execFileSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const [base, nsuid, scroll = '520'] = process.argv.slice(2);
if (!base || !nsuid) throw new Error('usage: node tool/shoot.js <app base URL> <nsuid> [scroll px]');
const site = path.join(__dirname, '..');
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'rr-shoot-'));
// the preview page is set from a string, so it can't load files: everything goes in as data URIs
const data = (file, type) => `data:${type};base64,${fs.readFileSync(file).toString('base64')}`;
const font = (f) => data(path.join(site, 'static', 'fonts', f), 'font/woff2');
const icon = data(path.join(site, 'static', 'icon-192.png'), 'image/png');

const og = (tagline, shot, zh) => `<!doctype html><html><head><meta charset="utf-8"><style>
@font-face { font-family: M; font-weight: 700; src: url(${font('MPLUSRounded1c-Bold.woff2')}); }
@font-face { font-family: Z; font-weight: 700; src: url(${font('RinggitZh-Bold.woff2')}); }
html, body { margin: 0; width: 1200px; height: 630px; overflow: hidden; background: #EAEAEA; font-family: M, ${zh ? 'Z,' : ''} sans-serif; color: #1A1A1A; }
.bar { position: absolute; left: 0; top: 0; bottom: 0; width: 24px; background: #C8102E; }
.words { position: absolute; left: 96px; top: 150px; width: 560px; }
.words img { width: 112px; height: 112px; border-radius: 26px; }
h1 { font-size: 76px; line-height: 1.05; margin: 36px 0 18px; }
p { font-size: 40px; line-height: 1.3; margin: 0; color: #5C5C5C; font-weight: 700; }
.phone { position: absolute; right: 80px; top: 115px; width: 400px; height: 380px; border-radius: 32px; overflow: hidden; /* ends under the chart, before any store name */
  border: 10px solid #1A1A1A; background: #fff; box-shadow: 0 20px 60px rgb(0 0 0 / .25); }
.phone img { width: 100%; display: block; margin-top: -92px; } /* starts at the sale line, above the game art */
</style></head><body><div class="bar"></div>
<div class="words"><img src="${icon}" alt=""><h1>Ringgit Radar</h1><p>${tagline}</p></div>
<div class="phone"><img src="${data(shot, 'image/png')}" alt=""></div></body></html>`;

(async () => {
  const browser = await chromium.launch();
  for (const lang of ['en', 'zh', 'ms']) {
    const ctx = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, locale: 'en-US' });
    await ctx.addInitScript((l) => {
      localStorage.setItem('flutter.locale', JSON.stringify(l));
      localStorage.setItem('flutter.notice_seen', 'true');
    }, lang);
    const page = await ctx.newPage();
    await page.goto(`${base}/games/${nsuid}`);
    await page.waitForTimeout(8000);
    await page.mouse.move(195, 500);
    await page.mouse.wheel(0, Number(scroll));
    await page.waitForTimeout(2500);
    const png = path.join(tmp, `shot-${lang}.png`);
    await page.screenshot({ path: png });
    await ctx.close();
    execFileSync('cwebp', ['-quiet', '-q', '80', '-resize', '780', '0', png, '-o', path.join(site, 'static', `shot-${lang}.webp`)]);

    const text = JSON.parse(fs.readFileSync(path.join(site, 'text', `${lang}.json`), 'utf8'));
    const p = await browser.newPage({ viewport: { width: 1200, height: 630 } });
    await p.setContent(og(text.ogTagline, png, lang === 'zh'));
    await p.waitForTimeout(500);
    await p.screenshot({ path: path.join(site, 'static', `og-${lang}.png`) });
    await p.close();
    console.log(lang, 'done');
  }
  await browser.close();
})();
