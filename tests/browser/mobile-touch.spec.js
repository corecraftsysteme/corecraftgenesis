const { test, expect } = require('@playwright/test');

const pages = [
  ['Startseite', '/'],
  ['Developer Tools', '/products/developer-tools/'],
  ['File Validator', '/products/developer-tools/validators/file/'],
  ['Schema Validator', '/products/developer-tools/validators/schema/'],
  ['Manifest Inspector', '/products/developer-tools/diagnostics/manifest-inspector/'],
  ['Data Inspector', '/products/developer-tools/data-tools/data-inspector/'],
  ['Route Checker', '/products/developer-tools/web-tools/route-checker/'],
  ['Link Checker', '/products/developer-tools/web-tools/link-checker/']
];

const mobileProfiles = [
  ['Phone 390', { viewport: { width: 390, height: 844 }, deviceScaleFactor: 1, isMobile: true, hasTouch: true }],
  ['Phone 360', { viewport: { width: 360, height: 800 }, deviceScaleFactor: 1, isMobile: true, hasTouch: true }]
];

async function pageOverflow(page) {
  return page.evaluate(() => ({
    innerWidth: window.innerWidth,
    documentWidth: document.documentElement.scrollWidth,
    bodyWidth: document.body.scrollWidth
  }));
}

async function clippedControls(page) {
  return page.locator('button, input, textarea, select, a[href]').evaluateAll(nodes => nodes
    .filter(el => {
      const style = getComputedStyle(el);
      const r = el.getBoundingClientRect();
      return style.display !== 'none' && style.visibility !== 'hidden' && r.width > 0 && r.height > 0;
    })
    .filter(el => {
      const r = el.getBoundingClientRect();
      return r.left < -1 || r.right > window.innerWidth + 1;
    })
    .map(el => ({
      tag: el.tagName.toLowerCase(),
      id: el.id || '',
      text: (el.innerText || el.value || el.getAttribute('aria-label') || '').trim().slice(0, 80)
    }))
  );
}

async function undersizedNonInlineTargets(page) {
  return page.locator('button, input[type="button"], input[type="submit"], input[type="file"], select, [role="button"]').evaluateAll(nodes => nodes
    .filter(el => {
      const style = getComputedStyle(el);
      const r = el.getBoundingClientRect();
      return style.display !== 'none' && style.visibility !== 'hidden' && !el.disabled && r.width > 0 && r.height > 0;
    })
    .filter(el => {
      const r = el.getBoundingClientRect();
      return r.width < 24 || r.height < 24;
    })
    .map(el => {
      const r = el.getBoundingClientRect();
      return {
        tag: el.tagName.toLowerCase(), id: el.id || '',
        text: (el.innerText || el.value || el.getAttribute('aria-label') || '').trim().slice(0, 80),
        width: Number(r.width.toFixed(1)), height: Number(r.height.toFixed(1))
      };
    })
  );
}

for (const [profileName, profile] of mobileProfiles) {
  test.describe(profileName, () => {
    test.use(profile);

    for (const [name, path] of pages) {
      test(`${name}: mobile Layout und Touch-Ziele`, async ({ page }) => {
        await page.goto(path);

        const overflow = await pageOverflow(page);
        expect(overflow.documentWidth, JSON.stringify(overflow)).toBeLessThanOrEqual(overflow.innerWidth + 1);

        const clipped = await clippedControls(page);
        expect(clipped, `Abgeschnittene Controls:\n${JSON.stringify(clipped, null, 2)}`).toEqual([]);

        const undersized = await undersizedNonInlineTargets(page);
        expect(undersized, `Touch-Ziele unter 24x24 CSS px:\n${JSON.stringify(undersized, null, 2)}`).toEqual([]);
      });
    }
  });
}

test.describe('Touch-Interaktionen', () => {
  test.use({ viewport: { width: 393, height: 851 }, deviceScaleFactor: 2.75, isMobile: true, hasTouch: true });

  test('Schema Validator: Beispiel laden per Tap', async ({ page }) => {
    await page.goto('/products/developer-tools/validators/schema/');
    const button = page.getByRole('button', { name: /Beispiel laden/i });
    await button.tap();
    const values = await page.locator('textarea').evaluateAll(nodes => nodes.map(n => n.value));
    expect(values.some(v => v.trim().length > 0)).toBeTruthy();
  });

  test('Link Checker: Extraktion per Tap', async ({ page }) => {
    await page.goto('/products/developer-tools/web-tools/link-checker/');
    await page.locator('#baseUrl').fill('https://corecraftgenesis.ch/');
    await page.locator('#htmlInput').fill('<a href="/products/">Produkte</a>');
    await page.locator('#extractButton').tap();
    await expect(page.locator('#totalValue')).toHaveText('1');
  });

  test('File Validator: Leeren per Tap', async ({ page }) => {
    await page.goto('/products/developer-tools/validators/file/');
    await page.locator('#expectedName').fill('metafields.json');
    await page.locator('#clearButton').tap();
    await expect(page.locator('#expectedName')).toHaveValue('');
  });
});
