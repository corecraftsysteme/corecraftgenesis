import { MiningApi } from "../src/mining.js";

const mining = new MiningApi();

console.log("[TEST] CoreCraft Mining API");

let failed = false;

async function runTest(name, fn) {
  try {
    const data = await fn();
    console.log(`[PASS] ${name}`);
    console.log(JSON.stringify(data, null, 2));
  } catch (error) {
    failed = true;
    console.error(`[FAIL] ${name}`);
    console.error(error);
  }
}

await runTest(
  "Mining pools (1w)",
  () => mining.getPools("1w")
);

await runTest(
  "Network hashrate (1m)",
  () => mining.getNetworkHashrate("1m")
);

process.exitCode = failed ? 1 : 0;
