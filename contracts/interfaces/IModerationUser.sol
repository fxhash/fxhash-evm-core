// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IModerationUser {
    /**
     * Requests the state held by a wallet. The state can be changed by 
     * moderators to prevent access to certain features, if the user has 
     * infringed some guidelines of the platform, for instance. It also returns
     * if a user is verified (state = 10) .If no state specified by a moderator,
     * returns 0 (default state = NONE)
     * @param user the address of the issuer requested
     * @return state numeric identifier of the state
     */
    function userState(address user) external view returns (uint256);
}
