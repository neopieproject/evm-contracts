require("@nomiclabs/hardhat-ethers");
const inquirer = require("inquirer");
const { PIE_CA, ONEO_CA } = require("./consts");

async function getContract() {
  return ethers.getContractAt("NeoPie", PIE_CA);
}

async function deploy() {
  const NeoPie = await ethers.getContractFactory("NeoPie");
  const res = await NeoPie.deploy(ONEO_CA);
  await res.waitForDeployment();
  console.log(`Deployed. Contract address is ${res.target}`);
}

async function setMinter(address) {
  const contract = await getContract();
  const res = await contract.setMinter(address);
  console.log(res);
}

async function status() {
  const contract = await getContract();
  // Fetch values from the contract
  const minter = await contract.minter();
  const totalSupply = await contract.totalSupply();
  const decimals = await contract.decimals();
  const name = await contract.name();
  const symbol = await contract.symbol();

  // Display the fetched information
  console.log("Contract Status:");
  console.log(`Minter: ${minter}`);
  console.log(`Total Supply: ${totalSupply.toString()}`);
  console.log(`Decimals: ${decimals}`);
  console.log(`Name: ${name}`);
  console.log(`Symbol: ${symbol}`);
}

async function main() {
  const answers = await inquirer.prompt([
    {
      type: "list",
      name: "action",
      message: "What do you want to do?",
      choices: [
        { name: "Status", value: "status" },
        { name: "Set the minter", value: "setMinter" },
        { name: "Deploy", value: "deploy" },
      ],
    },
  ]);

  switch (answers.action) {
    case "status":
      await status();
      break;

    case "setMinter":
      await setMinter(
        await inquirer.prompt([
          {
            type: "input",
            name: "minter",
            message: "Minter address:",
          },
        ]).minter
      );
      break;
    case "deploy":
      await deploy();
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