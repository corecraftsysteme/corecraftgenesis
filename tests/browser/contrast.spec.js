const { test, expect } = require('@playwright/test');

const pages = [
  ['Startseite', '/'],
  ['Developer Tools', '/products/developer-tools/'],
  ['File Validator', '/products/developer-tools/validators/file/'],
  ['Schema Validator', '/products/developer-tools/validators/schema/'],
  ['Manifest Inspector', '/products/developer-tools/diagnostics/manifest-inspector/'],
  ['Data Inspector', '/products/developer-tools/data-tools/data-inspector/'],
  ['Route Checker', '/products/developer-tools/web-tools/route-checker/'],
  ['Link Checker', '/products/developer-tools/web-tools/link-checker/']
];

function contrastHelpers() {
  function parseColor(value) {
    const m = value && value.match(/rgba?\((\d+(?:\.\d+)?)[, ]+(\d+(?:\.\d+)?)[, ]+(\d+(?:\.\d+)?)(?:[, /]+(\d*(?:\.\d+)?))?\)/i);
    if (!m) return null;
    return { r: +m[1], g: +m[2], b: +m[3], a: m[4] === undefined || m[4] === '' ? 1 : +m[4] };
  }
  function composite(fg, bg) {
    const a = fg.a + bg.a * (1 - fg.a);
    if (a === 0) return { r: 255, g: 255, b: 255, a: 1 };
    return {
      r: (fg.r * fg.a + bg.r * bg.a * (1 - fg.a)) / a,
      g: (fg.g * fg.a + bg.g * bg.a * (1 - fg.a)) / a,
      b: (fg.b * fg.a + bg.b * bg.a * (1 - fg.a)) / a,
      a
    };
  }
  function backgroundFor(el) {
    let node = el;
    let bg = { r: 255, g: 255, b: 255, a: 1 };
    const layers = [];
    while (node && node.nodeType === 1) {
      const c = parseColor(getComputedStyle(node).backgroundColor);
      if (c && c.a > 0) layers.push(c);
      node = node.parentElement;
    }
    for (let i = layers.length - 1; i >= 0; i--) bg = composite(layers[i], bg);
    return bg;
  }
  function luminance(c) {
    const f = v => {
      v /= 255;
      return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
    };
    return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
  }
  function ratio(a, b) {
    const x = luminance(a), y = luminance(b);
    return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05);
  }
  return { parseColor, composite, backgroundFor, ratio };
}

for (const [name, path] of pages) {
  test(`${name}: sichtbarer Text erfüllt WCAG-AA-Kontrast`, async ({ page }) => {
    await page.goto(path);

    const failures = await page.locator('body *').evaluateAll((nodes, helperSource) => {
      const helpers = eval(`(${helperSource})`)();
      const results = [];
      for (const el of nodes) {
        if (!(el instanceof HTMLElement)) continue;
        const rect = el.getBoundingClientRect();
        const style = getComputedStyle(el);
        if (rect.width <= 0 || rect.height <= 0 || style.visibility === 'hidden' || style.display === 'none' || Number(style.opacity) === 0) continue;
        const ownText = Array.from(el.childNodes).filter(n => n.nodeType === Node.TEXT_NODE).map(n => n.textContent).join(' ').trim();
        if (!ownText) continue;
        const fgRaw = helpers.parseColor(style.color);
        if (!fgRaw) continue;
        const bg = helpers.backgroundFor(el);
        const fg = helpers.composite(fgRaw, bg);
        const cr = helpers.ratio(fg, bg);
        const size = parseFloat(style.fontSize);
        const weight = parseInt(style.fontWeight, 10) || 400;
        const large = size >= 24 || (size >= 18.66 && weight >= 700);
        const required = large ? 3 : 4.5;
        if (cr + 0.01 < required) {
          results.push({
            tag: el.tagName.toLowerCase(), id: el.id || '', cls: el.className || '',
            text: ownText.slice(0, 100), ratio: Number(cr.toFixed(2)), required,
            color: style.color, background: style.backgroundColor,
            fontSize: size, fontWeight: weight
          });
        }
      }
      return results;
    }, contrastHelpers.toString());

    expect(failures, JSON.stringify(failures, null, 2)).toEqual([]);
  });
}
