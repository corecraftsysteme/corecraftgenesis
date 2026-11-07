const { test, expect } = require('@playwright/test');

const BLOG = '/blog/';

test.describe('CoreCraft Genesis - Blog Acceptance', () => {

  test('Blog lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(BLOG);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/blog\/?$/);
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(BLOG);

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

  test('SEO-Grunddaten sind korrekt', async ({ page }) => {
    await page.goto(BLOG);

    await expect(page).toHaveTitle(
      /Insights.*Publications.*CoreCraft Genesis/i
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
      'https://corecraftgenesis.ch/blog/'
    );
  });

  test('H1 und H2-Struktur sind vorhanden', async ({ page }) => {
    await page.goto(BLOG);

    await expect(page.locator('h1')).toContainText(
      /Technische Inhalte und Veröffentlichungen/i
    );

    expect(
      await page.locator('h2').count()
    ).toBeGreaterThanOrEqual(4);
  });

  test('geplante Themenbereiche sind vorhanden', async ({ page }) => {
    await page.goto(BLOG);

    const topics = [
      'Engineering & Runtime',
      'Developer Tools',
      'Bitcoin Infrastructure',
      'Audio & Payments'
    ];

    for (const topic of topics) {
      await expect(
        page.getByRole('heading', {
          name: topic,
          exact: true
        })
      ).toBeVisible();
    }
  });

  test('Veröffentlichungsstatus ist transparent', async ({ page }) => {
    await page.goto(BLOG);

    await expect(
      page.locator('.notice')
    ).toContainText(
      /Veröffentlichungen werden schrittweise ergänzt/i
    );

    await expect(
      page.locator('.notice')
    ).toContainText(
      /keine.*Platzhalterartikel.*Veröffentlichungsdaten/is
    );
  });

  test('keine erfundenen Beiträge oder Datumsangaben vorhanden', async ({ page }) => {
    await page.goto(BLOG);

    await expect(
      page.locator('time')
    ).toHaveCount(0);

    const articles = page.locator(
      'article'
    );

    await expect(articles).toHaveCount(4);

    const articleLinks = articles.locator('a[href]');

    await expect(articleLinks).toHaveCount(0);
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

      await page.goto(BLOG);

      const width = await page.evaluate(() => ({
        scroll: document.documentElement.scrollWidth,
        client: document.documentElement.clientWidth
      }));

      expect(
        width.scroll,
        `Horizontal overflow: ${width.scroll}px > ${width.client}px`
      ).toBeLessThanOrEqual(
        width.client + 1
      );
    });
  }

  test('zentrale Ressourcen sind verlinkt', async ({ page }) => {
    await page.goto(BLOG);

    const targets = [
      '/products/',
      '/solutions/',
      '/docs/',
      '/products/documentation/',
      '/downloads/',
      '/support/',
      '/contact/',
      '/legal/',
      '/legal/privacy/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Blog-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('interne Links sind erreichbar', async ({ page, request }) => {
    await page.goto(BLOG);

    const hrefs = await page.locator(
      'a[href]'
    ).evaluateAll(elements =>
      [...new Set(
        elements
          .map(element => element.getAttribute('href'))
          .filter(Boolean)
      )]
    );

    const internal = hrefs.filter(href =>
      href.startsWith('/') &&
      !href.startsWith('//')
    );

    for (const href of internal) {
      const response = await request.get(href);

      expect(
        response.status(),
        `${href} liefert HTTP ${response.status()}`
      ).toBeLessThan(400);
    }
  });

  test('Tastaturfokus ist sichtbar', async ({ page }) => {
    await page.goto(BLOG);

    const link = page.locator('a[href]').first();

    await link.focus();
    await expect(link).toBeFocused();

    const focus = await link.evaluate(element => {
      const style = getComputedStyle(element);

      return {
        type: style.outlineStyle,
        width: style.outlineWidth
      };
    });

    expect(focus.type).not.toBe('none');
    expect(focus.width).not.toBe('0px');
  });

  test('Navigation besitzt Accessible-Bezeichnung', async ({ page }) => {
    await page.goto(BLOG);

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

    await page.goto(BLOG);

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

    await page.goto(BLOG);
    await page.waitForLoadState('load');

    expect(
      errors,
      errors.join('\n')
    ).toEqual([]);
  });

});