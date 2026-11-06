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

async function horizontalOverflow(page) {
  return page.evaluate(() => ({
    innerWidth: window.innerWidth,
    scrollWidth: document.documentElement.scrollWidth,
    bodyScrollWidth: document.body.scrollWidth
  }));
}

async function clippedInteractiveElements(page) {
  return page.locator('a[href], button, input, textarea, select').evaluateAll(nodes => nodes
    .filter(el => {
      const s = getComputedStyle(el);
      const r = el.getBoundingClientRect();
      return s.display !== 'none' && s.visibility !== 'hidden' && r.width > 0 && r.height > 0;
    })
    .filter(el => {
      const r = el.getBoundingClientRect();
      return r.right > window.innerWidth + 1 || r.left < -1;
    })
    .map(el => ({ tag: el.tagName.toLowerCase(), id: el.id || '', text: (el.innerText || el.value || '').trim().slice(0, 80) }))
  );
}

for (const [name, path] of pages) {
  test(`${name}: Reflow bei 320 CSS px`, async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 900 });
    await page.goto(path);

    const overflow = await horizontalOverflow(page);
    expect(overflow.scrollWidth, JSON.stringify(overflow)).toBeLessThanOrEqual(321);

    const clipped = await clippedInteractiveElements(page);
    expect(clipped, JSON.stringify(clipped, null, 2)).toEqual([]);
  });

  test(`${name}: Reflow bei 200 Prozent Äquivalent`, async ({ page }) => {
    await page.setViewportSize({ width: 640, height: 900 });
    await page.goto(path);

    const overflow = await horizontalOverflow(page);
    expect(overflow.scrollWidth, JSON.stringify(overflow)).toBeLessThanOrEqual(641);

    const clipped = await clippedInteractiveElements(page);
    expect(clipped, JSON.stringify(clipped, null, 2)).toEqual([]);
  });
}
