// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct TaxInfo {
    uint64 currentPrice;
    uint64 foreclosure;
    uint128 depositAmount;
}

interface IFxMintTicket721 {
    event TicketInitialized(address indexed _owner, address indexed _genArt721);

    error Foreclosure();
    error GracePeriodActive();
    error InsufficientPayment();
    error InvalidDuration();
    error InvalidPrice();
    error NotAuthorized();
    error TransferFailed();
    error UnregisteredMinter();

    function burn(uint256 _tokenId) external;

    function claim(uint256 _tokenId, uint64 _newPrice, uint64 _days) external payable;

    function getCurrentPrice(uint256 _tokenId) external view returns (uint256);

    function initialize(address _genArt721, address _owner, uint48 _gracePeriod) external;

    function isForeclosed(uint256 _tokenId) external view returns (bool);

    function isMinter(address _minter) external view returns (bool);

    function mint(address _to, uint256 _amount) external payable;

    function deposit(uint256 _tokenId) external payable;

    function setBaseURI(string calldata _uri) external;

    function setPrice(uint256 _tokenId, uint64 _newPrice, uint64 _days) external payable;

    function totalSupply() external returns (uint48);

    function withdraw(address _to) external;
}
