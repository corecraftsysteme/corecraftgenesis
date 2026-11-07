const { test, expect } = require('@playwright/test');

const SHOP = '/shop/';

test.describe('CoreCraft Genesis - Shop Acceptance', () => {

  test('Shop lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(SHOP);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/shop\/?$/);
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(SHOP);

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
    await page.goto(SHOP);

    await expect(page).toHaveTitle(
      /Shop.*CoreCraft Genesis/i
    );
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(SHOP);

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
      'https://corecraftgenesis.ch/shop/'
    );
  });

  test('H1 beschreibt den Produktkatalog', async ({ page }) => {
    await page.goto(SHOP);

    await expect(page.locator('h1')).toContainText(
      /Produkte und digitale Ressourcen entdecken/i
    );
  });

  test('Shop besitzt strukturierte Inhaltsbereiche', async ({ page }) => {
    await page.goto(SHOP);

    expect(
      await page.locator('h2').count()
    ).toBeGreaterThanOrEqual(6);

    const headings = [
      /Technische Produktbereiche im Überblick/i,
      /Werkzeuge für Prüfung und Diagnose/i,
      /Preis und Lizenzierung transparent zuordnen/i,
      /Verfügbare Ressourcen zentral finden/i,
      /Produkte nach technischem Problemfeld entdecken/i,
      /Häufige Fragen zum Produktkatalog/i,
      /Den passenden Bereich direkt öffnen/i
    ];

    for (const name of headings) {
      await expect(
        page.getByRole('heading', { name })
      ).toBeVisible();
    }
  });

  test('sechs Produktbereiche sind vorhanden', async ({ page }) => {
    await page.goto(SHOP);

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
        }).first()
      ).toBeVisible();
    }
  });

  test('Developer Resources sind vorhanden', async ({ page }) => {
    await page.goto(SHOP);

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

  test('FAQ besitzt sechs Fragen', async ({ page }) => {
    await page.goto(SHOP);

    const faqHeading = page.getByRole('heading', {
      name: /Häufige Fragen zum Produktkatalog/i
    });

    await expect(faqHeading).toBeVisible();

    const faqSection = faqHeading.locator('xpath=ancestor::section');

    await expect(
      faqSection.locator('article.card')
    ).toHaveCount(6);
  });

  test('wichtige FAQ-Fragen sind vorhanden', async ({ page }) => {
    await page.goto(SHOP);

    const questions = [
      /Sind alle dargestellten Produkte bereits verfügbar/i,
      /Wo finde ich Preise/i,
      /Welche Lizenz gilt für ein Produkt/i,
      /Wo finde ich verfügbare Downloads/i,
      /Sind Developer Tools bereits nutzbar/i,
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

  test('Verfügbarkeitshinweis ist vorhanden', async ({ page }) => {
    await page.goto(SHOP);

    const notice = page.locator('.notice');

    await expect(notice).toBeVisible();

    await expect(notice).toContainText(
      /Hinweis zur Verfügbarkeit/i
    );

    await expect(notice).toContainText(
      /stellt noch kein Verkaufsangebot dar/i
    );
  });

  test('Shop stellt aktuell keinen aktiven Verkauf dar', async ({ page }) => {
    await page.goto(SHOP);

    const text = await page.locator('body').innerText();

    expect(text).not.toMatch(
      /Jetzt kaufen|Jetzt bestellen|Buy now|Purchase now/i
    );

    expect(text).not.toMatch(
      /CHF\s*\d+|EUR\s*\d+|USD\s*\d+|€\s*\d+|\$\s*\d+/i
    );
  });

  test('kein Warenkorb oder Checkout ist implementiert', async ({ page }) => {
    await page.goto(SHOP);

    await expect(
      page.locator(
        '[data-cart], #cart, .cart, [data-testid*="cart"]'
      )
    ).toHaveCount(0);

    await expect(
      page.locator(
        '[data-checkout], #checkout, .checkout, [data-testid*="checkout"]'
      )
    ).toHaveCount(0);
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

      await page.goto(SHOP);

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
    await page.goto(SHOP);

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
    await page.goto(SHOP);

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
        `Developer-Tool-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('zentrale Shop-Ziele sind verlinkt', async ({ page }) => {
    await page.goto(SHOP);

    const targets = [
      '/products/',
      '/solutions/',
      '/pricing/',
      '/downloads/',
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
        `Shop-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(SHOP);

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
    await page.goto(SHOP);

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
    await page.goto(SHOP);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() =>
      document.activeElement?.tagName || ''
    );

    expect(focused).not.toBe('BODY');
    expect(focused).not.toBe('HTML');
    expect(focused).not.toBe('');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(SHOP);

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
    await page.goto(SHOP);

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

    await page.goto(SHOP);

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

    await page.goto(SHOP);
    await page.waitForLoadState('load');

    expect(
      errors,
      errors.join('\n')
    ).toEqual([]);
  });

});