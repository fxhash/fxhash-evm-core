// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @param gracePeriod Timestamp of period before token entering harberger taxation
 * @param foreclosureTime Timestamp of token foreclosure
 * @param currentPrice Current ether price of token
 * @param depositAmount Total amount of taxes deposited
 */
struct TaxInfo {
    uint128 gracePeriod; // uint256
    uint128 foreclosureTime; // uint64
    uint128 currentPrice; // uint96
    uint128 depositAmount; // uint96
}

/**
 * @title IFxMintTicket721
 * @notice ERC-721 proxy token for Gen Art mint tickets
 */
interface IFxMintTicket721 {
    /**
     * @notice Event emitted when mint ticket is initialized
     * @param _genArt721 Address of FxGenArt721 token
     * @param _gracePeriod Period of time before token enters harberger taxation
     */
    event TicketInitialized(address indexed _genArt721, uint48 indexed _gracePeriod);

    /**
     * @notice Event emitted when token is claimed at either listing or auction price
     * @param _tokenId ID of the token
     * @param _claimer Address of the token claimer
     * @param _newPrice New listing price of token
     * @param _payment Current price of token in addition to taxes deposited
     */
    event Claimed(uint256 indexed _tokenId, address indexed _claimer, uint128 indexed _newPrice, uint256 _payment);

    /**
     * @notice Event emitted when additional taxes are deposited
     * @param _tokenId ID of the token
     * @param _depositer Address of tax depositer
     * @param _amount Total amount of taxes deposited
     * @param _newForeclosure Timestmap of new foreclosure date
     */
    event Deposited(
        uint256 indexed _tokenId,
        address indexed _depositer,
        uint256 indexed _amount,
        uint256 _newForeclosure
    );

    /**
     * @notice Event emitted when new listing price is set
     * @param _tokenId ID of the token
     * @param _newPrice New listing price of token
     * @param _newForeclosure Timestmap of new foreclosure date
     * @param _depositAmount Adjusted amount of taxes deposited due to price change
     */
    event SetPrice(
        uint256 indexed _tokenId,
        uint128 indexed _newPrice,
        uint128 indexed _newForeclosure,
        uint128 _depositAmount
    );

    /**
     * @notice Event emitted when balance is withdrawn
     * @param _caller Address of caller
     * @param _to Address receiving balance amount
     * @param _balance Amount of ether being withdrawn
     */
    event Withdraw(address indexed _caller, address indexed _to, uint256 indexed _balance);

    /// @notice Error thrown when token is in foreclosure
    error Foreclosure();

    /// @notice Error thrown when token is being claimed within the grace period
    error GracePeriodActive();

    /// @notice Error thrown when deposit amount is not for at least one day
    error InsufficientDeposit();

    /// @notice Error thrown when payment amount does not meet price plus daily tax amount
    error InsufficientPayment();

    /// @notice Error thrown when new listing price is less than the mininmum amount
    error InvalidPrice();

    /// @notice Error thrown when caller is not authorized to execute transaction
    error NotAuthorized();

    /// @notice Error thrown when caller does not have the specified role
    error UnauthorizedAccount();

    /// @notice Error thrown when caller is not a registered minter
    error UnregisteredMinter();

    /**
     * @notice Mapping of wallet address to balance amount available for withdrawal
     */
    function balances(address) external view returns (uint256);

    /**
     * @notice Returns the URI of the token metadata
     */
    function baseURI() external view returns (string memory);

    /**
     * @notice Burns token ID from the circulating supply
     * @param _tokenId ID of the token
     */
    function burn(uint256 _tokenId) external;

    /**
     * @notice Claims token at current price and sets new price of token with initial deposit amount
     * @param _tokenId ID of the token
     * @param _newPrice New listing price of token
     */
    function claim(uint256 _tokenId, uint128 _newPrice) external payable;

    /**
     * @notice Deposits taxes for given token
     * @param _tokenId ID of the token
     */
    function deposit(uint256 _tokenId) external payable;

