// Checks the built site in a real browser: every page and link, the buttons by device, the language carried
// into the app, accessibility, no third-party requests, and the app at /app/.
// usage: PLAYWRIGHT=<path to playwright> AXE=<path to axe.min.js> [NSUID=<a game id>] node tool/check.js <base URL>
// Prints one PASS/FAIL line per case and exits 1 if any failed.
const { chromium } = require(process.env.PLAYWRIGHT || 'playwright');

const base = (process.argv[2] || '').replace(/\/$/, '');
if (!base || !process.env.AXE) throw new Error('usage: AXE=<axe.min.js> node tool/check.js <base URL>');
const origin = new URL(base).origin;
const nsuid = process.env.NSUID || '70010000109166';
const PAGES = ['/', '/zh/', '/ms/', '/android/', '/zh/android/', '/ms/android/'];
const UA = {
  android: 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36',
  iphone: 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1',
  ipad: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15',
};

let failed = 0;
async function check(name, fn) {
  try {
    await fn();
    console.log('PASS', name);
  } catch (e) {
    failed++;
    console.log('FAIL', name, '-', e.message.split('\n')[0]);
  }
}
function assert(ok, msg) {
  if (!ok) throw new Error(msg);
}

(async () => {
  const browser = await chromium.launch();
  const ctx = (opts = {}) => browser.newContext({ viewport: { width: 390, height: 844 }, ...opts });
  // stands in for the app, so a click on "Open" is checked without loading Flutter
  const stubApp = (page) => page.route(/\/app\//, (r) => r.fulfill({ contentType: 'text/html', body: '<p>app</p>' }));
  const order = (page) => page.$$eval('#cta > *', (els) => els.map((e) => `${e.id}${e.hidden ? ':hidden' : ''}`).join(','));
  const cls = (page, sel) => page.$eval(sel, (e) => e.className);

  await check('pages, no-third-party, no-console-errors', async () => {
    const c = await ctx();
    const page = await c.newPage();
    const problems = [];
    page.on('request', (r) => { if (!r.url().startsWith(origin) && !r.url().startsWith('data:')) problems.push('third party: ' + r.url()); });
    page.on('console', (m) => { if (m.type() === 'error') problems.push(`console: ${m.text()} (${m.location().url})`); });
    page.on('pageerror', (e) => problems.push('page error: ' + e.message));
    page.on('requestfailed', (r) => problems.push(`failed: ${r.url()} ${r.failure().errorText}`));
    for (const p of PAGES) {
      const res = await page.goto(base + p, { waitUntil: 'networkidle' });
      assert(res.status() === 200, `${p} answered ${res.status()}`);
    }
    await c.close();
    assert(problems.length === 0, problems.join('; '));
  });

  await check('links', async () => {
    const c = await ctx();
    const page = await c.newPage();
    const hrefs = new Set();
    for (const p of PAGES) {
      await page.goto(base + p);
      for (const h of await page.$$eval('a[href]', (as) => as.map((a) => a.href))) hrefs.add(h);
    }
    const bad = [];
    for (const h of hrefs) {
      if (h.startsWith('mailto:')) continue;
      const res = await c.request.get(h, { maxRedirects: 5 });
      if (res.status() >= 400) bad.push(`${h} ${res.status()}`);
    }
    await c.close();
    assert(bad.length === 0, bad.join('; '));
  });

  await check('desktop-order', async () => {
    const c = await ctx({ viewport: { width: 1280, height: 900 } });
    const page = await c.newPage();
    await page.goto(base + '/');
    assert((await order(page)) === 'open,android,iphone:hidden', 'order ' + (await order(page)));
    assert((await cls(page, '#open')).includes('primary'), 'Open is not red');
    await c.close();
  });

  await check('android-order', async () => {
    const c = await ctx({ userAgent: UA.android, isMobile: true, hasTouch: true });
    const page = await c.newPage();
    await page.goto(base + '/ms/');
    assert((await order(page)) === 'android,open,iphone:hidden', 'order ' + (await order(page)));
    assert((await cls(page, '#android a')).includes('primary'), 'Android is not red');
    assert((await cls(page, '#open')).includes('secondary'), 'Open is still red');
    await c.close();
  });

  for (const [name, opts, init] of [
    ['iphone', { userAgent: UA.iphone, isMobile: true, hasTouch: true }, null],
    ['ipad', { userAgent: UA.ipad, hasTouch: true }, () => Object.defineProperty(Navigator.prototype, 'maxTouchPoints', { get: () => 5 })],
  ]) {
    await check(name, async () => {
      const c = await ctx(opts);
      if (init) await c.addInitScript(init);
      const page = await c.newPage();
      await page.goto(base + '/zh/');
      assert((await order(page)) === 'open,android:hidden,iphone', 'order ' + (await order(page)));
      await page.click('#iphone summary');
      assert((await page.locator('#iphone li').count()) === 3, 'no three steps');
      assert(await page.locator('#iphone ol').isVisible(), 'steps not shown');
      await c.close();
    });
  }

  await check('no-js', async () => {
    const c = await ctx({ javaScriptEnabled: false, userAgent: UA.iphone });
    const page = await c.newPage();
    await page.goto(base + '/');
    assert((await order(page)) === 'open,android,iphone:hidden', 'order ' + (await order(page)));
    await c.close();
  });

  await check('lang-carry', async () => {
    const stored = async (path, steps) => {
      const c = await ctx();
      const page = await c.newPage();
      await stubApp(page);
      await page.goto(base + path);
      await steps(page);
      await page.waitForURL(/\/app\//);
      const v = await page.evaluate(() => localStorage.getItem('flutter.locale'));
      await c.close();
      return v;
    };
    const zh = await stored('/zh/', (p) => p.click('#open'));
    assert(zh === '"zh"', `/zh/ then Open stored ${zh}`);
    const plain = await stored('/', (p) => p.click('#open'));
    assert(plain === null, `/ then Open stored ${plain}`);
    const en = await stored('/zh/', async (p) => {
      await p.click('.sw a[data-lang="en"]');
      await p.waitForURL(base + '/');
      await p.click('#open');
    });
    assert(en === '"en"', `EN switch then Open stored ${en}`);
  });

  await check('storage-blocked', async () => {
    const c = await ctx();
    await c.addInitScript(() => { Storage.prototype.setItem = () => { throw new Error('blocked'); }; });
    const page = await c.newPage();
    await stubApp(page);
    await page.goto(base + '/zh/');
    await page.click('#open');
    await page.waitForURL(/\/app\/$/, { timeout: 5000 });
    await c.close();
  });

  await check('status-down', async () => {
    const c = await ctx();
    const page = await c.newPage();
    const errors = [];
    page.on('pageerror', (e) => errors.push(e.message));
    await page.route('**/v1/status/prices', (r) => r.abort());
    const html = await (await c.request.get(base + '/')).text();
    const built = html.match(/<span data-count>([^<]*)<\/span>/)[1];
    await page.goto(base + '/', { waitUntil: 'networkidle' });
    const shown = await page.textContent('[data-count]');
    await c.close();
    assert(shown === built, `count ${shown}, built ${built}`);
    assert(errors.length === 0, errors.join('; '));
  });

  await check('overflow-320', async () => {
    const c = await ctx({ viewport: { width: 320, height: 640 } });
    const page = await c.newPage();
    const wide = [];
    for (const p of PAGES) {
      await page.goto(base + p);
      const [sw, iw] = await page.evaluate(() => [document.documentElement.scrollWidth, window.innerWidth]);
      if (sw > iw) wide.push(`${p} ${sw}>${iw}`);
    }
    await c.close();
    assert(wide.length === 0, wide.join('; '));
  });

  await check('a11y (light and dark)', async () => {
    const found = [];
    for (const colorScheme of ['light', 'dark']) {
      const c = await ctx({ colorScheme });
      const page = await c.newPage();
      for (const p of PAGES) {
        await page.goto(base + p, { waitUntil: 'networkidle' });
        await page.addScriptTag({ path: process.env.AXE });
        const v = await page.evaluate(() =>
          axe.run(document, { runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa'] } }).then((r) =>
            r.violations.map((x) => `${x.id} (${x.nodes.length}: ${x.nodes[0].target})`)));
        for (const x of v) found.push(`${colorScheme} ${p} ${x}`);
      }
      await c.close();
    }
    assert(found.length === 0, found.join('; '));
  });

  await check('app', async () => {
    const c = await ctx();
    const page = await c.newPage();
    const bad = [];
    page.on('response', (r) => {
      if (!r.url().startsWith(origin)) return;
      if (r.status() >= 400) bad.push(`${r.url()} ${r.status()}`);
      // a missing font answered with the app's index.html breaks text silently
      if (/\.(woff2?|ttf|otf)$/.test(r.url()) && (r.headers()['content-type'] || '').includes('text/html')) bad.push(`${r.url()} is HTML`);
    });
    // a navigation cancels the previous page's requests (ERR_ABORTED); anything else is a real failure
    page.on('requestfailed', (r) => { if (r.url().startsWith(origin) && r.failure().errorText !== 'net::ERR_ABORTED') bad.push(`${r.url()} ${r.failure().errorText}`); });
    await page.goto(base + '/app/', { waitUntil: 'networkidle' });
    const workers = await page.evaluate(() => navigator.serviceWorker.getRegistrations().then((r) => r.length));
    assert(workers === 0, `the app registered ${workers} service worker(s)`);
    const game = page.waitForResponse((r) => r.url().includes(`/v1/games/${nsuid}`), { timeout: 60000 });
    await page.goto(`${base}/app/games/${nsuid}`);
    const res = await game;
    await page.waitForTimeout(3000);
    await c.close();
    assert(res.status() === 200, `/v1/games/${nsuid} answered ${res.status()}`);
    assert(bad.length === 0, bad.join('; '));
  });

  await check('carry', async () => {
    // web app data lives per address: the old address hands it over (carry.html) and the app's index.html merges it
    const OLD = 'https://ringgit-radar-mu.vercel.app', NEW = 'https://ringgitradar.snitco.com';
    const c = await ctx();
    // both addresses are served from base, documents only, so this runs before a deploy and Flutter never starts
    for (const host of [OLD, NEW]) await c.route(host + '/**', async (r) => {
      if (r.request().resourceType() !== 'document') return r.abort();
      const path = r.request().url().slice(host.length).split('#')[0];
      if (path === '/seed') return r.fulfill({ contentType: 'text/html', body: '<p>seed</p>' });
      return r.fulfill({ response: await c.request.get(base + path) });
    });
    const page = await c.newPage();
    const store = (o) => page.evaluate((o) => { for (const [k, v] of Object.entries(o)) localStorage.setItem(k, v); }, o);
    const read = () => page.evaluate(() => Object.fromEntries(Object.entries(localStorage)));
    await page.goto(OLD + '/seed');
    await store({ 'flutter.wishlist': '["70010000109166","1"]', 'flutter.locale': '"zh"', 'flutter.notice_seen': 'true', other: 'x' });
    await page.goto(NEW + '/seed');
    await store({ 'flutter.wishlist': '["2","1"]', 'flutter.locale': '"en"' });
    await page.goto(OLD + '/carry.html?p=/games/70010000109166&ref=x');
    await page.waitForURL(NEW + '/app/games/70010000109166?ref=x', { timeout: 5000 });
    let s = await read();
    assert(s['flutter.wishlist'] === '["2","1","70010000109166"]', 'wishlist ' + s['flutter.wishlist']);
    assert(s['flutter.locale'] === '"en"' && s['flutter.notice_seen'] === 'true' && !('other' in s), JSON.stringify(s));
    // a link made anywhere else can't write into someone's storage
    await page.goto(NEW + '/app/#carry=' + encodeURIComponent(JSON.stringify({ 'flutter.wishlist': '["666"]' })));
    s = await read();
    assert(s['flutter.wishlist'] === '["2","1","70010000109166"]', 'a foreign link wrote ' + s['flutter.wishlist']);
    assert(!page.url().includes('#'), 'fragment left in ' + page.url());
    await c.close();
  });

  await check('slashes', async () => {
    const c = await ctx();
    const bad = [];
    for (const p of ['/zh', '/ms', '/android', '/zh/android', '/ms/android', '/app']) {
      const res = await c.request.get(base + p, { maxRedirects: 5 });
      if (res.status() !== 200 || !res.url().endsWith(p + '/')) bad.push(`${p} → ${res.url()} ${res.status()}`);
    }
    await c.close();
    assert(bad.length === 0, bad.join('; '));
  });

  await browser.close();
  console.log(failed ? `${failed} failed` : 'all passed');
  process.exit(failed ? 1 : 0);
})();
