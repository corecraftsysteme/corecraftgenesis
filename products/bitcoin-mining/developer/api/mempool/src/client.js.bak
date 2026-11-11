export class MiningApiError extends Error {
  constructor(
    message,
    {
      status = null,
      statusText = null,
      url = null,
      code = "API_ERROR",
      retryAfter = null,
      cause = null
    } = {}
  ) {
    super(message, { cause });

    this.name = "MiningApiError";
    this.status = status;
    this.statusText = statusText;
    this.url = url;
    this.code = code;
    this.retryAfter = retryAfter;
  }
}

export class MiningApiClient {
  constructor({
    baseUrl = "https://mempool.space/api",
    timeout = 10000,
    maxRetries = 2,
    retryDelay = 1000
  } = {}) {
    this.baseUrl = baseUrl.replace(/\/$/, "");
    this.timeout = timeout;
    this.maxRetries = maxRetries;
    this.retryDelay = retryDelay;
  }

  async get(path) {
    const normalizedPath = String(path).replace(/^\//, "");
    const url = `${this.baseUrl}/${normalizedPath}`;

    return this.#request(url);
  }

  async #request(url) {
    let lastError;

    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      const controller = new AbortController();

      const timer = setTimeout(
        () => controller.abort(),
        this.timeout
      );

      try {
        const response = await fetch(url, {
          method: "GET",
          headers: {
            Accept: "application/json"
          },
          signal: controller.signal
        });

        if (response.status === 429) {
          const retryAfter = this.#getRetryAfter(response);

          if (attempt >= this.maxRetries) {
            throw new MiningApiError(
              "API rate limit exceeded.",
              {
                status: response.status,
                statusText: response.statusText,
                url,
                code: "RATE_LIMIT",
                retryAfter
              }
            );
          }

          const delay =
            retryAfter ??
            this.retryDelay * Math.pow(2, attempt);

          await this.#sleep(delay);
          continue;
        }

        if (!response.ok) {
          throw new MiningApiError(
            `HTTP ${response.status}: ${response.statusText}`,
            {
              status: response.status,
              statusText: response.statusText,
              url,
              code: "HTTP_ERROR"
            }
          );
        }

        return await this.#parseJson(response, url);
      } catch (error) {
        if (error instanceof MiningApiError) {
          throw error;
        }

        if (
          error?.name === "AbortError" ||
          controller.signal.aborted
        ) {
          throw new MiningApiError(
            `Request timed out after ${this.timeout} ms.`,
            {
              url,
              code: "TIMEOUT",
              cause: error
            }
          );
        }

        lastError = new MiningApiError(
          "Network request failed.",
          {
            url,
            code: "NETWORK_ERROR",
            cause: error
          }
        );

        if (attempt >= this.maxRetries) {
          throw lastError;
        }

        const delay =
          this.retryDelay * Math.pow(2, attempt);

        await this.#sleep(delay);
      } finally {
        clearTimeout(timer);
      }
    }

    throw (
      lastError ??
      new MiningApiError(
        "Request failed.",
        {
          url,
          code: "API_ERROR"
        }
      )
    );
  }

  async #parseJson(response, url) {
    try {
      return await response.json();
    } catch (error) {
      throw new MiningApiError(
        "API returned invalid JSON.",
        {
          status: response.status,
          statusText: response.statusText,
          url,
          code: "INVALID_JSON",
          cause: error
        }
      );
    }
  }

  #getRetryAfter(response) {
    const value = response.headers.get("retry-after");

    if (!value) {
      return null;
    }

    const seconds = Number(value);

    if (Number.isFinite(seconds)) {
      return Math.max(0, seconds * 1000);
    }

    const date = Date.parse(value);

    if (!Number.isNaN(date)) {
      return Math.max(0, date - Date.now());
    }

    return null;
  }

  #sleep(milliseconds) {
    return new Promise((resolve) => {
      setTimeout(resolve, milliseconds);
    });
  }
}