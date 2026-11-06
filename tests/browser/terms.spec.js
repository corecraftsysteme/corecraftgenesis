const { test, expect } = require('@playwright/test');

const PAGE = '/legal/terms/';
const NAME = 'Terms';
const TITLE = /Nutzungsbedingungen.*CoreCraft Genesis/i;
const H1 = 'Nutzungsbedingungen';
const CANONICAL = 'https://corecraftgenesis.ch/legal/terms/';

test.describe(`CoreCraft Genesis - ${NAME} Acceptance`, () => {

  test(`${NAME} lädt erfolgreich`, async ({ page }) => {
    const response = await page.goto(PAGE);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(new RegExp(
      PAGE.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '?$'
    ));
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(PAGE);

    await expect(page.locator('html')).toHaveAttribute(
      'lang',
      /^(de|de-CH)$/i
    );

    await expect(page.locator('header')).toHaveCount(1);
    await expect(page.locator('nav')).toHaveCount(1);
    await expect(page.locator('main')).toHaveCount(1);
    await expect(page.locator('h1')).toHaveCount(1);
    await expect(page.locator('footer')).toHaveCount(1);
  });

  test('Seitentitel ist korrekt', async ({ page }) => {
    await page.goto(PAGE);

    await expect(page).toHaveTitle(TITLE);
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(PAGE);

    const description = page.locator('meta[name="description"]');
    const canonical = page.locator('link[rel="canonical"]');

    await expect(description).toHaveCount(1);
    await expect(description).toHaveAttribute('content', /.+/);

    await expect(canonical).toHaveCount(1);
    await expect(canonical).toHaveAttribute(
      'href',
      CANONICAL
    );
  });

  test('H1 ist korrekt', async ({ page }) => {
    await page.goto(PAGE);

    await expect(page.locator('h1')).toContainText(H1);
  });

  test('Seite besitzt strukturierten Inhalt', async ({ page }) => {
    await page.goto(PAGE);

    const headings = page.locator('h2');

    expect(await headings.count()).toBeGreaterThan(0);
  });

  const viewports = [
    { name: '320px', width: 320, height: 800 },
    { name: '375px', width: 375, height: 812 },
    { name: '768px', width: 768, height: 1024 },
    { name: '1440px', width: 1440, height: 900 }
  ];

  for (const viewport of viewports) {
    test(`kein horizontales Overflow bei ${viewport.name}`, async ({ page }) => {
      await page.setViewportSize({
        width: viewport.width,
        height: viewport.height
      });

      await page.goto(PAGE);

      const dimensions = await page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        clientWidth: document.documentElement.clientWidth
      }));

      expect(
        dimensions.scrollWidth,
        `Horizontal overflow: ${dimensions.scrollWidth}px > ${dimensions.clientWidth}px`
      ).toBeLessThanOrEqual(dimensions.clientWidth + 1);
    });
  }

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(PAGE);

    const links = await page.locator('a[href]').evaluateAll(elements =>
      elements.map(element => element.getAttribute('href'))
    );

    expect(links.length).toBeGreaterThan(0);

    for (const href of links) {
      expect(href).not.toBeNull();
      expect(href.trim()).not.toBe('');
      expect(href.trim()).not.toBe('#');
      expect(href.toLowerCase()).not.toMatch(/^javascript:/);
    }
  });

  test('interne Links sind erreichbar', async ({ page, request }) => {
    await page.goto(PAGE);

    const hrefs = await page.locator('a[href]').evaluateAll(elements =>
      [...new Set(elements.map(element => element.getAttribute('href')))]
    );

    const internalLinks = hrefs.filter(href =>
      href &&
      href.startsWith('/') &&
      !href.startsWith('//')
    );

    for (const href of internalLinks) {
      const response = await request.get(href);

      expect(
        response.status(),
        `${href} liefert HTTP ${response.status()}`
      ).toBeLessThan(400);
    }
  });

  test('Tastaturfokus erreicht interaktives Element', async ({ page }) => {
    await page.goto(PAGE);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() =>
      document.activeElement?.tagName || ''
    );

    expect(focused).not.toBe('BODY');
    expect(focused).not.toBe('HTML');
    expect(focused).not.toBe('');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(PAGE);

    const link = page.locator('a[href]').first();

    await expect(link).toBeVisible();
    await link.focus();
    await expect(link).toBeFocused();

    const style = await link.evaluate(element => {
      const computed = getComputedStyle(element);

      return {
        outlineStyle: computed.outlineStyle,
        outlineWidth: computed.outlineWidth
      };
    });

    expect(style.outlineStyle).not.toBe('none');
    expect(style.outlineWidth).not.toBe('0px');
  });

  test('Navigation besitzt Accessible-Bezeichnung', async ({ page }) => {
    await page.goto(PAGE);

    await expect(
      page.locator('nav[aria-label="Hauptnavigation"]')
    ).toHaveCount(1);
  });

  test('Reduced Motion wird unterstützt', async ({ page }) => {
    await page.emulateMedia({
      reducedMotion: 'reduce'
    });

    await page.goto(PAGE);

    const behavior = await page.locator('html').evaluate(element =>
      getComputedStyle(element).scrollBehavior
    );

    expect(behavior).toBe('auto');
  });

  test('keine schweren Browserfehler', async ({ page }) => {
    const errors = [];

    page.on('pageerror', error => {
      errors.push(error.message);
    });

    await page.goto(PAGE);
    await page.waitForLoadState('load');

    expect(
      errors,
      errors.join('\n')
    ).toEqual([]);
  });

});
