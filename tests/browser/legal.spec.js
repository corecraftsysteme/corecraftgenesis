const { test, expect } = require('@playwright/test');

const LEGAL = '/legal/';

test.describe('CoreCraft Genesis - Legal Acceptance', () => {

  test('Legal-Seite lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(LEGAL);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/legal\/?$/);
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(LEGAL);

    await expect(page.locator('html')).toHaveAttribute('lang', /^(de|de-CH)$/i);
    await expect(page.locator('header')).toHaveCount(1);
    await expect(page.locator('nav')).toHaveCount(1);
    await expect(page.locator('main')).toHaveCount(1);
    await expect(page.locator('h1')).toHaveCount(1);
    await expect(page.locator('footer')).toHaveCount(1);
  });

  test('Seitentitel bezeichnet den Legal-Bereich', async ({ page }) => {
    await page.goto(LEGAL);

    await expect(page).toHaveTitle(
      /Rechtliche Informationen.*CoreCraft Genesis/i
    );
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(LEGAL);

    const description = page.locator('meta[name="description"]');
    const canonical = page.locator('link[rel="canonical"]');

    await expect(description).toHaveCount(1);
    await expect(description).toHaveAttribute('content', /.+/);

    await expect(canonical).toHaveCount(1);
    await expect(canonical).toHaveAttribute(
      'href',
      'https://corecraftgenesis.ch/legal/'
    );
  });

  test('H1 bezeichnet den rechtlichen Bereich', async ({ page }) => {
    await page.goto(LEGAL);

    await expect(page.locator('h1')).toContainText(
      /Rechtliche Informationen/i
    );
  });

  test('vier Legal-Bereiche werden angeboten', async ({ page }) => {
    await page.goto(LEGAL);

    await expect(page.locator('.card')).toHaveCount(4);

    await expect(
      page.getByRole('heading', { name: 'Impressum' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Datenschutz' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Nutzungsbedingungen' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Lizenzen' })
    ).toBeVisible();
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

      await page.goto(LEGAL);

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

  test('alle vier Legal-Ziele sind verlinkt', async ({ page }) => {
    await page.goto(LEGAL);

    const targets = [
      '/legal/imprint/',
      '/legal/privacy/',
      '/legal/terms/',
      '/legal/licenses/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Legal-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Legal-Zielseiten sind HTTP-erreichbar', async ({ request }) => {
    const targets = [
      '/legal/imprint/',
      '/legal/privacy/',
      '/legal/terms/',
      '/legal/licenses/'
    ];

    for (const target of targets) {
      const response = await request.get(target);

      expect(
        response.status(),
        `${target} liefert HTTP ${response.status()}`
      ).toBeLessThan(400);
    }
  });

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(LEGAL);

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

  test('Tastaturfokus erreicht ein interaktives Element', async ({ page }) => {
    await page.goto(LEGAL);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() => ({
      tag: document.activeElement?.tagName || '',
      href: document.activeElement?.getAttribute?.('href') || ''
    }));

    expect(focused.tag).not.toBe('BODY');
    expect(focused.tag).not.toBe('HTML');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(LEGAL);

    const link = page.locator('a[href]').first();

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

  test('Navigation besitzt eine Accessible-Bezeichnung', async ({ page }) => {
    await page.goto(LEGAL);

    await expect(
      page.locator('nav[aria-label="Hauptnavigation"]')
    ).toHaveCount(1);
  });

  test('Reduced Motion wird unterstützt', async ({ page }) => {
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.goto(LEGAL);

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

    await page.goto(LEGAL);
    await page.waitForLoadState('load');

    expect(errors, errors.join('\n')).toEqual([]);
  });

});
