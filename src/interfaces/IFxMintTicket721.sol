// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct TaxInfo {
    uint128 gracePeriod; // uint256
    uint128 foreclosureTime; // uint64
    uint128 currentPrice; // uint96
    uint128 depositAmount; // uint96
}

interface IFxMintTicket721 {
    event TicketInitialized(address indexed _genArt721, uint48 indexed _gracePeriod);
    event Claimed(
        uint256 indexed _tokenId,
        address indexed _claimer,
        uint128 indexed _newPrice,
        uint256 _payment
    );
    event Deposited(
        uint256 indexed _tokenId,
        address indexed _depositer,
        uint256 indexed _amount,
        uint256 _newForeclosure
    );
    event SetPrice(uint256 indexed _tokenId, address indexed _owner, uint128 indexed _newPrice);
    event Withdraw(address indexed _caller, address indexed _to, uint256 indexed _balance);

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

    function baseURI() external view returns (string memory);

    function burn(uint256 _tokenId, address _operator) external;

    function claim(uint256 _tokenId, uint128 _newPrice) external payable;

    function initialize(address _owner, address _genArt721, uint48 _gracePeriod) external;

    function isForeclosed(uint256 _tokenId) external view returns (bool);

    function isMinter(address _minter) external view returns (bool);

    function getAuctionPrice(uint256 _currentPrice, uint256 _foreclosureTime)
        external
        view
        returns (uint256);

    function getDailyTax(uint256 _currentPrice) external pure returns (uint256);

    function getExcessTax(uint256 _totalDeposit, uint256 _dailyTax)
        external
        pure
        returns (uint256);

    function getForeclosureTime(uint256 _dailyTax, uint256 _foreclosureTime, uint256 _taxPayment)
        external
        pure
        returns (uint128);

    function getRemainingDeposit(
        uint256 _dailyTax,
        uint256 _foreclosureTime,
        uint256 _depositAmount
    ) external view returns (uint256);

    function getTaxDuration(uint256 _taxPayment, uint256 _dailyTax)
        external
        pure
        returns (uint256);

    function mint(address _to, uint256 _amount, uint256 _payment) external;

    function deposit(uint256 _tokenId) external payable;

    function setBaseURI(string calldata _uri) external;

    function setPrice(uint256 _tokenId, uint128 _newPrice) external;

    function taxes(uint256) external returns (uint128, uint128, uint128, uint128);

    function totalSupply() external returns (uint48);

    function withdraw(address _to) external;
}
