const { test, expect } = require('@playwright/test');

const PAGE_PATH = '/products/developer-tools/web-tools/link-checker/';

async function extract(page, html, baseUrl = 'https://corecraftgenesis.ch/') {
  await page.locator('#baseUrl').fill(baseUrl);
  await page.locator('#htmlInput').fill(html);
  await page.locator('#extractButton').click();
  await expect(page.locator('#status')).not.toContainText(/Zuerst Links extrahieren/i);
}

test.describe('CoreCraft Genesis Link Checker', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(PAGE_PATH);
    await expect(page.locator('body')).toContainText(/Link Checker/i);
  });

  test('externe JavaScript-Datei wird geladen', async ({ page }) => {
    await expect(page.locator('script[src="./assets/js/link-checker.js"]')).toHaveCount(1);
  });

  test('extrahiert und klassifiziert interne, externe und spezielle Links', async ({ page }) => {
    const html = [
      '<a href="/products/">Produkte</a>',
      '<a href="https://example.com/">Extern</a>',
      '<a href="mailto:test@example.com">E-Mail</a>'
    ].join('\n');

    await extract(page, html);

    await expect(page.locator('#totalValue')).toHaveText('3');
    await expect(page.locator('#internalValue')).toHaveText('1');
    await expect(page.locator('#externalValue')).toHaveText('1');
    await expect(page.locator('#specialValue')).toHaveText('1');
    await expect(page.locator('#duplicateValue')).toHaveText('0');
    await expect(page.locator('#resultList')).toContainText('/products/');
    await expect(page.locator('#resultList')).toContainText('example.com');
  });

  test('erkennt doppelte Links', async ({ page }) => {
    const html = [
      '<a href="/products/">Produkte A</a>',
      '<a href="/products/">Produkte B</a>'
    ].join('\n');

    await extract(page, html);

    await expect(page.locator('#totalValue')).toHaveText('2');
    await expect(page.locator('#duplicateValue')).toHaveText('2');
    await expect(page.locator('#resultList')).toContainText('/products/');
  });

  test('leeren setzt die Analyse zurück und verursacht keinen JavaScript-Fehler', async ({ page }) => {
    const pageErrors = [];
    page.on('pageerror', error => pageErrors.push(error.message));

    await extract(page, '<a href="/products/">Produkte</a>');
    await page.locator('#clearButton').click();

    await expect(page.locator('#totalValue')).toHaveText('0');
    await expect(page.locator('#htmlInput')).toHaveValue('');
    expect(pageErrors).toEqual([]);
  });
});
