import { ethers } from "hardhat";

async function main() {
  const TWO_WEEKS_IN_SECS = 14 * 24 * 60 * 60;
  const timestamp = Math.floor(Date.now() / 1000)
  console.log(timestamp)
  const deadline = timestamp + TWO_WEEKS_IN_SECS;

  const WorldCup = await ethers.getContractFactory("WorldCup");
  const worldcup = await WorldCup.deploy(deadline);

  await worldcup.deployed();

  console.log(`new worldcup deployed to ${worldcup.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
