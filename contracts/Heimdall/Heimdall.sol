// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

interface ISupportedTokens {
    function mint(address account, uint amount) external;

    function burn(address account, uint amount) external;
}

contract Heimdall is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{
    event Welcome(
        uint no,
        address neoTokenAddress,
        address evmTokenAddress,
        address receiver,
        uint amount
    );

    event GoodBye(
        uint no,
        address neoTokenAddress,
        address evmTokenAddress,
        address receiver,
        uint amount
    );

    event FeeChanged(address tokenAddress, uint amount);

    event MintNoUpdatedByAdmin(uint256 oldMintNo, uint256 newMintNo);

    event BurnNoUpdatedByAdmin(uint256 oldBurnNo, uint256 newBurnNo);

    struct Burn {
        uint256 no;
        address neoTokenAddress;
        address evmTokenAddress;
        address sender;
        address receiver;
        uint amount;
        uint createdAt;
        uint256 blockNo;
    }

    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint public mintNo;
    uint public burnNo;
    mapping(address => address) public NEOToEVM;
    mapping(address => address) public EVMToNEO;
    mapping(uint => bool) public MintMap;
    mapping(uint => Burn) public BurnMap;

    // Initializer function
    function initialize() public initializer {
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
    }

    // Address, amount and receiver for fees
    address public feeToken;
    uint public feeAmount;
    address public feeReceiver;

    // NEO to EVM
    function mint(
        uint no,
        address neoAddress,
        address receiver,
        uint amount
    ) public onlyOwner {
        require(!MintMap[no], "Transaction already processed: Mint locked.");
        address evmTokenAddress = getEVMTokenAddress(neoAddress);
        require(
            evmTokenAddress != address(0),
            "Invalid NEO token address: EVM token not found."
        );
        require(
            receiver != address(0),
            "Invalid receiver address: Cannot be zero."
        );
        require(amount > 0, "Invalid amount: Must be greater than zero.");

        MintMap[no] = true;
        mintNo++;

        ISupportedTokens(evmTokenAddress).mint(address(this), amount);
        IERC20Upgradeable(evmTokenAddress).transfer(receiver, amount);

        emit Welcome(no, neoAddress, evmTokenAddress, receiver, amount);
    }

    // EVM to NEO
    function burn(
        address evmTokenAddress,
        address receiver,
        uint amount
    ) public nonReentrant {
        address neoTokenAddress = getNEOTokenAddress(evmTokenAddress);
        require(
            neoTokenAddress != address(0),
            "Invalid EVM token address: NEO token not found."
        );
        require(
            receiver != address(0),
            "Invalid receiver address: Cannot be zero."
        );
        require(amount > 0, "Invalid amount: Must be greater than zero.");

        IERC20Upgradeable(evmTokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );

        IERC20Upgradeable(feeToken).transferFrom(
            msg.sender,
            feeReceiver,
            feeAmount
        );

        ISupportedTokens(evmTokenAddress).burn(address(this), amount);

        uint no = burnNo + 1;

        emit GoodBye(no, neoTokenAddress, evmTokenAddress, receiver, amount);

        BurnMap[no] = Burn({
            blockNo: block.number,
            no: no,
            neoTokenAddress: neoTokenAddress,
            evmTokenAddress: evmTokenAddress,
            sender: msg.sender,
            receiver: receiver,
            amount: amount,
            createdAt: block.timestamp
        });
        burnNo = no;
    }

    // Function to set a pair of token addresses
    function setTokenAddress(
        address addressOnNEO,
        address addressOnChain
    ) public onlyOwner {
        require(
            addressOnNEO != address(0),
            "Invalid NEO token address: Cannot be zero."
        );
        require(
            addressOnChain != address(0),
            "Invalid EVM token address: Cannot be zero."
        );

        NEOToEVM[addressOnNEO] = addressOnChain;
        EVMToNEO[addressOnChain] = addressOnNEO;
    }

    // Function to get the EVM token address
    function getEVMTokenAddress(
        address neoAddress
    ) public view returns (address) {
        return NEOToEVM[neoAddress];
    }

    // Function to get the NEO token address
    function getNEOTokenAddress(
        address evmATokenddress
    ) public view returns (address) {
        return EVMToNEO[evmATokenddress];
    }

    function isMinted(uint no) public view returns (bool) {
        return MintMap[no];
    }

    function getBurnDetail(uint no) public view returns (Burn memory) {
        return BurnMap[no];
    }

    // Function to set the fee token address
    function setFee(address tokenAddress, uint amount) public onlyOwner {
        require(
            tokenAddress != address(0),
            "Invalid fee token address: Cannot be zero."
        );
        require(amount >= 0, "Invalid fee amount: Must be non-negative.");
        feeToken = tokenAddress;
        feeAmount = amount;
        emit FeeChanged(tokenAddress, amount);
    }

    // ADMIN FUNCTIONS: Function to set the fee receiver
    function setFeeReceiver(address _address) public onlyOwner {
        require(
            _address != address(0),
            "Invalid fee receiver address: Cannot be zero."
        );
        feeReceiver = _address;
    }

    // ADMIN FUNCTIONS: Function to control mint no manually for incidents
    function setMintNo(uint no) public onlyOwner {
        emit MintNoUpdatedByAdmin(mintNo, no);
        mintNo = no;
    }

    // ADMIN FUNCTIONS: Function to control burn no manually for incidents
    function setBurnNo(uint no) public onlyOwner {
        emit BurnNoUpdatedByAdmin(burnNo, no);
        burnNo = no;
    }

    // ADMIN FUNCTIONS: Function to authorize contract upgrades
    function _authorizeUpgrade(address) internal virtual override onlyOwner {}
}
