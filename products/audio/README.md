# CoreCraft Genesis Audio

## Zweck

Der Audio-Bereich stellt technische Produktseiten,
browserbasierte Audio-Werkzeuge, Demonstrationen
und strukturierte Konfigurationsdaten bereit.

## Hauptmodule

- AudioState Architecture
- Digital Signal Processing
- Audio Orchestration
- State Validation
- Scaling and Failover
- Audio Diagnostics

## Tools

- Audio Analyzer
- Audio Oscillator
- Signal Monitor

## Demos

- Signal Chain Demo
- AudioState Demo

## JavaScript-Module

- assets/js/audio-core.js
- assets/js/audio-analyzer.js
- assets/js/audio-state.js
- assets/js/ui.js

## AudioWorklet

- assets/worklets/audio-processor.js

## Daten

- data/modules.json
- data/capabilities.json
- data/tools.json

## Lokaler Test

Website über einen lokalen Webserver öffnen.

PowerShell:

Set-Location C:\corecraftgenesis.ch
python -m http.server 8080

Danach die Website über den lokalen Port 8080 öffnen.

## Validierung

1. Dateien prüfen
2. JSON prüfen
3. JavaScript prüfen
4. interne Routen prüfen
5. Browser-Konsole prüfen
6. AudioContext prüfen
