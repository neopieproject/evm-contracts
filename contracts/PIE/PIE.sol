// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NeoPie is ERC20, Ownable {
    address public minter;

    constructor(address _minter) ERC20("Neo Pie", "PIE") {
        minter = _minter;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function mint(address account, uint256 amount) public {
        require(minter == msg.sender, "Not authorized");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        require(account == msg.sender, "Not authorized");
        _burn(account, amount);
    }
}
