import { MiningApiClient } from "./client.js";

export class MiningNetworkApi {
  constructor(client = new MiningApiClient()) {
    this.client = client;
  }

  getMempool() {
    return this.client.get("mempool");
  }

  getDifficultyAdjustment() {
    return this.client.get("v1/difficulty-adjustment");
  }
}
