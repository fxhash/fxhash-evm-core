// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibModeration.sol";
import "contracts/abstract/admin/FxHashAdmin.sol";
import "contracts/abstract/AddressConfig.sol";
import "contracts/moderation/ModerationTeam.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ModerationUser is FxHashAdmin, AddressConfig {
    mapping(address => LibModeration.ModerationState) public users;
    mapping(uint256 => string) public reasons;
    uint256 private reasonsCount;

    // Constructor
    constructor(address _admin) {
        // Initialize storage variables
        reasonsCount = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(FXHASH_ADMIN, _admin);
    }

    modifier onlyModerator() {
        require(isModerator(_msgSender()), "NOT_MOD");
        _;
    }

    // Helpers

    // Get the address of the moderation team contract
    function getModerationTeamAddress() private view returns (address payable) {
        return payable(addresses["mod"]);
    }

    // Check if an address is a user moderator on the moderation team contract
    function isModerator(address user) public view returns (bool) {
        return
            ModerationTeam(getModerationTeamAddress()).isAuthorized(user, 20);
    }

    // Moderate a user with a given state/reason
    function moderateUser(
        address user,
        uint256 state,
        uint256 reason
    ) private onlyModerator {
        if (reason != 0) {
            require(Strings.equal(reasons[reason], ""), "REASON_DOESNT_EXISTS");
        }

        users[user] = LibModeration.ModerationState(state, reason);
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
    function verify(address user) public onlyModerator {
        users[user] = LibModeration.ModerationState(10, 0);
    }

    // Moderators can add new reasons
    function reasonAdd(string memory reason) public onlyModerator {
        reasons[reasonsCount] = reason;
        reasonsCount += 1;
    }

    // Update a reason
    function reasonUpdate(uint256 reasonId, string memory reason) public {
        require(Strings.equal(reasons[reasonId], ""), "REASON_DOESNT_EXISTS");
        reasons[reasonId] = reason;
    }

    // Checks if a given user exists in the contract, if so returns its state. Otherwise, returns 0 (NONE)
    function userState(address user) public view returns (uint256) {
        return users[user].state;
    }
}
