const { ethers } = require("hardhat");
const inquirer = require("inquirer");
const { HEIMDALL_CA, N3_NEO_CA, ONEO_CA, PIE_CA } = require("./consts");

async function deploy() {
  const contract = await ethers.getContractFactory("Heimdall");
  console.log(`Deploying Heimdall...`);
  const res = await upgrades.deployProxy(contract, [], {
    initializer: "initialize",
    kind: "uups",
  });
  await res.waitForDeployment();
  console.log(res.target);
}

async function update() {
  const res = await upgrades.upgradeProxy(
    HEIMDALL_CA,
    await ethers.getContractFactory("Heimdall")
  );
  await res.waitForDeployment();
  console.log("Contract updated");
}

async function getContract() {
  return await ethers.getContractAt("Heimdall", HEIMDALL_CA);
}

async function status() {
  const contract = await getContract();
  const feeTokenAddress = await contract.feeToken();
  const feeAmount = await contract.feeAmount();
  const feeReceiver = await contract.feeReceiver();

  // Display the fetched information
  console.log("Contract Status:");
  console.log(`Fee Token Address: ${feeTokenAddress}`);
  console.log(`Fee Amount: ${feeAmount}`);
  console.log(`Fee Receiver: ${feeReceiver}`);
}

async function setPair() {
  const contract = await getContract();
  const res = await contract.setTokenAddress(
    N3_NEO_CA, // N3
    ONEO_CA // EVM
  );
  console.log(res);
}

async function setFee() {
  const contract = await getContract();
  const res = await contract.setFee(PIE_CA, 0);
  console.log(res);
}

async function setFeeReceiver() {
  const contract = await getContract();
  [owner] = await ethers.getSigners();
  const res = await contract.setFeeReceiver(owner);
  console.log(res);
}

async function main() {
  const actions = await inquirer.prompt([
    {
      type: "list",
      name: "action",
      message: "What do you want to do?",
      choices: [
        { name: "Status", value: "status" },
        { name: "Set Pair", value: "setPair" },
        { name: "Set Fee", value: "setFee" },
        { name: "Set Fee Receiver", value: "setFeeReceiver" },
        { name: "Update Contract", value: "update" },
        { name: "Deploy Contract", value: "deploy" },
      ],
    },
  ]);

  switch (actions.action) {
    case "deploy":
      await deploy();
      break;
    case "update":
      await update();
      break;
    case "status":
      await status();
      break;
    case "setPair":
      await setPair();
      break;
    case "setFee":
      await setFee();
      break;
    case "setFeeReceiver":
      await setFeeReceiver();
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
