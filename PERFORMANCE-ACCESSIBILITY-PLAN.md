\# CoreCraft Genesis – Performance \& Accessibility Plan



\## Gesamtziel



CoreCraft Genesis soll nach dieser Entwicklungsphase:



\- schnell und ressourcenschonend laden

\- auf Desktop und Mobilgeräten zuverlässig funktionieren

\- vollständig mit der Tastatur bedienbar sein

\- für Menschen mit unterschiedlichen Einschränkungen zugänglich sein

\- semantisch sauber aufgebaut sein

\- technische Qualitätsprobleme automatisiert erkennen können



\### Accessibility-Ziel



Zielstandard:



\*\*WCAG 2.2 Level AA\*\*



\---



\# Phase A – Performance



\## A1 – Ressourceninventar



Automatisch erfassen:



\- HTML-Dateien

\- CSS-Dateien

\- JavaScript-Dateien

\- Bilder

\- Fonts

\- JSON-Dateien

\- Audio- und Video-Dateien

\- Dateigrößen

\- Gesamtgröße

\- ungewöhnlich große Ressourcen



\### Ziel



Wir wissen exakt, welche Dateien und Assets die Website belasten.



\---



\## A2 – HTML/CSS/JavaScript-Qualität



Prüfen:



\- doppelte CSS-Referenzen

\- doppelte JavaScript-Referenzen

\- fehlende lokale Assets

\- große Inline-Styles

\- große Inline-Skripte

\- ungewöhnlich große Einzeldateien

\- unnötig viele Ressourcen pro Seite

\- potenziell blockierende Ressourcen



\### Ziel



Keine kritischen strukturellen Performance-Probleme.



\---



\## A3 – Live-Performance



Nach dem lokalen Audit zusätzlich prüfen:



\- reale Ladezeiten

\- Verhalten der produktiven Website

\- mobile Performance

\- Ressourcenübertragung

\- Browser-Verhalten

\- sichtbare Verzögerungen

\- große oder langsam geladene Ressourcen



\---



\# Phase B – Accessibility



\## B1 – Semantische Grundstruktur



Jede geeignete HTML-Seite prüfen auf:



\- `html lang`

\- `title`

\- sinnvolle H1-Hauptüberschrift

\- Überschriftenhierarchie

\- `main`

\- Navigation

\- Header

\- Footer

\- Buttons als echte Buttons

\- Links als echte Links



\---



\## B2 – Bilder



Für Bilder prüfen:



\- `alt`-Attribut vorhanden

\- sinnvoller Alternativtext bei Inhaltsbildern

\- dekorative Bilder korrekt behandelt

\- keine kaputten Bildquellen



\---



\## B3 – Tastaturbedienung



Interaktive Komponenten müssen ohne Maus bedienbar sein.



Besonders prüfen:



\- Eingabefelder

\- Validatoren

\- Buttons

\- Navigation

\- Menüs

\- Copy-Funktionen

\- Datei-Eingaben

\- Developer Tools



\### Ziel



Alle wichtigen Funktionen sind per Tastatur erreichbar und bedienbar.



\---



\## B4 – Fokus



Prüfen:



\- Fokus sichtbar

\- Fokus nicht verdeckt

\- sinnvolle Tab-Reihenfolge

\- keine Keyboard-Traps

\- aktive Elemente eindeutig erkennbar



\---



\## B5 – Formulare



Prüfen:



\- Eingaben besitzen verständliche Beschriftungen

\- Buttons sind eindeutig benannt

\- Fehlermeldungen sind verständlich

\- Pflichtfelder sind erkennbar

\- Statusänderungen sind verständlich

\- Formulare funktionieren mit Tastatur



\---



\## B6 – Kontrast und Lesbarkeit



Prüfen:



\- Textkontrast

\- Button-Kontrast

\- Linkerkennbarkeit

\- Fokusdarstellung

\- Fehlermeldungen verwenden nicht ausschließlich Farbe

\- ausreichende Lesbarkeit

\- Zoom

\- Reflow



\---



\# Phase C – Mobile



Gezielt prüfen:



\- kleine Bildschirmbreiten

\- Hauptnavigation

\- Produktnavigation

\- Developer Tools

\- Formulare

\- Tabellen

\- Codebereiche

\- Buttons

\- lange URLs

\- horizontales Scrollen

\- Überlappungen

\- Touch-Bedienung



\### Ziel



Keine kritischen Layout- oder Bedienungsprobleme auf kleinen Bildschirmen.



\---



\# Phase D – Automatisiertes Audit



Audit-Skript:



`Final-PerformanceAccessibilityAudit.ps1`



Automatisch prüfen:



\- HTML pages

\- CSS files

\- JavaScript files

\- Images

\- Fonts

\- JSON files

\- Media files

\- Large assets

\- Missing assets

\- Broken resources

\- Duplicate resources

\- Missing alt attributes

\- Missing lang

\- Missing H1

\- Multiple H1

\- Missing main

\- Empty links

\- Empty buttons

\- Form label problems

\- Duplicate script references

\- Duplicate stylesheet references



\## Einschränkung



Das automatisierte Audit kann keine vollständige WCAG-Konformität garantieren.



Zusätzlich erforderlich:



\- manueller Tastaturtest

\- visuelle Prüfung

\- Kontrastprüfung

\- Mobile-Test

\- Prüfung interaktiver Komponenten



\---



\# Definition of Done



\## PERFORMANCE



\- \[ ] Broken resources: 0

\- \[ ] Missing assets: 0

\- \[ ] Duplicate resources: 0

\- \[ ] Critical size findings: 0



\## ACCESSIBILITY



\- \[ ] Missing lang: 0

\- \[ ] Missing H1: 0

\- \[ ] Critical heading issues: 0

\- \[ ] Missing required alt: 0

\- \[ ] Empty controls: 0

\- \[ ] Critical form issues: 0



\## QUALITY



\- \[ ] Site Audit: PASS

\- \[ ] SEO Audit: PASS

\- \[ ] Live SEO Audit: PASS

\- \[ ] Performance \& Accessibility Audit: PASS

\- \[ ] Manual keyboard test: PASS

\- \[ ] Mobile review: PASS



\## FINAL STATUS



`PRODUCTION QUALITY READY: TRUE`



\---



\# Entwicklungsreihenfolge



1\. `Final-PerformanceAccessibilityAudit.ps1` erstellen

2\. Alle 82 HTML-Seiten prüfen

3\. Befunde klassifizieren

4\. Kritische Performance-Probleme beheben

5\. Kritische Accessibility-Probleme beheben

6\. Audit erneut ausführen

7\. Tastaturbedienung manuell testen

8\. Mobile Darstellung prüfen

9\. Live-Performance testen

10\. Production Build ausführen

11\. Änderungen committen und pushen

12\. abschließenden Live-Audit durchführen

