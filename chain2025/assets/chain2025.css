/* ============================================================
   Chain2025 — Viewer Runtime
   Event-Handler, Audit-Panel, Manifest-Loader
   Deterministic, audit-ready
   ============================================================ */

(function () {
    "use strict";

    const Chain2025 = {
        manifestUrl: "assets/manifest.json",
        auditLog: [],
        selectors: {
            auditSection: "section.cc-section:nth-of-type(11)", // Audit Marker section
        }
    };

    /* ------------------------------
       Utility: Timestamp
       ------------------------------ */
    function nowIso() {
        return new Date().toISOString();
    }

    /* ------------------------------
       Audit Logging
       ------------------------------ */
    function addAuditEntry(type, message) {
        const entry = {
            ts: nowIso(),
            type: type,
            message: message
        };
        Chain2025.auditLog.push(entry);
        renderAuditEntry(entry);
    }

    function renderAuditEntry(entry) {
        const auditSection = document.querySelector(Chain2025.selectors.auditSection);
        if (!auditSection) return;

        const p = document.createElement("p");
        p.className = "audit-entry";
        p.textContent = `${entry.ts} | ${entry.type} | ${entry.message}`;
        auditSection.appendChild(p);
    }

    /* ------------------------------
       Manifest Loader
       ------------------------------ */
    async function loadManifest() {
        try {
            const res = await fetch(Chain2025.manifestUrl, { cache: "no-store" });
            if (!res.ok) {
                addAuditEntry("manifest", `Failed to load manifest (${res.status})`);
                return;
            }

            const manifest = await res.json();
            addAuditEntry("manifest", "Manifest loaded");
            attachManifestToPage(manifest);
        } catch (err) {
            addAuditEntry("manifest", "Error loading manifest");
        }
    }

    function attachManifestToPage(manifest) {
        // Optional: attach manifest details to a dedicated section
        // This is intentionally minimal and deterministic.
        const sections = document.querySelectorAll(".cc-section");
        const target = sections[0]; // first section or dedicated manifest section
        if (!target) return;

        const block = document.createElement("div");
        block.className = "cc-code";
        block.textContent = JSON.stringify(manifest, null, 2);
        target.appendChild(block);

        addAuditEntry("manifest", "Manifest attached to page");
    }

    /* ------------------------------
       Export Actions (JSON/YAML)
       ------------------------------ */
    function exportJson() {
        addAuditEntry("export", "Export JSON triggered");
        // Placeholder: integrate with backend or download mechanism
    }

    function exportYaml() {
        addAuditEntry("export", "Export YAML triggered");
        // Placeholder: integrate with backend or download mechanism
    }

    /* ------------------------------
       Init
       ------------------------------ */
    function init() {
        addAuditEntry("boot", "Chain2025 Viewer initialized");
        loadManifest();

        // Wire export actions if buttons exist
        const btnJson = document.querySelector("[data-action='export-json']");
        const btnYaml = document.querySelector("[data-action='export-yaml']");

        if (btnJson) {
            btnJson.addEventListener("click", exportJson);
        }
        if (btnYaml) {
            btnYaml.addEventListener("click", exportYaml);
        }
    }

    document.addEventListener("DOMContentLoaded", init);
})();
