// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimelockedController is TimelockController {
    constructor(
        uint256 minDelay, // Minimum delay before an action can be executed
        address[] memory proposers, // Accounts allowed to propose
        address[] memory executors, // Accounts allowed to execute
        address admin // Initial admin address
    ) TimelockController(minDelay, proposers, executors, admin) {}
}
