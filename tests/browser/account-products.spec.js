const { test, expect } = require('@playwright/test');

const DOWNLOADS = '/account/downloads/';

test.describe('CoreCraft Genesis - Account Downloads Acceptance', () => {

  test('Account Downloads lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(DOWNLOADS);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(
      /\/account\/downloads\/?$/
    );
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(page.locator('html')).toHaveAttribute(
      'lang',
      /^(de|de-CH)$/i
    );

    await expect(page.locator('header')).toHaveCount(1);
    await expect(page.locator('main')).toHaveCount(1);
    await expect(page.locator('h1')).toHaveCount(1);
    await expect(page.locator('footer')).toHaveCount(1);
  });

  test('SEO-Grunddaten sind korrekt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(page).toHaveTitle(
      /Account Downloads.*CoreCraft Genesis/i
    );

    await expect(
      page.locator('meta[name="description"]')
    ).toHaveAttribute(
      'content',
      /.+/
    );

    await expect(
      page.locator('link[rel="canonical"]')
    ).toHaveAttribute(
      'href',
      'https://corecraftgenesis.ch/account/downloads/'
    );
  });

  test('H1 ist korrekt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(
      page.locator('h1')
    ).toContainText(
      /Persönliche Downloads transparent vorbereiten/i
    );
  });

  test('H2-Struktur ist vollständig', async ({ page }) => {
    await page.goto(DOWNLOADS);

    expect(
      await page.locator('h2').count()
    ).toBeGreaterThanOrEqual(5);

    const headings = [
      /Accountbezogene Bereitstellung ist vorbereitet/i,
      /Öffentliche Ressourcen bleiben separat verfügbar/i,
      /Zukünftige Bereitstellung folgt klaren Zuständen/i,
      /Downloads und Zugangsinformationen schützen/i,
      /Produktzugriff und Downloads getrennt verwalten/i,
      /Weitere Account-Ressourcen/i
    ];

    for (const heading of headings) {
 