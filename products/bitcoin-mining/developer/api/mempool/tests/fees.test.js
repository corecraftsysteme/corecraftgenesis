import { MiningFeesApi } from "../src/fees.js";

const fees = new MiningFeesApi();

console.log("[TEST] CoreCraft Mining Fees API");

let failed = false;

async function runTest(name, fn) {
  console.log("");
  console.log(`[TEST] ${name}`);

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
  "Recommended fees",
  () => fees.getRecommendedFees()
);

await runTest(
  "Mempool blocks",
  () => fees.getMempoolBlocks()
);

console.log("");

if (failed) {
  console.error("[FAIL] Fees API runtime test failed.");
  process.exitCode = 1;
} else {
  console.log("[PASS] All Fees API runtime tests successful.");
  process.exitCode = 0;
}
