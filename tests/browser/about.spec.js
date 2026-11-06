const { test, expect } = require('@playwright/test');

const ABOUT = '/about/';

test.describe('CoreCraft Genesis - About Acceptance', () => {

  test('About lädt erfolgreich und besitzt die Grundstruktur', async ({ page }) => {
    const response = await page.goto(ABOUT);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page.locator('html')).toHaveAttribute('lang', /.+/);
    await expect(page.locator('main')).toHaveCount(1);
    await expect(page.locator('h1')).toHaveCount(1);
    await expect(page.locator('footer')).toHaveCount(1);

    await expect(page).toHaveTitle(/CoreCraft Genesis/i);
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

      await page.goto(ABOUT);

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

  test('interne Navigation enthält keine leeren Ziele', async ({ page }) => {
    await page.goto(ABOUT);

    const links = await page.locator('a[href]').evaluateAll(elements =>
      elements.map(a => a.getAttribute('href'))
    );

    expect(links.length).toBeGreaterThan(0);

    for (const href of links) {
      expect(href).not.toBeNull();
      expect(href.trim()).not.toBe('');
      expect(href.trim()).not.toBe('#');
    }
  });

  test('Bilder besitzen alt-Attribute', async ({ page }) => {
    await page.goto(ABOUT);

    const images = page.locator('img');
    const count = await images.count();

    for (let i = 0; i < count; i++) {
      await expect(images.nth(i)).toHaveAttribute('alt');
    }
  });

  test('Tastaturfokus erreicht interaktive Elemente', async ({ page }) => {
    await page.goto(ABOUT);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() => {
      const element = document.activeElement;

      return {
        tag: element?.tagName || '',
        href: element?.getAttribute?.('href') || '',
        tabindex: element?.getAttribute?.('tabindex')
      };
    });

    expect(focused.tag).not.toBe('BODY');
    expect(focused.tag).not.toBe('HTML');
  });

  test('keine schweren Browserfehler', async ({ page }) => {
    const errors = [];

    page.on('pageerror', error => {
      errors.push(error.message);
    });

    await page.goto(ABOUT);
    await page.waitForLoadState('load');

    expect(errors, errors.join('\n')).toEqual([]);
  });

});
