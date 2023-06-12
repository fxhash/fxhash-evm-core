// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibModeration.sol";

contract ModerationUser {
    mapping(address => LibModeration.ModerationState) public users;
    mapping(uint256 => string) public reasons;
    uint256 private reasonsCount;

    // Constructor
    constructor(address admin) {
        // Initialize storage variables
        reasonsCount = 0;
    }

    // Helpers

    // Get the address of the moderation team contract
    function getModerationTeamAddress() private view returns (address) {
        // The implementation of this function depends on how the moderation team contract is deployed
        // Return the address of the moderation team contract
    }

    // Check if an address is a user moderator on the moderation team contract
    function isModerator(address user) private view returns (bool) {
        // The implementation of this function depends on how the moderation team contract is designed
        // Return true if the address is a moderator, false otherwise
    }

    // Moderate a user with a given state/reason
    function moderateUser(address user, uint256 state, uint256 reason) private {
        require(isModerator(msg.sender), "NOT_MOD");

        if (reason != 0) {
            require(reasons[reason] != "", "REASON_DOESNT_EXISTS");
        }

        users[user] = ModerationState(state, reason);
    }

    // Verifications

    // Verify if the sender is a user moderator
    function verifySenderModerator() private view {
        require(isModerator(msg.sender), "NOT_MOD");
    }

    // Entry Points

    // Moderators can moderate a user
    // They can send an optional reason which maps to a reason in storage
    function moderate(address user, uint256 state, uint256 reason) public {
        moderateUser(user, state, reason);
    }

    // Quicker way to set the state of users as "MALICIOUS", which is 3
    function ban(address user, uint256 reason) public {
        moderateUser(user, 3, reason);
    }

    // Quicker way to verify a user (set its state as 10 = VERIFIED)
    function verify(address user) public {
        verifySenderModerator();
        users[user] = ModerationState(10, 0);
    }

    // Moderators can add new reasons
    function reasonAdd(string memory reason) public {
        verifySenderModerator();
        reasons[reasonsCount] = reason;
        reasonsCount += 1;
    }

    // Update a reason
    function reasonUpdate(uint256 reasonId, string memory reason) public {
        verifySenderModerator();
        require(reasons[reasonId] != "", "REASON_DOESNT_EXIST");
        reasons[reasonId] = reason;
    }

    // Views

    // Checks if a given user exists in the contract, if so returns its state. Otherwise, returns 0 (NONE)
    function userState(address user) public view returns (uint256) {
        return users[user].state;
    }
}
