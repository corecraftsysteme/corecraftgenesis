"use strict";

(() => {
    const input =
        document.getElementById("jsonInput");

    const output =
        document.getElementById("output");

    const status =
        document.getElementById("status");

    const searchInput =
        document.getElementById("searchInput");

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

    const rootTypeValue =
        document.getElementById("rootTypeValue");

    const nodeValue =
        document.getElementById("nodeValue");

    const objectValue =
        document.getElementById("objectValue");

    const arrayValue =
        document.getElementById("arrayValue");

    const primitiveValue =
        document.getElementById("primitiveValue");

    const depthValue =
        document.getElementById("depthValue");

    let currentRows = [];
    let currentReport = "";

    function setStatus(state, message) {
        status.dataset.state = state;
        status.textContent = message;
    }

    function getType(value) {
        if (value === null) {
            return "null";
        }

        if (Array.isArray(value)) {
            return "array";
        }

        if (
            typeof value === "number" &&
            Number.isInteger(value)
        ) {
            return "integer";
        }

        return typeof value;
    }

    function createPreview(value, type) {
        if (type === "object") {
            return `{${Object.keys(value).length} properties}`;
        }

        if (type === "array") {
            return `[${value.length} items]`;
        }

        if (type === "string") {
            const shortened =
                value.length > 180
                    ? `${value.slice(0, 180)}…`
                    : value;

            return JSON.stringify(shortened);
        }

        return JSON.stringify(value);
    }

    function inspectValue(
        value,
        path,
        depth,
        rows,
        stats
    ) {
        const type =
            getType(value);

        rows.push({
            path,
            type,
            value: createPreview(value, type),
            depth
        });

        stats.nodes += 1;
        stats.maxDepth =
            Math.max(stats.maxDepth, depth);

        if (type === "object") {
            stats.objects += 1;

            Object.entries(value).forEach(
                ([key, child]) => {
                    const safeKey =
                        /^[A-Za-z_$][\w$]*$/.test(key);

                    const childPath =
                        safeKey
                            ? `${path}.${key}`
                            : `${path}[${JSON.stringify(key)}]`;

                    inspectValue(
                        child,
                        childPath,
                        depth + 1,
                        rows,
                        stats
                    );
                }
            );

            return;
        }

        if (type === "array") {
            stats.arrays += 1;

            value.forEach((child, index) => {
                inspectValue(
                    child,
                    `${path}[${index}]`,
                    depth + 1,
                    rows,
                    stats
                );
            });

            return;
        }

        stats.primitives += 1;
    }

    function renderRows(rows) {
        output.innerHTML = "";

        if (rows.length === 0) {
            output.innerHTML =
                '<p class="inspector-empty">' +
                'Keine passenden Ergebnisse gefunden.' +
                '</p>';

            return;
        }

        const list =
            document.createElement("ul");

        list.className = "tree-list";

        rows.forEach((row) => {
            const item =
                document.createElement("li");

            item.className = "tree-node";

            item.dataset.search =
                `${row.path} ${row.type} ${row.value}`
                    .toLowerCase();

            const path =
                document.createElement("span");

            path.className = "tree-path";
            path.textContent = row.path;

            const type =
                document.createElement("span");

            type.className = "tree-type";
            type.textContent =
                `[${row.type.toUpperCase()}]`;

            const value =
                document.createElement("span");

            value.className = "tree-value";
            value.textContent = row.value;

            item.append(
                path,
                type,
                value
            );

            list.appendChild(item);
        });

        output.appendChild(list);
    }

    function resetStats() {
        rootTypeValue.textContent = "—";
        nodeValue.textContent = "0";
        objectValue.textContent = "0";
        arrayValue.textContent = "0";
        primitiveValue.textContent = "0";
        depthValue.textContent = "0";
    }

    function inspectData() {
        try {
            const text =
                input.value.trim();

            if (!text) {
                throw new Error(
                    "Bitte JSON-Daten eingeben."
                );
            }

            const data =
                JSON.parse(text);

            const rows = [];

            const stats = {
                nodes: 0,
                objects: 0,
                arrays: 0,
                primitives: 0,
                maxDepth: 0
            };

            inspectValue(
                data,
                "$",
                0,
                rows,
                stats
            );

            currentRows = rows;

            rootTypeValue.textContent =
                getType(data).toUpperCase();

            nodeValue.textContent =
                String(stats.nodes);

            objectValue.textContent =
                String(stats.objects);

            arrayValue.textContent =
                String(stats.arrays);

            primitiveValue.textContent =
                String(stats.primitives);

            depthValue.textContent =
                String(stats.maxDepth);

            renderRows(rows);

            searchInput.value = "";

            currentReport = [
                "Data Inspector Report",
                `Root Type: ${getType(data).toUpperCase()}`,
                `Total Nodes: ${stats.nodes}`,
                `Objects: ${stats.objects}`,
                `Arrays: ${stats.arrays}`,
                `Primitives: ${stats.primitives}`,
                `Max Depth: ${stats.maxDepth}`,
                "",
                ...rows.map(
                    (row) =>
                        `${row.path} [${row.type.toUpperCase()}] ${row.value}`
                )
            ].join("\n");

            setStatus(
                "pass",
                `${stats.nodes} Datenknoten erfolgreich analysiert.`
            );
        }
        catch (error) {
            currentRows = [];
            currentReport = "";

            resetStats();

            output.innerHTML =
                '<p class="inspector-empty">' +
                'Die Daten konnten nicht analysiert werden.' +
                '</p>';

            setStatus(
                "fail",
                error instanceof Error
                    ? error.message
                    : String(error)
            );
        }
    }

    function filterRows() {
        const query =
            searchInput.value
                .trim()
                .toLowerCase();

        if (!query) {
            renderRows(currentRows);

            return;
        }

        const filtered =
            currentRows.filter((row) =>
                `${row.path} ${row.type} ${row.value}`
                    .toLowerCase()
                    .includes(query)
            );

        renderRows(filtered);

        setStatus(
            "pass",
            `${filtered.length} passende Datenpfade gefunden.`
        );
    }

    function loadExample() {
        input.value =
`{
  "product": {
    "name": "CoreCraft Genesis",
    "active": true,
    "version": 1
  },
  "developerTools": {
    "validators": [
      "json",
      "schema",
      "file"
    ],
    "diagnostics": {
      "sha256": true
    },
    "dataTools": {
      "formatter": true,
      "inspector": true
    }
  },
  "release": null
}`;

        inspectData();
    }

    function formatJson() {
        try {
            const data =
                JSON.parse(input.value);

            input.value =
                JSON.stringify(
                    data,
                    null,
                    2
                );

            setStatus(
                "pass",
                "JSON-Daten wurden formatiert."
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
                "Noch kein Analysebericht vorhanden."
            );

            return;
        }

        try {
            await navigator.clipboard.writeText(
                currentReport
            );

            setStatus(
                "pass",
                "Analysebericht wurde kopiert."
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
        input.value = "";
        searchInput.value = "";

        currentRows = [];
        currentReport = "";

        resetStats();

        output.innerHTML =
            '<p class="inspector-empty">' +
            'Noch keine Daten analysiert.' +
            '</p>';

        setStatus(
            "neutral",
            "Bereit. JSON-Daten in das Eingabefeld einfügen."
        );

        input.focus();
    }

    function insertTab(event) {
        if (event.key !== "Tab") {
            return;
        }

        event.preventDefault();

        const start =
            input.selectionStart;

        const end =
            input.selectionEnd;

        input.value =
            input.value.substring(0, start) +
            "  " +
            input.value.substring(end);

        input.selectionStart =
            input.selectionEnd =
                start + 2;
    }

    inspectButton.addEventListener(
        "click",
        inspectData
    );

    exampleButton.addEventListener(
        "click",
        loadExample
    );

    formatButton.addEventListener(
        "click",
        formatJson
    );

    copyButton.addEventListener(
        "click",
        copyReport
    );

    clearButton.addEventListener(
        "click",
        clearAll
    );

    searchInput.addEventListener(
        "input",
        filterRows
    );

    input.addEventListener(
        "keydown",
        (event) => {
            insertTab(event);

            if (
                (event.ctrlKey || event.metaKey) &&
                event.key === "Enter"
            ) {
                event.preventDefault();
                inspectData();
            }
        }
    );
})();
