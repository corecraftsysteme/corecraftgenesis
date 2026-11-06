"use strict";

(() => {
    const manifestInput =
        document.getElementById("manifestInput");

    const baseUrl =
        document.getElementById("baseUrl");

    const fileInput =
        document.getElementById("fileInput");

    const inspectButton =
        document.getElementById("inspectButton");

    const exampleButton =
        document.getElementById("exampleButton");

    const formatButton =
        document.getElementById("formatButton");

    const copyButton =
        document.getElementById("copyButton");

    const clearButton =
        document.getElementById("clearButton");

    const status =
        document.getElementById("status");

    const memberValue =
        document.getElementById("memberValue");

    const iconValue =
        document.getElementById("iconValue");

    const warningValue =
        document.getElementById("warningValue");

    const failureValue =
        document.getElementById("failureValue");

    const resultList =
        document.getElementById("resultList");

    const iconTable =
        document.getElementById("iconTable");

    let currentReport = "";

    const recognizedMembers = new Set([
        "id",
        "name",
        "short_name",
        "description",
        "start_url",
        "scope",
        "display",
        "display_override",
        "orientation",
        "theme_color",
        "background_color",
        "lang",
        "dir",
        "icons",
        "screenshots",
        "categories",
        "shortcuts",
        "related_applications",
        "prefer_related_applications",
        "file_handlers",
        "protocol_handlers",
        "share_target"
    ]);

    const displayModes = new Set([
        "browser",
        "minimal-ui",
        "standalone",
        "fullscreen",
        "window-controls-overlay"
    ]);

    function setStatus(state, message) {
        status.dataset.state = state;
        status.textContent = message;
    }

    function addResult(
        results,
        state,
        label,
        message
    ) {
        results.push({
            state,
            label,
            message
        });
    }

    function resolveUrl(value) {
        if (
            typeof value !== "string" ||
            !value.trim()
        ) {
            return "";
        }

        return new URL(
            value,
            baseUrl.value.trim()
        ).href;
    }

    function renderResults(results) {
        resultList.innerHTML = "";

        results.forEach((result) => {
            const item =
                document.createElement("li");

            item.className =
                "manifest-result";

            item.dataset.state =
                result.state;

            item.textContent =
                `[${result.state.toUpperCase()}] ` +
                `${result.label}: ${result.message}`;

            resultList.appendChild(item);
        });
    }

    function renderIcons(icons) {
        iconTable.innerHTML = "";

        if (icons.length === 0) {
            iconTable.innerHTML =
                '<tr><td colspan="4">' +
                'Keine Symbole definiert.' +
                '</td></tr>';

            return;
        }

        icons.forEach((icon) => {
            const row =
                document.createElement("tr");

            const source =
                document.createElement("td");

            const sizes =
                document.createElement("td");

            const type =
                document.createElement("td");

            const purpose =
                document.createElement("td");

            try {
                source.textContent =
                    resolveUrl(icon.src) ||
                    "(fehlend)";
            }
            catch {
                source.textContent =
                    icon.src || "(ungültig)";
            }

            sizes.textContent =
                icon.sizes || "—";

            type.textContent =
                icon.type || "—";

            purpose.textContent =
                icon.purpose || "any";

            row.append(
                source,
                sizes,
                type,
                purpose
            );

            iconTable.appendChild(row);
        });
    }

    function inspectManifest() {
        try {
            const text =
                manifestInput.value.trim();

            if (!text) {
                throw new Error(
                    "Bitte ein Manifest einfügen."
                );
            }

            const manifest =
                JSON.parse(text);

            if (
                manifest === null ||
                typeof manifest !== "object" ||
                Array.isArray(manifest)
            ) {
                throw new Error(
                    "Das Manifest muss ein JSON-Objekt sein."
                );
            }

            new URL(baseUrl.value.trim());

            const results = [];

            if (
                typeof manifest.name === "string" &&
                manifest.name.trim()
            ) {
                addResult(
                    results,
                    "pass",
                    "name",
                    manifest.name
                );
            }
            else {
                addResult(
                    results,
                    "warning",
                    "name",
                    "Kein vollständiger App-Name vorhanden."
                );
            }

            if (
                typeof manifest.short_name === "string" &&
                manifest.short_name.trim()
            ) {
                addResult(
                    results,
                    "pass",
                    "short_name",
                    manifest.short_name
                );
            }
            else {
                addResult(
                    results,
                    "warning",
                    "short_name",
                    "Kein Kurzname vorhanden."
                );
            }

            for (
                const member of [
                    "start_url",
                    "scope",
                    "id"
                ]
            ) {
                if (
                    Object.prototype.hasOwnProperty.call(
                        manifest,
                        member
                    )
                ) {
                    try {
                        addResult(
                            results,
                            "pass",
                            member,
                            resolveUrl(manifest[member])
                        );
                    }
                    catch {
                        addResult(
                            results,
                            "fail",
                            member,
                            "Adresse ist ungültig."
                        );
                    }
                }
                else if (member === "start_url") {
                    addResult(
                        results,
                        "warning",
                        member,
                        "Keine Startadresse definiert."
                    );
                }
            }

            if (
                Object.prototype.hasOwnProperty.call(
                    manifest,
                    "display"
                )
            ) {
                if (
                    displayModes.has(
                        manifest.display
                    )
                ) {
                    addResult(
                        results,
                        "pass",
                        "display",
                        manifest.display
                    );
                }
                else {
                    addResult(
                        results,
                        "warning",
                        "display",
                        `Unbekannter Wert: ${manifest.display}`
                    );
                }
            }
            else {
                addResult(
                    results,
                    "warning",
                    "display",
                    "Kein Anzeigemodus definiert."
                );
            }

            for (
                const colorMember of [
                    "theme_color",
                    "background_color"
                ]
            ) {
                if (
                    typeof manifest[colorMember] ===
                        "string"
                ) {
                    addResult(
                        results,
                        "pass",
                        colorMember,
                        manifest[colorMember]
                    );
                }
                else {
                    addResult(
                        results,
                        "warning",
                        colorMember,
                        "Nicht definiert."
                    );
                }
            }

            const icons =
                Array.isArray(manifest.icons)
                    ? manifest.icons
                    : [];

            if (icons.length > 0) {
                icons.forEach((icon, index) => {
                    if (
                        !icon ||
                        typeof icon !== "object" ||
                        typeof icon.src !== "string" ||
                        !icon.src.trim()
                    ) {
                        addResult(
                            results,
                            "fail",
                            `icons[${index}]`,
                            "Symbolquelle fehlt."
                        );

                        return;
                    }

                    try {
                        addResult(
                            results,
                            "pass",
                            `icons[${index}]`,
                            resolveUrl(icon.src)
                        );
                    }
                    catch {
                        addResult(
                            results,
                            "fail",
                            `icons[${index}]`,
                            "Symboladresse ist ungültig."
                        );
                    }
                });
            }
            else {
                addResult(
                    results,
                    "warning",
                    "icons",
                    "Keine Symbole definiert."
                );
            }

            const unknownMembers =
                Object.keys(manifest).filter(
                    (member) =>
                        !recognizedMembers.has(member) &&
                        !member.startsWith("$")
                );

            if (unknownMembers.length > 0) {
                addResult(
                    results,
                    "warning",
                    "members",
                    `Nicht zugeordnete Mitglieder: ${unknownMembers.join(", ")}`
                );
            }

            const warnings =
                results.filter(
                    (result) =>
                        result.state === "warning"
                );

            const failures =
                results.filter(
                    (result) =>
                        result.state === "fail"
                );

            memberValue.textContent =
                String(
                    Object.keys(manifest).length
                );

            iconValue.textContent =
                String(icons.length);

            warningValue.textContent =
                String(warnings.length);

            failureValue.textContent =
                String(failures.length);

            renderResults(results);
            renderIcons(icons);

            currentReport = [
                "Manifest Inspector Report",
                `Members: ${Object.keys(manifest).length}`,
                `Icons: ${icons.length}`,
                `Warnings: ${warnings.length}`,
                `Failures: ${failures.length}`,
                "",
                ...results.map(
                    (result) =>
                        `[${result.state.toUpperCase()}] ` +
                        `${result.label}: ${result.message}`
                )
            ].join("\n");

            if (failures.length === 0) {
                setStatus(
                    "pass",
                    `Manifest analysiert. ${warnings.length} Warnung(en).`
                );
            }
            else {
                setStatus(
                    "fail",
                    `${failures.length} Fehler und ` +
                    `${warnings.length} Warnung(en) gefunden.`
                );
            }
        }
        catch (error) {
            currentReport = "";

            memberValue.textContent = "0";
            iconValue.textContent = "0";
            warningValue.textContent = "0";
            failureValue.textContent = "1";

            renderResults([
                {
                    state: "fail",
                    label: "Manifest",
                    message:
                        error instanceof Error
                            ? error.message
                            : String(error)
                }
            ]);

            renderIcons([]);

            setStatus(
                "fail",
                error instanceof Error
                    ? error.message
                    : String(error)
            );
        }
    }

    function loadExample() {
        manifestInput.value =
`{
  "id": "/",
  "name": "CoreCraft Genesis",
  "short_name": "CoreCraft",
  "description": "Developer tools and technical products.",
  "start_url": "/",
  "scope": "/",
  "display": "standalone",
  "theme_color": "#05070a",
  "background_color": "#05070a",
  "icons": [
    {
      "src": "/assets/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/assets/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}`;

        setStatus(
            "neutral",
            "Beispielmanifest geladen."
        );
    }

    function formatManifest() {
        try {
            manifestInput.value =
                JSON.stringify(
                    JSON.parse(
                        manifestInput.value
                    ),
                    null,
                    2
                );

            setStatus(
                "pass",
                "Manifest wurde formatiert."
            );
        }
        catch (error) {
            setStatus(
                "fail",
                error instanceof Error
                    ? error.message
                    : String(error)
            );
        }
    }

    async function copyReport() {
        if (!currentReport) {
            setStatus(
                "fail",
                "Noch kein Manifestbericht vorhanden."
            );

            return;
        }

        try {
            await navigator.clipboard.writeText(
                currentReport
            );

            setStatus(
                "pass",
                "Manifestbericht wurde kopiert."
            );
        }
        catch {
            setStatus(
                "fail",
                "Zwischenablage konnte nicht verwendet werden."
            );
        }
    }

    function clearAll() {
        manifestInput.value = "";
        fileInput.value = "";

        currentReport = "";

        memberValue.textContent = "0";
        iconValue.textContent = "0";
        warningValue.textContent = "0";
        failureValue.textContent = "0";

        resultList.innerHTML =
            '<li class="manifest-result" data-state="warning">' +
            'Noch keine Analyse durchgeführt.' +
            '</li>';

        renderIcons([]);

        setStatus(
            "neutral",
            "Bereit. Manifest einfügen oder Datei auswählen."
        );

        manifestInput.focus();
    }

    fileInput.addEventListener(
        "change",
        async () => {
            const file =
                fileInput.files?.[0];

            if (!file) {
                return;
            }

            try {
                manifestInput.value =
                    await file.text();

                setStatus(
                    "neutral",
                    `Datei geladen: ${file.name}`
                );
            }
            catch (error) {
                setStatus(
                    "fail",
                    error instanceof Error
                        ? error.message
                        : String(error)
                );
            }
        }
    );

    inspectButton.addEventListener(
        "click",
        inspectManifest
    );

    exampleButton.addEventListener(
        "click",
        loadExample
    );

    formatButton.addEventListener(
        "click",
        formatManifest
    );

    copyButton.addEventListener(
        "click",
        copyReport
    );

    clearButton.addEventListener(
        "click",
        clearAll
    );
})();
