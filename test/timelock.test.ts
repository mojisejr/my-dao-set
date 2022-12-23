import { expect } from "chai";
import { ethers } from "hardhat";
import { mine } from "@nomicfoundation/hardhat-network-helpers";
import { getExpectedContractAddress } from "../utils/getExpectedContractAddress";

describe("Auction Tests", async () => {
  async function deploy() {
    const timelockFac = await ethers.getContractFactory("ChickenDAOExecutor");
    const [dev, signer1] = await ethers.getSigners();

    // const labsExpectedAddr = await getExpectedContractAddress(owner, 3);
    const timelockDelay = 1; // 10 sec

    const timelock = await timelockFac
      .connect(dev)
      .deploy(dev.address, timelockDelay);
    await timelock.deployed();

    // console.log({
    //   nft: nft.address,
    //   auction: auction.address,
    //   dev: dev.address,
    //   treasury: treasury.address,
    //   bidder1: bidder1.address,
    //   bidder2: bidder2.address,
    //   bidder3: bidder3.address,
    // });

    return {
      dev,
      signer1,
      timelock,
    };
  }

  it("test queue => execute transaction", async () => {
    const { dev, signer1, timelock } = await deploy();

    const target = dev.address;
    const value = 0;
    const signature = "setPendingAdmin(address)";
    const data = `0x000000000000000000000000${signer1.address.substring(2)}`;
    const eta = new Date().getTime();

    const tx = await timelock
      .connect(dev)
      .queueTransaction(target, value, signature, data, eta);
    const receipt = await tx.wait();
    console.log(receipt);

    await mine();

    const tx1 = await timelock
      .connect(dev)
      .executeTransaction(target, value, signature, data, eta);

    const receipt2 = await tx1.wait();
    console.log(receipt2);
  });
});
