const { test, expect } = require('@playwright/test');

async function expectLiveStatus(locator) {
  await expect(locator).toHaveCount(1);
  const semantics = await locator.evaluate(el => ({
    role: el.getAttribute('role'),
    ariaLive: el.getAttribute('aria-live'),
    ariaAtomic: el.getAttribute('aria-atomic')
  }));
  expect(
    semantics.role === 'status' || semantics.role === 'alert' || ['polite', 'assertive'].includes(semantics.ariaLive),
    JSON.stringify(semantics)
  ).toBeTruthy();
}

test('File Validator: Statusbereich ist als Live-Region ausgezeichnet', async ({ page }) => {
  await page.goto('/products/developer-tools/validators/file/');
  await expectLiveStatus(page.locator('#status'));
});

test('Schema Validator: dynamischer Status ist screenreader-tauglich', async ({ page }) => {
  await page.goto('/products/developer-tools/validators/schema/');
  const status = page.locator('#status');
  await expectLiveStatus(status);
  const before = await status.textContent();
  await page.getByRole('button', { name: /Beispiel laden/i }).click();
  await expect(status).not.toHaveText(before || '');
});

test('Data Inspector: dynamischer Status ist screenreader-tauglich', async ({ page }) => {
  await page.goto('/products/developer-tools/data-tools/data-inspector/');
  const status = page.locator('#status');
  await expectLiveStatus(status);
  await page.locator('#exampleButton').click();
  await page.locator('#inspectButton').click();
  await expect(status).not.toBeEmpty();
});

test('Route Checker: Statusbereich ist als Live-Region ausgezeichnet', async ({ page }) => {
  await page.goto('/products/developer-tools/web-tools/route-checker/');
  await expectLiveStatus(page.locator('#status'));
});

test('Link Checker: dynamischer Status ist screenreader-tauglich', async ({ page }) => {
  await page.goto('/products/developer-tools/web-tools/link-checker/');
  const status = page.locator('#status');
  await expectLiveStatus(status);
  await page.locator('#baseUrl').fill('https://corecraftgenesis.ch/');
  await page.locator('#htmlInput').fill('<a href="/products/">Produkte</a>');
  const before = await status.textContent();
  await page.locator('#extractButton').click();
  await expect(status).not.toHaveText(before || '');
  await expect(status).not.toBeEmpty();
});
