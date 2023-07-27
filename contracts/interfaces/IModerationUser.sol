// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct UserModInfo {
    uint128 state;
    uint128 reason;
}

interface IModerationUser {
    event UserModerated(address _account, uint128 _state, uint128 _reason);

    function users(address) external view returns (uint128, uint128);
}
