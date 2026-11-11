import { MiningApiClient } from "./client.js";

export class MiningApi {
  constructor(client = new MiningApiClient()) {
    this.client = client;
  }

  getPools(timePeriod = "1w") {
    return this.client.get(
      `v1/mining/pools/${encodeURIComponent(timePeriod)}`
    );
  }

  getPool(slug) {
    if (!slug) {
      throw new TypeError("Mining pool slug is required.");
    }

    return this.client.get(
      `v1/mining/pool/${encodeURIComponent(slug)}`
    );
  }

  getNetworkHashrate(timePeriod = "1m") {
    return this.client.get(
      `v1/mining/hashrate/${encodeURIComponent(timePeriod)}`
    );
  }

  getPoolHashrate(slug) {
    if (!slug) {
      throw new TypeError("Mining pool slug is required.");
    }

    return this.client.get(
      `v1/mining/pool/${encodeURIComponent(slug)}/hashrate`
    );
  }
}
