import { expect } from "chai";
import { ethers } from "hardhat";
import { mine } from "@nomicfoundation/hardhat-network-helpers";
import { getExpectedContractAddress } from "../utils/getExpectedContractAddress";

describe("Auction Tests", async () => {
  async function deploy() {
    const nftFac = await ethers.getContractFactory("ChickenDAONFT");
    const auctionFac = await ethers.getContractFactory(
      "ChickenDAOAuctionHouse"
    );
    const [dev, treasury, bidder1, bidder2, bidder3] =
      await ethers.getSigners();

    // const labsExpectedAddr = await getExpectedContractAddress(owner, 3);

    const auction = await auctionFac
      .connect(dev)
      .deploy(dev.address, treasury.address);
    await auction.deployed();
    const nft = await nftFac.connect(dev).deploy(dev.address, auction.address);
    await nft.deployed();

    await auction.connect(dev).setNFTAddress(nft.address);

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
      nft,
      auction,
      dev,
      treasury,
      bidder1,
      bidder2,
      bidder3,
    };
  }

  it("should be able to do the start BID", async () => {
    const { nft, auction, dev, treasury, bidder1, bidder2, bidder3 } =
      await deploy();

    await auction.connect(dev).start();
    const currentBidId = await auction.getCurrentBidId();
    const bidData = await auction.bids(currentBidId);

    const totalSupply = await nft.totalSupply();

    expect(bidData[2].toString()).to.equal("1");
    expect(totalSupply.toString()).to.equal("1");
  });

  it("shoud be able to bid after started", async () => {
    const { nft, auction, dev, treasury, bidder1, bidder2, bidder3 } =
      await deploy();

    await auction.connect(dev).start();

    await auction
      .connect(bidder1)
      .bid({ value: ethers.utils.parseUnits("3", "ether") });

    const currentBidId = await auction.getCurrentBidId();
    const bidData = await auction.bids(currentBidId);

    expect(bidData[0].toString()).to.equal(bidder1.address);
  });

  it("should not be able to re-bid to previous bidder", async () => {
    const { nft, auction, dev, treasury, bidder1, bidder2, bidder3 } =
      await deploy();
    await auction.connect(dev).start();

    await auction
      .connect(bidder1)
      .bid({ value: ethers.utils.parseUnits("3", "ether") });

    await expect(
      auction
        .connect(bidder1)
        .bid({ value: ethers.utils.parseUnits("3", "ether") })
    ).revertedWith("bid: you are the current bidder");
  });

  it("shoud be able to bid from particular bidder", async () => {
    const { nft, auction, dev, treasury, bidder1, bidder2, bidder3 } =
      await deploy();
    await auction.connect(dev).start();

    await auction
      .connect(bidder1)
      .bid({ value: ethers.utils.parseUnits("3", "ether") });
    await auction
      .connect(bidder2)
      .bid({ value: ethers.utils.parseUnits("7", "ether") });
    await auction
      .connect(bidder3)
      .bid({ value: ethers.utils.parseUnits("10", "ether") });

    const currentBidId = await auction.getCurrentBidId();
    const bidData = await auction.bids(currentBidId);

    expect(bidData[0].toString()).to.equal(bidder3.address);
    expect(bidData[2].toString()).to.equal("1");
  });

  it("should be able to refund to previous bidder", async () => {
    const { nft, auction, dev, treasury, bidder1, bidder2, bidder3 } =
      await deploy();
    await auction.connect(dev).start();

    await auction
      .connect(bidder1)
      .bid({ value: ethers.utils.parseUnits("3", "ether") });

    expect((await auction.getBalance()).toString()).to.equal(
      ethers.utils.parseEther("3")
    );
    await auction
      .connect(bidder2)
      .bid({ value: ethers.utils.parseUnits("7", "ether") });
    expect((await auction.getBalance()).toString()).to.equal(
      ethers.utils.parseEther("7")
    );
    await auction
      .connect(bidder3)
      .bid({ value: ethers.utils.parseUnits("10", "ether") });
    expect((await auction.getBalance()).toString()).to.equal(
      ethers.utils.parseEther("10")
    );
  });

  it("shoud be able to getAllBid Action infos", async () => {
    const { nft, auction, dev, treasury, bidder1, bidder2, bidder3 } =
      await deploy();
    await auction.connect(dev).start();

    await auction
      .connect(bidder1)
      .bid({ value: ethers.utils.parseUnits("3", "ether") });

    await mine(1000);

    await auction.sattle();

    const bids = await auction.getAllBids();
    const parsed = bids.map((bid) => {
      return bid;
    });
    // const parsedBids = JSON.parse(bids);

    // console.log(parsedBids);

    expect(parsed.length).to.equal(2);
  });

  it("should be able to sattle auction after has some bids", async () => {
    const { nft, auction, dev, treasury, bidder1, bidder2, bidder3 } =
      await deploy();
    await auction.connect(dev).start();

    await auction
      .connect(bidder1)
      .bid({ value: ethers.utils.parseUnits("3", "ether") });

    await mine(1000);

    expect(await auction.sattle()).to.ok;
  });
});
