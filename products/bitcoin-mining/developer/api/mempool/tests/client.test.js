import { MiningApiClient } from "../src/client.js";

const client = new MiningApiClient();

console.log("[TEST] CoreCraft Mining API Client");
console.log("[TEST] Requesting current mempool data...");

try {
  const data = await client.get("mempool");

  console.log("[PASS] API request successful.");
  console.log("");
  console.log("Response:");
  console.log(JSON.stringify(data, null, 2));

  process.exitCode = 0;
} catch (error) {
  console.error("[FAIL] API request failed.");
  console.error(error);
  process.exitCode = 1;
}
