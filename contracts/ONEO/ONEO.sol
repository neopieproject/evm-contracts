// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface NEOPIE {
    function mint(address account, uint amount) external;
}

contract ONEO is ERC20, Ownable, ReentrancyGuard, Pausable {
    using Address for address;

    event MinterChanged(address indexed newMinter);
    event TokenMinted(address indexed to, uint256 amount);
    event TokenBurned(address indexed from, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    // Mapping for keeping track of each address's reward debt
    mapping(address => uint) public RewardDebtMap;

    // Mapping for keeping track of each address's claimable amount
    mapping(address => uint) public ClaimAbleMap;

    address public minter;

    address public rewardTokenAddress;

    // Amount of rewards per block
    uint public rewardsPerBlock = 1;

    // Last block number where rewards were accumulated
    uint public lastBlock = 0;

    // Accumulated rewards per token
    uint private accumulatedRewardsPerToken = 0;

    // Precision factor to avoid rounding errors
    uint private REWARDS_PRECISION = 1e12;

    constructor(address _minter) ERC20("Oh! NEO", "ONEO") {
        minter = _minter;
        lastBlock = block.number;
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    // Function to mint tokens, only accessible by the minter
    function mint(address to, uint256 amount) public {
        require(msg.sender == minter, "No authority to mint");
        deposit(to, balanceOf(to), amount);
        _mint(to, amount);
        emit TokenMinted(to, amount);
    }

    // Function to burn tokens, only accessible by the minter (Bridge)
    function burn(address from, uint256 amount) public {
        require(msg.sender == minter, "No authority to burn");
        withdraw(from, balanceOf(from), amount);
        _burn(from, amount);
        emit TokenBurned(from, amount);
    }

    // Function for users to claim their rewards
    function claim() public whenNotPaused nonReentrant {
        address sender = msg.sender;
        uint bal = balanceOf(sender);

        harvest(sender, bal);

        uint claimableAmount = ClaimAbleMap[sender];
        require(claimableAmount > 0, "No amount to claim.");
        ClaimAbleMap[sender] = 0;

        NEOPIE(rewardTokenAddress).mint(sender, claimableAmount);
        // require(sent, "Reward Transfer failed");

        emit RewardClaimed(sender, claimableAmount);

        RewardDebtMap[sender] =
            (bal * accumulatedRewardsPerToken) /
            REWARDS_PRECISION;
    }

    // Override the transfer function to update reward details for sender and recipient
    function transfer(
        address recipient,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        address sender = msg.sender;
        uint senderBal = balanceOf(sender);
        uint receiverBal = balanceOf(recipient);
        bool isTransffered = super.transfer(recipient, amount);
        if (isTransffered) {
            if (sender != recipient) {
                deposit(recipient, receiverBal, amount);
                withdraw(sender, senderBal, amount);
            }
        }
        return isTransffered;
    }

    // Override the transferFrom function to update reward details for sender and recipient
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override whenNotPaused returns (bool) {
        uint senderBal = balanceOf(sender);
        uint receiverBal = balanceOf(recipient);
        bool isTransffered = super.transferFrom(sender, recipient, amount);
        if (isTransffered) {
            if (sender != recipient) {
                deposit(recipient, receiverBal, amount);
                withdraw(sender, senderBal, amount);
            }
        }
        return isTransffered;
    }

    // Private function to update user's reward details when tokens are deposited
    function deposit(address account, uint bal, uint amount) private {
        harvest(account, bal);

        RewardDebtMap[account] =
            ((bal + amount) * accumulatedRewardsPerToken) /
            REWARDS_PRECISION;
    }

    // Private function to update user's reward details when tokens are withdrawn
    function withdraw(address account, uint bal, uint amount) private {
        harvest(account, bal);

        RewardDebtMap[account] =
            ((bal - amount) * accumulatedRewardsPerToken) /
            REWARDS_PRECISION;
    }

    // Private function to calculate the rewards to harvest
    function harvest(address account, uint bal) private {
        updateRewards();

        if (bal > 0) {
            uint rewards = (bal * accumulatedRewardsPerToken) /
                REWARDS_PRECISION;
            uint rewardsToHarvest = rewards - RewardDebtMap[account];

            ClaimAbleMap[account] = ClaimAbleMap[account] + rewardsToHarvest;
        }
    }

    // Private function to update the accumulated rewards per token
    function updateRewards() private {
        uint totalSupply = totalSupply();
        if (totalSupply == 0) {
            lastBlock = block.number;
        } else {
            uint newBlocks = block.number - lastBlock;
            if (newBlocks > 0) {
                uint rewards = newBlocks * rewardsPerBlock;
                accumulatedRewardsPerToken =
                    accumulatedRewardsPerToken +
                    ((rewards * REWARDS_PRECISION) / totalSupply);
                lastBlock = block.number;
            }
        }
    }

    function claimable(address _address) public view returns (uint) {
        uint rewards = (block.number - lastBlock) * rewardsPerBlock;
        uint _accumulatedRewardsPerToken = accumulatedRewardsPerToken +
            ((rewards * REWARDS_PRECISION) / totalSupply());

        uint rewardsToClaim = ((balanceOf(_address) *
            _accumulatedRewardsPerToken) / REWARDS_PRECISION) -
            RewardDebtMap[_address];

        return rewardsToClaim + ClaimAbleMap[_address];
    }

    function setRewardsPerBlock(uint perBlock) external onlyOwner {
        updateRewards();
        rewardsPerBlock = perBlock;
    }

    function setRewardTokenAddress(
        address _rewardTokenAddress
    ) external onlyOwner {
        require(_rewardTokenAddress.isContract(), "Invalid contract address");
        rewardTokenAddress = _rewardTokenAddress;
    }

    function setMinter(address newMinter) external onlyOwner {
        require(newMinter != address(0), "Minter cannot be the zero address");
        minter = newMinter;
        emit MinterChanged(newMinter);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
