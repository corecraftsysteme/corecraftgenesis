# **audit-spec.md — Genesis Operational Layer / Audit Specification**

## 1. Zweck der Audit‑Schicht
Die Audit‑Schicht des Genesis Operational Layer definiert die technischen Verfahren zur Verifikation aller Genesis‑bezogenen Abläufe. Sie stellt sicher, dass:

- Genesis‑Konfigurationen deterministisch reproduzierbar sind  
- Operator‑Aktionen nachvollziehbar und signiert sind  
- Ritual‑Abläufe prüfbar bleiben  
- Payout‑Ereignisse vollständig dokumentiert sind  
- Echo‑Registry‑Einträge unveränderbar verifiziert werden können  
- Skeletton™‑Drift‑Signale technisch validiert werden können  

Die Audit‑Schicht bildet die Integritäts‑Ebene zwischen Portal (Beschreibung) und Engine (Ausführung).

---

## 2. Audit‑Modelle
Die Audit‑Schicht verwendet fünf Audit‑Modelle:

### 2.1 Genesis‑Audit
Prüft die Integrität der initialen Chain‑Konfiguration:

- ChainID  
- Genesis‑Block  
- Validator‑Signaturen  
- Initiale Operator‑Rollen  
- Initiale Echo‑Registry‑Struktur  
- Initiale Payout‑Parameter  

Ergebnis: `genesis-audit.json`

---

### 2.2 Operator‑Audit
Prüft alle Operator‑bezogenen Aktionen:

- Operator‑Erstellung  
- Rollen‑Zuweisung  
- Siegel‑Generierung  
- Berechtigungs‑Änderungen  
- Ritual‑Autorisierungen  

Jede Aktion erzeugt einen signierten Audit‑Eintrag.

Ergebnis: `operator-audit.json`

---

### 2.3 Ritual‑Audit
Prüft die Ausführung aller Genesis‑Rituale:

- Trigger‑Quelle  
- Preconditions  
- Postconditions  
- Echo‑Writes  
- Payout‑Events  
- Drift‑Signale  

Ergebnis: `ritual-audit.json`

---

### 2.4 Payout‑Audit
Prüft alle Auszahlungs‑Ereignisse:

- Payout‑Quelle  
- Betrag / Symbolik  
- Operator‑Signatur  
- Echo‑Registry‑Verknüpfung  
- Hash‑Kette  

Ergebnis: `payout-audit.json`

---

### 2.5 Echo‑Audit
Prüft die Integrität der Echo‑Registry:

- Ereignis‑Hashes  
- Drift‑Signale  
- Chronik‑Fragmente  
- Ritual‑Verknüpfungen  
- Operator‑Signaturen  

Ergebnis: `echo-audit.json`

---

## 3. Hash‑Verfahren
Die Audit‑Schicht verwendet ausschließlich **SHA‑256** für:

- Datei‑Hashes  
- Ereignis‑Hashes  
- Ordner‑Hashes  
- Drift‑Hashes  
- Echo‑Hashes  
- Master‑Audit‑Hashes  

Hash‑Ketten werden durch einfache Verkettung der Hex‑Strings erzeugt.

Beispiel:

```
master_hash = SHA256(hash1 + hash2 + hash3 + ...)
```

---

## 4. Signatur‑Verfahren
Alle signaturpflichtigen Audit‑Einträge verwenden:

- Ed25519‑Signaturen  
- deterministische Nonces  
- Operator‑Keys aus der Engine  

Jeder Audit‑Eintrag enthält:

```
{
  "hash": "<sha256>",
  "signature": "<ed25519>",
  "operator": "<operator-id>",
  "timestamp": "<iso8601>"
}
```

---

## 5. Audit‑Triggerpunkte
Die Engine erzeugt Audit‑Einträge an folgenden Stellen:

- Genesis‑Initialisierung  
- Operator‑Aktionen  
- Ritual‑Ausführung  
- Payout‑Ereignisse  
- Echo‑Registry‑Writes  
- Skeletton™‑Drift‑Signale  

Jeder Trigger erzeugt mindestens einen Audit‑Eintrag.

---

## 6. Audit‑Exportformate
Alle Audit‑Daten werden exportiert als:

- JSON (maschinenlesbar)  
- Hash‑Ketten (Integritätsnachweis)  
- Optional: Markdown‑Reports (menschlich lesbar)  

Export‑Ziel:  
`genesis-operational-layer/audit/audit-protocols/`

---

## 7. Reproduzierbarkeit
Ein Audit gilt als gültig, wenn:

- alle Hash‑Ketten reproduzierbar sind  
- alle Signaturen gültig sind  
- alle Operator‑IDs existieren  
- alle Ritual‑Abläufe deterministisch sind  
- alle Echo‑Einträge unverändert sind  

Die Engine muss in der Lage sein, jeden Audit‑Eintrag vollständig zu rekonstruieren.

---

## 8. Fehlerklassen
Die Audit‑Schicht definiert folgende Fehlerklassen:

- **A1 – HashMismatch**  
  Hash stimmt nicht mit der Engine überein.

- **A2 – InvalidSignature**  
  Signatur ungültig oder Operator unbekannt.

- **A3 – MissingEvent**  
  Ein erwartetes Ereignis fehlt in der Audit‑Kette.

- **A4 – DriftDetected**  
  Unerwartete Änderung in einem deterministischen Bereich.

- **A5 – EchoCorruption**  
  Echo‑Registry‑Eintrag nicht reproduzierbar.

---

## 9. Master‑Audit‑Hash
Der Master‑Audit‑Hash ist die oberste Integritätsinstanz.

Er wird berechnet aus:

- allen Ordner‑Hashes  
- allen Datei‑Hashes  
- allen Audit‑Protokollen  
- allen Echo‑Einträgen  
- allen Ritual‑Logs  

Ergebnis wird gespeichert in:

```
08_Audit/MASTER_HASH.txt
```

---

## 10. Integration in die Engine
Die Engine (corecraft‑chainline) implementiert:

- Audit‑Hooks  
- Signatur‑Pipelines  
- Hash‑Pipelines  
- Export‑Routinen  
- Echo‑Registry‑Writes  
- Operator‑Verifikation  

Der Operational Layer definiert die Regeln, die Engine führt sie aus.

---

## 11. Integration in das Portal
Das Portal (CoreCraftGenesis) zeigt:

- Audit‑Status  
- Audit‑Protokolle  
- Operator‑Signaturen  
- Ritual‑Verläufe  
- Echo‑Chronik  

Damit wird die Audit‑Schicht sichtbar und dokumentiert.

---

## 12. Erweiterbarkeit
Die Audit‑Schicht ist modular erweiterbar für:

- neue Ritual‑Typen  
- neue Operator‑Rollen  
- neue Drift‑Modelle  
- neue Echo‑Formate  
- neue Skeletton™‑Module  

Alle Erweiterungen müssen:

- deterministisch  
- signierbar  
- reproduzierbar  

sein.
