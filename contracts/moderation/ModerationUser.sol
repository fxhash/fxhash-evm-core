// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ModerationTeam} from "contracts/moderation/ModerationTeam.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {BaseModeration} from "contracts/moderation/BaseModeration.sol";
import {IModerationUser, UserModInfo} from "contracts/interfaces/IModerationUser.sol";

contract ModerationUser is BaseModeration, IModerationUser {
    mapping(address => UserModInfo) public users;

    constructor(address _moderation) BaseModeration(_moderation) {}

    // Check if an address is a user moderator on the moderation team contract
    function isModerator(address _account) public view override returns (bool) {
        return ModerationTeam(moderation).isAuthorized(_account, 20);
    }

    function verify(address _account) external onlyModerator {
        users[_account] = UserModInfo(VERIFIED, 0);
    }

    function ban(address _account, uint128 _reason) external onlyModerator {
        moderate(_account, MALICIOUS, _reason);
    }

    function moderate(address _account, uint128 _state, uint128 _reason) public onlyModerator {
        if (bytes(reasons[_reason]).length == 0) revert InvalidReason();
        users[_account] = UserModInfo(_state, _reason);
        emit UserModerated(_account, _state, _reason);
    }
}
