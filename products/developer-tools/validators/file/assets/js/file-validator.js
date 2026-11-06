"use strict";

(() => {
    const fileInput =
        document.getElementById("fileInput");

    const dropZone =
        document.getElementById("dropZone");

    const expectedName =
        document.getElementById("expectedName");

    const expectedExtensions =
        document.getElementById("expectedExtensions");

    const maxSize =
        document.getElementById("maxSize");

    const validateButton =
        document.getElementById("validateButton");

    const copyButton =
        document.getElementById("copyButton");

    const clearButton =
        document.getElementById("clearButton");

    const status =
        document.getElementById("status");

    const resultList =
        document.getElementById("resultList");

    const preview =
        document.getElementById("preview");

    const nameValue =
        document.getElementById("nameValue");

    const extensionValue =
        document.getElementById("extensionValue");

    const mimeValue =
        document.getElementById("mimeValue");

    const bytesValue =
        document.getElementById("bytesValue");

    const sizeValue =
        document.getElementById("sizeValue");

    const modifiedValue =
        document.getElementById("modifiedValue");

    const contentValue =
        document.getElementById("contentValue");

    let selectedFile = null;
    let currentReport = "";

    const textExtensions = new Set([
        ".txt",
        ".md",
        ".json",
        ".csv",
        ".xml",
        ".html",
        ".htm",
        ".css",
        ".js",
        ".mjs",
        ".ts",
        ".tsx",
        ".jsx",
        ".yml",
        ".yaml",
        ".ini",
        ".conf",
        ".config",
        ".log",
        ".ps1",
        ".sh",
        ".sql"
    ]);

    function setStatus(state, message) {
        status.dataset.state = state;
        status.textContent = message;
    }

    function getExtension(name) {
        const index =
            name.lastIndexOf(".");

        if (
            index <= 0 ||
            index === name.length - 1
        ) {
            return "";
        }

        return name
            .slice(index)
            .toLowerCase();
    }

    function formatSize(bytes) {
        if (bytes < 1024) {
            return `${bytes} B`;
        }

        if (bytes < 1024 * 1024) {
            return `${(
                bytes / 1024
            ).toFixed(2)} KiB`;
        }

        if (bytes < 1024 * 1024 * 1024) {
            return `${(
                bytes / (1024 * 1024)
            ).toFixed(2)} MiB`;
        }

        return `${(
            bytes / (1024 * 1024 * 1024)
        ).toFixed(2)} GiB`;
    }

    function isTextFile(file, extension) {
        return (
            file.type.startsWith("text/") ||
            file.type === "application/json" ||
            file.type === "application/xml" ||
            file.type === "application/javascript" ||
            textExtensions.has(extension)
        );
    }

    function createResult(
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

    function renderResults(results) {
        resultList.innerHTML = "";

        results.forEach((result) => {
            const item =
                document.createElement("li");

            item.className = "file-result";
            item.dataset.state = result.state;

            item.textContent =
                `[${result.state.toUpperCase()}] ` +
                `${result.label}: ${result.message}`;

            resultList.appendChild(item);
        });
    }

    function updateMetadata(file) {
        const extension =
            getExtension(file.name);

        nameValue.textContent =
            file.name;

        extensionValue.textContent =
            extension || "NONE";

        mimeValue.textContent =
            file.type || "UNKNOWN";

        bytesValue.textContent =
            String(file.size);

        sizeValue.textContent =
            formatSize(file.size);

        modifiedValue.textContent =
            file.lastModified
                ? new Date(
                    file.lastModified
                ).toLocaleString("de-CH")
                : "UNKNOWN";
    }

    async function readTextPreview(
        file,
        extension
    ) {
        if (!isTextFile(file, extension)) {
            preview.value = "";
            contentValue.textContent = "BINARY";

            return {
                readable: false,
                text: ""
            };
        }

        const text =
            await file.text();

        preview.value =
            text.slice(0, 100000);

        if (text.length > 100000) {
            preview.value +=
                "\n\n[Preview auf 100.000 Zeichen begrenzt]";
        }

        contentValue.textContent = "TEXT";

        return {
            readable: true,
            text
        };
    }

    function parseExtensions() {
        return expectedExtensions.value
            .split(",")
            .map((value) =>
                value.trim().toLowerCase()
            )
            .filter(Boolean)
            .map((value) =>
                value.startsWith(".")
                    ? value
                    : `.${value}`
            );
    }

    async function validateFile() {
        if (!selectedFile) {
            setStatus(
                "fail",
                "Bitte zuerst eine Datei auswählen."
            );

            return;
        }

        const file =
            selectedFile;

        const extension =
            getExtension(file.name);

        const results = [];

        updateMetadata(file);

        createResult(
            results,
            "pass",
            "Datei",
            "Datei wurde erfolgreich ausgewählt."
        );

        if (file.size > 0) {
            createResult(
                results,
                "pass",
                "Dateigröße",
                `${formatSize(file.size)}`
            );
        }
        else {
            createResult(
                results,
                "fail",
                "Dateigröße",
                "Datei ist leer."
            );
        }

        const requiredName =
            expectedName.value.trim();

        if (requiredName) {
            if (file.name === requiredName) {
                createResult(
                    results,
                    "pass",
                    "Dateiname",
                    `Entspricht ${requiredName}.`
                );
            }
            else {
                createResult(
                    results,
                    "fail",
                    "Dateiname",
                    `Erwartet ${requiredName}, erhalten ${file.name}.`
                );
            }
        }
        else {
            createResult(
                results,
                "info",
                "Dateiname",
                "Keine Namensregel definiert."
            );
        }

        const allowedExtensions =
            parseExtensions();

        if (allowedExtensions.length > 0) {
            if (
                allowedExtensions.includes(
                    extension
                )
            ) {
                createResult(
                    results,
                    "pass",
                    "Erweiterung",
                    `${extension} ist erlaubt.`
                );
            }
            else {
                createResult(
                    results,
                    "fail",
                    "Erweiterung",
                    `${extension || "NONE"} ist nicht erlaubt.`
                );
            }
        }
        else {
            createResult(
                results,
                "info",
                "Erweiterung",
                "Keine Erweiterungsregel definiert."
            );
        }

        const maxKiB =
            Number(maxSize.value);

        if (
            maxSize.value.trim() &&
            Number.isFinite(maxKiB) &&
            maxKiB >= 0
        ) {
            const maximumBytes =
                maxKiB * 1024;

            if (file.size <= maximumBytes) {
                createResult(
                    results,
                    "pass",
                    "Maximale Größe",
                    `Datei liegt innerhalb von ${maxKiB} KiB.`
                );
            }
            else {
                createResult(
                    results,
                    "fail",
                    "Maximale Größe",
                    `Datei überschreitet ${maxKiB} KiB.`
                );
            }
        }
        else {
            createResult(
                results,
                "info",
                "Maximale Größe",
                "Keine Größenregel definiert."
            );
        }

        try {
            const textResult =
                await readTextPreview(
                    file,
                    extension
                );

            if (textResult.readable) {
                createResult(
                    results,
                    "pass",
                    "Textinhalt",
                    "Datei konnte als Text gelesen werden."
                );

                if (extension === ".json") {
                    try {
                        JSON.parse(
                            textResult.text
                        );

                        createResult(
                            results,
                            "pass",
                            "JSON-Syntax",
                            "Datei enthält gültiges JSON."
                        );
                    }
                    catch (error) {
                        createResult(
                            results,
                            "fail",
                            "JSON-Syntax",
                            error instanceof Error
                                ? error.message
                                : String(error)
                        );
                    }
                }
            }
            else {
                createResult(
                    results,
                    "info",
                    "Inhalt",
                    "Binärdatei wird nicht als Text dargestellt."
                );
            }
        }
        catch (error) {
            preview.value = "";
            contentValue.textContent = "ERROR";

            createResult(
                results,
                "fail",
                "Inhalt",
                error instanceof Error
                    ? error.message
                    : String(error)
            );
        }

        renderResults(results);

        const failures =
            results.filter(
                (result) =>
                    result.state === "fail"
            );

        currentReport = [
            `File Validator Report`,
            `Name: ${file.name}`,
            `Extension: ${extension || "NONE"}`,
            `MIME: ${file.type || "UNKNOWN"}`,
            `Bytes: ${file.size}`,
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
                "Dateiprüfung bestanden."
            );
        }
        else {
            setStatus(
                "fail",
                `${failures.length} Dateiprüfung(en) fehlgeschlagen.`
            );
        }
    }

    async function copyReport() {
        if (!currentReport) {
            setStatus(
                "fail",
                "Noch kein Prüfbericht vorhanden."
            );

            return;
        }

        try {
            await navigator.clipboard.writeText(
                currentReport
            );

            setStatus(
                "pass",
                "Prüfbericht wurde kopiert."
            );
        }
        catch {
            setStatus(
                "fail",
                "Zwischenablage konnte nicht verwendet werden."
            );
        }
    }

    function selectFile(file) {
        selectedFile = file || null;
        currentReport = "";
        preview.value = "";

        if (!selectedFile) {
            setStatus(
                "neutral",
                "Bereit. Datei auswählen."
            );

            return;
        }

        updateMetadata(selectedFile);

        setStatus(
            "neutral",
            `Datei ausgewählt: ${selectedFile.name}`
        );
    }

    function clearAll() {
        selectedFile = null;
        currentReport = "";

        fileInput.value = "";
        expectedName.value = "";
        expectedExtensions.value = "";
        maxSize.value = "";
        preview.value = "";

        nameValue.textContent = "—";
        extensionValue.textContent = "—";
        mimeValue.textContent = "—";
        bytesValue.textContent = "0";
        sizeValue.textContent = "0 B";
        modifiedValue.textContent = "—";
        contentValue.textContent = "—";

        resultList.innerHTML =
            '<li class="file-result" data-state="info">' +
            'Noch keine Validierung durchgeführt.' +
            '</li>';

        setStatus(
            "neutral",
            "Bereit. Datei auswählen."
        );
    }

    fileInput.addEventListener(
        "change",
        () => {
            selectFile(
                fileInput.files?.[0]
            );
        }
    );

    validateButton.addEventListener(
        "click",
        validateFile
    );

    copyButton.addEventListener(
        "click",
        copyReport
    );

    clearButton.addEventListener(
        "click",
        clearAll
    );

    [
        "dragenter",
        "dragover"
    ].forEach((eventName) => {
        dropZone.addEventListener(
            eventName,
            (event) => {
                event.preventDefault();
                dropZone.dataset.active = "true";
            }
        );
    });

    [
        "dragleave",
        "drop"
    ].forEach((eventName) => {
        dropZone.addEventListener(
            eventName,
            (event) => {
                event.preventDefault();
                dropZone.dataset.active = "false";
            }
        );
    });

    dropZone.addEventListener(
        "drop",
        (event) => {
            const file =
                event.dataTransfer?.files?.[0];

            if (file) {
                selectFile(file);
            }
        }
    );
})();
