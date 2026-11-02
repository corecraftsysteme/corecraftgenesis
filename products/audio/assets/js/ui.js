/**
 * CoreCraft Genesis
 * Audio UI
 *
 * Bindet AudioCore, AudioState und AudioAnalyzer
 * an optionale HTML-Oberflächenelemente.
 */

import {
    createAudioContext,
    resumeAudioContext,
    suspendAudioContext,
    closeAudioContext,
    getAudioSystemInfo,
    setMasterVolume
} from "./audio-core.js";

import {
    AudioState,
    getAudioState,
    setAudioState,
    subscribeAudioState
} from "./audio-state.js";

import {
    createAudioAnalyzer
} from "./audio-analyzer.js";

let analyzer = null;

function query(selector) {
    return document.querySelector(selector);
}

function setText(selector, value) {
    const element = query(selector);

    if (element) {
        element.textContent = String(value);
    }
}

function setStatus(state) {
    setText(
        "[data-audio-state]",
        state.toUpperCase()
    );

    const element = query("[data-audio-state]");

    if (element) {
        element.dataset.state = state;
    }
}

function updateSystemInfo() {
    const info = getAudioSystemInfo();

    setText(
        "[data-audio-context-state]",
        info.state
    );

    setText(
        "[data-audio-sample-rate]",
        info.sampleRate ?? "-"
    );

    setText(
        "[data-audio-master-volume]",
        info.masterVolume ?? "-"
    );
}

async function initializeAudio() {
    try {
        const context = createAudioContext();

        analyzer = createAudioAnalyzer(
            context,
            {
                fftSize: 2048,
                smoothingTimeConstant: 0.8
            }
        );

        setAudioState(
            AudioState.READY,
            "audio-context-created"
        );

        updateSystemInfo();

        return context;
    }
    catch (error) {
        console.error(error);

        try {
            setAudioState(
                AudioState.ERROR,
                "initialization-error"
            );
        }
        catch {
            // Zustand kann bereits ERROR sein.
        }

        throw error;
    }
}

async function startAudio() {
    try {
        if (!createAudioContext()) {
            return;
        }

        await resumeAudioContext();

        const state = getAudioState();

        if (
            state === AudioState.IDLE ||
            state === AudioState.ERROR
        ) {
            setAudioState(
                AudioState.READY,
                "prepare-start"
            );
        }

        if (getAudioState() !== AudioState.RUNNING) {
            setAudioState(
                AudioState.RUNNING,
                "user-start"
            );
        }

        updateSystemInfo();
    }
    catch (error) {
        console.error(
            "Audio start failed:",
            error
        );
    }
}

async function suspendAudio() {
    try {
        await suspendAudioContext();

        if (
            getAudioState() === AudioState.RUNNING
        ) {
            setAudioState(
                AudioState.SUSPENDED,
                "user-suspend"
            );
        }

        updateSystemInfo();
    }
    catch (error) {
        console.error(
            "Audio suspend failed:",
            error
        );
    }
}

async function stopAudio() {
    try {
        await closeAudioContext();

        const state = getAudioState();

        if (state !== AudioState.CLOSED) {
            setAudioState(
                AudioState.CLOSED,
                "user-close"
            );
        }

        updateSystemInfo();
    }
    catch (error) {
        console.error(
            "Audio close failed:",
            error
        );
    }
}

function handleVolumeInput(event) {
    try {
        const value = Number(
            event.currentTarget.value
        );

        const normalized =
            setMasterVolume(value);

        setText(
            "[data-audio-master-volume]",
            normalized.toFixed(2)
        );
    }
    catch (error) {
        console.error(
            "Volume update failed:",
            error
        );
    }
}

function bindControls() {
    const initializeButton =
        query("[data-audio-init]");

    const startButton =
        query("[data-audio-start]");

    const suspendButton =
        query("[data-audio-suspend]");

    const stopButton =
        query("[data-audio-stop]");

    const volumeControl =
        query("[data-audio-volume]");

    if (initializeButton) {
        initializeButton.addEventListener(
            "click",
            initializeAudio
        );
    }

    if (startButton) {
        startButton.addEventListener(
            "click",
            startAudio
        );
    }

    if (suspendButton) {
        suspendButton.addEventListener(
            "click",
            suspendAudio
        );
    }

    if (stopButton) {
        stopButton.addEventListener(
            "click",
            stopAudio
        );
    }

    if (volumeControl) {
        volumeControl.addEventListener(
            "input",
            handleVolumeInput
        );
    }
}

function bindStateObserver() {
    subscribeAudioState(
        ({ state }) => {
            setStatus(state);
            updateSystemInfo();
        }
    );

    setStatus(getAudioState());
}

export function getAnalyzer() {
    return analyzer;
}

export function initializeAudioUI() {
    bindControls();
    bindStateObserver();
    updateSystemInfo();

    document.documentElement.dataset.audioUi =
        "ready";

    console.info(
        "[CoreCraft Audio] UI ready"
    );
}

if (document.readyState === "loading") {
    document.addEventListener(
        "DOMContentLoaded",
        initializeAudioUI,
        { once: true }
    );
}
else {
    initializeAudioUI();
}
