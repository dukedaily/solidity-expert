// import { ethers} from "hardhat";
import env from "hardhat";

async function main() {
    const currentTimestampInSeconds = Math.round(Date.now() / 1000);
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;
    console.log('unlockTime:', unlockTime);

    //   const lockedAmount = env.ethers.utils.parseEther("1");
    const lockedAmount = env.ethers.utils.parseEther("0.0000001");

    const Lock = await env.ethers.getContractFactory("Lock");
    const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

    await lock.deployed();

    console.log(`Lock with 1 ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`);

    console.log('network:', env.network.name);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
