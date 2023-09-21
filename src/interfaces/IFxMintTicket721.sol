// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct TaxInfo {
    uint128 gracePeriod; // uint256
    uint128 foreclosureTime; // uint64
    uint128 currentPrice; // uint96
    uint128 depositAmount; // uint96
}

interface IFxMintTicket721 {
    event TicketInitialized(address indexed _owner, address indexed _genArt721);
    event Deposited(
        uint256 indexed _tokenId,
        address indexed _depositer,
        uint256 indexed _amount,
        uint256 newForeclosure
    );

    error Foreclosure();
    error GracePeriodActive();
    error InsufficientDeposit();
    error InsufficientPayment();
    error InvalidDuration();
    error InvalidPrice();
    error NotAuthorized();
    error TransferFailed();
    error UnauthorizedAccount();
    error UnregisteredMinter();

    function burn(uint256 _tokenId) external;

    function claim(uint256 _tokenId, uint128 _newPrice) external payable;

    function initialize(address _genArt721, address _owner, uint48 _gracePeriod) external;

    function isForeclosed(uint256 _tokenId) external view returns (bool);

    function isMinter(address _minter) external view returns (bool);

    function mint(address _to, uint256 _amount) external payable;

    function deposit(uint256 _tokenId) external payable;

    function setBaseURI(string calldata _uri) external;

    function setPrice(uint256 _tokenId, uint128 _newPrice) external;

    function totalSupply() external returns (uint48);

    function withdraw(address _to) external;
}
