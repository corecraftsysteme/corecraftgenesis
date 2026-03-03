# **audit-flow-diagram.md — Genesis Operational Layer / Audit Flow Diagram**

## 1. Überblick
Dieses Dokument beschreibt den vollständigen Ablauf eines Audit‑Zyklus innerhalb der Genesis‑Infrastruktur.  
Der Ablauf ist deterministisch, reproduzierbar und vollständig signiert.

---

## 2. High‑Level‑Flow

```
┌────────────────────┐
│  Engine Event       │
│  (Genesis / Ritual) │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Event Collector     │
│ - Validierung       │
│ - Normalisierung    │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Hash Pipeline       │
│ - Canonical JSON    │
│ - SHA-256 Hash      │
│ - Hash-Kette        │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Signature Pipeline  │
│ - Ed25519 Signatur  │
│ - Operator-ID       │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Storage Layer       │
│ - JSON-Protokolle   │
│ - Fehlerlogs        │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Reproduction Engine │
│ - Hash-Rebuild      │
│ - Signaturprüfung   │
│ - Konsistenzcheck   │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Master Audit Hash   │
│ - SHA-256 über alle │
│   Audit-Ketten      │
└────────────────────┘
```

---

## 3. Detaillierter Ablauf

### 3.1 Engine Event
Ein Ereignis entsteht:

- Genesis‑Initialisierung  
- Ritual‑Ausführung  
- Operator‑Aktion  
- Payout‑Event  
- Echo‑Write  
- Skeletton‑Drift  

### 3.2 Event Collector
Der Collector prüft:

- Struktur  
- Operator‑ID  
- Payload  
- Zeitstempel  

### 3.3 Hash Pipeline
Erzeugt:

- Event‑Hash  
- Ketten‑Hash  

### 3.4 Signature Pipeline
Signiert:

- Event‑Hash  
- Ketten‑Hash  

### 3.5 Storage Layer
Speichert:

- Audit‑Eintrag  
- Signatur  
- Fehler (falls vorhanden)  

### 3.6 Reproduction Engine
Rekonstruiert:

- Hashes  
- Signaturen  
- Ereignisse  

### 3.7 Master Audit Hash
Berechnet:

```
MASTER = SHA256(all folder hashes + all audit hashes)
```

---

## 4. Audit‑Flow‑Garantien
Der Audit‑Flow garantiert:

- deterministische Reproduzierbarkeit  
- vollständige Signaturkonsistenz  
- unveränderbare Hash‑Ketten  
- vollständige Ereignis‑Chronik  
- Drift‑Erkennung  
