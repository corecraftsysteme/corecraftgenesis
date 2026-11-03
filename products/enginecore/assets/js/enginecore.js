"use strict";

window.EngineCore = (() => {
    const VERSION = "1.0.0";

    const state = {
        initialized: false,
        startedAt: null,
        page: null
    };

    function normalizePageName(value) {
        if (typeof value !== "string") {
            return "unknown";
        }

        const name = value.trim().toLowerCase();

        return name.length > 0 ? name : "unknown";
    }

    function init(options = {}) {
        if (state.initialized) {
            return getState();
        }

        state.initialized = true;
        state.startedAt = new Date().toISOString();
        state.page = normalizePageName(options.page || document.body.dataset.page);

        document.documentElement.dataset.enginecore = "ready";

        window.dispatchEvent(
            new CustomEvent("enginecore:ready", {
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
            new CustomEvent(`enginecore:${name}`, {
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
