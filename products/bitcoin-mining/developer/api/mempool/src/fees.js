import { MiningApiClient } from "./client.js";

export class MiningFeesApi {
  constructor(client = new MiningApiClient()) {
    this.client = client;
  }

  getRecommendedFees() {
    return this.client.get("v1/fees/recommended");
  }

  getMempoolBlocks() {
    return this.client.get("v1/fees/mempool-blocks");
  }
}
