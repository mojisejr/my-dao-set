import { expect } from "chai";
import { ethers } from "hardhat";
import { mine, time } from "@nomicfoundation/hardhat-network-helpers";
import { getExpectedContractAddress } from "../utils/getExpectedContractAddress";

describe("Auction Tests", async () => {
  async function deploy() {
    const nftFac = await ethers.getContractFactory("ChickenDAONFT");
    const auctionFac = await ethers.getContractFactory(
      "ChickenDAOAuctionHouse"
    );
    const timelockFac = await ethers.getContractFactory("ChickenDAOExecutor");

    const timelockDelay = 100; // 10 sec
    const [dev, signer1] = await ethers.getSigners();

    const timelock = await timelockFac.deploy(dev.address, timelockDelay);
    await timelock.deployed();
    const auction = await auctionFac.deploy(dev.address, timelock.address);
    await auction.deployed();
    const nft = await nftFac.deploy(dev.address, auction.address);
    await nft.deployed();

    // const labsExpectedAddr = await getExpectedContractAddress(owner, 3);

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
      timelock,
      auction,
      nft,
    };
  }

  it("should be able to deploy governane and accept timelock admin", async () => {
    const { dev, timelock, auction, nft } = await deploy();

    const govFac = await ethers.getContractFactory("ChickenDAOGovernor");
    const gov = await govFac.deploy(nft.address, timelock.address, 1, 20, 1);
    await gov.deployed();

    const target = dev.address;
    const value = 0;
    const signature = "0x4dd18bf5";
    // const data = `0x000000000000000000000000${gov.address.substring(2)}`;
    const data =
      "0x000000000000000000000000f4b146fba71f41e0592668ffbf264f1d186b2ca8";

    const eta = (await time.latest()) + 200;

    const tx = await timelock
      .connect(dev)
      .queueTransaction(target, value, signature, data, eta);

    await time.increase(1000);

    const rr = await tx.wait();
    console.log(rr.events?.filter((x) => x.event == "QueueTransaction"));

    const tx1 = await timelock
      .connect(dev)
      .executeTransaction(target, value, signature, data, eta);
    const r = await tx1.wait();

    console.log(r.events?.filter((x) => x.event == "ExecuteTransaction"));
    console.log(r.events?.filter((x) => x.event == "NewPendingAdmin"));

    expect((await timelock.pendingAdmin()).toString()).to.equal(gov.address);
  });
});
