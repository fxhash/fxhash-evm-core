// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Strings.sol";
import "contracts/libs/LibModeration.sol";
import "contracts/admin/moderation/ModerationTeam.sol";
import "contracts/admin/BaseModeration.sol";
import "contracts/interfaces/IModerationUser.sol";

contract ModerationUser is BaseModeration, IModerationUser {
    mapping(address => LibModeration.ModerationState) public users;

    event UserModerated(address user, uint256 state, uint256 reason);

    // Constructor
    constructor(address _moderation) BaseModeration(_moderation) {}

    // Check if an address is a user moderator on the moderation team contract
    function isModerator(address user) public view override returns (bool) {
        return ModerationTeam(moderation).isAuthorized(user, 20);
    }

    // Moderate a user with a given state/reason
    function moderateUser(address user, uint256 state, uint256 reason) public onlyModerator {
        require(!Strings.equal(reasons[reason], ""), "REASON_DOESNT_EXISTS");
        users[user] = LibModeration.ModerationState(state, reason);
        emit UserModerated(user, state, reason);
    }

    // Quicker way to set the state of users as "MALICIOUS", which is 3
    function ban(address user, uint256 reason) external onlyModerator {
        moderateUser(user, 3, reason);
    }

    // Quicker way to verify a user (set its state as 10 = VERIFIED)
    function verify(address user) external onlyModerator {
        users[user] = LibModeration.ModerationState(10, 0);
    }

    // Checks if a given user exists in the contract, if so returns its state. Otherwise, returns 0 (NONE)
    function userState(address user) external view returns (uint256) {
        return users[user].state;
    }
}
