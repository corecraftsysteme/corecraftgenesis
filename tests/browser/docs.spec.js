const { test, expect } = require('@playwright/test');

const DOCS = '/docs/';
const ENGINECORE_DOCS = '/docs/enginecore/';

const pages = [
  {
    name: 'Docs',
    url: DOCS,
    title: /Dokumentation.*CoreCraft Genesis/i,
    canonical: 'https://corecraftgenesis.ch/docs/',
    h1: /Technische Dokumentation zentral erschließen/i
  },
  {
    name: 'EngineCore Docs',
    url: ENGINECORE_DOCS,
    title: /EngineCore Dokumentation.*CoreCraft Genesis/i,
    canonical: 'https://corecraftgenesis.ch/docs/enginecore/',
    h1: /EngineCore technisch erschließen/i
  }
];

test.describe('CoreCraft Genesis - Documentation Acceptance', () => {

  for (const entry of pages) {

    test(`${entry.name} lädt erfolgreich`, async ({ page }) => {
      const response = await page.goto(entry.url);

      expect(response).not.toBeNull();
      expect(response.status()).toBeLessThan(400);

      await expect(page).toHaveURL(
        new RegExp(
          `${entry.url.replace(/\//g, '\\/')}?$`
        )
      );
    });

    test(`${entry.name} besitzt vollständige Grundstruktur`, async ({ page }) => {
      await page.goto(entry.url);

      await expect(page.locator('html')).toHaveAttribute(
        'lang',
        /^(de|de-CH)$/i
      );

      await expect(page.locator('header')).toHaveCount(1);
      await expect(page.locator('nav')).toHaveCount(1);
      await expect(page.locator('main')).toHaveCount(1);
      await expect(page.locator('h1')).toHaveCount(1);
      await expect(page.locator('footer')).toHaveCount(1);

      expect(
        await page.locator('h2').count()
      ).toBeGreaterThanOrEqual(2);
    });

    test(`${entry.name} SEO-Grunddaten sind korrekt`, async ({ page }) => {
      await page.goto(entry.url);

      await expect(page).toHaveTitle(entry.title);

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
        entry.canonical
      );
    });

    test(`${entry.name} H1 ist korrekt`, async ({ page }) => {
      await page.goto(entry.url);

      await expect(
        page.locator('h1')
      ).toContainText(entry.h1);
    });
  }

  test('Docs enthält zentrale Produktdokumentationen', async ({ page }) => {
    await page.goto(DOCS);

    const areas = [
      'EngineCore',
      'Developer Tools',
      'CoreCraft Pay',
      'Audio Systems',
      'Bitcoin Mining',
      'Documentation Product'
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

  test('Docs enthält zentrale Dokumentationsbereiche', async ({ page }) => {
    await page.goto(DOCS);

    const areas = [
      'Getting Started',
      'Architecture',
      'Guides',
      'Reference',
      'Standards',
      'Releases'
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

  test('EngineCore Docs enthält alle Kernbereiche', async ({ page }) => {
    await page.goto(ENGINECORE_DOCS);

    const areas = [
      'Architecture',
      'Runtime',
      'Modules',
      'Validation',
      'Diagnostics',
      'Developer'
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

  test('EngineCore Docs verlinkt alle Kernbereiche', async ({ page }) => {
    await page.goto(ENGINECORE_DOCS);

    const targets = [
      '/products/enginecore/',
      '/products/enginecore/architecture/',
      '/products/enginecore/runtime/',
      '/products/enginecore/modules/',
      '/products/enginecore/validation/',
      '/products/enginecore/diagnostics/',
      '/products/enginecore/developer/',
      '/products/enginecore/demos/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `EngineCore-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Docs verlinkt die Dokumentationsstruktur korrekt', async ({ page }) => {
    await page.goto(DOCS);

    const targets = [
      '/docs/enginecore/',
      '/products/documentation/',
      '/products/documentation/getting-started/',
      '/products/documentation/architecture/',
      '/products/documentation/guides/',
      '/products/documentation/reference/',
      '/products/documentation/standards/',
      '/products/documentation/releases/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Dokumentations-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  const viewports = [
    { name: '320px', width: 320, height: 800 },
    { name: '375px', width: 375, height: 812 },
    { name: '768px', width: 768, height: 1024 },
    { name: '1440px', width: 1440, height: 900 }
  ];

  for (const entry of pages) {

    for (const viewport of viewports) {

      test(
        `${entry.name}: kein horizontales Overflow bei ${viewport.name}`,
        async ({ page }) => {

          await page.setViewportSize({
            width: viewport.width,
            height: viewport.height
          });

          await page.goto(entry.url);

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
        }
      );
    }
  }

  for (const entry of pages) {

    test(`${entry.name}: interne Links sind erreichbar`, async ({
      page,
      request
    }) => {

      await page.goto(entry.url);

      const hrefs = await page.locator(
        'a[href]'
      ).evaluateAll(elements =>
        [...new Set(
          elements
            .map(element =>
              element.getAttribute('href')
            )
            .filter(Boolean)
        )]
      );

      const internalLinks = hrefs.filter(href =>
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
  }

  for (const entry of pages) {

    test(`${entry.name}: keine leeren oder JavaScript-Links`, async ({ page }) => {
      await page.goto(entry.url);

      const hrefs = await page.locator(
        'a[href]'
      ).evaluateAll(elements =>
        elements.map(element =>
          element.getAttribute('href')
        )
      );

      expect(hrefs.length).toBeGreaterThan(0);

      for (const href of hrefs) {
        expect(href).not.toBeNull();
        expect(href.trim()).not.toBe('');
        expect(href.trim()).not.toBe('#');
        expect(href.toLowerCase()).not.toMatch(
          /^javascript:/
        );
      }
    });
  }

  for (const entry of pages) {

    test(`${entry.name}: Tastaturfokus ist sichtbar`, async ({ page }) => {
      await page.goto(entry.url);

      const link = page.locator(
        'a[href]'
      ).first();

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

      expect(
        focusStyle.outlineStyle
      ).not.toBe('none');

      expect(
        focusStyle.outlineWidth
      ).not.toBe('0px');
    });

    test(`${entry.name}: Navigation ist zugänglich bezeichnet`, async ({ page }) => {
      await page.goto(entry.url);

      await expect(
        page.locator(
          'nav[aria-label="Hauptnavigation"]'
        )
      ).toHaveCount(1);
    });

    test(`${entry.name}: Reduced Motion wird unterstützt`, async ({ page }) => {
      await page.emulateMedia({
        reducedMotion: 'reduce'
      });

      await page.goto(entry.url);

      const behavior = await page.locator(
        'html'
      ).evaluate(element =>
        getComputedStyle(element).scrollBehavior
      );

      expect(behavior).toBe('auto');
    });

    test(`${entry.name}: keine schweren Browserfehler`, async ({ page }) => {
      const errors = [];

      page.on('pageerror', error => {
        errors.push(error.message);
      });

      await page.goto(entry.url);
      await page.waitForLoadState('load');

      expect(
        errors,
        errors.join('\n')
      ).toEqual([]);
    });
  }

});