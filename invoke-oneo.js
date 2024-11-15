const { ethers } = require("hardhat");
const inquirer = require("inquirer");
const { PIE_CA, ONEO_CA, HEIMDALL_CA } = require("./consts");

async function getContract() {
  return await ethers.getContractAt("ONEO", ONEO_CA);
}

async function deploy() {
  console.log(`Deploying ONEO`);
  const ONEO = await ethers.getContractFactory("ONEO");
  [owner] = await ethers.getSigners();
  const res = await ONEO.deploy(HEIMDALL_CA);
  await res.waitForDeployment();
  console.log(res.target);
}

async function status() {
  const contract = await getContract();
  [owner] = await ethers.getSigners();
  // Fetch values from the contract
  const minter = await contract.minter();
  const totalSupply = await contract.totalSupply();
  const decimals = await contract.decimals();
  const name = await contract.name();
  const symbol = await contract.symbol();
  const rewardTokenAddress = await contract.rewardTokenAddress();
  const rewardsPerBlock = await contract.rewardsPerBlock();
  const lastBlock = await contract.lastBlock();
  const claimable = await contract.claimable(owner.address);

  // Display the fetched information
  console.log("Contract Status:");
  console.log(`Total Supply: ${totalSupply.toString()}`);
  console.log(`Decimals: ${decimals}`);
  console.log(`Name: ${name}`);
  console.log(`Symbol: ${symbol}`);
  console.log(`Minter: ${minter}`);
  console.log(`Reward Token Address: ${rewardTokenAddress}`);
  console.log(`Rewards Per Block: ${rewardsPerBlock}`);
  console.log(`Last block for rewards claim: ${lastBlock}`);
  console.log(`Rewards claimable for ${owner.address}: ${claimable}`);
}

async function userStatus(_address) {
  const contract = await getContract();
  // Fetch values from the contract
  const claimable = await contract.getClaimable(_address);

  // Display the fetched information
  console.log("User Status:");
  console.log(`Rewards claimable: ${claimable}`);
}

async function setRewards() {
  const contract = await getContract();
  const res1 = await contract.setRewardsPerBlock(100000000); // 0.1
  const res2 = await contract.setRewardTokenAddress(PIE_CA);
  console.log(res1);
  console.log(res2);
}

async function setMinter() {
  const contract = await getContract();
  [owner] = await ethers.getSigners();
  const res = await contract.setMinter(HEIMDALL_CA);
  console.log(res);
}

async function main() {
  const answers = await inquirer.prompt([
    {
      type: "list",
      name: "action",
      message: "What do you want to do?",
      choices: [
        { name: "Status", value: "status" },
        { name: "User Status", value: "userStatus" },
        { name: "Set Minter", value: "setMinter" },
        { name: "Set Rewards", value: "setRewards" },
        { name: "Deploy", value: "deploy" },
      ],
    },
  ]);

  switch (answers.action) {
    case "deploy":
      await deploy();
      break;
    case "status":
      await status();
      break;
    case "setMinter":
      await setMinter();
      break;
    case "setRewards":
      await setRewards();
      break;
    case "userStatus":
      await userStatus(
        await inquirer.prompt([
          {
            type: "input",
            name: "address",
            message: "Address:",
          },
        ]).address
      );
      break;
    default:
      console.log("Action not recognized");
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
