// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMinter} from "src/interfaces/IMinter.sol";

interface IFixedPrice is IMinter {
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

    /// @notice Thrown when the sale has not started
    error NotStarted();

    /// @notice Thrown when amount purchased exceeds remaining allocation
    error TooMany();

    /**
     * @notice Buys tokens by sending payment to the contract
     * @param _token The address of the token to buy
     * @param _mintId The mint ID of the reserve for the token
     * @param _amount The number of tokens to buy
     * @param _to The address to receive the tokens
     */
    function buy(address _token, uint256 _mintId, uint256 _amount, address _to) external payable;

    /**
     * @notice Withdraws the sale proceeds to the sale receiver
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
