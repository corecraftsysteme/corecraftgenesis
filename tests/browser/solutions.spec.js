const { test, expect } = require('@playwright/test');

const SOLUTIONS = '/solutions/';

test.describe('CoreCraft Genesis - Solutions Acceptance', () => {

  test('Solutions lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(SOLUTIONS);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/solutions\/?$/);
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(SOLUTIONS);

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
    await page.goto(SOLUTIONS);

    await expect(page).toHaveTitle(
      /Solutions.*CoreCraft Genesis/i
    );
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(SOLUTIONS);

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
      'https://corecraftgenesis.ch/solutions/'
    );
  });

  test('H1 beschreibt die technische Orientierung', async ({ page }) => {
    await page.goto(SOLUTIONS);

    await expect(page.locator('h1')).toContainText(
      /Technische Systeme nach Problemfeldern entdecken/i
    );
  });

  test('Solutions besitzt strukturierte Inhaltsbereiche', async ({ page }) => {
    await page.goto(SOLUTIONS);

    const headings = page.locator('h2');

    expect(
      await headings.count()
    ).toBeGreaterThanOrEqual(5);

    await expect(
      page.getByRole('heading', {
        name: /technischen Problem zum passenden Systembereich/i
      })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', {
        name: /Struktur vor Komplexität/i
      })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', {
        name: /Technische Prüfung als eigener Lösungsbereich/i
      })
    ).toBeVisible();

    await expect(
      page.getByRole('heading', {
        name: /Technische Systeme nachvollziehbar machen/i
      })
    ).toBeVisible();
  });

  test('sechs zentrale Solution Areas sind vorhanden', async ({ page }) => {
    await page.goto(SOLUTIONS);

    const areas = [
      'Engineering & Runtime',
      'Payments & Transaction Architecture',
      'Developer & Validation',
      'Technical Documentation',
      'Audio Systems',
      'Bitcoin Mining Systems'
    ];

    for (const area of areas) {
      await expect(
        page.getByRole('heading', { name: area })
      ).toBeVisible();
    }
  });

  test('Engineering-Bereiche sind vorhanden', async ({ page }) => {
    await page.goto(SOLUTIONS);

    const areas = [
      'Architecture',
      'Validation',
      'Diagnostics',
      'Documentation'
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

  test('Solution Area Links sind korrekt', async ({ page }) => {
    await page.goto(SOLUTIONS);

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
        `Solution Area fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Developer-Tool-Bereiche sind verlinkt', async ({ page }) => {
    await page.goto(SOLUTIONS);

    const targets = [
      '/products/developer-tools/',
      '/products/developer-tools/validators/',
      '/products/developer-tools/diagnostics/',
      '/products/developer-tools/web-tools/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Developer-Tool-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Solutions enthält keinen falschen Beratungsanspruch', async ({ page }) => {
    await page.goto(SOLUTIONS);

    const text = await page.locator('body').innerText();

    expect(text).not.toMatch(
      /maßgeschneiderte Beratung|individuelle Beratung|Beratung buchen|Consulting buchen/i
    );

    await expect(
      page.locator('.notice')
    ).toContainText(
      /kein\s+pauschales\s+Beratungs-\s*oder\s+Dienstleistungsversprechen/i
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

      await page.goto(SOLUTIONS);

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

  test('zentrale Solutions-Ziele sind verlinkt', async ({ page }) => {
    await page.goto(SOLUTIONS);

    const targets = [
      '/products/',
      '/pricing/',
      '/docs/',
      '/support/',
      '/contact/',
      '/legal/',
      '/legal/imprint/',
      '/legal/privacy/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Solutions-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(SOLUTIONS);

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
    await page.goto(SOLUTIONS);

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
    await page.goto(SOLUTIONS);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() =>
      document.activeElement?.tagName || ''
    );

    expect(focused).not.toBe('BODY');
    expect(focused).not.toBe('HTML');
    expect(focused).not.toBe('');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(SOLUTIONS);

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

    expect(
      style.outlineStyle
    ).not.toBe('none');

    expect(
      style.outlineWidth
    ).not.toBe('0px');
  });

  test('Navigation besitzt Accessible-Bezeichnung', async ({ page }) => {
    await page.goto(SOLUTIONS);

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

    await page.goto(SOLUTIONS);

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

    await page.goto(SOLUTIONS);
    await page.waitForLoadState('load');

    expect(
      errors,
      errors.join('\n')
    ).toEqual([]);
  });

});
