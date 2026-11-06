"use strict";

(() => {
    const routeInput =
        document.getElementById("routeInput");

    const baseUrl =
        document.getElementById("baseUrl");

    const timeoutValue =
        document.getElementById("timeoutValue");

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

    const resultList =
        document.getElementById("resultList");

    const totalValue =
        document.getElementById("totalValue");

    const passValue =
        document.getElementById("passValue");

    const failValue =
        document.getElementById("failValue");

    const blockedValue =
        document.getElementById("blockedValue");

    const averageValue =
        document.getElementById("averageValue");

    let currentReport = "";

    function setStatus(state, message) {
        status.dataset.state = state;
        status.textContent = message;
    }

    function getRoutes() {
        return Array.from(
            new Set(
                routeInput.value
                    .split(/\r?\n/)
                    .map((value) => value.trim())
                    .filter(Boolean)
            )
        );
    }

    function normalizeUrl(route) {
        try {
            return new URL(route).href;
        }
        catch {
            const base =
                baseUrl.value.trim();

            if (!base) {
                throw new Error(
                    `Relative Route ohne Basisadresse: ${route}`
                );
            }

            return new URL(route, base).href;
        }
    }

    async function checkRoute(route) {
        let url;

        try {
            url = normalizeUrl(route);
        }
        catch (error) {
            return {
                route,
                url: route,
                finalUrl: "",
                state: "fail",
                code: "INVALID",
                duration: 0,
                redirected: false,
                message:
                    error instanceof Error
                        ? error.message
                        : String(error)
            };
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
                    url,
                    {
                        method: "GET",
                        redirect: "follow",
                        credentials: "omit",
                        cache: "no-store",
                        signal: controller.signal
                    }
                );

            const duration =
                Math.round(
                    performance.now() - started
                );

            return {
                route,
                url,
                finalUrl: response.url || url,
                state:
                    response.ok
                        ? "pass"
                        : "fail",
                code: String(response.status),
                duration,
                redirected:
                    response.redirected ||
                    Boolean(
                        response.url &&
                        response.url !== url
                    ),
                message:
                    response.statusText ||
                    (
                        response.ok
                            ? "HTTP request successful"
                            : "HTTP request failed"
                    )
            };
        }
        catch (error) {
            const duration =
                Math.round(
                    performance.now() - started
                );

            const aborted =
                error instanceof DOMException &&
                error.name === "AbortError";

            return {
                route,
                url,
                finalUrl: "",
                state:
                    aborted
                        ? "fail"
                        : "blocked",
                code:
                    aborted
                        ? "TIMEOUT"
                        : "BLOCKED",
                duration,
                redirected: false,
                message:
                    aborted
                        ? `Zeitlimit von ${timeout} ms überschritten.`
                        : (
                            error instanceof Error
                                ? error.message
                                : String(error)
                        )
            };
        }
        finally {
            window.clearTimeout(timer);
        }
    }

    function renderResults(results) {
        resultList.innerHTML = "";

        results.forEach((result) => {
            const item =
                document.createElement("li");

            item.className = "route-result";
            item.dataset.state = result.state;

            const head =
                document.createElement("div");

            head.className = "route-result-head";

            const url =
                document.createElement("span");

            url.className = "route-url";
            url.textContent = result.url;

            const code =
                document.createElement("span");

            code.className = "route-code";
            code.dataset.state =
                result.state === "pass"
                    ? "pass"
                    : "fail";

            code.textContent =
                `${result.code} · ${result.duration} ms`;

            const details =
                document.createElement("div");

            details.className = "route-detail";

            const redirectText =
                result.redirected
                    ? ` · Redirect → ${result.finalUrl}`
                    : "";

            details.textContent =
                `${result.message}${redirectText}`;

            head.append(url, code);
            item.append(head, details);

            resultList.appendChild(item);
        });
    }

    async function runCheck() {
        const routes =
            getRoutes();

        if (routes.length === 0) {
            setStatus(
                "fail",
                "Bitte mindestens eine Route eingeben."
            );

            return;
        }

        checkButton.disabled = true;

        setStatus(
            "neutral",
            `${routes.length} Route(n) werden geprüft.`
        );

        resultList.innerHTML = "";

        const results = [];

        for (const route of routes) {
            const result =
                await checkRoute(route);

            results.push(result);

            renderResults(results);
        }

        const passed =
            results.filter(
                (result) =>
                    result.state === "pass"
            );

        const failed =
            results.filter(
                (result) =>
                    result.state === "fail"
            );

        const blocked =
            results.filter(
                (result) =>
                    result.state === "blocked"
            );

        const measured =
            results.filter(
                (result) =>
                    result.duration > 0
            );

        const average =
            measured.length > 0
                ? Math.round(
                    measured.reduce(
                        (sum, result) =>
                            sum + result.duration,
                        0
                    ) / measured.length
                )
                : 0;

        totalValue.textContent =
            String(results.length);

        passValue.textContent =
            String(passed.length);

        failValue.textContent =
            String(failed.length);

        blockedValue.textContent =
            String(blocked.length);

        averageValue.textContent =
            `${average} ms`;

        currentReport = [
            "Route Checker Report",
            `Routes: ${results.length}`,
            `Pass: ${passed.length}`,
            `Fail: ${failed.length}`,
            `Blocked: ${blocked.length}`,
            `Average: ${average} ms`,
            "",
            ...results.map(
                (result) =>
                    `[${result.state.toUpperCase()}] ` +
                    `${result.code} ${result.url} ` +
                    `(${result.duration} ms) ` +
                    `${result.message}` +
                    (
                        result.redirected
                            ? ` -> ${result.finalUrl}`
                            : ""
                    )
            )
        ].join("\n");

        if (
            failed.length === 0 &&
            blocked.length === 0
        ) {
            setStatus(
                "pass",
                "Alle Routen wurden erfolgreich geprüft."
            );
        }
        else {
            setStatus(
                "fail",
                `${failed.length} fehlgeschlagen, ` +
                `${blocked.length} durch Browser-Regeln blockiert.`
            );
        }

        checkButton.disabled = false;
    }

    function loadExample() {
        routeInput.value =
`/products/developer-tools/
/products/developer-tools/validators/
/products/developer-tools/validators/json/
/products/developer-tools/validators/schema/
/products/developer-tools/validators/file/
/products/developer-tools/diagnostics/sha256/
/products/developer-tools/data-tools/json-formatter/
/products/developer-tools/data-tools/data-inspector/`;

        setStatus(
            "neutral",
            "Beispielrouten geladen."
        );
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
                "Routenbericht wurde kopiert."
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
        routeInput.value = "";

        currentReport = "";

        totalValue.textContent = "0";
        passValue.textContent = "0";
        failValue.textContent = "0";
        blockedValue.textContent = "0";
        averageValue.textContent = "0 ms";

        resultList.innerHTML =
            '<li class="route-result" data-state="info">' +
            'Noch keine Prüfung durchgeführt.' +
            '</li>';

        setStatus(
            "neutral",
            "Bereit. Routen eingeben."
        );

        routeInput.focus();
    }

    checkButton.addEventListener(
        "click",
        runCheck
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
})();
