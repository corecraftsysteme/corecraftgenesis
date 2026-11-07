const { test, expect } = require('@playwright/test');

const SUPPORT = '/support/';

test.describe('CoreCraft Genesis - Support Acceptance', () => {

  test('Support lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(SUPPORT);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/support\/?$/);
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(SUPPORT);

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
    await page.goto(SUPPORT);

    await expect(page).toHaveTitle(
      /Support.*CoreCraft Genesis/i
    );
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(SUPPORT);

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
      'https://corecraftgenesis.ch/support/'
    );
  });

  test('H1 beschreibt den Support-Bereich', async ({ page }) => {
    await page.goto(SUPPORT);

    await expect(page.locator('h1')).toContainText(
      'Technische Ressourcen für Analyse und Orientierung'
    );
  });

  test('Support besitzt strukturierte Inhaltsbereiche', async ({ page }) => {
    await page.goto(SUPPORT);

    const headings = page.locator('h2');

    expect(await headings.count()).toBeGreaterThanOrEqual(4);

    await expect(
      page.getByRole('heading', {
        name: /passende Einstieg/i
      })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', {
        name: /Erst prüfen.*Dann eingrenzen/i
      })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', {
        name: /technisches Problem nachvollziehbar eingrenzen/i
      })
    ).toBeVisible();
  });

  test('zentrale Support-Ressourcen sind vorhanden', async ({ page }) => {
    await page.goto(SUPPORT);

    await expect(
      page.getByRole('heading', { name: 'Dokumentation' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Developer Tools' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Produkte & Lösungen' })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', { name: 'Kontakt' }).first()
    ).toBeVisible();
  });

  test('Diagnosewerkzeuge sind vorhanden', async ({ page }) => {
    await page.goto(SUPPORT);

    const tools = [
      'Link Checker',
      'Route Checker',
      'Schema Validator',
      'File Validator'
    ];

    for (const tool of tools) {
      await expect(
        page.getByRole('heading', { name: tool })
      ).toBeVisible();
    }
  });

  test('Analyseleitfaden besitzt fünf Schritte', async ({ page }) => {
    await page.goto(SUPPORT);

    await expect(
      page.locator('ol.steps > li')
    ).toHaveCount(5);
  });

  test('Sicherheitshinweis ist vorhanden', async ({ page }) => {
    await page.goto(SUPPORT);

    await expect(
      page.locator('.notice')
    ).toContainText(/Passwörter|private Schlüssel|Zugangstoken/i);
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

      await page.goto(SUPPORT);

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

  test('zentrale Support-Ziele sind verlinkt', async ({ page }) => {
    await page.goto(SUPPORT);

    const targets = [
      '/docs/',
      '/products/',
      '/products/developer-tools/',
      '/products/developer-tools/web-tools/link-checker/',
      '/products/developer-tools/web-tools/route-checker/',
      '/products/developer-tools/validators/schema/',
      '/products/developer-tools/validators/file/',
      '/contact/',
      '/legal/',
      '/legal/imprint/',
      '/legal/privacy/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Support-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(SUPPORT);

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
      expect(href.toLowerCase()).not.toMatch(
        /^javascript:/
      );
    }
  });

  test('interne Links sind erreichbar', async ({ page, request }) => {
    await page.goto(SUPPORT);

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
    await page.goto(SUPPORT);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() =>
      document.activeElement?.tagName || ''
    );

    expect(focused).not.toBe('BODY');
    expect(focused).not.toBe('HTML');
    expect(focused).not.toBe('');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(SUPPORT);

    const link = page.locator(
      'a[href]'
    ).first();

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
    await page.goto(SUPPORT);

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

    await page.goto(SUPPORT);

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

    await page.goto(SUPPORT);
    await page.waitForLoadState('load');

    expect(
      errors,
      errors.join('\n')
    ).toEqual([]);
  });

});