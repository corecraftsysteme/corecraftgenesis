# operator-lifecycle.md

## Überblick
Der Operator‑Lifecycle beschreibt alle technischen Phasen, die ein Operator innerhalb der Genesis‑Engine durchläuft. Jede Phase ist deterministisch, signiert und vollständig auditierbar. Der Lifecycle bildet die Grundlage für Operator‑Management, Berechtigungsprüfung und State‑Rekonstruktion.

---

## 1. Erstellung eines Operators

### 1.1 Initiale Erzeugung
Ein Operator wird durch folgende Schritte erzeugt:

- Generierung einer **operatorId**  
- Erzeugung eines **Ed25519‑Schlüsselpaares**  
- Zuweisung einer **Rolle**  
- Erstellung eines **Seals** (signiertes Identitäts‑Artefakt)  
- Initiale Vergabe von **Permissions**  
- Setzen von **active = true**

### 1.2 Audit‑Eintrag
Die Engine erzeugt:

- `operator_created` Event  
- SHA‑256‑Hash  
- Ketten‑Hash  
- Ed25519‑Signatur  
- Zeitstempel  

---

## 2. Rollenverwaltung

### 2.1 Rollenvergabe
Eine Rolle wird einem Operator zugewiesen:

- `role_assigned` Event  
- Aktualisierung des Operator‑State  
- Signatur durch autorisierten Operator  

### 2.2 Rollenänderung
Eine bestehende Rolle wird ersetzt:

- `role_changed` Event  
- deterministische State‑Rekonstruktion  

### 2.3 Rollenmodell
Gültige Rollen:

- GENESIS_OPERATOR  
- RITUAL_OPERATOR  
- PAYOUT_OPERATOR  
- ECHO_OPERATOR  
- SKELETTON_OPERATOR  
- AUDIT_OPERATOR  

---

## 3. Berechtigungsverwaltung

### 3.1 Vergabe von Permissions
Ein Operator erhält zusätzliche Berechtigungen:

- `permission_granted` Event  
- Aktualisierung des State  

### 3.2 Entzug von Permissions
Eine Berechtigung wird entfernt:

- `permission_revoked` Event  

### 3.3 Permission‑Sets
Granulare Berechtigungen:

- canTriggerRituals  
- canWriteEcho  
- canAuthorizePayouts  
- canModifyOperators  
- canModifyGenesis  
- canModifySkeletton  

---

## 4. Seal‑Management

### 4.1 Seal‑Erzeugung
Ein neues Seal wird generiert:

- `seal_generated` Event  
- Signatur durch autorisierten Operator  

### 4.2 Seal‑Rotation
Ein bestehendes Seal kann ersetzt werden, z. B. bei Schlüsselrotation.

---

## 5. Aktivierung & Deaktivierung

### 5.1 Deaktivierung
Ein Operator wird deaktiviert:

- `operator_disabled` Event  
- State: `active = false`  

### 5.2 Reaktivierung
Optional möglich, abhängig von Engine‑Regeln.

---

## 6. Audit‑Integration

### 6.1 Audit‑Trigger
Jede Operator‑Aktion erzeugt:

- Event‑Hash  
- Ketten‑Hash  
- Ed25519‑Signatur  
- Zeitstempel  

### 6.2 Audit‑Kette
Die Operator‑Audit‑Kette ist eine verkettete Hash‑Struktur:

```
SHA256(event1 + event2 + event3 + ...)
```

### 6.3 Reproduktion
Der Operator‑State wird vollständig aus der Audit‑Kette rekonstruiert:

- Rolle  
- Seal  
- Permissions  
- Aktivierungsstatus  

---

## 7. Fehlerklassen

- **HashMismatch** – Hash stimmt nicht  
- **InvalidSignature** – Signatur ungültig  
- **MissingEvent** – Ereignis fehlt  
- **DriftDetected** – State widerspricht Audit‑Kette  
- **PermissionViolation** – fehlende Berechtigung  
- **UnknownOperator** – Operator existiert nicht  
- **SealMismatch** – Seal ungültig  

---

## 8. Engine‑Integration

### 8.1 Genesis
Nur Operatoren mit:

- `GENESIS_OPERATOR`  
- `canModifyGenesis`  

dürfen Genesis‑Parameter ändern.

### 8.2 Rituale
Rituale erfordern:

- `RITUAL_OPERATOR`  
- `canTriggerRituals`  

### 8.3 Echo‑Registry
Echo‑Writes erfordern:

- `ECHO_OPERATOR`  
- `canWriteEcho`  

### 8.4 Payouts
Payout‑Ereignisse erfordern:

- `PAYOUT_OPERATOR`  
- `canAuthorizePayouts`  

### 8.5 Skeletton
Drift‑Signale erfordern:

- `SKELETTON_OPERATOR`  

---

## 9. Zusammenfassung
Der Operator‑Lifecycle definiert:

- wie Operatoren entstehen  
- wie sie verändert werden  
- wie sie autorisiert werden  
- wie sie deaktiviert werden  
- wie ihr Zustand rekonstruiert wird  
- wie jede Aktion auditierbar bleibt  

Er bildet die technische Grundlage für Governance, Sicherheit und deterministische Kontrolle innerhalb der Genesis‑Engine.
