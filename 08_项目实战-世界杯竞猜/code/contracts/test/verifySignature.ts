const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("VerifySignature", function () {
  it("Check signature", async function () {
    const accounts = await ethers.getSigners()

    const VerifySignature = await ethers.getContractFactory("VerifySignature")
    const contract = await VerifySignature.deploy()
    await contract.deployed()

    // const PRIV_KEY = "0x..."
    // const signer = new ethers.Wallet(PRIV_KEY)
    const signer = accounts[0]
    const to = accounts[0].address
    const amount = 100

    // 第一种测试：生成hash的过程，还是通过合约来计算生成的
    const hash = await contract.getMessageHash(to, amount)
    let ethHash = await contract.getEthSignedMessageHash(hash)

    // signer签名的时候，仅对msgHash进行签名
    const sig = await signer.signMessage(ethers.utils.arrayify(hash))

    console.log("signer          ", signer.address)
    console.log("recovered signer", await contract.recoverSigner(ethHash, sig))

    // Correct signature and message returns true
    expect(
      await contract.verify(ethHash, sig, signer.address)
    ).to.equal(true)

    // Incorrect message returns false
    expect(
      await contract.verify(ethHash, sig, accounts[1].address)
    ).to.equal(false)
  })
})