    /**
     * @notice Initializes new generative art project
     * @param _owner Address of contract owner
     * @param _genArt721 Address of GenArt721 token contract
     * @param _gracePeriod Period time before token enters harberger taxation
     * @param _baseURI Base URI of the token metadata
     */
    function initialize(address _owner, address _genArt721, uint48 _gracePeriod, string calldata _baseURI) external;

    /**
     * @notice Checks if token is foreclosed
     * @param _tokenId ID of the token
     * @return Status of foreclosure
     */
    function isForeclosed(uint256 _tokenId) external view returns (bool);

    /**
     * @notice Checks if the specified minter is authorized to perform the action
     * @param _minter Address of the minter contract
     * @return Status of authorization
     */
    function isMinter(address _minter) external view returns (bool);

    /**
     * @notice Returns address of the FxGenArt721 token contract
     */
    function genArt721() external view returns (address);

    /**
     * @notice Gets the current auction price of the token
     * @param _currentPrice Listing price of the token
     * @param _foreclosureTime Timestamp of the foreclosure
     */
    function getAuctionPrice(uint256 _currentPrice, uint256 _foreclosureTime) external view returns (uint256);

    /**
     * @notice Gets the daily tax amount based on current price
     * @param _currentPrice Current listing price
     * @return Daily tax amount
     */
    function getDailyTax(uint256 _currentPrice) external pure returns (uint256);

    /**
     * @notice Gets the excess amount of taxes paid
     * @param _totalDeposit Total amount of taxes deposited
     * @param _dailyTax Daily tax amount based on current price
     * @return Excess amount of taxes
     */
    function getExcessTax(uint256 _totalDeposit, uint256 _dailyTax) external pure returns (uint256);

    /**
     * @notice Gets the new foreclosure timestamp
     * @param _dailyTax Daily tax amount based on current price
     * @param _foreclosureTime Timestamp of current foreclosure
     * @param _taxPayment Amount of taxes being deposited
     * @return Timestamp of new foreclosure
     */
    function getForeclosureTime(
        uint256 _dailyTax,
        uint256 _foreclosureTime,
        uint256 _taxPayment
    ) external pure returns (uint128);

    /**
     * @notice Gets the remaining amount of taxes to be deposited
     * @param _dailyTax Daily tax amount based on current price
     * @param _foreclosureTime Timestamp of current foreclosure
     * @param _depositAmount Total amount of taxes deposited
     * @return Remainig deposit amount
     */
    function getRemainingDeposit(
        uint256 _dailyTax,
        uint256 _foreclosureTime,
        uint256 _depositAmount
    ) external view returns (uint256);

    /**
     * @notice Gets the total duration of time covered
     * @param _taxPayment Amount of taxes being deposited
     * @param _dailyTax Daily tax amount based on current price
     * @return Total time duration
     */
    function getTaxDuration(uint256 _taxPayment, uint256 _dailyTax) external pure returns (uint256);

    /**
     * @notice Returns default grace period of time for each token
     */
    function gracePeriod() external view returns (uint48);

    /**
     * @notice Allows any minter contract to mint an arbitrary amount of tokens to a given account
     * @param _to Address being minted to
     * @param _amount Amount of tokens being minted
     * @param _payment Payment amount of transaction
     */
    function mint(address _to, uint256 _amount, uint256 _payment) external;

    /**
     * @notice Pauses all function executions where modifier is applied
     */
    function pause() external;

    /**
     * @notice Unpauses all function executions where modifier is applied
     */
    function unpause() external;

    /**
     * @notice Sets the new URI of the token metadata
     * @param _uri Pointer of the metadata
     */
    function setBaseURI(string calldata _uri) external;

    /**
     * @notice Sets new price for given token
     * @param _tokenId ID of the token
     * @param _newPrice New ether price of the token
     */
    function setPrice(uint256 _tokenId, uint128 _newPrice) external;

    /**
     * @notice Mapping of ticket ID to tax information
     */
    function taxes(uint256) external returns (uint128, uint128, uint128, uint128);

    /**
     * @notice Returns the current total supply of tokens
     */
    function totalSupply() external returns (uint48);

    /**
     * @notice Withdraws available balance amount to given address
     * @param _to Address being withdrawn to
     */
    function withdraw(address _to) external;
}
