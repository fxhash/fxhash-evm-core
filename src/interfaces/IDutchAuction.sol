// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IFxMinter} from "src/interfaces/IFxMinter.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @notice Struct to store the Dutch auction information.
 * @param prices The array of prices for each step of the auction.
 * @param stepLength The duration (in seconds) of each auction step.
 * @param refunded Flag indicating if refunds are enabled.
 */
struct AuctionInfo {
    uint248 stepLength;
    bool refunded;
    uint256[] prices;
}

struct MinterInfo {
    uint128 totalMints;
    uint128 totalPaid;
}

struct RefundInfo {
    mapping(address minter => MinterInfo) minterInfo;
    uint256 lastPrice;
}

interface IDutchAuction is IFxMinter {
    /**
     * @notice Emitted when the mint details for a Dutch auction are set
     * @param token The address of the token being minted
     * @param reserveId The ID of the mint
     * @param reserve The reserve info of the Dutch auction
     * @param daInfo The Dutch auction info
     */
    event MintDetailsSet(address indexed token, uint256 indexed reserveId, ReserveInfo reserve, AuctionInfo daInfo);

    /**
     * @notice Emitted when a purchase is made in the Dutch auction
     * @param token The address of the token being purchased
     * @param reserveId The ID of the mint
     * @param buyer The address of the buyer
     * @param to The address where the purchased tokens will be sent
     * @param amount The amount of tokens purchased
     * @param price The price at which the tokens were purchased
     */
    event Purchase(
        address indexed token,
        uint256 indexed reserveId,
        address indexed buyer,
        address to,
        uint256 amount,
        uint256 price
    );

    /**
     * @notice Emitted when a refund is claimed by a buyer
     * @param token The address of the token for which the refund is claimed
     * @param reserveId The ID of the mint
     * @param buyer The address of the buyer claiming the refund
     * @param refundAmount The amount of refund claimed
     */
    event RefundClaimed(address indexed token, uint256 indexed reserveId, address indexed buyer, uint256 refundAmount);

    /**
     * @notice Emitted when the sale proceeds are withdrawn
     * @param token The address of the token for which the sale proceeds are withdrawn
     * @param reserveId The ID of the mint
     * @param creator The address of the creator of the project
     * @param proceeds The amount of sale proceeds withdrawn
     */
    event Withdrawn(address indexed token, uint256 indexed reserveId, address indexed creator, uint256 proceeds);

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
     * @notice Error thrown when a buyer requets to buy more than the remaining allocation
     */
    error TooMany();

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
