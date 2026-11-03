"use strict";

window.EngineCoreUI = (() => {
    function setCurrentNavigation() {
        const currentPath = window.location.pathname.replace(/\/+$/, "/");

        document.querySelectorAll("[data-ec-nav]").forEach((link) => {
            const linkPath = new URL(link.href, window.location.origin)
                .pathname
                .replace(/\/+$/, "/");

            if (linkPath === currentPath) {
                link.setAttribute("aria-current", "page");
            } else {
                link.removeAttribute("aria-current");
            }
        });
    }

    function bindToggleButtons() {
        document.querySelectorAll("[data-ec-toggle]").forEach((button) => {
            const selector = button.getAttribute("data-ec-toggle");

            if (!selector) {
                return;
            }

            const target = document.querySelector(selector);

            if (!target) {
                return;
            }

            button.addEventListener("click", () => {
                const hidden = target.classList.toggle("ec-hidden");
                button.setAttribute("aria-expanded", String(!hidden));
            });
        });
    }

    function updateYear() {
        const year = String(new Date().getFullYear());

        document.querySelectorAll("[data-ec-year]").forEach((element) => {
            element.textContent = year;
        });
    }

    function init() {
        setCurrentNavigation();
        bindToggleButtons();
        updateYear();

        if (window.EngineCore) {
            window.EngineCore.init({
                page: document.body.dataset.page
            });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init, {
            once: true
        });
    } else {
        init();
    }

    return Object.freeze({
        init,
        setCurrentNavigation
    });
})();
