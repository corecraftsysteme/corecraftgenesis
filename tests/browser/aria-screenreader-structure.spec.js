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

for (const [name, path] of pages) {
  test(`${name}: Grundstruktur für assistive Technologien`, async ({ page }) => {
    await page.goto(path);

    await expect(page.locator('html')).toHaveAttribute('lang', /\S+/);
    expect((await page.title()).trim()).not.toBe('');
    await expect(page.getByRole('main')).toHaveCount(1);
    expect(await page.getByRole('heading').count()).toBeGreaterThan(0);

    const unnamed = await page.locator('button, input:not([type="hidden"]), textarea, select').evaluateAll(nodes =>
      nodes.filter(el => {
        const style = getComputedStyle(el);
        const r = el.getBoundingClientRect();
        if (style.display === 'none' || style.visibility === 'hidden' || r.width === 0 || r.height === 0) return false;
        const id = el.id;
        const explicit = id && document.querySelector(`label[for="${CSS.escape(id)}"]`);
        const wrapping = el.closest('label');
        const aria = el.getAttribute('aria-label') || el.getAttribute('aria-labelledby');
        const title = el.getAttribute('title');
        const buttonText = el.tagName === 'BUTTON' && el.textContent.trim();
        return !(explicit || wrapping || aria || title || buttonText);
      }).map(el => ({ tag: el.tagName.toLowerCase(), id: el.id || '', type: el.getAttribute('type') || '' }))
    );

    expect(unnamed, `Unbenannte Controls:\n${JSON.stringify(unnamed, null, 2)}`).toEqual([]);
  });
}
