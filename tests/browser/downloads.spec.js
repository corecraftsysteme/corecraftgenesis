const { test, expect } = require('@playwright/test');

const DOWNLOADS = '/downloads/';

test.describe('CoreCraft Genesis - Downloads Acceptance', () => {

  test('Downloads lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(DOWNLOADS);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/downloads\/?$/);
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(DOWNLOADS);

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
    await page.goto(DOWNLOADS);

    await expect(page).toHaveTitle(
      /Downloads.*CoreCraft Genesis/i
    );
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(DOWNLOADS);

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
      'https://corecraftgenesis.ch/downloads/'
    );
  });

  test('H1 beschreibt den Download-Bereich', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(page.locator('h1')).toContainText(
      /Veröffentlichte Ressourcen zentral finden/i
    );
  });

  test('Downloads besitzt strukturierte Inhaltsbereiche', async ({ page }) => {
    await page.goto(DOWNLOADS);

    expect(
      await page.locator('h2').count()
    ).toBeGreaterThanOrEqual(7);

    const headings = [
      /Downloads nur dann anzeigen/i,
      /Ressourcen nach Produktbereich einordnen/i,
      /Dokumentation direkt online öffnen/i,
      /Technische Werkzeuge direkt nutzen/i,
      /Veröffentlichte Dateien eindeutig zuordnen/i,
      /Bereitstellung und Lizenzierung unterscheiden/i,
      /Häufige Fragen zu Downloads und Ressourcen/i,
      /Direkt zum passenden Bereich/i
    ];

    for (const name of headings) {
      await expect(
        page.getByRole('heading', { name })
      ).toBeVisible();
    }
  });

  test('Verfügbarkeitshinweis ist vorhanden', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const notice = page.locator('.notice');

    await expect(notice).toBeVisible();

    await expect(notice).toContainText(
      /Hinweis zur Verfügbarkeit/i
    );

    await expect(notice).toContainText(
      /erst angezeigt.*Datei.*freigegeben/is
    );
  });

  test('keine Dummy-Downloads sind vorhanden', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(
      page.locator('[download]')
    ).toHaveCount(0);

    const hrefs = await page.locator(
      'a[href]'
    ).evaluateAll(elements =>
      elements.map(element =>
        element.getAttribute('href')
      )
    );

    const fileLinks = hrefs.filter(href =>
      href &&
      /\.(zip|pdf|exe|msi|dmg|pkg|tar|gz|7z)$/i.test(
        href.split('?')[0]
      )
    );

    expect(fileLinks).toEqual([]);
  });

  test('keine erfundenen Versions- oder Dateigrößenangaben', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const text = await page.locator('body').innerText();

    expect(text).not.toMatch(
      /\bv\d+\.\d+(?:\.\d+)?\b/i
    );

    expect(text).not.toMatch(
      /\b\d+(?:[.,]\d+)?\s*(?:KB|MB|GB)\b/i
    );
  });

  test('sechs Produktbereiche sind vorhanden', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const products = [
      'EngineCore',
      'CoreCraft Pay',
      'Developer Tools',
      'Technical Documentation',
      'Audio Systems',
      'Bitcoin Mining Systems'
    ];

    for (const product of products) {
      await expect(
        page.getByRole('heading', {
          name: product,
          exact: true
        })
      ).toBeVisible();
    }
  });

  test('Developer Resources sind vorhanden', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const resources = [
      'Validatoren',
      'Diagnostics',
      'Web Tools',
      'Data Tools'
    ];

    for (const resource of resources) {
      await expect(
        page.getByRole('heading', {
          name: resource,
          exact: true
        })
      ).toBeVisible();
    }
  });

  test('Integritätsinformationen sind vorbereitet', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const areas = [
      'Version',
      'Dateiformat',
      'Lizenzierung',
      'Dateiintegrität'
    ];

    for (const area of areas) {
      await expect(
        page.getByRole('heading', {
          name: area,
          exact: true
        })
      ).toBeVisible();
    }
  });

  test('FAQ besitzt sechs Fragen', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const faqHeading = page.getByRole('heading', {
      name: /Häufige Fragen zu Downloads und Ressourcen/i
    });

    await expect(faqHeading).toBeVisible();

    const faqSection = faqHeading.locator(
      'xpath=ancestor::section'
    );

    await expect(
      faqSection.locator('article.card')
    ).toHaveCount(6);
  });

  test('wichtige FAQ-Fragen sind vorhanden', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const questions = [
      /Welche Downloads sind verfügbar/i,
      /Wo finde ich technische Dokumentation/i,
      /Welche Lizenz gilt für einen Download/i,
      /Wo werden neue Ressourcen veröffentlicht/i,
      /Wie erkenne ich die Produktzuordnung/i,
      /Wo kann ich allgemeine Fragen stellen/i
    ];

    for (const question of questions) {
      await expect(
        page.getByRole('heading', {
          name: question
        })
      ).toBeVisible();
    }
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

      await page.goto(DOWNLOADS);

      const dimensions = await page.evaluate(() => ({
        scrollWidth:
          document.documentElement.scrollWidth,

        clientWidth:
          document.documentElement.clientWidth
      }));

      expect(
        dimensions.scrollWidth,
        `Horizontal overflow: ${dimensions.scrollWidth}px > ${dimensions.clientWidth}px`
      ).toBeLessThanOrEqual(
        dimensions.clientWidth + 1
      );
    });
  }

  test('Produktziele sind verlinkt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const targets = [
      '/products/enginecore/',
      '/products/corecraft-pay/',
      '/products/developer-tools/',
      '/products/documentation/',
      '/products/audio/',
      '/products/bitcoin-mining/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Produkt-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Developer-Tool-Bereiche sind verlinkt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const targets = [
      '/products/developer-tools/',
      '/products/developer-tools/validators/',
      '/products/developer-tools/diagnostics/',
      '/products/developer-tools/web-tools/',
      '/products/developer-tools/data-tools/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Developer-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('zentrale Download-Ziele sind verlinkt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const targets = [
      '/products/',
      '/solutions/',
      '/shop/',
      '/pricing/',
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
        `Downloads-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(DOWNLOADS);

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

      expect(
        href.toLowerCase()
      ).not.toMatch(/^javascript:/);
    }
  });

  test('interne Links sind erreichbar', async ({ page, request }) => {
    await page.goto(DOWNLOADS);

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
    await page.goto(DOWNLOADS);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() =>
      document.activeElement?.tagName || ''
    );

    expect(focused).not.toBe('BODY');
    expect(focused).not.toBe('HTML');
    expect(focused).not.toBe('');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(DOWNLOADS);

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
    await page.goto(DOWNLOADS);

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

    await page.goto(DOWNLOADS);

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

    await page.goto(DOWNLOADS);
    await page.waitForLoadState('load');

    expect(
      errors,
      errors.join('\n')
    ).toEqual([]);
  });

});