/**
 * CoreCraft Genesis
 * Audio Analyzer
 *
 * Frequenz- und Zeitbereichsanalyse über AnalyserNode.
 */

export class CoreCraftAudioAnalyzer {

    constructor(
        audioContext,
        options = {}
    ) {
        if (!audioContext) {
            throw new Error(
                "AudioContext ist erforderlich."
            );
        }

        const {
            fftSize = 2048,
            smoothingTimeConstant = 0.8,
            minDecibels = -100,
            maxDecibels = -30
        } = options;

        this.context = audioContext;

        this.analyser = this.context.createAnalyser();

        this.setFFTSize(fftSize);

        this.analyser.smoothingTimeConstant =
            smoothingTimeConstant;

        this.analyser.minDecibels = minDecibels;
        this.analyser.maxDecibels = maxDecibels;

        this.source = null;

        this.frequencyData =
            new Uint8Array(
                this.analyser.frequencyBinCount
            );

        this.timeDomainData =
            new Uint8Array(
                this.analyser.fftSize
            );
    }

    setFFTSize(fftSize) {
        const size = Number(fftSize);

        if (!Number.isInteger(size)) {
            throw new TypeError(
                "FFT-Größe muss eine Ganzzahl sein."
            );
        }

        this.analyser.fftSize = size;

        this.frequencyData =
            new Uint8Array(
                this.analyser.frequencyBinCount
            );

        this.timeDomainData =
            new Uint8Array(
                this.analyser.fftSize
            );

        return this.analyser.fftSize;
    }

    connectSource(source) {
        if (!source || typeof source.connect !== "function") {
            throw new TypeError(
                "Ungültige Audioquelle."
            );
        }

        this.disconnectSource();

        source.connect(this.analyser);

        this.source = source;

        return this;
    }

    disconnectSource() {
        if (!this.source) {
            return;
        }

        try {
            this.source.disconnect(this.analyser);
        }
        catch {
            // Quelle war möglicherweise bereits getrennt.
        }

        this.source = null;
    }

    connectOutput(destination) {
        const target =
            destination || this.context.destination;

        this.analyser.connect(target);

        return this;
    }

    disconnectOutput() {
        try {
            this.analyser.disconnect();
        }
        catch {
            // Keine aktive Ausgangsverbindung.
        }

        return this;
    }

    getFrequencyData() {
        this.analyser.getByteFrequencyData(
            this.frequencyData
        );

        return this.frequencyData;
    }

    getTimeDomainData() {
        this.analyser.getByteTimeDomainData(
            this.timeDomainData
        );

        return this.timeDomainData;
    }

    getAverageLevel() {
        const data = this.getFrequencyData();

        if (data.length === 0) {
            return 0;
        }

        let sum = 0;

        for (const value of data) {
            sum += value;
        }

        return sum / data.length;
    }

    getPeakLevel() {
        const data = this.getFrequencyData();

        let peak = 0;

        for (const value of data) {
            if (value > peak) {
                peak = value;
            }
        }

        return peak;
    }

    getFrequencyResolution() {
        return (
            this.context.sampleRate /
            this.analyser.fftSize
        );
    }

    getBinFrequency(index) {
        if (
            !Number.isInteger(index) ||
            index < 0 ||
            index >= this.analyser.frequencyBinCount
        ) {
            throw new RangeError(
                "Ungültiger Frequenz-Bin."
            );
        }

        return index * this.getFrequencyResolution();
    }

    getSnapshot() {
        const frequencyData =
            Array.from(this.getFrequencyData());

        const timeDomainData =
            Array.from(this.getTimeDomainData());

        return {
            timestamp: new Date().toISOString(),
            fftSize: this.analyser.fftSize,
            frequencyBinCount:
                this.analyser.frequencyBinCount,
            sampleRate:
                this.context.sampleRate,
            averageLevel:
                this.getAverageLevel(),
            peakLevel:
                this.getPeakLevel(),
            frequencyData,
            timeDomainData
        };
    }
}

export function createAudioAnalyzer(
    audioContext,
    options = {}
) {
    return new CoreCraftAudioAnalyzer(
        audioContext,
        options
    );
}
