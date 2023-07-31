// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {BaseModeration} from "contracts/admin/moderation/BaseModeration.sol";
import {ModerationTeam} from "contracts/admin/moderation/ModerationTeam.sol";

import {IModerationUser, UserModInfo} from "contracts/interfaces/IModerationUser.sol";
import {MALICIOUS_USER, USER_AUTH, VERIFIED} from "contracts/utils/Constants.sol";

contract ModerationUser is BaseModeration, IModerationUser {
    mapping(address => UserModInfo) public users;

    constructor(address _moderation) BaseModeration(_moderation) {}

    function verify(address _account) external onlyModerator {
        users[_account] = UserModInfo(VERIFIED, 0);

        emit UserModerated(_account, VERIFIED, 0);
    }

    function ban(address _account, uint128 _reasonId) external onlyModerator {
        moderate(_account, MALICIOUS_USER, _reasonId);
    }

    function moderate(address _account, uint128 _state, uint128 _reasonId) public onlyModerator {
        if (bytes(reasons[_reasonId]).length == 0) revert InvalidReason();
        users[_account] = UserModInfo(_state, _reasonId);

        emit UserModerated(_account, _state, _reasonId);
    }

    function isModerator(
        address _account
    ) public view override(BaseModeration, IModerationUser) returns (bool) {
        return ModerationTeam(moderation).isAuthorized(_account, USER_AUTH);
    }
}