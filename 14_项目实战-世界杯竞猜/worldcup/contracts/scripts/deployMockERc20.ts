import { ethers } from "hardhat";

async function main() {

  // const totalSupply = 100000000 * 10**18
  const totalSupply = ethers.utils.parseUnits('100000000', 18)
  console.log('totalSupply:', totalSupply);
  
  const FHTToken = await ethers.getContractFactory("FHTToken");
  const fht = await FHTToken.deploy("FHT Token", "FHT", totalSupply);

  await fht.deployed();

  console.log(`new FHT Token deployed to ${fht.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
