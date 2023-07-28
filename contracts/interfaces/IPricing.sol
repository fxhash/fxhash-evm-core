// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IPricing {
    /**
     * Updates the price details associated to a project.
     * @param details decsribes information about the price, packed into bytes
     * (as abstract interfaces are used to interfact with the different
     * pricing mechanisms in place).
     */
    function setPrice(bytes memory details) external;

    /**
     * Returns the price at a given point in time (most often block time will
     * be used by the contracts)
     * @param timestamp the time at which the price is evaluated
     */
    function getPrice(uint256 timestamp) external view returns (uint256);

    /**
     * Gives the ability for the issuer contract to lock the price. (can be used
     * when the dutch auction price needs to be locked).
     */
    function lockPrice() external;
}
