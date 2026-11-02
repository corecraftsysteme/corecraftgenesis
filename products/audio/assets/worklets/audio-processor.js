class CoreCraftAudioProcessor extends AudioWorkletProcessor {

    static get parameterDescriptors() {
        return [
            {
                name: "gain",
                defaultValue: 1,
                minValue: 0,
                maxValue: 2,
                automationRate: "a-rate"
            }
        ];
    }

    process(inputs, outputs, parameters) {
        const input = inputs[0];
        const output = outputs[0];
        const gainValues = parameters.gain;

        if (!input || !output) {
            return true;
        }

        for (
            let channelIndex = 0;
            channelIndex < output.length;
            channelIndex++
        ) {
            const inputChannel = input[channelIndex];
            const outputChannel = output[channelIndex];

            if (!inputChannel || !outputChannel) {
                continue;
            }

            for (
                let sampleIndex = 0;
                sampleIndex < outputChannel.length;
                sampleIndex++
            ) {
                const gain =
                    gainValues.length === 1
                        ? gainValues[0]
                        : gainValues[sampleIndex];

                outputChannel[sampleIndex] =
                    inputChannel[sampleIndex] * gain;
            }
        }

        return true;
    }
}

registerProcessor(
    "corecraft-audio-processor",
    CoreCraftAudioProcessor
);
