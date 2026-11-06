"use strict";

(() => {
    const instanceInput =
        document.getElementById("instanceInput");

    const schemaInput =
        document.getElementById("schemaInput");

    const validateButton =
        document.getElementById("validateButton");

    const exampleButton =
        document.getElementById("exampleButton");

    const formatButton =
        document.getElementById("formatButton");

    const clearButton =
        document.getElementById("clearButton");

    const status =
        document.getElementById("status");

    const errorList =
        document.getElementById("errorList");

    const resultValue =
        document.getElementById("resultValue");

    const errorValue =
        document.getElementById("errorValue");

    const instanceTypeValue =
        document.getElementById("instanceTypeValue");

    const keywordValue =
        document.getElementById("keywordValue");

    const instanceCharacters =
        document.getElementById("instanceCharacters");

    const schemaCharacters =
        document.getElementById("schemaCharacters");

    function setStatus(state, message) {
        status.dataset.state = state;
        status.textContent = message;
    }

    function updateCharacterCounts() {
        instanceCharacters.textContent =
            `${instanceInput.value.length} Zeichen`;

        schemaCharacters.textContent =
            `${schemaInput.value.length} Zeichen`;
    }

    function jsonType(value) {
        if (value === null) {
            return "null";
        }

        if (Array.isArray(value)) {
            return "array";
        }

        if (
            typeof value === "number" &&
            Number.isInteger(value)
        ) {
            return "integer";
        }

        return typeof value;
    }

    function displayType(value) {
        const type = jsonType(value);

        return type.toUpperCase();
    }

    function valuesEqual(left, right) {
        return JSON.stringify(left) ===
            JSON.stringify(right);
    }

    function addError(errors, path, message) {
        errors.push({
            path,
            message
        });
    }

    function validateType(
        value,
        expectedType
    ) {
        const actualType =
            jsonType(value);

        if (Array.isArray(expectedType)) {
            return expectedType.some(
                (type) =>
                    validateType(value, type)
            );
        }

        if (expectedType === "number") {
            return (
                typeof value === "number" &&
                Number.isFinite(value)
            );
        }

        if (expectedType === "integer") {
            return (
                typeof value === "number" &&
                Number.isInteger(value)
            );
        }

        if (expectedType === "object") {
            return (
                value !== null &&
                typeof value === "object" &&
                !Array.isArray(value)
            );
        }

        return actualType === expectedType;
    }

    function validateValue(
        value,
        schema,
        path,
        errors
    ) {
        if (
            typeof schema === "boolean"
        ) {
            if (!schema) {
                addError(
                    errors,
                    path,
                    "Boolean-Schema false lehnt den Wert ab."
                );
            }

            return;
        }

        if (
            schema === null ||
            typeof schema !== "object" ||
            Array.isArray(schema)
        ) {
            addError(
                errors,
                path,
                "Schema muss ein Objekt oder Boolean sein."
            );

            return;
        }

        if (
            Object.prototype.hasOwnProperty.call(
                schema,
                "type"
            )
        ) {
            if (
                !validateType(
                    value,
                    schema.type
                )
            ) {
                const expected =
                    Array.isArray(schema.type)
                        ? schema.type.join(" | ")
                        : schema.type;

                addError(
                    errors,
                    path,
                    `Typfehler: erwartet ${expected}, erhalten ${jsonType(value)}.`
                );

                return;
            }
        }

        if (
            Array.isArray(schema.enum) &&
            !schema.enum.some(
                (allowed) =>
                    valuesEqual(value, allowed)
            )
        ) {
            addError(
                errors,
                path,
                "Wert ist nicht in enum enthalten."
            );
        }

        if (
            Object.prototype.hasOwnProperty.call(
                schema,
                "const"
            ) &&
            !valuesEqual(
                value,
                schema.const
            )
        ) {
            addError(
                errors,
                path,
                "Wert entspricht nicht const."
            );
        }

        if (typeof value === "string") {
            if (
                Number.isInteger(schema.minLength) &&
                value.length < schema.minLength
            ) {
                addError(
                    errors,
                    path,
                    `String ist kürzer als minLength ${schema.minLength}.`
                );
            }

            if (
                Number.isInteger(schema.maxLength) &&
                value.length > schema.maxLength
            ) {
                addError(
                    errors,
                    path,
                    `String ist länger als maxLength ${schema.maxLength}.`
                );
            }

            if (
                typeof schema.pattern === "string"
            ) {
                try {
                    const expression =
                        new RegExp(schema.pattern, "u");

                    if (!expression.test(value)) {
                        addError(
                            errors,
                            path,
                            `String entspricht nicht pattern ${schema.pattern}.`
                        );
                    }
                }
                catch {
                    addError(
                        errors,
                        path,
                        "Schema enthält einen ungültigen regulären Ausdruck."
                    );
                }
            }
        }

        if (
            typeof value === "number" &&
            Number.isFinite(value)
        ) {
            if (
                typeof schema.minimum === "number" &&
                value < schema.minimum
            ) {
                addError(
                    errors,
                    path,
                    `Wert liegt unter minimum ${schema.minimum}.`
                );
            }

            if (
                typeof schema.maximum === "number" &&
                value > schema.maximum
            ) {
                addError(
                    errors,
                    path,
                    `Wert liegt über maximum ${schema.maximum}.`
                );
            }

            if (
                typeof schema.exclusiveMinimum ===
                    "number" &&
                value <= schema.exclusiveMinimum
            ) {
                addError(
                    errors,
                    path,
                    `Wert muss größer als ${schema.exclusiveMinimum} sein.`
                );
            }

            if (
                typeof schema.exclusiveMaximum ===
                    "number" &&
                value >= schema.exclusiveMaximum
            ) {
                addError(
                    errors,
                    path,
                    `Wert muss kleiner als ${schema.exclusiveMaximum} sein.`
                );
            }
        }

        if (Array.isArray(value)) {
            if (
                Number.isInteger(schema.minItems) &&
                value.length < schema.minItems
            ) {
                addError(
                    errors,
                    path,
                    `Array enthält weniger als minItems ${schema.minItems}.`
                );
            }

            if (
                Number.isInteger(schema.maxItems) &&
                value.length > schema.maxItems
            ) {
                addError(
                    errors,
                    path,
                    `Array enthält mehr als maxItems ${schema.maxItems}.`
                );
            }

            if (schema.uniqueItems === true) {
                const serialized =
                    value.map((item) =>
                        JSON.stringify(item)
                    );

                if (
                    new Set(serialized).size !==
                    serialized.length
                ) {
                    addError(
                        errors,
                        path,
                        "Array enthält doppelte Werte."
                    );
                }
            }

            if (
                Object.prototype.hasOwnProperty.call(
                    schema,
                    "items"
                )
            ) {
                value.forEach(
                    (item, index) => {
                        validateValue(
                            item,
                            schema.items,
                            `${path}[${index}]`,
                            errors
                        );
                    }
                );
            }
        }

        if (
            value !== null &&
            typeof value === "object" &&
            !Array.isArray(value)
        ) {
            const keys =
                Object.keys(value);

            if (
                Number.isInteger(
                    schema.minProperties
                ) &&
                keys.length < schema.minProperties
            ) {
                addError(
                    errors,
                    path,
                    `Objekt enthält weniger als minProperties ${schema.minProperties}.`
                );
            }

            if (
                Number.isInteger(
                    schema.maxProperties
                ) &&
                keys.length > schema.maxProperties
            ) {
                addError(
                    errors,
                    path,
                    `Objekt enthält mehr als maxProperties ${schema.maxProperties}.`
                );
            }

            if (Array.isArray(schema.required)) {
                schema.required.forEach(
                    (property) => {
                        if (
                            !Object.prototype
                                .hasOwnProperty
                                .call(value, property)
                        ) {
                            addError(
                                errors,
                                path,
                                `Pflichtfeld fehlt: ${property}.`
                            );
                        }
                    }
                );
            }

            const properties =
                schema.properties &&
                typeof schema.properties === "object" &&
                !Array.isArray(schema.properties)
                    ? schema.properties
                    : {};

            Object.entries(properties).forEach(
                ([property, propertySchema]) => {
                    if (
                        Object.prototype
                            .hasOwnProperty
                            .call(value, property)
                    ) {
                        validateValue(
                            value[property],
                            propertySchema,
                            `${path}.${property}`,
                            errors
                        );
                    }
                }
            );

            const knownProperties =
                new Set(Object.keys(properties));

            keys.forEach((key) => {
                if (knownProperties.has(key)) {
                    return;
                }

                if (
                    schema.additionalProperties ===
                    false
                ) {
                    addError(
                        errors,
                        `${path}.${key}`,
                        "Zusätzliche Eigenschaft ist nicht erlaubt."
                    );

                    return;
                }

                if (
                    schema.additionalProperties &&
                    typeof schema.additionalProperties ===
                        "object"
                ) {
                    validateValue(
                        value[key],
                        schema.additionalProperties,
                        `${path}.${key}`,
                        errors
                    );
                }
            });
        }
    }

    function renderErrors(errors) {
        errorList.innerHTML = "";

        if (errors.length === 0) {
            const item =
                document.createElement("li");

            item.className = "schema-empty";
            item.textContent =
                "Keine Schema-Verletzungen gefunden.";

            errorList.appendChild(item);

            return;
        }

        errors.forEach((error) => {
            const item =
                document.createElement("li");

            item.className = "schema-error";
            item.textContent =
                `${error.path}: ${error.message}`;

            errorList.appendChild(item);
        });
    }

    function validateDocuments() {
        let instance;
        let schema;

        try {
            if (!instanceInput.value.trim()) {
                throw new Error(
                    "JSON Instance ist leer."
                );
            }

            instance =
                JSON.parse(instanceInput.value);
        }
        catch (error) {
            setStatus(
                "fail",
                `Instance-Fehler: ${
                    error instanceof Error
                        ? error.message
                        : String(error)
                }`
            );

            resultValue.textContent = "INVALID";
            errorValue.textContent = "1";

            renderErrors([
                {
                    path: "$",
                    message:
                        "JSON Instance konnte nicht gelesen werden."
                }
            ]);

            return;
        }

        try {
            if (!schemaInput.value.trim()) {
                throw new Error(
                    "JSON Schema ist leer."
                );
            }

            schema =
                JSON.parse(schemaInput.value);
        }
        catch (error) {
            setStatus(
                "fail",
                `Schema-Fehler: ${
                    error instanceof Error
                        ? error.message
                        : String(error)
                }`
            );

            resultValue.textContent = "INVALID";
            errorValue.textContent = "1";

            renderErrors([
                {
                    path: "$schema",
                    message:
                        "JSON Schema konnte nicht gelesen werden."
                }
            ]);

            return;
        }

        const errors = [];

        validateValue(
            instance,
            schema,
            "$",
            errors
        );

        instanceTypeValue.textContent =
            displayType(instance);

        keywordValue.textContent =
            String(
                schema !== null &&
                typeof schema === "object" &&
                !Array.isArray(schema)
                    ? Object.keys(schema).length
                    : 0
            );

        errorValue.textContent =
            String(errors.length);

        renderErrors(errors);

        if (errors.length === 0) {
            resultValue.textContent = "PASS";

            setStatus(
                "pass",
                "JSON Instance erfüllt die unterstützten Schema-Regeln."
            );
        }
        else {
            resultValue.textContent = "FAIL";

            setStatus(
                "fail",
                `${errors.length} Schema-Verletzung(en) gefunden.`
            );
        }
    }

    function loadExample() {
        instanceInput.value =
`{
  "name": "CoreCraft Genesis",
  "version": 1,
  "active": true,
  "modules": [
    "validators",
    "diagnostics",
    "data-tools"
  ]
}`;

        schemaInput.value =
`{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": [
    "name",
    "version",
    "active"
  ],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 3
    },
    "version": {
      "type": "integer",
      "minimum": 1
    },
    "active": {
      "type": "boolean"
    },
    "modules": {
      "type": "array",
      "minItems": 1,
      "uniqueItems": true,
      "items": {
        "type": "string"
      }
    }
  },
  "additionalProperties": false
}`;

        updateCharacterCounts();

        setStatus(
            "neutral",
            "Beispiel geladen. Validierung kann gestartet werden."
        );

        resultValue.textContent = "—";
        errorValue.textContent = "0";
        instanceTypeValue.textContent = "—";
        keywordValue.textContent = "0";

        renderErrors([]);
    }

    function formatDocuments() {
        try {
            const instance =
                JSON.parse(instanceInput.value);

            const schema =
                JSON.parse(schemaInput.value);

            instanceInput.value =
                JSON.stringify(
                    instance,
                    null,
                    2
                );

            schemaInput.value =
                JSON.stringify(
                    schema,
                    null,
                    2
                );

            updateCharacterCounts();

            setStatus(
                "pass",
                "JSON Instance und Schema wurden formatiert."
            );
        }
        catch (error) {
            setStatus(
                "fail",
                error instanceof Error
                    ? error.message
                    : String(error)
            );
        }
    }

    function clearAll() {
        instanceInput.value = "";
        schemaInput.value = "";

        resultValue.textContent = "—";
        errorValue.textContent = "0";
        instanceTypeValue.textContent = "—";
        keywordValue.textContent = "0";

        updateCharacterCounts();

        errorList.innerHTML =
            '<li class="schema-empty">Noch keine Validierung durchgeführt.</li>';

        setStatus(
            "neutral",
            "Bereit. JSON-Daten und Schema einfügen."
        );

        instanceInput.focus();
    }

    function insertTab(event, target) {
        if (event.key !== "Tab") {
            return;
        }

        event.preventDefault();

        const start =
            target.selectionStart;

        const end =
            target.selectionEnd;

        target.value =
            target.value.substring(0, start) +
            "  " +
            target.value.substring(end);

        target.selectionStart =
            target.selectionEnd =
                start + 2;

        updateCharacterCounts();
    }

    validateButton.addEventListener(
        "click",
        validateDocuments
    );

    exampleButton.addEventListener(
        "click",
        loadExample
    );

    formatButton.addEventListener(
        "click",
        formatDocuments
    );

    clearButton.addEventListener(
        "click",
        clearAll
    );

    instanceInput.addEventListener(
        "input",
        updateCharacterCounts
    );

    schemaInput.addEventListener(
        "input",
        updateCharacterCounts
    );

    instanceInput.addEventListener(
        "keydown",
        (event) => {
            insertTab(event, instanceInput);
        }
    );

    schemaInput.addEventListener(
        "keydown",
        (event) => {
            insertTab(event, schemaInput);
        }
    );

    updateCharacterCounts();
})();
