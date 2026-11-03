"use strict";

window.DeveloperToolsUI = (() => {
    function normalizePath(path) {
        if (!path) {
            return "/";
        }

        return path.replace(/\/+$/, "") + "/";
    }

    function setCurrentNavigation() {
        const currentPath = normalizePath(
            window.location.pathname
        );

        document
            .querySelectorAll("[data-dev-nav]")
            .forEach((link) => {
                const linkPath = normalizePath(
                    new URL(
                        link.href,
                        window.location.origin
                    ).pathname
                );

                if (linkPath === currentPath) {
                    link.setAttribute(
                        "aria-current",
                        "page"
                    );
                }
                else {
                    link.removeAttribute(
                        "aria-current"
                    );
                }
            });
    }

    function updateYear() {
        const year = String(
            new Date().getFullYear()
        );

        document
            .querySelectorAll("[data-dev-year]")
            .forEach((element) => {
                element.textContent = year;
            });
    }

    function init() {
        setCurrentNavigation();
        updateYear();

        if (window.DeveloperTools) {
            window.DeveloperTools.init({
                page: document.body.dataset.page
            });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener(
            "DOMContentLoaded",
            init,
            {
                once: true
            }
        );
    }
    else {
        init();
    }

    return Object.freeze({
        init,
        setCurrentNavigation
    });
})();
