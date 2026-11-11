import { MiningNetworkApi } from "../src/network.js";

const network = new MiningNetworkApi();

console.log("[TEST] CoreCraft Mining Network API");

try {
  console.log("[TEST] Difficulty adjustment...");

  const difficulty = await network.getDifficultyAdjustment();

  console.log("[PASS] Difficulty request successful.");
  console.log(JSON.stringify(difficulty, null, 2));

  console.log("");
  console.log("[TEST] Mempool status...");

  const mempool = await network.getMempool();

  console.log("[PASS] Mempool request successful.");
  console.log(JSON.stringify(mempool, null, 2));

  process.exitCode = 0;
} catch (error) {
  console.error("[FAIL] Network API test failed.");
  console.error(error);

  process.exitCode = 1;
}
