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

const focusableSelector = [
  'a[href]', 'button:not([disabled])', 'input:not([disabled]):not([type="hidden"])',
  'select:not([disabled])', 'textarea:not([disabled])', '[tabindex]:not([tabindex="-1"])'
].join(',');

async function visibleFocusableCount(page) {
  return await page.locator(focusableSelector).evaluateAll(nodes => nodes.filter(node => {
    const style = getComputedStyle(node);
    const rect = node.getBoundingClientRect();
    return style.display !== 'none' && style.visibility !== 'hidden' && rect.width > 0 && rect.height > 0;
  }).length);
}

async function focusDescriptor(page) {
  return await page.evaluate(() => {
    const el = document.activeElement;
    if (!el || el === document.body) return null;
    return `${el.tagName.toLowerCase()}#${el.id || ''}.${el.className || ''}`;
  });
}

async function focusIsVisible(page) {
  return await page.evaluate(() => {
    const el = document.activeElement;
    if (!el || el === document.body) return false;
    const s = getComputedStyle(el);
    const outlineWidth = parseFloat(s.outlineWidth || '0');
    const outlineVisible = s.outlineStyle !== 'none' && outlineWidth > 0;
    const boxShadowVisible = s.boxShadow && s.boxShadow !== 'none';
    const borderChanged = parseFloat(s.borderWidth || '0') > 0;
    return outlineVisible || boxShadowVisible || borderChanged;
  });
}

test.describe('CoreCraft Genesis Tastatur und Fokus', () => {
  for (const [name, path] of pages) {
    test(`${name}: Tab-Reihenfolge ohne Trap und sichtbarer Fokus`, async ({ page }) => {
      await page.goto(path);
      const count = await visibleFocusableCount(page);
      expect(count).toBeGreaterThan(0);

      const seen = [];
      let visibleFocusSeen = false;
      const presses = Math.min(count + 4, 80);

      for (let i = 0; i < presses; i++) {
        await page.keyboard.press('Tab');
        const descriptor = await focusDescriptor(page);
        if (descriptor) seen.push(descriptor);
        if (await focusIsVisible(page)) visibleFocusSeen = true;
      }

      expect(seen.length).toBeGreaterThan(0);
      expect(new Set(seen).size).toBeGreaterThan(1);
      expect(visibleFocusSeen).toBeTruthy();
    });
  }

  test('File Validator: zentrale Steuerelemente sind per Tastatur erreichbar', async ({ page }) => {
    await page.goto('/products/developer-tools/validators/file/');
    for (const id of ['fileInput', 'expectedName', 'expectedExtensions', 'maxSize', 'validateButton', 'copyButton', 'clearButton']) {
      const locator = page.locator(`#${id}`);
      await expect(locator).toHaveCount(1);
      await locator.focus();
      await expect(locator).toBeFocused();
    }
  });

  test('Schema Validator: Buttons reagieren auf Enter', async ({ page }) => {
    await page.goto('/products/developer-tools/validators/schema/');
    const example = page.getByRole('button', { name: /Beispiel laden/i });
    await example.focus();
    await expect(example).toBeFocused();
    await page.keyboard.press('Enter');
    const values = await page.locator('textarea').evaluateAll(nodes => nodes.map(n => n.value));
    expect(values.some(v => v.trim().length > 0)).toBeTruthy();
  });

  test('Link Checker: Extraktion kann per Enter ausgelöst werden', async ({ page }) => {
    await page.goto('/products/developer-tools/web-tools/link-checker/');
    await page.locator('#baseUrl').fill('https://corecraftgenesis.ch/');
    await page.locator('#htmlInput').fill('<a href="/products/">Produkte</a>');
    await page.locator('#extractButton').focus();
    await expect(page.locator('#extractButton')).toBeFocused();
    await page.keyboard.press('Enter');
    await expect(page.locator('#totalValue')).toHaveText('1');
  });
});
