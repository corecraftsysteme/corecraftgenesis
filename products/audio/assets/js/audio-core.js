/**
 * CoreCraft Genesis
 * Audio Core
 *
 * Zentrale Verwaltung des Web-Audio-Kontexts,
 * Master-Gain-Nodes und Audio-Verbindungen.
 */

let audioContext = null;
let masterGain = null;

function getAudioContextClass() {
    return window.AudioContext || window.webkitAudioContext || null;
}

export function isWebAudioSupported() {
    return getAudioContextClass() !== null;
}

export function createAudioContext() {
    if (audioContext) {
        return audioContext;
    }

    const AudioContextClass = getAudioContextClass();

    if (!AudioContextClass) {
        throw new Error(
            "Die Web Audio API wird von diesem Browser nicht unterstützt."
        );
    }

    audioContext = new AudioContextClass();

    masterGain = audioContext.createGain();
    masterGain.gain.value = 1;

    masterGain.connect(audioContext.destination);

    return audioContext;
}

export function getAudioContext() {
    return audioContext;
}

export function getMasterGain() {
    if (!audioContext) {
        createAudioContext();
    }

    return masterGain;
}

export async function resumeAudioContext() {
    const context = createAudioContext();

    if (context.state === "suspended") {
        await context.resume();
    }

    return context.state;
}

export async function suspendAudioContext() {
    if (!audioContext) {
        return "uninitialized";
    }

    if (audioContext.state === "running") {
        await audioContext.suspend();
    }

    return audioContext.state;
}

export async function closeAudioContext() {
    if (!audioContext) {
        return "closed";
    }

    if (audioContext.state !== "closed") {
        await audioContext.close();
    }

    audioContext = null;
    masterGain = null;

    return "closed";
}

export function setMasterVolume(value) {
    const gain = getMasterGain();

    const numericValue = Number(value);

    if (!Number.isFinite(numericValue)) {
        throw new TypeError(
            "Master-Lautstärke muss eine gültige Zahl sein."
        );
    }

    const normalizedValue = Math.min(
        1,
        Math.max(0, numericValue)
    );

    gain.gain.value = normalizedValue;

    return normalizedValue;
}

export function getMasterVolume() {
    const gain = getMasterGain();

    return gain.gain.value;
}

export function connectToMaster(node) {
    if (!node || typeof node.connect !== "function") {
        throw new TypeError(
            "Es wurde kein gültiger AudioNode übergeben."
        );
    }

    node.connect(getMasterGain());

    return node;
}

export function createOscillator(options = {}) {
    const context = createAudioContext();

    const {
        frequency = 440,
        type = "sine",
        gain = 0.2
    } = options;

    const oscillator = context.createOscillator();
    const gainNode = context.createGain();

    oscillator.type = type;
    oscillator.frequency.value = frequency;

    gainNode.gain.value = Math.min(
        1,
        Math.max(0, Number(gain))
    );

    oscillator.connect(gainNode);
    gainNode.connect(getMasterGain());

    return {
        oscillator,
        gainNode
    };
}

export function getAudioSystemInfo() {
    if (!audioContext) {
        return {
            initialized: false,
            state: "uninitialized",
            sampleRate: null,
            currentTime: 0,
            masterVolume: null
        };
    }

    return {
        initialized: true,
        state: audioContext.state,
        sampleRate: audioContext.sampleRate,
        currentTime: audioContext.currentTime,
        masterVolume: masterGain
            ? masterGain.gain.value
            : null
    };
}
