// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMinter} from "src/interfaces/IMinter.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

interface IFixedPrice is IMinter {
    /**
     * @dev Emitted when a new fixed price mint is added.
     * @param token The address of the token being minted.
     * @param price The fixed price for the mint.
     * @param reserve The reserve information for the mint.
     */
    event FixedPriceMintDetails(address indexed token, uint256 price, ReserveInfo reserve);

    /**
     * @dev Emitted when a purchase is made.
     * @param token The address of the token being purchased.
     * @param mintId The ID of the mint.
     * @param amount The amount of tokens being purchased.
     * @param to The address to which the tokens are being transferred.
     * @param price The price of the purchase.
     */
    event Purchase(
        address indexed token,
        uint256 indexed mintId,
        uint256 amount,
        address indexed to,
        uint256 price
    );

    /**
     * @dev Emitted when proceeds are withdrawn.
     * @param token The address of the token.
     * @param proceeds The amount of proceeds being withdrawn.
     */
    event Withdrawn(address indexed token, uint256 proceeds);

    /// @dev Thrown when *to* address is the zero address
    error AddressZero();

    /// @dev Thrown when the sale has already ended
    error Ended();

    /// @dev Thrown when there is no funds from a sale to withdraw
    error InsufficientFunds();

    /// @dev Thrown when the allocation is zero
    error InvalidAllocation();

    /// @dev Thrown when payment doesn't equal price
    error InvalidPayment();

    /// @dev Thrown when an invalid price is provided
    error InvalidPrice();

    /// @dev Thrown when invalid times are provided for reserve
    error InvalidTimes();

    /// @dev Thrown when an invalid token address is provided
    error InvalidToken();

    /// @dev Thrown when the sale has not started
    error NotStarted();

    /// @dev Thrown when amount purchased exceeds remaining allocation
    error TooMany();

    /**
     * @dev Buys tokens by sending payment to the contract
     * @param _token The address of the token to buy
     * @param _mintId The mint ID of the reserve for the token
     * @param _amount The number of tokens to buy
     * @param _to The address to receive the tokens
     */
    function buy(address _token, uint256 _mintId, uint256 _amount, address _to) external payable;

    /**
     * @dev Withdraws the sale proceeds to the sale receiver
     * @param _token The address of the token to withdraw proceeds for
     */
    function withdraw(address _token) external;

    /// @notice Returns the price of a token for a mintId
    function prices(address _token, uint256 _mintId) external view returns (uint256);

    /// @notice Returns the reserve of a token for a mintId
    function reserves(address _token, uint256 _mintId)
        external
        view
        returns (uint64, uint64, uint128);

    /// @notice Returns the amount of saleProceeds of a token
    function saleProceeds(address _token) external view returns (uint256);
}
