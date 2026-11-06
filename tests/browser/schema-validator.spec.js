const { test, expect } = require('@playwright/test');

const PAGE_PATH = '/products/developer-tools/validators/schema/';

test.describe('CoreCraft Genesis Schema Validator', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(PAGE_PATH);
    await expect(page.locator('body')).toContainText(/Schema Validator/i);
  });

  test('externe JavaScript-Datei wird geladen', async ({ page }) => {
    await expect(page.locator('script[src="./assets/js/schema-validator.js"]')).toHaveCount(1);
  });

  test('Beispiel laden funktioniert ohne JavaScript-Fehler', async ({ page }) => {
    const pageErrors = [];
    page.on('pageerror', error => pageErrors.push(error.message));

    const button = page.getByRole('button', { name: /Beispiel laden/i });
    await expect(button).toHaveCount(1);
    await button.click();

    const textareas = page.locator('textarea');
    expect(await textareas.count()).toBeGreaterThan(0);
    const values = await textareas.evaluateAll(nodes => nodes.map(n => n.value));
    expect(values.some(value => value.trim().length > 0)).toBeTruthy();
    expect(pageErrors).toEqual([]);
  });

  test('Validator kann nach Beispiel-Laden ausgeführt werden', async ({ page }) => {
    const pageErrors = [];
    page.on('pageerror', error => pageErrors.push(error.message));

    await page.getByRole('button', { name: /Beispiel laden/i }).click();

    const validateButton = page.getByRole('button', { name: /validieren|prüfen|schema.*prüfen/i }).first();
    await expect(validateButton).toHaveCount(1);
    await validateButton.click();

    await expect(page.locator('body')).not.toContainText(/Noch keine Validierung durchgeführt/i);
    expect(pageErrors).toEqual([]);
  });

  test('Leeren setzt Eingaben zurück', async ({ page }) => {
    await page.getByRole('button', { name: /Beispiel laden/i }).click();
    const clearButton = page.getByRole('button', { name: /^Leeren$/i });
    await expect(clearButton).toHaveCount(1);
    await clearButton.click();

    const textareas = page.locator('textarea');
    const values = await textareas.evaluateAll(nodes => nodes.map(n => n.value));
    expect(values.every(value => value === '')).toBeTruthy();
  });
});
