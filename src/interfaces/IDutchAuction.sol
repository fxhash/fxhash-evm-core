// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @notice Struct to store the Dutch auction information
 * @param prices The array of prices for each step of the auction
 * @param refunded Flag indicating if refunds are enabled
 * @param stepLength The duration (in seconds) of each auction step
 */
struct AuctionInfo {
    uint248 stepLength;
    bool refunded;
    uint256[] prices;
}

/**
 * @notice Struct to store information about a minter
 * @param totalMints The total number of mints performed by the minter
 * @param totalPaid The total amount paid by the minter
 */
struct MinterInfo {
    uint128 totalMints;
    uint128 totalPaid;
}

/**
 * @notice Struct to store information about refunds
 * @param minterInfo Mapping of minter address to MinterInfo struct
 * @param lastPrice The price for the last sale before selling out
 */
struct RefundInfo {
    mapping(address minter => MinterInfo) minterInfo;
    uint256 lastPrice;
}

interface IDutchAuction is IMinter {
    /**
     * @notice Emitted when the mint details for a Dutch auction are set
     * @param _token The address of the token being minted
     * @param _reserveId The ID of the mint
     * @param _reserve The reserve info of the Dutch auction
     * @param _daInfo The Dutch auction info
     */
    event MintDetailsSet(address indexed _token, uint256 indexed _reserveId, ReserveInfo _reserve, AuctionInfo _daInfo);

    /**
     * @notice Emitted when a purchase is made in the Dutch auction
     * @param _token The address of the token being purchased
     * @param _reserveId The ID of the mint
     * @param _buyer The address of the buyer
     * @param _to The address where the purchased tokens will be sent
     * @param _amount The amount of tokens purchased
     * @param _price The price at which the tokens were purchased
     */
    event Purchase(
        address indexed _token,
        uint256 indexed _reserveId,
        address indexed _buyer,
        address _to,
        uint256 _amount,
        uint256 _price
    );

    /**
     * @notice Emitted when a refund is claimed by a buyer
     * @param _token The address of the token for which the refund is claimed
     * @param _reserveId The ID of the mint
     * @param _buyer The address of the buyer claiming the refund
     * @param _refundAmount The amount of refund claimed
     */
    event RefundClaimed(
        address indexed _token,
        uint256 indexed _reserveId,
        address indexed _buyer,
        uint256 _refundAmount
    );

    /**
     * @notice Emitted when the sale proceeds are withdrawn
     * @param _token The address of the token for which the sale proceeds are withdrawn
     * @param _reserveId The ID of the mint
     * @param _creator The address of the creator of the project
     * @param _proceeds The amount of sale proceeds withdrawn
     */
    event Withdrawn(address indexed _token, uint256 indexed _reserveId, address indexed _creator, uint256 _proceeds);

    /**
     * @notice Error thrown when an input address is zero
     */
    error AddressZero();

    /**
     * @notice Error thrown when the auction has already ended
     */
    error Ended();

    /**
     * @notice Error thrown when trying to send an amount of 0
     */
    error InsufficientFunds();

    /**
     * @notice Error thrown when the price is insufficient
     */
    error InsufficientPrice();

    /**
     * @notice Error thrown when the allocation is 0
     */
    error InvalidAllocation();

    /**
     * @notice Error thrown when the amount is 0
     */
    error InvalidAmount();

    /**
     * @notice Error thrown when the payment sent with purchase doesnt equal the required payment
     */
    error InvalidPayment();

    /**
     * @notice Error thrown when the price is 0
     */
    error InvalidPrice();
    /**
     * @notice Error thrown when the passing a price curve with less than 2 points
     */
    error InvalidPriceCurve();

    /**
     * @notice Error thrown when a reserve doesnt exist
     */
    error InvalidReserve();

    /**
     * @notice Error thrown when the step length passed doesn't divide auction duration isn't a
     * discrete number of steps
     */
    error InvalidStep();

    /**
     * @notice Error thrown when the token is address zero
     */
    error InvalidToken();

    /**
     * @notice Error thrown when the prices are out of order
     */
    error PricesOutOfOrder();

    /**
     * @notice Error thrown when there is no refund available
     */
    error NoRefund();

    /**
     * @notice Error thrown on function only callable after an auction ends
     */
    error NotEnded();

    /**
     * @notice Error thrown when the auction has not started
     */
    error NotStarted();

    /**
     * @notice Allows a buyer to purchase tokens in the Dutch auction
     * @param _token The address of the token being purchased
     * @param _reserveId The ID of the mint
     * @param _amount The amount of tokens to purchase
     * @param _to The address where the purchased tokens will be sent
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable;

    /**
     * @notice Allows a buyer to claim a refund for a Dutch Auction configured with a rebate
     * @param _reserveId The ID of the mint
     * @param _token The address of the token for which the refund is claimed
     * @param _who The address of the buyer claiming the refund
     */
    function refund(address _token, uint256 _reserveId, address _who) external;

    /**
     * @notice Allows the sale proceeds to be withdrawn to the primary sale receiver for a token
     * @param _reserveId The ID of the mint
     * @param _token The address of the token sold by the dutch auction
     */
    function withdraw(address _token, uint256 _reserveId) external;

    /**
     * @notice Retrieves the current price for a Dutch auction
     * @param _token The address of the token
     * @param _reserveId The ID of the mint
     * @return price The current price of the token
     */
    function getPrice(address _token, uint256 _reserveId) external view returns (uint256);

    /**
     * @notice Mapping to store the Dutch auction info for each token
     * @param _reserveId The ID of the mint
     * @param _token The address of the token
     */
    function auctionInfo(address _token, uint256 _reserveId) external view returns (uint248, bool);

    /**
     * @notice Mapping to store the Dutch auction info for each token
     * @param _reserveId The ID of the mint
     * @param _token The address of the token
     */
    function refundInfo(address _token, uint256 _reserveId) external view returns (uint256);

    /**
     * @notice Retrieves the reserve info for a token
     * @param _token The address of the token
     * @param _reserveId The ID of the mint
     * @return allocation The allocation of the token in the reserve
     * @return reservePrice The reserve price of the token
     * @return maxMint The maximum number of tokens that can be minted in the Dutch auction
     */
    function reserves(address _token, uint256 _reserveId) external view returns (uint64, uint64, uint128);

    /**
     * @notice Retrieves the sale proceeds for a token
     * @param _token The address of the token
     * @param _reserveId The ID of the mint
     * @return The amount of sale proceeds withdrawn
     */
    function saleProceeds(address _token, uint256 _reserveId) external view returns (uint256);
}
