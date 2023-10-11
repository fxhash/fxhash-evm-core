// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @title IFixedPrice
 * @notice Minter contract for purchasing tokens at a fixed price
 */
interface IFixedPrice is IMinter {
    /**
     * @notice Emitted when a new fixed price mint is added
     * @param token The address of the token being minted
     * @param reserveId The ID of the reserve
     * @param price The fixed price for the mint
     * @param reserve The reserve information for the mint
     * @param openEdition The status of an open edition mint
     */
    event MintDetailsSet(
        address indexed token,
        uint256 indexed reserveId,
        uint256 price,
        ReserveInfo reserve,
        bool openEdition
    );

    /**
     * @notice Emitted when a purchase is made
     * @param token The address of the token being purchased
     * @param reserveId The ID of the mint
     * @param buyer The address to purchasing the tokens
     * @param amount The amount of tokens being purchased
     * @param to The address to which the tokens are being transferred
     * @param price The price of the purchase
     */
    event Purchase(
        address indexed token,
        uint256 indexed reserveId,
        address indexed buyer,
        uint256 amount,
        address to,
        uint256 price
    );

    /**
     * @notice Emitted when proceeds are withdrawn
     * @param token The address of the token
     * @param creator The address of the creator of the project
     * @param proceeds The amount of proceeds being withdrawn
     */
    event Withdrawn(address indexed token, address indexed creator, uint256 proceeds);

    /// @notice Thrown when *to* address is the zero address
    error AddressZero();

    /// @notice Thrown when the sale has already ended
    error Ended();

    /// @notice Thrown when there is no funds from a sale to withdraw
    error InsufficientFunds();

    /// @notice Thrown when the allocation is zero
    error InvalidAllocation();

    /// @notice Thrown when payment doesn't equal price
    error InvalidPayment();

    /// @notice Thrown when an invalid price is provided
    error InvalidPrice();

    /// @notice Thrown when invalid times are provided for reserve
    error InvalidTimes();

    /// @notice Thrown when an invalid token address is provided
    error InvalidToken();

    /// @notice Error thrown when a reserve doesnt exist
    error InvalidReserve();

    /// @notice Thrown when the sale has not started
    error NotStarted();

    /// @notice Thrown when amount purchased exceeds remaining allocation
    error TooMany();

    /**
     * @notice Buys tokens by sending payment to the contract
     * @param _token The address of the token to buy
     * @param _reserveId The mint ID of the reserve for the token
     * @param _amount The number of tokens to buy
     * @param _to The address to receive the tokens
     */
    function buy(address _token, uint256 _reserveId, uint256 _amount, address _to) external payable;

    /**
     * @notice Withdraws the sale proceeds to the sale receiver
     * @param _token The address of the token to withdraw proceeds for
     */
    function withdraw(address _token) external;

    /// @notice Returns the price of a token for a reserveId
    function prices(address _token, uint256 _reserveId) external view returns (uint256);

    /// @notice Returns the reserve of a token for a reserveId
    function reserves(address _token, uint256 _reserveId) external view returns (uint64, uint64, uint128);

    /// @notice Returns the amount of saleProceeds of a token
    function saleProceeds(address _token) external view returns (uint256);
}
