import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import hre from "hardhat";
import { WorldCup } from "../typechain-types";

describe("WorldCup", function () {
    enum Country {
        GERMANY,
        FRANCH,
        CHINA,
        BRAZIL,
        KOREA
    }

    const TWO_WEEKS_IN_SECS = 14 * 24 * 60 * 60;
    const ONE_GWEI = 1_000_000_000;
    const ONE_ETHER = ethers.utils.parseEther("1");

    let worldcupIns: WorldCup
    // let owner : SignerWithAddress
    // let otherAccount : SingerWithAddress

    let ownerAddr: string
    let otherAccountAddr: string
    let deadline1: number

    this.beforeEach(async () => {
        // console.log("in beforeEach...");

        const { worldcup, owner, otherAccount, deadline } = await loadFixture(deployWorldcupFixture);
        worldcupIns = worldcup
        ownerAddr = owner.address
        otherAccountAddr = otherAccount.address
        deadline1 = deadline

        // console.log("worldcupIns:", worldcupIns.address);
        // console.log("ownerAddr:", ownerAddr);
        // console.log("otherAccountAddr:", otherAccountAddr);
    })

    let preparePlay = async () => {
        const [A, B, C, D] = await ethers.getSigners();
        await worldcupIns.connect(A).play(Country.GERMANY, { value: ONE_GWEI }) //0
        await worldcupIns.connect(B).play(Country.GERMANY, { value: ONE_GWEI }) //0
        await worldcupIns.connect(C).play(Country.GERMANY, { value: ONE_GWEI }) //0
        await worldcupIns.connect(D).play(Country.FRANCH, { value: ONE_GWEI }) //1
    }

    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployWorldcupFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const WorldCup = await ethers.getContractFactory("WorldCup");
        const deadline = (await time.latest()) + TWO_WEEKS_IN_SECS;
        const worldcup = await WorldCup.deploy(deadline);

        return { worldcup, deadline, owner, otherAccount };
    }

    describe("Deployment", function () {
        it("Should set the right deadline", async function () {
            // const { worldcup, deadline } = await loadFixture(deployWorldcupFixture);
            console.log('deadline:', deadline1);

            expect(await worldcupIns.deadline()).to.equal(deadline1);
        });

        it("Should set the right owner", async function () {
            // const { worldcup, owner } = await loadFixture(deployWorldcupFixture);
            expect(await worldcupIns.admin()).to.equal(ownerAddr);
        });

        it("Should fail if the deadline is not in the future", async function () {
            // We don't use the fixture here because we want a different deployment
            const latestTime = await time.latest();
            const WorldCup = await ethers.getContractFactory("WorldCup");
            await expect(WorldCup.deploy(latestTime)).to.be.revertedWith(
                "WorldCupLottery: invalid deadline!"
            );
        });
    });

    describe("Play", function () {
        it("Should deposit 1 gwei", async function () {
            // 获取合约实例
            // const { worldcup, owner } = await loadFixture(deployWorldcupFixture);

            // 调用合约
            await worldcupIns.play(Country.CHINA, {
                value: ONE_GWEI
            })

            // 校验
            let bal = await worldcupIns.getVaultBalance()
            console.log("bal:", bal);
            console.log("bal.toString():", bal.toString());

            expect(bal).to.equal(ONE_GWEI)
        })

        it("Should faild with invalid eth", async function () {
            // const { worldcup, owner } = await loadFixture(deployWorldcupFixture);

            await expect(worldcupIns.play(Country.CHINA, {
                value: ONE_GWEI * 2
            })).to.revertedWith("invalid funds provided!")
        })

        it("Should have 1 player for selected country", async function () {
            // const { worldcup, owner } = await loadFixture(deployWorldcupFixture);

            await expect(worldcupIns.play(10, {
                value: ONE_GWEI
            })).to.revertedWithoutReason()
        })

        it("Should emit Event Play", async function () {
            // const { worldcup, owner } = await loadFixture(deployWorldcupFixture);
            await expect(worldcupIns.play(Country.BRAZIL, {
                value: ONE_GWEI
            })).to.emit(worldcupIns, "Play").withArgs(0, ownerAddr, Country.BRAZIL)
        })
    })

    describe("Finalize", function () {
        it("Should failed when called by other account", async function () {
            let otherAccount = await ethers.getSigner(otherAccountAddr)

            await expect(worldcupIns.connect(otherAccount).finialize(Country.BRAZIL)).to.
                revertedWith("not authorized!")
        })

        it("Should distribute with correct reward", async function () {
            // 调用play
            // A:0, B:0, C:0, D:1，Finalize: 0中奖
            const [A, B, C, D] = await ethers.getSigners();
            await preparePlay()

            // 调用finalize
            await worldcupIns.finialize(Country.GERMANY)

            // 校验数据
            let rewardForA = await worldcupIns.winnerVaults(A.address)
            let rewardForB = await worldcupIns.winnerVaults(B.address)
            let rewardForC = await worldcupIns.winnerVaults(C.address)
            let rewardForD = await worldcupIns.winnerVaults(D.address)

            // console.log("rewardForA:", rewardForA);
            // console.log("rewardForB:", rewardForB);
            // console.log("rewardForC:", rewardForC);
            // console.log("rewardForD:", rewardForD);

            expect(rewardForA).to.equal(ethers.BigNumber.from(1333333334))
            expect(rewardForB).to.equal(ethers.BigNumber.from(1333333333))
            expect(rewardForC).to.equal(ethers.BigNumber.from(1333333333))
            expect(rewardForD).to.equal(ethers.BigNumber.from(0))
        })

        it("Should emit Finalzie Event", async function () {
            const [A, B, C, D] = await ethers.getSigners();
            await preparePlay()

            let winners = [A.address, B.address, C.address]

            await expect(worldcupIns.finialize(Country.GERMANY)).to.
                emit(worldcupIns, "Finialize").withArgs(0, winners, 4 * ONE_GWEI, 1)
        })
    })

    describe("ClaimReward", function () {
        it("Should fail if the claimer has no reward", async function () {
            await expect(worldcupIns.claimReward()).to.revertedWith("nothing to claim!")
        })

        it("Should clear reward after claim", async function () {
            // paly
            // A:0, B:0, C:0, D:1，Finalize: 0中奖
            const [A, B, C, D] = await ethers.getSigners();
            await preparePlay()

            // finalize
            await worldcupIns.finialize(Country.GERMANY)

            // data before claim
            let balBefore_A = await ethers.provider.getBalance(B.address)
            let balBefore_WC = await worldcupIns.getVaultBalance()
            let balBefore_lockedAmts = await worldcupIns.lockedAmts()


            console.log("balBefore_A: ", balBefore_A.toString());
            console.log("balBefore_WC: ", balBefore_WC.toString())
            console.log("balBefore_lockedAmts: ", balBefore_lockedAmts.toString())


            // claim
            let rewardForB = await worldcupIns.winnerVaults(B.address)
            await worldcupIns.connect(B).claimReward()


            // data after claim
            let balAfter_B = await ethers.provider.getBalance(B.address)
            let balAfter_WC = await worldcupIns.getVaultBalance()
            let balAfter_lockedAmts = await worldcupIns.lockedAmts()

            console.log("balAfter_B :  ", balAfter_B.toString());
            console.log("balAfter_WC: ", balAfter_WC.toString())
            console.log("balAfter_lockedAmts: ", balAfter_lockedAmts.toString())

            // check
            // A钱包的金额增加

            // 合约的金额减少
            // expect(balBefore_WC.sub(balAfter_WC)).to.equal(rewardForB.add(1))
            expect(balBefore_WC.sub(balAfter_WC)).to.equal(rewardForB)

            // lockedAmts记录减少
            expect(balBefore_lockedAmts.sub(balAfter_lockedAmts)).to.equal(rewardForB)
        })
    })
});
