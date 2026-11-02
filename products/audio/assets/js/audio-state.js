/**
 * CoreCraft Genesis
 * Audio State
 *
 * Explizites Zustandsmodell für die Audio-Anwendung.
 */

export const AudioState = Object.freeze({
    IDLE: "idle",
    READY: "ready",
    RUNNING: "running",
    SUSPENDED: "suspended",
    ERROR: "error",
    CLOSED: "closed"
});

const allowedTransitions = Object.freeze({
    [AudioState.IDLE]: [
        AudioState.READY,
        AudioState.ERROR,
        AudioState.CLOSED
    ],

    [AudioState.READY]: [
        AudioState.RUNNING,
        AudioState.SUSPENDED,
        AudioState.ERROR,
        AudioState.CLOSED
    ],

    [AudioState.RUNNING]: [
        AudioState.SUSPENDED,
        AudioState.ERROR,
        AudioState.CLOSED
    ],

    [AudioState.SUSPENDED]: [
        AudioState.RUNNING,
        AudioState.ERROR,
        AudioState.CLOSED
    ],

    [AudioState.ERROR]: [
        AudioState.IDLE,
        AudioState.READY,
        AudioState.CLOSED
    ],

    [AudioState.CLOSED]: [
        AudioState.IDLE
    ]
});

let currentState = AudioState.IDLE;

const listeners = new Set();

const history = [
    {
        from: null,
        to: AudioState.IDLE,
        timestamp: new Date().toISOString(),
        reason: "initial-state"
    }
];

function isKnownState(state) {
    return Object.values(AudioState).includes(state);
}

export function getAudioState() {
    return currentState;
}

export function canTransitionTo(nextState) {
    if (!isKnownState(nextState)) {
        return false;
    }

    if (nextState === currentState) {
        return true;
    }

    const allowed = allowedTransitions[currentState] || [];

    return allowed.includes(nextState);
}

export function setAudioState(
    nextState,
    reason = "state-change"
) {
    if (!isKnownState(nextState)) {
        throw new Error(
            `Unbekannter AudioState: ${nextState}`
        );
    }

    if (!canTransitionTo(nextState)) {
        throw new Error(
            `Ungültiger AudioState-Übergang: ` +
            `${currentState} -> ${nextState}`
        );
    }

    if (nextState === currentState) {
        return currentState;
    }

    const previousState = currentState;

    currentState = nextState;

    const entry = {
        from: previousState,
        to: nextState,
        timestamp: new Date().toISOString(),
        reason
    };

    history.push(entry);

    for (const listener of listeners) {
        try {
            listener({
                state: currentState,
                previousState,
                reason,
                historyEntry: entry
            });
        }
        catch (error) {
            console.error(
                "AudioState Listener Error:",
                error
            );
        }
    }

    return currentState;
}

export function resetAudioState() {
    if (currentState !== AudioState.IDLE) {
        const previousState = currentState;

        currentState = AudioState.IDLE;

        history.push({
            from: previousState,
            to: AudioState.IDLE,
            timestamp: new Date().toISOString(),
            reason: "reset"
        });
    }

    return currentState;
}

export function subscribeAudioState(listener) {
    if (typeof listener !== "function") {
        throw new TypeError(
            "AudioState Listener muss eine Funktion sein."
        );
    }

    listeners.add(listener);

    return function unsubscribe() {
        listeners.delete(listener);
    };
}

export function getAudioStateHistory() {
    return history.map((entry) => ({ ...entry }));
}

export function getAllowedTransitions() {
    return [
        ...(allowedTransitions[currentState] || [])
    ];
}

export function getAudioStateSnapshot() {
    return {
        state: currentState,
        allowedTransitions: getAllowedTransitions(),
        transitionCount: history.length - 1,
        lastTransition:
            history.length > 0
                ? { ...history[history.length - 1] }
                : null
    };
}
