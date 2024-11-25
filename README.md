# Neo Pie Solidify Contracts

This project contains smart contracts and scripts for the Neo Pie bridge, which
facilitates token transfers between the NEO and EVM-compatible blockchains.

## Contracts

- **Heimdall.sol**: Manages the bridging logic between NEO and EVM-compatible
  blockchains.
  - Verified:
    [0xF572Bf8447Dd9Cc5a1FB82E500051329764eb9bB](https://xexplorer.neo.org/address/0xF572Bf8447Dd9Cc5a1FB82E500051329764eb9bB?tab=contract)
- **ONEO.sol**: ERC20 token contract for ONEO token.
  - Verified:
    [0xb31b4934FFBb8A99e211CAAde052D1B051C2424e](https://xexplorer.neo.org/address/0xb31b4934FFBb8A99e211CAAde052D1B051C2424e?tab=contract)
- **PIE.sol**: ERC20 token contract for Neo Pie token.
  - Verified:
    [0x6Ac5a2c3A82Ae858d7C4A6a0dBe9e90e7a0b2794](https://xexplorer.neo.org/address/0x6Ac5a2c3A82Ae858d7C4A6a0dBe9e90e7a0b2794?tab=contract)

## Scripts

- **invoke-heimdall.js**: Script to interact with the Heimdall contract.
- **invoke-oneo.js**: Script to interact with the ONEO contract.
- **invoke-pie.js**: Script to interact with the Neo Pie contract.

## Setup

1. Clone the repository.
2. Install dependencies:
3. Create a .env file and add your environment variables:

PRIVATE_KEY=<your_private_key>

## V2

Working on the V2 branch for production after the Neo Grind
Hackathon. Until the V2 launch, all functionalities and deployments are
considered non-official.

## License

This project is licensed under the MIT License.
