import { task } from "hardhat/config";
import { getExpectedContractAddress } from "../../utils/getExpectedContractAddress";

import {
  DrawDAONFT,
  DrawDAONFT__factory,
  DrawDAOGovernor,
  DrawDAOGovernor__factory,
  DrawDAOExecutor,
  DrawDAOExecutor__factory,
  // Box,
  // Box__factory,
} from "../../typechain-types";

task("deploy:dao").setAction(async (_, { ethers, run }) => {
  const timelockDelay = 2;
  const votingPeriod = 1800; // 5 mins
  const votingDelay = 5; // 1 mins
  const proposalThreshold = 1;
  const quorum = 2;
  // const devAddress = "0x08aD6ad5C0F56E54ef036BaDA81424872ea3C076";
  const devAddress = "0x4C06524B1bd7AA002747252257bBE0C472735A6D";
  // const nftFactory: TaladPluNFT__factory = await ethers.getContractFactory(
  //   "TaladPluNFT"
  // );
  const nftFactory: DrawDAONFT__factory = await ethers.getContractFactory(
    "DrawDAONFT"
  );

  //get signer
  const signerAddress = await nftFactory.signer.getAddress();
  const signer = await ethers.getSigner(signerAddress);

  //get the address for governor contract in next 2 nonces
  const timelockExpectedAddress = await getExpectedContractAddress(signer, 1);
  const governorExpectedAddress = await getExpectedContractAddress(signer, 2);

  const nft: DrawDAONFT = await nftFactory.deploy(
    signer.address,
    timelockExpectedAddress,
    devAddress
  );
  await nft.deployed();

  //deploy timelock and set the governor address to be admin of the timelock
  const timelockFactory: DrawDAOExecutor__factory =
    await ethers.getContractFactory("DrawDAOExecutor");
  const timelock: DrawDAOExecutor = await timelockFactory.deploy(
    governorExpectedAddress,
    timelockDelay
  );
  await timelock.deployed();

  //deploy governor
  //governor setting

  const governorFactory: DrawDAOGovernor__factory =
    await ethers.getContractFactory("DrawDAOGovernor");
  const governor: DrawDAOGovernor = await governorFactory.deploy(
    nft.address,
    timelock.address,
    votingDelay,
    votingPeriod,
    proposalThreshold
  );
  await governor.deployed();

  // const boxFactory: Box__factory = await ethers.getContractFactory("Box");
  // const box: Box = await boxFactory.deploy();
  // await box.deployed();

  console.log("Dao deployed to: ", {
    governorExpectedAddress,
    timelockExpectedAddress,
    governor: governor.address,
    timelock: timelock.address,
    nft: nft.address,
    // box: box.address,
  });

  // await box.transferOwnership(timelock.address);

  // console.log("Granted the timelock ownership of the Box");

  // await run("verify:verify", {
  //   address: nft.address,
  //   constructorArguments: [signer.address, timelockExpectedAddress, devAddress],
  // });

  // await run("verify:verify", {
  //   address: box.address,
  // });

  // await run("verify:verify", {
  //   address: timelock.address,
  //   contract: "contracts/Governance/ChickenSpinTimelock.sol:DrawDAOExecutor",
  //   constructorArguments: [governor.address, timelockDelay],
  // });

  // await run("verify:verify", {
  //   address: governor.address,
  //   contract: "contracts/Governance/ChickenSpinGovernor.sol:DrawDAOGovernor",
  //   constructorArguments: [
  //     nft.address,
  //     timelock.address,
  //     votingDelay,
  //     votingPeriod,
  //     proposalThreshold,
  //   ],
  // });
});

// Dao deployed to:  {
//   governorExpectedAddress: '0x2f4699feF25b8734F12f87C72af35b3D467e3e73',
//   timelockExpectedAddress: '0xA0116451393254Ca1A11910d98fa396D74367c5D',
//   governor: '0x2f4699feF25b8734F12f87C72af35b3D467e3e73',
//   timelock: '0xA0116451393254Ca1A11910d98fa396D74367c5D',
//   nft: '0x6312cDDeA6087316d034f34DefDa156ea6468C7f',
//   box: '0x9d5F8e34d2B6e0F8565d7848565B22Cc6B158Eb8'
// }

// Dao deployed to: KUBCHAIN TESTNET  {
//   governorExpectedAddress: '0xF8AE5905336D65Db832e30CBF3381C1e6800952c',
//   timelockExpectedAddress: '0x25Ce72DF1440988098710754653bE4A1de527E7E',
//   governor: '0xF8AE5905336D65Db832e30CBF3381C1e6800952c',
//   timelock: '0x25Ce72DF1440988098710754653bE4A1de527E7E',
//   nft: '0x6Cd542CbC2f6D84FbE9Df8f7A3F9cFBe685138DA'
// }
