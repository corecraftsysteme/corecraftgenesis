const { test, expect } = require('@playwright/test');

const ACCOUNT = '/account/';

test.describe('CoreCraft Genesis - Account Acceptance', () => {

  test('Account lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(ACCOUNT);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(/\/account\/?$/);
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(ACCOUNT);

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
    await page.goto(ACCOUNT);

    await expect(page).toHaveTitle(
      /Account.*Access.*CoreCraft Genesis/i
    );
  });

  test('SEO-Grunddaten sind vorhanden', async ({ page }) => {
    await page.goto(ACCOUNT);

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
      'https://corecraftgenesis.ch/account/'
    );
  });

  test('H1 beschreibt den Account-Status korrekt', async ({ page }) => {
    await page.goto(ACCOUNT);

    await expect(page.locator('h1')).toContainText(
      /Account-Funktionen transparent vorbereiten/i
    );
  });

  test('Account besitzt strukturierte Inhaltsbereiche', async ({ page }) => {
    await page.goto(ACCOUNT);

    expect(
      await page.locator('h2').count()
    ).toBeGreaterThanOrEqual(6);

    const headings = [
      /klare Grundlage für zukünftige Kontofunktionen/i,
      /Bereits verfügbare Bereiche direkt öffnen/i,
      /Zugangsdaten und persönliche Informationen schützen/i,
      /Produktzugang und Lizenzierung getrennt betrachten/i,
      /Funktionen werden erst mit realer Infrastruktur aktiviert/i,
      /Häufige Fragen zum Account-Bereich/i,
      /Direkt zu den verfügbaren Ressourcen/i
    ];

    for (const name of headings) {
      await expect(
        page.getByRole('heading', { name })
      ).toBeVisible();
    }
  });

  test('vier geplante Account-Bereiche sind vorhanden', async ({ page }) => {
    await page.goto(ACCOUNT);

    const areas = [
      'Kontoverwaltung',
      'Product Access',
      'Persönliche Ressourcen',
      'Produkt- und Lizenzzuordnung'
    ];

    for (const area of areas) {
      await expect(
        page.getByRole('heading', {
          name: area,
          exact: true
        })
      ).toBeVisible();
    }

    await expect(
      page.getByText('In Vorbereitung', {
        exact: true
      })
    ).toHaveCount(4);
  });

  test('aktuell verfügbare Ressourcen sind vorhanden', async ({ page }) => {
    await page.goto(ACCOUNT);

    const areas = [
      'Produkte',
      'Downloads',
      'Dokumentation',
      'Technische Ressourcen'
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

  test('Account-Status wird transparent dargestellt', async ({ page }) => {
    await page.goto(ACCOUNT);

    const notice = page.locator('.notice').first();

    await expect(notice).toBeVisible();

    await expect(notice).toContainText(
      /Aktueller Status/i
    );

    await expect(notice).toContainText(
      /Account-Bereich\s+befindet\s+sich\s+in\s+Vorbereitung/i
    );

    await expect(notice).toContainText(
      /noch keine Anmeldung.*Registrierung.*Kontofunktionen/is
    );
  });

  test('kein Login-Formular ist implementiert', async ({ page }) => {
    await page.goto(ACCOUNT);

    await expect(
      page.locator('form')
    ).toHaveCount(0);

    await expect(
      page.locator('input[type="email"]')
    ).toHaveCount(0);

    await expect(
      page.locator('input[type="password"]')
    ).toHaveCount(0);
  });

  test('keine Login- oder Registrierungsaktion wird angeboten', async ({ page }) => {
    await page.goto(ACCOUNT);

    const interactiveText = await page.locator(
      'a, button, input[type="submit"]'
    ).allInnerTexts();

    const combined = interactiveText.join(' ');

    expect(combined).not.toMatch(
      /Anmelden|Einloggen|Login|Sign in|Registrieren|Register|Sign up/i
    );
  });

  test('keine vorgetäuschten persönlichen Kontodaten vorhanden', async ({ page }) => {
    await page.goto(ACCOUNT);

    const text = await page.locator('body').innerText();

    expect(text).not.toMatch(
      /Meine Bestellungen|Bestellhistorie|Meine Rechnungen|Meine Käufe/i
    );

    expect(text).not.toMatch(
      /Lizenzschlüssel:\s*[A-Z0-9-]{8,}/i
    );
  });

  test('Sicherheitshinweis ist vorhanden', async ({ page }) => {
    await page.goto(ACCOUNT);

    const notices = page.locator('.notice');

    expect(await notices.count()).toBeGreaterThanOrEqual(2);

    await expect(
      notices.filter({
        hasText: 'Sicherheitshinweis'
      })
    ).toContainText(
      /Passwörter.*privaten Schlüssel.*Zugangstoken/is
    );
  });

  test('zukünftige Account-Architektur besitzt fünf Schritte', async ({ page }) => {
    await page.goto(ACCOUNT);

    await expect(
      page.locator('ol.steps > li')
    ).toHaveCount(5);
  });

  test('FAQ besitzt sechs Fragen', async ({ page }) => {
    await page.goto(ACCOUNT);

    const faqHeading = page.getByRole('heading', {
      name: /Häufige Fragen zum Account-Bereich/i
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
    await page.goto(ACCOUNT);

    const questions = [
      /Ist ein persönlicher Account bereits verfügbar/i,
      /Muss ich mich derzeit registrieren/i,
      /Wo finde ich verfügbare Ressourcen/i,
      /Wie funktionieren spätere Produktzugänge/i,
      /Wo finde ich Lizenzinformationen/i,
      /Wo finde ich technische Informationen/i
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

      await page.goto(ACCOUNT);

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

  test('zentrale Account-Ziele sind verlinkt', async ({ page }) => {
    await page.goto(ACCOUNT);

    const targets = [
      '/products/',
      '/shop/',
      '/downloads/',
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
        `Account-Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(ACCOUNT);

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
    await page.goto(ACCOUNT);

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
    await page.goto(ACCOUNT);

    await page.keyboard.press('Tab');

    const focused = await page.evaluate(() =>
      document.activeElement?.tagName || ''
    );

    expect(focused).not.toBe('BODY');
    expect(focused).not.toBe('HTML');
    expect(focused).not.toBe('');
  });

  test('fokussierter Link besitzt sichtbaren Fokus', async ({ page }) => {
    await page.goto(ACCOUNT);

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
    await page.goto(ACCOUNT);

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

    await page.goto(ACCOUNT);

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

    await page.goto(ACCOUNT);
    await page.waitForLoadState('load');

    expect(
      errors,
      errors.join('\n')
    ).toEqual([]);
  });

});

