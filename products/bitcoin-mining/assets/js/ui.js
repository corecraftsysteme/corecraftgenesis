"use strict";

window.BitcoinMiningUI = (() => {
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
            .querySelectorAll("[data-mining-nav]")
            .forEach((link) => {
                const linkPath =
                    normalizePath(
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
                } else {
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
            .querySelectorAll("[data-mining-year]")
            .forEach((element) => {
                element.textContent = year;
            });
    }

    function bindToggles() {
        document
            .querySelectorAll("[data-mining-toggle]")
            .forEach((button) => {
                const selector =
                    button.getAttribute(
                        "data-mining-toggle"
                    );

                if (!selector) {
                    return;
                }

                const target =
                    document.querySelector(selector);

                if (!target) {
                    return;
                }

                button.addEventListener(
                    "click",
                    () => {
                        const hidden =
                            target.classList.toggle(
                                "mining-hidden"
                            );

                        button.setAttribute(
                            "aria-expanded",
                            String(!hidden)
                        );
                    }
                );
            });
    }

    function init() {
        setCurrentNavigation();
        updateYear();
        bindToggles();

        if (window.BitcoinMining) {
            window.BitcoinMining.init({
                page:
                    document.body.dataset.page
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
    } else {
        init();
    }

    return Object.freeze({
        init,
        setCurrentNavigation
    });
})();
