import { ethers } from "hardhat";

async function main() {
  const nftFac = await ethers.getContractFactory("ChickenDAOAuctionHouse");
  const auctionFac = await ethers.getContractFactory("ChickenDAONFT");
  const timelockFac = await ethers.getContractFactory("ChickenDAOExecutor");
  const [signer] = await ethers.getSigners();

  //1. deploy timelock
  const timelockDelay = 86400;
  const timelock = await timelockFac.deploy(signer.address, timelockDelay);
  await timelock.deployed();
  //2. deploy auction house
  const auction = await auctionFac.deploy(signer.address, timelock.address);
  await auction.deployed();
  //3. deploy nft
  const nft = await nftFac.deploy(signer.address, auction.address);
  await nft.deployed();

  console.log({
    signer: signer.address,
    timelock: timelock.address,
    auction: auction.address,
    nft: nft.address,
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
