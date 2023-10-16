// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IToken} from "src/interfaces/IToken.sol";
import {MintInfo} from "src/interfaces/IFxGenArt721.sol";

/*//////////////////////////////////////////////////////////////////////////
                                  STRUCTS
//////////////////////////////////////////////////////////////////////////*/

/**
 * @notice Struct of tax information
 * @param gracePeriod Timestamp of period before token entering harberger taxation
 * @param foreclosureTime Timestamp of token foreclosure
 * @param currentPrice Current ether price of token
 * @param depositAmount Total amount of taxes deposited
 */
struct TaxInfo {
    uint48 gracePeriod;
    uint48 foreclosureTime;
    uint80 currentPrice;
    uint80 depositAmount;
}

/**
 * @title IFxMintTicket721
 * @author fx(hash)
 * @notice ERC-721 token for mint tickets used to redeem FxGenArt721 tokens
 */
interface IFxMintTicket721 is IToken {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when mint ticket is initialized
     * @param _genArt721 Address of FxGenArt721 token
     * @param _redeemer Address of TicketRedeemer contract
     * @param _gracePeriod Time period before token enters harberger taxation
     * @param _baseURI Base URI of the token metadata
     * @param _mintInfo Array of authorized minter contracts and their reserves
     */
    event TicketInitialized(
        address indexed _genArt721,
        address indexed _redeemer,
        uint48 indexed _gracePeriod,
        string _baseURI,
        MintInfo[] _mintInfo
    );

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

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when total minter allocation exceeds maximum supply
     */
    error AllocationExceeded();

    /**
     * @notice Error thrown when token is in foreclosure
     */
    error Foreclosure();

    /**
     * @notice Error thrown when token is being claimed within the grace period
     */
    error GracePeriodActive();

    /**
     * @notice Error thrown when deposit amount is not for at least one day
     */
    error InsufficientDeposit();

    /**
     * @notice Error thrown when payment amount does not meet price plus daily tax amount
     */
    error InsufficientPayment();

    /**
     * @notice Error thrown when reserve end time is invalid
     */
    error InvalidEndTime();

    /**
     * @notice Error thrown when new listing price is less than the mininmum amount
     */
    error InvalidPrice();

    /**
     * @notice Error thrown when reserve start time is invalid
     */
    error InvalidStartTime();

    /**
     * @notice Error thrown when minting is active
     */
    error MintActive();

    /**
     * @notice Error thrown when caller is not authorized to execute transaction
     */
    error NotAuthorized();

    /**
     * @notice Error thrown when caller does not have the specified role
     */
    error UnauthorizedAccount();

    /**
     * @notice Error thrown when caller does not have minter role
     */
    error UnauthorizedMinter();

    /**
     * @notice Error thrown when caller does not have the redeemer role
     */
    error UnauthorizedRedeemer();

    /**
     * @notice Error thrown when caller is not a registered minter
     */
    error UnregisteredMinter();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the list of active minters
     */
    function activeMinters(uint256) external view returns (address);

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
    function claim(uint256 _tokenId, uint80 _newPrice) external payable;

    /**
     * @notice Returns the address of the FxContractRegistry contract
     */
    function contractRegistry() external view returns (address);

    /**
     * @notice Deposits taxes for given token
     * @param _tokenId ID of the token
     */
    function deposit(uint256 _tokenId) external payable;

    /**
     * @notice Initializes new generative art project
     * @param _owner Address of contract owner
     * @param _genArt721 Address of GenArt721 token contract
     * @param _redeemer Address of TicketRedeemer minter contract
     * @param _gracePeriod Period time before token enters harberger taxation
     * @param _baseURI Base URI of the token metadata
     * @param _mintInfo Array of authorized minter contracts and their reserves
     */
    function initialize(
        address _owner,
        address _genArt721,
        address _redeemer,
        uint48 _gracePeriod,
        string calldata _baseURI,
        MintInfo[] calldata _mintInfo
    ) external;

    /**
     * @notice Checks if token is foreclosed
     * @param _tokenId ID of the token
     * @return Status of foreclosure
     */
    function isForeclosed(uint256 _tokenId) external view returns (bool);

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
    ) external pure returns (uint48);

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
     * @inheritdoc IToken
     */
    function mint(address _to, uint256 _amount, uint256 _payment) external;

    /**
     * @notice Returns the active status of a registered minter contract
     */
    function minters(address) external view returns (bool);

    /**
     * @notice Pauses all function executions where modifier is set
     */
    function pause() external;

    /**
     * @notice Returns the address of the TickeRedeemer contract
     */
    function redeemer() external view returns (address);

    /**
     * @notice Registers minter contracts with resereve info
     */
    function registerMinters(MintInfo[] calldata _mintInfo) external;

    /**
     * @notice Returns the address of the FxRoleRegistry contract
     */
    function roleRegistry() external view returns (address);

    /**
     * @notice Sets the new URI of the token metadata
     * @param _uri Base URI pointer of the metadata
     */
    function setBaseURI(string calldata _uri) external;

    /**
     * @notice Sets new price for given token
     * @param _tokenId ID of the token
     * @param _newPrice New price of the token
     */
    function setPrice(uint256 _tokenId, uint80 _newPrice) external;

    /**
     * @notice Mapping of ticket ID to tax information (grace period, foreclosure time, current price, deposit amount)
     */
    function taxes(uint256) external returns (uint48, uint48, uint80, uint80);

    /**
     * @notice Returns the current circulating supply of tokens
     */
    function totalSupply() external returns (uint48);

    /**
     * @notice Unpauses all function executions where modifier is set
     */
    function unpause() external;

    /**
     * @notice Withdraws available balance amount to given address
     * @param _to Address being withdrawn to
     */
    function withdraw(address _to) external;
}
