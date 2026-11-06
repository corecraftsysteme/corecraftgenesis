"use strict";

(() => {
    const htmlTab =
        document.getElementById("htmlTab");

    const urlTab =
        document.getElementById("urlTab");

    const htmlPanel =
        document.getElementById("htmlPanel");

    const urlPanel =
        document.getElementById("urlPanel");

    const baseUrl =
        document.getElementById("baseUrl");

    const htmlInput =
        document.getElementById("htmlInput");

    const pageUrl =
        document.getElementById("pageUrl");

    const timeoutValue =
        document.getElementById("timeoutValue");

    const extractButton =
        document.getElementById("extractButton");

    const checkButton =
        document.getElementById("checkButton");

    const exampleButton =
        document.getElementById("exampleButton");

    const copyButton =
        document.getElementById("copyButton");

    const clearButton =
        document.getElementById("clearButton");

    const status =
        document.getElementById("status");

    const filterInput =
        document.getElementById("filterInput");

    const resultList =
        document.getElementById("resultList");

    const totalValue =
        document.getElementById("totalValue");

    const internalValue =
        document.getElementById("internalValue");

    const externalValue =
        document.getElementById("externalValue");

    const specialValue =
        document.getElementById("specialValue");

    const duplicateValue =
        document.getElementById("duplicateValue");

    const failedValue =
        document.getElementById("failedValue");

    let mode = "html";
    let links = [];
    let currentReport = "";

    function setStatus(state, message) {
        status.dataset.state = state;
        status.textContent = message;
    }

    function selectMode(nextMode) {
        mode = nextMode;

        const htmlActive =
            mode === "html";

        htmlTab.setAttribute(
            "aria-selected",
            String(htmlActive)
        );

        urlTab.setAttribute(
            "aria-selected",
            String(!htmlActive)
        );

        htmlPanel.hidden = !htmlActive;
        urlPanel.hidden = htmlActive;
    }

    function classifyHref(
        rawHref,
        resolvedUrl,
        documentUrl
    ) {
        const value =
            rawHref.trim().toLowerCase();

        if (value.startsWith("#")) {
            return "anchor";
        }

        if (value.startsWith("mailto:")) {
            return "email";
        }

        if (value.startsWith("tel:")) {
            return "telephone";
        }

        if (value.startsWith("javascript:")) {
            return "javascript";
        }

        if (!resolvedUrl) {
            return "invalid";
        }

        try {
            const target =
                new URL(resolvedUrl);

            const source =
                new URL(documentUrl);

            return target.origin === source.origin
                ? "internal"
                : "external";
        }
        catch {
            return "invalid";
        }
    }

    function resolveHref(
        href,
        documentUrl
    ) {
        const lower =
            href.trim().toLowerCase();

        if (
            lower.startsWith("#") ||
            lower.startsWith("mailto:") ||
            lower.startsWith("tel:") ||
            lower.startsWith("javascript:")
        ) {
            return href.trim();
        }

        try {
            return new URL(
                href,
                documentUrl
            ).href;
        }
        catch {
            return "";
        }
    }

    function extractFromHtml(
        html,
        documentUrl
    ) {
        const documentObject =
            new DOMParser()
                .parseFromString(
                    html,
                    "text/html"
                );

        const nodes =
            Array.from(
                documentObject
                    .querySelectorAll("a[href]")
            );

        const counts =
            new Map();

        const extracted =
            nodes.map((node, index) => {
                const href =
                    node
                        .getAttribute("href")
                        ?.trim() || "";

                const resolved =
                    resolveHref(
                        href,
                        documentUrl
                    );

                const type =
                    classifyHref(
                        href,
                        resolved,
                        documentUrl
                    );

                const key =
                    resolved ||
                    href ||
                    `empty-${index}`;

                counts.set(
                    key,
                    (counts.get(key) || 0) + 1
                );

                return {
                    index: index + 1,
                    href,
                    resolved,
                    text:
                        node.textContent
                            .replace(/\s+/g, " ")
                            .trim(),
                    type,
                    duplicate: false,
                    state: "unverified",
                    code: "",
                    duration: 0,
                    message:
                        "Noch nicht per HTTP geprüft."
                };
            });

        extracted.forEach((link) => {
            const key =
                link.resolved ||
                link.href ||
                `empty-${link.index - 1}`;

            link.duplicate =
                (counts.get(key) || 0) > 1;
        });

        return extracted;
    }

    function updateStats() {
        totalValue.textContent =
            String(links.length);

        internalValue.textContent =
            String(
                links.filter(
                    (link) =>
                        link.type === "internal"
                ).length
            );

        externalValue.textContent =
            String(
                links.filter(
                    (link) =>
                        link.type === "external"
                ).length
            );

        specialValue.textContent =
            String(
                links.filter(
                    (link) =>
                        ![
                            "internal",
                            "external"
                        ].includes(link.type)
                ).length
            );

        duplicateValue.textContent =
            String(
                links.filter(
                    (link) =>
                        link.duplicate
                ).length
            );

        failedValue.textContent =
            String(
                links.filter(
                    (link) =>
                        [
                            "fail",
                            "blocked"
                        ].includes(link.state)
                ).length
            );
    }

    function stateLabel(link) {
        if (link.state === "pass") {
            return link.code || "PASS";
        }

        if (link.state === "fail") {
            return link.code || "FAIL";
        }

        if (link.state === "blocked") {
            return "BLOCKED";
        }

        return link.type.toUpperCase();
    }

    function renderLinks() {
        resultList.innerHTML = "";

        if (links.length === 0) {
            resultList.innerHTML =
                '<li class="link-empty">' +
                'Keine Links gefunden.' +
                '</li>';

            updateStats();

            return;
        }

        links.forEach((link) => {
            const item =
                document.createElement("li");

            item.className =
                "link-result";

            item.dataset.state =
                link.state;

            item.dataset.search =
                [
                    link.href,
                    link.resolved,
                    link.text,
                    link.type,
                    link.state,
                    link.code
                ]
                    .join(" ")
                    .toLowerCase();

            item.dataset.visible =
                "true";

            const head =
                document.createElement("div");

            head.className =
                "link-result-head";

            const url =
                document.createElement("span");

            url.className =
                "link-url";

            url.textContent =
                link.resolved ||
                link.href ||
                "(leeres href)";

            const badge =
                document.createElement("span");

            badge.className =
                "link-badge";

            badge.dataset.state =
                [
                    "fail",
                    "blocked"
                ].includes(link.state)
                    ? "fail"
                    : "pass";

            badge.textContent =
                stateLabel(link);

            const detail =
                document.createElement("div");

            detail.className =
                "link-detail";

            const duplicate =
                link.duplicate
                    ? " · DUPLICATE"
                    : "";

            const timing =
                link.duration > 0
                    ? ` · ${link.duration} ms`
                    : "";

            detail.textContent =
                `#${link.index} · ` +
                `${link.type.toUpperCase()}` +
                duplicate +
                timing +
                ` · Text: ${link.text || "(leer)"}` +
                ` · ${link.message}`;

            head.append(
                url,
                badge
            );

            item.append(
                head,
                detail
            );

            resultList.appendChild(item);
        });

        applyFilter();
        updateStats();
    }

    async function loadSource() {
        if (mode === "html") {
            const html =
                htmlInput.value.trim();

            if (!html) {
                throw new Error(
                    "Bitte HTML-Quelltext einfügen."
                );
            }

            const sourceUrl =
                baseUrl.value.trim();

            if (!sourceUrl) {
                throw new Error(
                    "Bitte eine Basisadresse angeben."
                );
            }

            return {
                html,
                documentUrl:
                    new URL(sourceUrl).href
            };
        }

        const sourceUrl =
            pageUrl.value.trim();

        if (!sourceUrl) {
            throw new Error(
                "Bitte eine Webseitenadresse angeben."
            );
        }

        const response =
            await fetch(
                sourceUrl,
                {
                    method: "GET",
                    credentials: "omit",
                    cache: "no-store"
                }
            );

        if (!response.ok) {
            throw new Error(
                `Webseite lieferte HTTP ${response.status}.`
            );
        }

        return {
            html:
                await response.text(),

            documentUrl:
                response.url ||
                sourceUrl
        };
    }

    async function extractLinks() {
        extractButton.disabled = true;

        try {
            setStatus(
                "neutral",
                "HTML wird analysiert."
            );

            const source =
                await loadSource();

            links =
                extractFromHtml(
                    source.html,
                    source.documentUrl
                );

            renderLinks();
            createReport();

            setStatus(
                "pass",
                `${links.length} Link(s) extrahiert.`
            );
        }
        catch (error) {
            links = [];

            renderLinks();

            setStatus(
                "fail",
                error instanceof Error
                    ? error.message
                    : String(error)
            );
        }
        finally {
            extractButton.disabled = false;
        }
    }

    async function checkOne(link) {
        if (
            ![
                "internal",
                "external"
            ].includes(link.type)
        ) {
            link.state =
                "unverified";

            link.message =
                "Dieser Linktyp wird nicht per HTTP geprüft.";

            return;
        }

        const seconds =
            Number(timeoutValue.value);

        const timeout =
            Number.isFinite(seconds) &&
            seconds > 0
                ? seconds * 1000
                : 15000;

        const controller =
            new AbortController();

        const timer =
            window.setTimeout(
                () => controller.abort(),
                timeout
            );

        const started =
            performance.now();

        try {
            const response =
                await fetch(
                    link.resolved,
                    {
                        method: "GET",
                        redirect: "follow",
                        credentials: "omit",
                        cache: "no-store",
                        signal:
                            controller.signal
                    }
                );

            link.duration =
                Math.round(
                    performance.now() -
                    started
                );

            link.code =
                String(response.status);

            link.state =
                response.ok
                    ? "pass"
                    : "fail";

            link.message =
                response.statusText ||
                (
                    response.ok
                        ? "HTTP request successful"
                        : "HTTP request failed"
                );
        }
        catch (error) {
            link.duration =
                Math.round(
                    performance.now() -
                    started
                );

            const aborted =
                error instanceof DOMException &&
                error.name === "AbortError";

            link.state =
                aborted
                    ? "fail"
                    : "blocked";

            link.code =
                aborted
                    ? "TIMEOUT"
                    : "BLOCKED";

            link.message =
                aborted
                    ? `Zeitlimit von ${timeout} ms überschritten.`
                    : (
                        error instanceof Error
                            ? error.message
                            : String(error)
                    );
        }
        finally {
            window.clearTimeout(timer);
        }
    }

    async function checkLinks() {
        if (links.length === 0) {
            setStatus(
                "fail",
                "Zuerst Links extrahieren."
            );

            return;
        }

        checkButton.disabled = true;

        setStatus(
            "neutral",
            "HTTP-Links werden geprüft."
        );

        for (const link of links) {
            await checkOne(link);

            renderLinks();
        }

        const failed =
            links.filter(
                (link) =>
                    link.state === "fail"
            ).length;

        const blocked =
            links.filter(
                (link) =>
                    link.state === "blocked"
            ).length;

        createReport();

        if (
            failed === 0 &&
            blocked === 0
        ) {
            setStatus(
                "pass",
                "Alle prüfbaren HTTP-Links wurden erreicht."
            );
        }
        else {
            setStatus(
                "fail",
                `${failed} fehlgeschlagen, ` +
                `${blocked} durch Browser-Regeln blockiert.`
            );
        }

        checkButton.disabled = false;
    }

    function createReport() {
        currentReport = [
            "Link Checker Report",
            `Total: ${links.length}`,
            `Internal: ${
                links.filter(
                    (link) =>
                        link.type === "internal"
                ).length
            }`,
            `External: ${
                links.filter(
                    (link) =>
                        link.type === "external"
                ).length
            }`,
            "",
            ...links.map(
                (link) =>
                    `[${stateLabel(link)}] ` +
                    `${link.resolved || link.href} ` +
                    `(${link.type}) ` +
                    `${link.message}`
            )
        ].join("\n");
    }

    function applyFilter() {
        const query =
            filterInput.value
                .trim()
                .toLowerCase();

        resultList
            .querySelectorAll(
                ".link-result"
            )
            .forEach((item) => {
                item.dataset.visible =
                    String(
                        !query ||
                        item.dataset.search
                            .includes(query)
                    );
            });
    }

    function loadExample() {
        selectMode("html");

        baseUrl.value =
            "https://corecraftgenesis.ch/";

        htmlInput.value =
`<a href="/">Home</a>
<a href="/products/">Produkte</a>
<a href="/products/developer-tools/">Developer Tools</a>
<a href="/products/developer-tools/validators/">Validators</a>
<a href="#features">Features</a>
<a href="mailto:contact@example.com">E-Mail</a>
<a href="/products/">Produkte doppelt</a>`;

        setStatus(
            "neutral",
            "Beispiel-HTML geladen."
        );
    }

    async function copyReport() {
        if (!currentReport) {
            setStatus(
                "fail",
                "Noch kein Linkbericht vorhanden."
            );

            return;
        }

        try {
            await navigator.clipboard.writeText(
                currentReport
            );

            setStatus(
                "pass",
                "Linkbericht wurde kopiert."
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
        htmlInput.value = "";
        pageUrl.value = "";
        filterInput.value = "";

        links = [];
        currentReport = "";

        renderLinks();

        setStatus(
            "neutral",
            "Bereit. HTML einfügen oder Webseite angeben."
        );

        htmlInput.focus();
    }

    htmlTab.addEventListener(
        "click",
        () => selectMode("html")
    );

    urlTab.addEventListener(
        "click",
        () => selectMode("url")
    );

    extractButton.addEventListener(
        "click",
        extractLinks
    );

    checkButton.addEventListener(
        "click",
        checkLinks
    );

    exampleButton.addEventListener(
        "click",
        loadExample
    );

    copyButton.addEventListener(
        "click",
        copyReport
    );

    clearButton.addEventListener(
        "click",
        clearAll
    );

    filterInput.addEventListener(
        "input",
        applyFilter
    );
})();
