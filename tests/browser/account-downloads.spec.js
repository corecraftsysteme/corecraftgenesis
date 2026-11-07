const { test, expect } = require('@playwright/test');

const DOWNLOADS = '/account/downloads/';

test.describe('CoreCraft Genesis - Account Downloads Acceptance', () => {

  test('Account Downloads lädt erfolgreich', async ({ page }) => {
    const response = await page.goto(DOWNLOADS);

    expect(response).not.toBeNull();
    expect(response.status()).toBeLessThan(400);

    await expect(page).toHaveURL(
      /\/account\/downloads\/?$/
    );
  });

  test('HTML-Grundstruktur ist vollständig', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(page.locator('html')).toHaveAttribute(
      'lang',
      /^(de|de-CH)$/i
    );

    await expect(page.locator('header')).toHaveCount(1);
    await expect(page.locator('main')).toHaveCount(1);
    await expect(page.locator('h1')).toHaveCount(1);
    await expect(page.locator('footer')).toHaveCount(1);
  });

  test('SEO-Grunddaten sind korrekt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(page).toHaveTitle(
      /Account Downloads.*CoreCraft Genesis/i
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
      'https://corecraftgenesis.ch/account/downloads/'
    );
  });

  test('H1 ist korrekt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(
      page.locator('h1')
    ).toContainText(
      /Persönliche Downloads transparent vorbereiten/i
    );
  });

  test('H2-Struktur ist vollständig', async ({ page }) => {
    await page.goto(DOWNLOADS);

    expect(
      await page.locator('h2').count()
    ).toBeGreaterThanOrEqual(5);

    const headings = [
      /Accountbezogene Bereitstellung ist vorbereitet/i,
      /Öffentliche Ressourcen bleiben separat verfügbar/i,
      /Zukünftige Bereitstellung folgt klaren Zuständen/i,
      /Downloads und Zugangsinformationen schützen/i,
      /Produktzugriff und Downloads getrennt verwalten/i,
      /Weitere Account-Ressourcen/i
    ];

    for (const heading of headings) {
      await expect(
        page.getByRole('heading', {
          name: heading
        })
      ).toBeVisible();
    }
  });

  test('vier Download-Statusbereiche sind vorhanden', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const headings = [
      'Persönliche Downloads',
      'Produktressourcen',
      'Download-Berechtigungen',
      'Download-Verlauf'
    ];

    for (const heading of headings) {
      await expect(
        page.getByRole('heading', {
          name: heading,
          exact: true
        })
      ).toBeVisible();
    }
  });

  test('Download-Status ist korrekt inaktiv', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(
      page.getByText('In Vorbereitung', {
        exact: true
      })
    ).toHaveCount(2);

    await expect(
      page.getByText('Nicht aktiviert', {
        exact: true
      })
    ).toHaveCount(2);
  });

  test('Status wird transparent erklärt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const notice = page.locator('.notice').first();

    await expect(notice).toBeVisible();

await expect(notice).toContainText(/Passwörter/i);
await expect(notice).toContainText(/private\s+Schlüssel/i);
await expect(notice).toContainText(/Zugangstoken/i);

    await expect(notice).toContainText(
      /keine Dateien.*Zugriffsrechte.*Download-Berechtigungen/is
    );
  });

  test('keine persönlichen Download-Dateien werden vorgetäuscht', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const body = await page.locator('body').innerText();

    expect(body).not.toMatch(
      /Download-ID\s*:\s*[A-Z0-9-]+|File-ID\s*:\s*[A-Z0-9-]+/i
    );

    expect(body).not.toMatch(
      /https?:\/\/[^\s]+\/private\/[^\s]+/i
    );
  });

  test('keine Tokens oder Lizenzschlüssel werden angezeigt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const body = await page.locator('body').innerText();

    expect(body).not.toMatch(
      /Lizenzschlüssel\s*:\s*[A-Z0-9-]{8,}/i
    );

    expect(body).not.toMatch(
      /Access Token\s*:\s*[A-Z0-9._-]{8,}/i
    );
  });

  test('Future Delivery enthält vier Schritte', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(
      page.locator('ol.steps > li')
    ).toHaveCount(4);

    const terms = [
      'Produktzuordnung',
      'Zugriffsprüfung',
      'Ressourcenzuordnung',
      'Download'
    ];

    for (const term of terms) {
      await expect(
        page.locator('ol.steps').getByText(
          term,
          { exact: true }
        )
      ).toBeVisible();
    }
  });

 test('Sicherheitshinweis ist vorhanden', async ({ page }) => {
  await page.goto(DOWNLOADS);

  const notice = page.locator('.notice').filter({
    hasText: 'Sicherheitshinweis'
  });

  await expect(notice).toBeVisible();

  await expect(notice).toContainText(/Passwörter/i);

  await expect(notice).toContainText(
    /private\s+Schlüssel/i
  );

  await expect(notice).toContainText(
    /Zugangstoken/i
  );
});

  test('Skip-Link ist vorhanden', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(
      page.locator(
        'a.skip-link[href="#content"]'
      )
    ).toHaveCount(1);

    await expect(
      page.locator('main#content')
    ).toHaveCount(1);
  });

  test('Navigation besitzt Accessible-Bezeichnungen', async ({ page }) => {
    await page.goto(DOWNLOADS);

    await expect(
      page.locator(
        'nav[aria-label="Hauptnavigation"]'
      )
    ).toHaveCount(1);

    await expect(
      page.locator(
        'nav[aria-label="Brotkrümelnavigation"]'
      )
    ).toHaveCount(1);
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

  test('zentrale Ressourcen sind verlinkt', async ({ page }) => {
    await page.goto(DOWNLOADS);

    const targets = [
      '/account/',
      '/account/products/',
      '/products/',
      '/downloads/',
      '/docs/',
      '/pricing/',
      '/legal/licenses/',
      '/legal/privacy/',
      '/support/'
    ];

    for (const target of targets) {
      await expect(
        page.locator(`a[href="${target}"]`).first(),
        `Link fehlt: ${target}`
      ).toBeVisible();
    }
  });

  test('Links enthalten keine leeren oder JavaScript-Ziele', async ({ page }) => {
    await page.goto(DOWNLOADS);

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
        elements
          .map(element =>
            element.getAttribute('href')
          )
          .filter(Boolean)
      )]
    );

    const links = hrefs.filter(href =>
      href.startsWith('/') &&
      !href.startsWith('//')
    );

    for (const href of links) {
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

    expect(errors, errors.join('\n')).toEqual([]);
  });

});
