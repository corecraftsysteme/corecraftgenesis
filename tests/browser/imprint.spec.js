const { test, expect } = require('@playwright/test');

const IMPRINT = '/legal/imprint/';

test.describe('CoreCraft Genesis - Imprint Acceptance', () => {

  test('Impressum lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(IMPRINT);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/legal\/imprint\/?$/);
  });

  test('Impressum besitzt die HTML-Grundstruktur', async ({ page }) => {
    await page.goto(IMPRINT);

    await expect(page.locator('html')).toHaveAttribute('lang', /^(de|de-CH)$/i);
    await expect(page.locator('main')).toHaveCount(1);
    await expect(page.locator('h1')).toHaveCount(1);
    await expect(page.locator('footer')).toHaveCount(1);
  });

  test('Seitentitel bezeichnet das Impressum', async ({ page }) => {
    await page.goto(IMPRINT);

    await expect(page).toHaveTitle(/Impressum|Imprint/i);
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(IMPRINT);

    const description = page.locator('meta[name="description"]');
    const canonical = page.locator('link[rel="canonical"]');

    await expect(description).toHaveCount(1);
    await expect(description).toHaveAttribute('content', /.+/);

    await expect(canonical).toHaveCount(1);
    await expect(canonical).toHaveAttribute(
      'href',
      'https://corecraftgenesis.ch/legal/imprint/'
    );
  });

  test('H1 bezeichnet das Impressum eindeutig', async ({ page }) => {
    await page.goto(IMPRINT);

    await expect(page.locator('h1')).toContainText(/Impressum|Imprint/i);
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

      await page.goto(IMPRINT);

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
    await page.goto(IMPRINT);

    const links = await page.locator('a[href]').evaluateAll(elements =>
      elements.map(element => element.getAttribute('href'))
    );

    for (const href of links) {
      expect(href).not.toBeNull();
      expect(href.trim()).not.toBe('');
      expect(href.trim()).not.toBe('#');
      expect(href.toLowerCase()).not.toMatch(/^javascript:/);
    }
  });

  test('interne Links sind erreichbar', async ({ page, request }) => {
    await page.goto(IMPRINT);

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

  test('Tastaturfokus erreicht ein interaktives Element', async ({ page }) => {
    await page.goto(IMPRINT);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() => {
      const element = document.activeElement;

      return {
        tag: element?.tagName || '',
        href: element?.getAttribute?.('href') || ''
      };
    });

    expect(focused.tag).not.toBe('BODY');
    expect(focused.tag).not.toBe('HTML');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(IMPRINT);

    const link = page.locator('a[href]').first();

    await expect(link).toBeVisible();
    await link.focus();
    await expect(link).toBeFocused();

    const focusStyle = await link.evaluate(element => {
      const style = getComputedStyle(element);

      return {
        outlineStyle: style.outlineStyle,
        outlineWidth: style.outlineWidth
      };
    });

    expect(focusStyle.outlineStyle).not.toBe('none');
    expect(focusStyle.outlineWidth).not.toBe('0px');
  });

  test('Bilder besitzen alt-Attribute', async ({ page }) => {
    await page.goto(IMPRINT);

    const images = page.locator('img');
    const count = await images.count();

    for (let i = 0; i < count; i++) {
      await expect(images.nth(i)).toHaveAttribute('alt');
    }
  });

  test('Reduced Motion wird unterstützt', async ({ page }) => {
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.goto(IMPRINT);

    const scrollBehavior = await page.locator('html').evaluate(element =>
      getComputedStyle(element).scrollBehavior
    );

    expect(scrollBehavior).toBe('auto');
  });

  test('keine schweren Browserfehler', async ({ page }) => {
    const errors = [];

    page.on('pageerror', error => {
      errors.push(error.message);
    });

    await page.goto(IMPRINT);
    await page.waitForLoadState('load');

    expect(errors, errors.join('\n')).toEqual([]);
  });

});
