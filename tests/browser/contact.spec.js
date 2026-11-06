const { test, expect } = require('@playwright/test');

const CONTACT = '/contact/';

test.describe('CoreCraft Genesis - Contact Acceptance', () => {

  test('Contact lädt erfolgreich und besitzt die Grundstruktur', async ({ page }) => {
    const response = await page.goto(CONTACT);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page.locator('html')).toHaveAttribute('lang', 'de');
    await expect(page.locator('main')).toHaveCount(1);
    await expect(page.locator('h1')).toHaveCount(1);
    await expect(page.locator('header')).toHaveCount(1);
    await expect(page.locator('nav')).toHaveCount(1);
    await expect(page.locator('footer')).toHaveCount(1);

    await expect(page).toHaveTitle(/Kontakt.*CoreCraft Genesis/i);
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(CONTACT);

    const description = page.locator('meta[name="description"]');
    const canonical = page.locator('link[rel="canonical"]');

    await expect(description).toHaveCount(1);
    await expect(description).toHaveAttribute('content', /.+/);

    await expect(canonical).toHaveCount(1);
    await expect(canonical).toHaveAttribute(
      'href',
      'https://corecraftgenesis.ch/contact/'
    );
  });

  test('Contact besitzt die erwartete Inhaltsstruktur', async ({ page }) => {
    await page.goto(CONTACT);

    await expect(page.locator('h1')).toContainText(
      'Lassen Sie uns über Ihre Anfrage sprechen'
    );

    await expect(page.locator('article.card')).toHaveCount(4);

    await expect(
      page.getByRole('heading', { name: 'Produkte & Lösungen' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Technischer Support' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Dokumentation' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Lizenzierung & Zusammenarbeit' })
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

      await page.goto(CONTACT);

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

  test('zentrale Contact-Ziele sind vorhanden', async ({ page }) => {
    await page.goto(CONTACT);

    const requiredTargets = [
      '/about/',
      '/products/',
      '/support/',
      '/docs/',
      '/pricing/',
      '/products/developer-tools/',
      '/legal/imprint/',
      '/legal/privacy/'
    ];

    for (const target of requiredTargets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Links enthalten keine leeren Ziele', async ({ page }) => {
    await page.goto(CONTACT);

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

  test('interne HTTP-Ziele sind erreichbar', async ({ page, request }) => {
    await page.goto(CONTACT);

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
    await page.goto(CONTACT);

    await page.keyboard.press('Tab');

    const focus = await page.evaluate(() => {
      const element = document.activeElement;

      return {
        tag: element?.tagName || '',
        href: element?.getAttribute?.('href') || ''
      };
    });

    expect(focus.tag).not.toBe('BODY');
    expect(focus.tag).not.toBe('HTML');
  });

  test('fokussierte Links besitzen sichtbaren Fokus', async ({ page }) => {
    await page.goto(CONTACT);

    const link = page.locator('a[href]').first();

    await link.focus();

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
    await page.goto(CONTACT);

    await expect(
      page.locator('nav[aria-label="Hauptnavigation"]')
    ).toHaveCount(1);
  });

  test('Reduced Motion wird unterstützt', async ({ page }) => {
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.goto(CONTACT);

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

    await page.goto(CONTACT);
    await page.waitForLoadState('load');

    expect(errors, errors.join('\n')).toEqual([]);
  });

});
