"use strict";

window.CoreCraftPay = (() => {
    const VERSION = "1.0.0";

    const state = {
        initialized: false,
        startedAt: null,
        page: null
    };

    function normalizePage(value) {
        if (typeof value !== "string") {
            return "unknown";
        }

        const page = value.trim().toLowerCase();

        return page.length > 0 ? page : "unknown";
    }

    function init(options = {}) {
        if (state.initialized) {
            return getState();
        }

        state.initialized = true;
        state.startedAt = new Date().toISOString();
        state.page = normalizePage(
            options.page || document.body.dataset.page
        );

        document.documentElement.dataset.corecraftPay = "ready";

        window.dispatchEvent(
            new CustomEvent("corecraftpay:ready", {
                detail: getState()
            })
        );

        return getState();
    }

    function getState() {
        return Object.freeze({
            initialized: state.initialized,
            startedAt: state.startedAt,
            page: state.page,
            version: VERSION
        });
    }

    async function loadJson(url) {
        if (!url) {
            throw new Error("A JSON URL is required.");
        }

        const response = await fetch(url, {
            method: "GET",
            headers: {
                Accept: "application/json"
            }
        });

        if (!response.ok) {
            throw new Error(
                `Request failed: ${response.status} ${response.statusText}`
            );
        }

        return response.json();
    }

    function emit(name, detail = {}) {
        if (!name) {
            throw new Error("An event name is required.");
        }

        window.dispatchEvent(
            new CustomEvent(`corecraftpay:${name}`, {
                detail
            })
        );
    }

    return Object.freeze({
        version: VERSION,
        init,
        getState,
        loadJson,
        emit
    });
})();
