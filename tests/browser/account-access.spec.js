const { test, expect } = require('@playwright/test');

const LOGIN = '/account/login/';
const REFERRAL = '/account/referrals/';

const pages = [
  {
    name: 'Login',
    url: LOGIN,
    title: /Account-Zugang.*CoreCraft Genesis/i,
    canonical: 'https://corecraftgenesis.ch/account/login/',
    h1: 'Account-Zugang'
  },
  {
    name: 'Referral',
    url: REFERRAL,
    title: /Referral.*CoreCraft Genesis/i,
    canonical: 'https://corecraftgenesis.ch/account/referrals/',
    h1: 'Referral'
  }
];

test.describe('CoreCraft Genesis - Account Access Acceptance', () => {

  for (const entry of pages) {

    test(`${entry.name} lädt erfolgreich`, async ({ page }) => {
      const response = await page.goto(entry.url);

      expect(response).not.toBeNull();
      expect(response.status()).toBeLessThan(400);

      await expect(page).toHaveURL(
        new RegExp(
          entry.url.replace(/\//g, '\\/') + '?$'
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
      await expect(page.locator('main')).toHaveCount(1);
      await expect(page.locator('h1')).toHaveCount(1);
      await expect(page.locator('footer')).toHaveCount(1);

      expect(
        await page.locator('h2').count()
      ).toBeGreaterThanOrEqual(3);
    });

    test(`${entry.name} SEO-Grunddaten sind korrekt`, async ({ page }) => {
      await page.goto(entry.url);

      await expect(page).toHaveTitle(
        entry.title
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
        entry.canonical
      );
    });

    test(`${entry.name} H1 ist korrekt`, async ({ page }) => {
      await page.goto(entry.url);

      await expect(
        page.getByRole('heading', {
          level: 1,
          name: entry.h1,
          exact: true
        })
      ).toBeVisible();
    });

    test(`${entry.name} Skip-Link ist vorhanden`, async ({ page }) => {
      await page.goto(entry.url);

      await expect(
        page.locator(
          'a.skip-link[href="#content"]'
        )
      ).toHaveCount(1);

      await expect(
        page.locator('main#content')
      ).toHaveCount(1);
    });

    test(`${entry.name} Navigation ist zugänglich bezeichnet`, async ({ page }) => {
      await page.goto(entry.url);

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
  }

  test('Login ist transparent deaktiviert', async ({ page }) => {
    await page.goto(LOGIN);

    await expect(
      page.getByText(
        'Nicht verfügbar',
        { exact: true }
      )
    ).toBeVisible();

    await expect(
      page.locator('.notice').first()
    ).toContainText(
      /Anmeldung ist aktuell nicht möglich/i
    );

    await expect(
      page.locator('.notice').first()
    ).toContainText(
      /keine Zugangsdaten verarbeitet/i
    );
  });

  test('Login besitzt kein Anmeldeformular', async ({ page }) => {
    await page.goto(LOGIN);

    await expect(
      page.locator('form')
    ).toHaveCount(0);

    await expect(
      page.locator('input')
    ).toHaveCount(0);

    await expect(
      page.locator('button')
    ).toHaveCount(0);
  });

  test('Login besitzt kein Passwortfeld', async ({ page }) => {
    await page.goto(LOGIN);

    await expect(
      page.locator('input[type="password"]')
    ).toHaveCount(0);
  });

  test('Login bietet keine Registrierung oder Passwortaktion', async ({ page }) => {
    await page.goto(LOGIN);

    const hrefs = await page.locator(
      'a[href]'
    ).evaluateAll(elements =>
      elements.map(element =>
        element.getAttribute('href')
      )
    );

    for (const href of hrefs) {
      expect(href.toLowerCase()).not.toMatch(
        /register|signup|sign-up|password-reset|forgot-password/
      );
    }
  });

  test('Login erzeugt keine clientseitige Fake-Session', async ({ page }) => {
    await page.goto(LOGIN);

    const storage = await page.evaluate(() => ({
      localStorageKeys:
        Object.keys(localStorage),

      sessionStorageKeys:
        Object.keys(sessionStorage)
    }));

    expect(
      storage.localStorageKeys
    ).toEqual([]);

    expect(
      storage.sessionStorageKeys
    ).toEqual([]);
  });

  test('Login besitzt vier Sicherheitsbereiche', async ({ page }) => {
    await page.goto(LOGIN);

    const headings = [
      'Identität',
      'Sitzung',
      'Zugriff',
      'Sicherheit'
    ];

    for (const heading of headings) {
      await expect(
        page.getByRole('heading', {
          level: 3,
          name: heading,
          exact: true
        })
      ).toBeVisible();
    }
  });

  test('Referral ist transparent deaktiviert', async ({ page }) => {
    await page.goto(REFERRAL);

    await expect(
      page.getByText(
        'Nicht verfügbar',
        { exact: true }
      )
    ).toBeVisible();

    const notice = page.locator(
      '.notice'
    ).first();

    await expect(notice).toContainText(
      /keine Referral-Codes/i
    );

    await expect(notice).toContainText(
      /Provisionen/i
    );

    await expect(notice).toContainText(
      /Auszahlungen/i
    );
  });

  test('Referral besitzt vier deaktivierte Funktionsbereiche', async ({ page }) => {
    await page.goto(REFERRAL);

    const headings = [
      'Referral-Code',
      'Zuordnung',
      'Vergütung',
      'Auszahlung'
    ];

    for (const heading of headings) {
      await expect(
        page.getByRole('heading', {
          level: 3,
          name: heading,
          exact: true
        })
      ).toBeVisible();
    }

    await expect(
      page.getByText(
        'Nicht aktiviert',
        { exact: true }
      )
    ).toHaveCount(4);
  });

  test('Referral erzeugt keine Codes oder Vergütungen', async ({ page }) => {
    await page.goto(REFERRAL);

    const body = await page.locator(
      'body'
    ).innerText();

    expect(body).not.toMatch(
      /Referral-Code\s*:\s*[A-Z0-9-]{4,}/i
    );

    expect(body).not.toMatch(
      /Provision\s*:\s*\d+/i
    );

    expect(body).not.toMatch(
      /Guthaben\s*:\s*(CHF|EUR|USD|\$|€)\s*\d+/i
    );
  });

  test('Referral enthält keine Tracking- oder Join-Aktion', async ({ page }) => {
    await page.goto(REFERRAL);

    await expect(
      page.locator('form')
    ).toHaveCount(0);

    const hrefs = await page.locator(
      'a[href]'
    ).evaluateAll(elements =>
      elements.map(element =>
        element.getAttribute('href')
      )
    );

    for (const href of hrefs) {
      expect(
        href.toLowerCase()
      ).not.toMatch(
        /\/referral\/join\/|javascript:/
      );
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
            dimensions.scrollWidth
          ).toBeLessThanOrEqual(
            dimensions.clientWidth + 1
          );
        }
      );
    }
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

      expect(
        hrefs.length
      ).toBeGreaterThan(0);

      for (const href of hrefs) {
        expect(href).not.toBeNull();
        expect(href.trim()).not.toBe('');
        expect(href.trim()).not.toBe('#');

        expect(
          href.toLowerCase()
        ).not.toMatch(/^javascript:/);
      }
    });

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
        const response = await request.get(
          href
        );

        expect(
          response.status(),
          `${href} liefert HTTP ${response.status()}`
        ).toBeLessThan(400);
      }
    });

    test(`${entry.name}: sichtbarer Tastaturfokus`, async ({ page }) => {
      await page.goto(entry.url);

      const link = page.locator(
        'a[href]'
      ).first();

      await link.focus();

      await expect(
        link
      ).toBeFocused();

      const style = await link.evaluate(element => {
        const computed =
          getComputedStyle(element);

        return {
          outlineStyle:
            computed.outlineStyle,

          outlineWidth:
            computed.outlineWidth
        };
      });

      expect(
        style.outlineStyle
      ).not.toBe('none');

      expect(
        style.outlineWidth
      ).not.toBe('0px');
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

      expect(
        behavior
      ).toBe('auto');
    });

    test(`${entry.name}: keine schweren Browserfehler`, async ({ page }) => {
      const errors = [];

      page.on(
        'pageerror',
        error => {
          errors.push(error.message);
        }
      );

      await page.goto(entry.url);
      await page.waitForLoadState('load');

      expect(
        errors,
        errors.join('\n')
      ).toEqual([]);
    });
  }

});