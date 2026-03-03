# **audit-engine.md — Genesis Operational Layer / Audit Engine**

## 1. Zweck der Audit Engine
Die Audit Engine ist die technische Komponente der Genesis‑Infrastruktur, die alle Audit‑Einträge erzeugt, signiert, speichert und reproduzierbar macht. Sie bildet die Brücke zwischen:

- **Engine‑Ausführung** (corecraft‑chainline)  
- **Operational Layer** (Blueprints, Operator‑Modelle, Ritual‑Definitionen)  
- **Audit‑Schicht** (Protokolle, Hash‑Ketten, Signaturen)

Die Audit Engine stellt sicher, dass jede relevante Aktion innerhalb der Genesis‑Chain deterministisch nachvollziehbar bleibt.

---

## 2. Architekturüberblick
Die Audit Engine besteht aus fünf Kernmodulen:

- **Event Collector** — empfängt Audit‑Trigger aus der Engine  
- **Hash Pipeline** — erzeugt SHA‑256‑Hashes für alle Audit‑Objekte  
- **Signature Pipeline** — signiert Audit‑Einträge mit Ed25519  
- **Storage Layer** — speichert Audit‑Protokolle in JSON‑Form  
- **Reproduction Engine** — rekonstruiert Audit‑Einträge zur Verifikation  

Alle Module sind deterministisch, side‑effect‑frei und reproduzierbar.

---

## 3. Audit‑Triggerpunkte
Die Engine löst Audit‑Trigger an folgenden Stellen aus:

- Genesis‑Initialisierung  
- Operator‑Erstellung, Rollenänderungen, Siegel‑Updates  
- Ritual‑Ausführung (Start, Preconditions, Postconditions)  
- Payout‑Ereignisse  
- Echo‑Registry‑Writes  
- Skeletton™‑Drift‑Signale  

Jeder Trigger erzeugt mindestens einen Audit‑Eintrag.

---

## 4. Event Collector
Der Event Collector ist die Eingangsstufe der Audit Engine.

Er nimmt strukturierte Audit‑Events entgegen:

```
{
  "type": "ritual",
  "action": "execute",
  "operator": "OP-001",
  "payload": { ... },
  "timestamp": "<iso8601>"
}
```

Der Collector validiert:

- Event‑Typ  
- Operator‑ID  
- Payload‑Struktur  
- Zeitstempel  

Ungültige Events werden verworfen und als Audit‑Fehler protokolliert.

---

## 5. Hash Pipeline
Die Hash Pipeline erzeugt deterministische SHA‑256‑Hashes.

### 5.1 Hash‑Regeln
- JSON‑Objekte werden **kanonisch serialisiert**  
- Felder werden alphabetisch sortiert  
- Whitespace wird entfernt  
- Zeitstempel werden normalisiert  

### 5.2 Hash‑Beispiel

```
hash = SHA256(canonical_json)
```

### 5.3 Hash‑Ketten
Audit‑Einträge werden verkettet:

```
chain_hash = SHA256(hash_previous + hash_current)
```

---

## 6. Signature Pipeline
Die Signature Pipeline signiert Audit‑Einträge mit Ed25519.

### 6.1 Signatur‑Objekt

```
{
  "hash": "<sha256>",
  "signature": "<ed25519>",
  "operator": "<operator-id>"
}
```

### 6.2 Signatur‑Regeln
- deterministische Nonces  
- Operator‑Keys aus der Engine  
- Signaturen werden separat gespeichert  

---

## 7. Storage Layer
Der Storage Layer speichert Audit‑Einträge in:

```
genesis-operational-layer/audit/audit-protocols/
```

Dateien:

- `genesis-audit.json`  
- `operator-audit.json`  
- `ritual-audit.json`  
- `payout-audit.json`  
- `echo-audit.json`  
- `skeletton-audit.json`  

Jede Datei enthält:

- Audit‑Einträge  
- Hash‑Ketten  
- Signaturen  
- Fehlerprotokolle  

---

## 8. Reproduction Engine
Die Reproduction Engine rekonstruiert Audit‑Einträge aus:

- Engine‑State  
- Echo‑Registry  
- Ritual‑Logs  
- Operator‑Daten  
- Genesis‑Blueprints  

Ein Audit gilt als gültig, wenn:

- alle Hashes reproduzierbar sind  
- alle Signaturen gültig sind  
- alle Ereignisse vorhanden sind  
- alle Ketten konsistent sind  

---

## 9. Fehlerbehandlung
Die Audit Engine erzeugt Fehlerobjekte:

```
{
  "error": "HashMismatch",
  "expected": "<sha256>",
  "actual": "<sha256>",
  "event": "<event-id>",
  "timestamp": "<iso8601>"
}
```

Fehlerklassen:

- HashMismatch  
- InvalidSignature  
- MissingEvent  
- DriftDetected  
- EchoCorruption  

---

## 10. Export‑Mechanismus
Die Audit Engine exportiert:

- vollständige Audit‑Protokolle  
- Master‑Audit‑Hash  
- reproduzierbare Hash‑Ketten  

Export‑Ziel:

```
08_Audit/
```

---

## 11. Integration in corecraft‑chainline
Die Engine implementiert:

- Audit‑Hooks  
- Signatur‑Pipelines  
- Hash‑Pipelines  
- Echo‑Writes  
- Operator‑Verifikation  

Der Operational Layer definiert die Regeln, die Engine führt sie aus.
