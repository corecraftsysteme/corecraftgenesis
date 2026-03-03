# operator-index.md

## Überblick
Der Operator‑Layer bildet die technische Kontrollschicht der Genesis‑Engine. Er definiert, wie Operatoren strukturiert sind, wie sie autorisiert werden, wie ihr Zustand rekonstruiert wird und wie sie mit dem Audit‑System interagieren.  
Dieser Ordner enthält alle maschinenlesbaren Modelle und Spezifikationen, die für das Operator‑System erforderlich sind.

---

## Dateien im Ordner

### operator-blueprint.json
Definiert die **Grundstruktur eines Operators**:

- operatorId  
- publicKey  
- role  
- seal  
- permissions  
- active  

Dieses Blueprint ist die Basis für alle Operator‑Instanzen.

---

### operator-roles.json
Enthält die **Liste aller gültigen Operator‑Rollen**:

- GENESIS_OPERATOR  
- RITUAL_OPERATOR  
- PAYOUT_OPERATOR  
- ECHO_OPERATOR  
- SKELETTON_OPERATOR  
- AUDIT_OPERATOR  

Rollen definieren die funktionale Zuständigkeit eines Operators.

---

### operator-permissions.json
Definiert alle **granularen Berechtigungen**, unabhängig von Rollen:

- canTriggerRituals  
- canWriteEcho  
- canAuthorizePayouts  
- canModifyOperators  
- canModifyGenesis  
- canModifySkeletton  

Permissions bestimmen, welche Aktionen ein Operator tatsächlich ausführen darf.

---

### operator-state-model.json
Beschreibt das **deterministische Zustandsmodell** eines Operators.  
Der State wird vollständig aus der Audit‑Kette abgeleitet und umfasst:

- Rolle  
- Seal  
- Permissions  
- Aktivierungsstatus  

Zusätzlich listet die Datei alle Audit‑Events auf, die den Operator‑State verändern.

---

### operator-lifecycle.md
Dokumentiert den **Lebenszyklus eines Operators**:

- Erstellung  
- Rollenvergabe und ‑änderung  
- Permission‑Management  
- Seal‑Rotation  
- Aktivierung/Deaktivierung  
- Audit‑Integration  
- Fehlerklassen  

Dieses Dokument verbindet die maschinenlesbaren Modelle mit dem operativen Prozess.

---

### operator-examples.json
Enthält **realistische Beispiel‑Operatoren** für Tests, Simulationen und Demo‑Deployments.  
Jeder Beispiel‑Operator nutzt gültige Rollen, Permissions und Seals.

---

## Zusammenspiel der Dateien
Die Dateien in diesem Ordner bilden gemeinsam das vollständige Operator‑System:

- **Blueprint** definiert die Struktur.  
- **Roles** und **Permissions** definieren die Fähigkeiten.  
- **State‑Model** definiert die Ableitung des Zustands.  
- **Lifecycle** definiert den Prozess.  
- **Examples** liefern konkrete Instanzen.  

Alle Operator‑Aktionen werden über das Audit‑System (`operator-audit.json`) nachvollzogen und reproduziert.

---

## Einbettung in die Genesis‑Engine
Der Operator‑Layer interagiert direkt mit:

- Ritual‑System  
- Echo‑Registry  
- Payout‑System  
- Genesis‑Konfiguration  
- Skeletton‑Modulen  
- Audit‑Engine  

Er stellt sicher, dass jede Aktion:

- autorisiert  
- signiert  
- deterministisch  
- auditierbar  

ist.
