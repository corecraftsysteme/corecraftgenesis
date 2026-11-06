const { test, expect } = require('@playwright/test');

const PAGE_PATH = '/products/developer-tools/validators/file/';
const validJson = JSON.stringify({
  title: 'CoreCraft Genesis',
  type: 'object',
  properties: {
    name: { type: 'string' },
    enabled: { type: 'boolean' }
  }
}, null, 2);

async function uploadMetafields(page, content = validJson) {
  await page.locator('#fileInput').setInputFiles({
    name: 'metafields.json',
    mimeType: 'application/json',
    buffer: Buffer.from(content, 'utf8')
  });
  await expect(page.locator('body')).toContainText('Datei ausgewählt: metafields.json');
}

async function validate(page) {
  await page.locator('#validateButton').click();
  await expect(page.locator('body')).not.toContainText('Noch keine Validierung durchgeführt.');
}

async function bodyText(page) {
  return await page.locator('body').innerText();
}

test.describe('CoreCraft Genesis File Validator', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(PAGE_PATH);
    await expect(page.locator('#fileInput')).toHaveAttribute('type', 'file');
    await expect(page.locator('#validateButton')).toHaveText(/Datei validieren/);
  });

  test('validiert metafields.json ohne optionale Regeln', async ({ page }) => {
    await uploadMetafields(page);
    await validate(page);

    const text = await bodyText(page);
    expect(text).toContain('metafields.json');
    expect(text).toContain('application/json');
    expect(text).toContain('Keine Namensregel definiert');
    expect(text).toContain('Keine Erweiterungsregel definiert');
    expect(text).toContain('Keine Größenregel definiert');
    expect(text).toMatch(/JSON/i);
  });

  test('besteht mit korrekten Dateiregeln', async ({ page }) => {
    await page.locator('#expectedName').fill('metafields.json');
    await page.locator('#expectedExtensions').fill('json');
    await page.locator('#maxSize').fill('10');

    await uploadMetafields(page);
    await validate(page);

    const text = await bodyText(page);
    expect(text).toContain('metafields.json');
    expect(text).not.toContain('Keine Namensregel definiert');
    expect(text).not.toContain('Keine Erweiterungsregel definiert');
    expect(text).not.toContain('Keine Größenregel definiert');
    expect(text).toMatch(/JSON/i);
  });

  test('erkennt einen falschen erwarteten Dateinamen', async ({ page }) => {
    await page.locator('#expectedName').fill('wrong-file.json');
    await uploadMetafields(page);
    await validate(page);

    const text = await bodyText(page);
    expect(text).toContain('metafields.json');
    expect(text).toMatch(/wrong-file\.json|Dateiname/i);
    expect(text).toMatch(/FAIL|nicht|abweich|erwart/i);
  });

  test('erkennt ungültige JSON-Syntax', async ({ page }) => {
    await uploadMetafields(page, '{"name": "broken",}');
    await validate(page);

    const text = await bodyText(page);
    expect(text).toContain('metafields.json');
    expect(text).toMatch(/JSON/i);
    expect(text).toMatch(/FAIL|ungültig|Fehler|nicht gültig/i);
  });
});
