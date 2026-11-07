const { test, expect } = require('@playwright/test');

const PRICING = '/pricing/';

test.describe('CoreCraft Genesis - Pricing Acceptance', () => {

  test('Pricing lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(PRICING);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/pricing\/?$/);
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(PRICING);

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
    await page.goto(PRICING);

    await expect(page).toHaveTitle(
      /Pricing.*Licensing.*CoreCraft Genesis/i
    );
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(PRICING);

    const description = page.locator(
      'meta[name="description"]'
    );

    const canonical = page.locator(
      'link[rel="canonical"]'
    );

    await expect(description).toHaveCount(1);
    await expect(description).toHaveAttribute(
      'content',
      /.+/
    );

    await expect(canonical).toHaveCount(1);
    await expect(canonical).toHaveAttribute(
      'href',
      'https://corecraftgenesis.ch/pricing/'
    );
  });

  test('H1 beschreibt Pricing und Licensing', async ({ page }) => {
    await page.goto(PRICING);

    await expect(page.locator('h1')).toContainText(
      /Produktmodelle und Lizenzierung/i
    );
  });

  test('Pricing besitzt strukturierte Inhaltsbereiche', async ({ page }) => {
    await page.goto(PRICING);

    const headings = page.locator('h2');

    expect(await headings.count()).toBeGreaterThanOrEqual(5);

    await expect(
      page.getByRole('heading', {
        name: /Unterschiedliche Produkte.*Klare Zuordnung/i
      })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', {
        name: /Preise dort.*wo sie konkret gelten/i
      })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', {
        name: /Lizenzbedingungen gehören zum jeweiligen Produkt/i
      })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', {
        name: /Produktstatus klar vom Preismodell trennen/i
      })
    ).toBeVisible();
  });

  test('vier Produktmodelle sind vorhanden', async ({ page }) => {
    await page.goto(PRICING);

    const expected = [
      'Technische Produkte',
      'Developer Tools',
      'Dokumentation',
      'Technische Lösungen'
    ];

    for (const name of expected) {
      await expect(
        page.getByRole('heading', { name })
      ).toBeVisible();
    }
  });

  test('Lizenzbereiche sind vorhanden', async ({ page }) => {
    await page.goto(PRICING);

    const expected = [
      'Produktspezifische Lizenzen',
      'Open-Source-Komponenten',
      'Drittanbieter-Komponenten',
      'Lizenzübersicht'
    ];

    for (const name of expected) {
      await expect(
        page.getByRole('heading', { name })
      ).toBeVisible();
    }
  });

  test('keine erfundenen Preis- oder Kaufangaben', async ({ page }) => {
    await page.goto(PRICING);

    const text = await page.locator('body').innerText();

    expect(text).not.toMatch(
      /CHF\s*\d+|EUR\s*\d+|USD\s*\d+|€\s*\d+|\$\s*\d+/i
    );

    expect(text).not.toMatch(
      /Jetzt kaufen|Jetzt bestellen|Buy now|Purchase now/i
    );
  });

  test('Transparenzhinweise sind vorhanden', async ({ page }) => {
    await page.goto(PRICING);

    await expect(
      page.locator('.notice').first()
    ).toContainText(
      /keine pauschalen Preise|kein konkretes Preismodell/i
    );

    await expect(
      page.locator('.notice').last()
    ).toContainText(
      /erst dann ausgewiesen|tatsächlich festgelegt/i
    );
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

      await page.goto(PRICING);

      const dimensions = await page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        clientWidth: document.documentElement.clientWidth
      }));

      expect(
        dimensions.scrollWidth,
        `Horizontal overflow: ${dimensions.scrollWidth}px > ${dimensions.clientWidth}px`
      ).toBeLessThanOrEqual(
        dimensions.clientWidth + 1
      );
    });
  }

  test('zentrale Pricing-Ziele sind verlinkt', async ({ page }) => {
    await page.goto(PRICING);

    const targets = [
      '/products/',
      '/products/developer-tools/',
      '/solutions/',
      '/docs/',
      '/support/',
      '/contact/',
      '/legal/',
      '/legal/imprint/',
      '/legal/privacy/',
      '/legal/licenses/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Pricing-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(PRICING);

    const links = await page.locator(
      'a[href]'
    ).evaluateAll(elements =>
      elements.map(element =>
        element.getAttribute('href')
      )
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
    await page.goto(PRICING);

    const hrefs = await page.locator(
      'a[href]'
    ).evaluateAll(elements =>
      [...new Set(
        elements.map(element =>
          element.getAttribute('href')
        )
      )]
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
    await page.goto(PRICING);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() =>
      document.activeElement?.tagName || ''
    );

    expect(focused).not.toBe('BODY');
    expect(focused).not.toBe('HTML');
    expect(focused).not.toBe('');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(PRICING);

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
    await page.goto(PRICING);

    await expect(
      page.locator(
        'nav[aria-label="Hauptnavigation"]'
      )
    ).toHaveCount(1);
  });

  test('Reduced Motion wird unterstützt', async ({ page }) => {
    await page.emulateMedia({
      reducedMotion: 'reduce'
    });

    await page.goto(PRICING);

    const behavior = await page.locator(
      'html'
    ).evaluate(element =>
      getComputedStyle(element).scrollBehavior
    );

    expect(behavior).toBe('auto');
  });

  test('keine schweren Browserfehler', async ({ page }) => {
    const errors = [];

    page.on('pageerror', error => {
      errors.push(error.message);
    });

    await page.goto(PRICING);
    await page.waitForLoadState('load');

    expect(
      errors,
      errors.join('\n')
    ).toEqual([]);
  });

});