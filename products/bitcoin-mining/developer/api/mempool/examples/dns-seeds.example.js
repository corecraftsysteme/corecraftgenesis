import {
  BitcoinDnsSeedResolver
} from "../src/network/dns-seed.js";

const seeds = [
  "seed.bitcoin.wiz.biz"
];

const resolver = new BitcoinDnsSeedResolver({
  timeout: 10000
});

console.log("[DNS] Resolving Bitcoin DNS seeds...");

try {
  const result = await resolver.resolveMany(seeds);

  console.log("");
  console.log("[DNS] Resolution summary");
  console.log(`Requested seeds: ${result.seedCount}`);
  console.log(`Successful: ${result.successfulSeedCount}`);
  console.log(`Failed: ${result.failedSeedCount}`);
  console.log(`Unique addresses: ${result.addressCount}`);

  console.log("");
  console.log("[DNS] Addresses");

  for (const address of result.addresses) {
    console.log(address);
  }

  if (result.failedSeeds.length > 0) {
    console.log("");
    console.log("[DNS] Failed seeds");

    for (const failure of result.failedSeeds) {
      console.log(
        `${failure.seed}: ${failure.code} - ${failure.message}`
      );
    }
  }

  process.exitCode =
    result.addressCount > 0 ? 0 : 1;
} catch (error) {
  console.error("[FAIL] DNS seed resolution failed.");
  console.error(error);
  process.exitCode = 1;
}
