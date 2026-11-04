"use strict";

window.DocumentationUI = (() => {
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
            .querySelectorAll("[data-doc-nav]")
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
            .querySelectorAll("[data-doc-year]")
            .forEach((element) => {
                element.textContent = year;
            });
    }

    function init() {
        setCurrentNavigation();
        updateYear();

        if (window.DocumentationPlatform) {
            window.DocumentationPlatform.init({
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
