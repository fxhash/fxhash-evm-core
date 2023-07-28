// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IModeration {
    /**
     * Requests whether a given address has a given authorization (represented
     * by an integer)
     * @param userAddress address of the wallet to request
     * @param authorization the authorization flag requested
     * @return authorized whether the address has the authorization requested
     */
    function isAuthorized(address userAddress, uint256 authorization) external view returns (bool);
}
