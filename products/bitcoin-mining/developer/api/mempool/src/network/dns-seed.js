import {
  resolve4,
  resolve6
} from "node:dns/promises";

export class DnsSeedError extends Error {
  constructor(
    message,
    {
      seed = null,
      code = "DNS_SEED_ERROR",
      cause = null
    } = {}
  ) {
    super(message, { cause });

    this.name = "DnsSeedError";
    this.seed = seed;
    this.code = code;
  }
}

export class BitcoinDnsSeedResolver {
  constructor({
    resolver = null,
    timeout = 5000
  } = {}) {
    this.timeout = timeout;

    this.resolver = resolver ?? {
      resolve4,
      resolve6
    };
  }

  async resolve(seed) {
    const normalizedSeed = this.#normalizeSeed(seed);

    const [ipv4Result, ipv6Result] = await Promise.allSettled([
      this.#withTimeout(
        this.resolver.resolve4(normalizedSeed),
        normalizedSeed,
        "IPv4"
      ),
      this.#withTimeout(
        this.resolver.resolve6(normalizedSeed),
        normalizedSeed,
        "IPv6"
      )
    ]);

    const ipv4 = this.#extractAddresses(ipv4Result);
    const ipv6 = this.#extractAddresses(ipv6Result);

    const addresses = this.#deduplicate([
      ...ipv4,
      ...ipv6
    ]);

    if (addresses.length === 0) {
      throw new DnsSeedError(
        `No addresses returned for DNS seed: ${normalizedSeed}`,
        {
          seed: normalizedSeed,
          code: "NO_ADDRESSES"
        }
      );
    }

    return {
      seed: normalizedSeed,
      ipv4,
      ipv6,
      addresses,
      addressCount: addresses.length,
      resolvedAt: new Date().toISOString()
    };
  }

  async resolveMany(seeds) {
    if (!Array.isArray(seeds) || seeds.length === 0) {
      throw new TypeError(
        "At least one DNS seed is required."
      );
    }

    const normalizedSeeds = this.#deduplicate(
      seeds.map((seed) => this.#normalizeSeed(seed))
    );

    const results = await Promise.allSettled(
      normalizedSeeds.map((seed) => this.resolve(seed))
    );

    const successfulSeeds = [];
    const failedSeeds = [];
    const allAddresses = [];

    results.forEach((result, index) => {
      const seed = normalizedSeeds[index];

      if (result.status === "fulfilled") {
        successfulSeeds.push(result.value);
        allAddresses.push(...result.value.addresses);
        return;
      }

      failedSeeds.push({
        seed,
        code: result.reason?.code ?? "DNS_SEED_ERROR",
        message:
          result.reason?.message ??
          "DNS seed resolution failed."
      });
    });

    const addresses = this.#deduplicate(allAddresses);

    return {
      requestedSeeds: normalizedSeeds,
      successfulSeeds,
      failedSeeds,
      addresses,
      addressCount: addresses.length,
      seedCount: normalizedSeeds.length,
      successfulSeedCount: successfulSeeds.length,
      failedSeedCount: failedSeeds.length,
      resolvedAt: new Date().toISOString()
    };
  }

  #normalizeSeed(seed) {
    if (typeof seed !== "string") {
      throw new TypeError(
        "DNS seed must be a string."
      );
    }

    const normalized = seed
      .trim()
      .toLowerCase()
      .replace(/\.$/, "");

    if (!normalized) {
      throw new TypeError(
        "DNS seed must not be empty."
      );
    }

    if (
      normalized.includes("/") ||
      normalized.includes(":") ||
      normalized.includes(" ")
    ) {
      throw new TypeError(
        `Invalid DNS seed hostname: ${seed}`
      );
    }

    return normalized;
  }

  async #withTimeout(promise, seed, recordType) {
    let timer;

    const timeoutPromise = new Promise((_, reject) => {
      timer = setTimeout(() => {
        reject(
          new DnsSeedError(
            `${recordType} lookup timed out after ${this.timeout} ms.`,
            {
              seed,
              code: "DNS_TIMEOUT"
            }
          )
        );
      }, this.timeout);
    });

    try {
      return await Promise.race([
        promise,
        timeoutPromise
      ]);
    } finally {
      clearTimeout(timer);
    }
  }

  #extractAddresses(result) {
    if (result.status !== "fulfilled") {
      return [];
    }

    if (!Array.isArray(result.value)) {
      return [];
    }

    return result.value.filter(
      (address) =>
        typeof address === "string" &&
        address.length > 0
    );
  }

  #deduplicate(values) {
    return [...new Set(values)];
  }
}
