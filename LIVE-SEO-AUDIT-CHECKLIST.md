Für deinen aktuellen Stand sollte der Live-SEO-Audit vor allem bestätigen, dass Deployment und lokale Optimierungen identisch online angekommen sind. Google empfiehlt insbesondere die Kontrolle aus Sicht des Crawlers, crawlbare Links, Sitemap, Indexierungsregeln und Canonical-Signale.

Live-SEO-Audit-Checkliste

## Deployment
- [ ] Commit 6b1ec72 deployed
- [ ] main entspricht Produktion
- [ ] Production Build weiterhin Production ready: True
- [ ] Keine unerwarteten Redirects
- [ ] HTTPS funktioniert
## HTTP-Status

Für alle öffentlichen URLs:
- [ ] normale Seite → HTTP 200
- [ ] fehlende Seite → HTTP 404
- [ ] keine unerwarteten 5xx
- [ ] keine unbeabsichtigten Redirect-Ketten
Besonders prüfen:

/

/products/

/products/developer-tools/

/products/developer-tools/validators/json/

/products/developer-tools/web-tools/route-checker/

/products/developer-tools/web-tools/link-checker/

/products/developer-tools/diagnostics/manifest-inspector/

/docs/

## Canonical URLs

Für jede indexierbare Seite:
- [ ] genau ein Canonical
- [ ] Canonical verwendet HTTPS
- [ ] Domain ist corecraftgenesis.ch
- [ ] Canonical entspricht der tatsächlichen bevorzugten Route
- [ ] kein Canonical verweist versehentlich auf eine andere Produktseite
- [ ] Sitemap und Canonical widersprechen sich nicht
rel="canonical" ist ein starkes Canonical-Signal; Sitemap-Aufnahme ist ebenfalls ein Signal.

Beispiel:

<link

 rel="canonical"

 href="https://corecraftgenesis.ch/products/developer-tools/"

>

## Titles
- [ ] jede öffentliche Seite hat <title>
- [ ] keine leeren Titel
- [ ] keine unerwünschten Duplikate
- [ ] EngineCore-Dokumentation und EngineCore-Produktseite unterscheiden sich
- [ ] Seitentitel entspricht dem tatsächlichen Inhalt
Google empfiehlt beschreibende und individuelle Seitentitel.

## Meta Descriptions
- [ ] jede öffentliche Seite besitzt eine Description
- [ ] optimierte Descriptions sind live
- [ ] keine leeren Descriptions
- [ ] keine Duplikate
- [ ] Beschreibung entspricht dem Seiteninhalt
## Robots

Prüfen:

https://corecraftgenesis.ch/robots.txt

Soll enthalten:

User-agent: *

Allow: /

Sitemap: https://corecraftgenesis.ch/sitemap.xml
- [ ] erreichbar
- [ ] HTTP 200
- [ ] kein HTML-Markup
- [ ] Sitemap-Verweis korrekt
- [ ] wichtige CSS-/JS-/HTML-Ressourcen nicht unbeabsichtigt blockiert
Google weist darauf hin, dass wichtige Ressourcen für Crawling und Rendering zugänglich sein sollten.

## Sitemap

Prüfen:

https://corecraftgenesis.ch/sitemap.xml
- [ ] HTTP 200
- [ ] gültiges XML
- [ ] urlset vorhanden
- [ ] aktuell 81 öffentliche URLs
ausschließlich https://corecraftgenesis.ch/...
- [ ] keine 404-Seite
- [ ] keine toten URLs
- [ ] Canonicals und Sitemap konsistent
Google beschreibt Sitemaps als Möglichkeit, neue beziehungsweise aktualisierte Seiten mitzuteilen und Crawling zu unterstützen.

## 404-Seite

Eine garantiert nicht vorhandene Route aufrufen, beispielsweise:

/__corecraft-live-seo-test-missing__/

Erwartung:

HTTP 404
- [ ] eigene CoreCraft-404-Seite sichtbar
<meta name="robots" content="noindex,follow">
- [ ] Navigation zurück zur Website funktioniert
- [ ] nicht in Sitemap enthalten
## Interne Links

Dein lokaler Audit hat bereits:

Internal links : 1450

Broken links   : 0

Live zusätzlich kontrollieren:
- [ ] Hauptnavigation
- [ ] Produktnavigation
- [ ] Developer Tools
- [ ] Dokumentation
- [ ] Footer
- [ ] wichtige Call-to-Actions
Googlebot folgt crawlbaren Links, um weitere URLs einer Website zu entdecken.

## Google-Sicht prüfen

Für wichtige URLs mit der URL-Prüfung kontrollieren:
- [ ] Seite erreichbar
- [ ] Crawling erlaubt
- [ ] von Google gewählter Canonical plausibel
- [ ] von dir angegebener Canonical korrekt
- [ ] gerenderte Seite vollständig
Google empfiehlt die URL-Prüfung ausdrücklich, um zu kontrollieren, wie die Seite gesehen wird und welche Canonical-Seite ausgewählt wurde.

Prioritätsseiten

/

/products/

/products/enginecore/

/products/developer-tools/

/products/corecraft-pay/

/products/bitcoin-mining/

/products/documentation/

Definition of Done

Der Live-SEO-Audit ist abgeschlossen, wenn:

HTTP failures          : 0

Canonical failures     : 0

Title failures         : 0

Description failures   : 0

Robots failures        : 0

Sitemap failures       : 0

404 failures           : 0

Broken live routes     : 0

SEO critical failures  : 0

LIVE SEO READY         : TRUE

Die 16 lokalen H2_MISSING-Hinweise würde ich nicht zum Live-Release-Kriterium machen. Sie sind aktuell reine Strukturhinweise und sollten später nach inhaltlichem Nutzen statt nur zur Reduktion einer Audit-Zahl überprüft werden.
