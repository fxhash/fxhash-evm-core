// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IModerationIssuer {
    /**
     * Requests the state held by an issuer contract. The state can be changed
     * by moderators to prevent minting for instance (if the project is not
     * respecting guidelines in place). If no state specified by a moderator,
     * returns 0 (default state = NONE)
     * @param issuerContract the address of the issuer requested
     * @return state numeric identifier of the state
     */
    function issuerState(address issuerContract) external view returns (uint256);
}
