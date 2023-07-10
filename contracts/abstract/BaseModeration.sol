// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/AuthorizedCaller.sol";
import "contracts/abstract/AddressConfig.sol";
import "contracts/moderation/ModerationTeam.sol";

abstract contract BaseModeration is AuthorizedCaller, AddressConfig {
    modifier onlyModerator() {
        require(isModerator(_msgSender()), "NOT_MOD");
        _;
    }
    mapping(uint256 => string) public reasons;
    uint256 internal reasonsCount;

    // Get the address of the moderation team contract
    function getModerationTeamAddress() internal view returns (address payable) {
        return payable(addresses["mod"]);
    }

    // Check if an address is a user moderator on the moderation team contract
    function isModerator(address user) public view virtual returns (bool);

    function reasonAdd(string memory reason) external onlyModerator {
        reasons[reasonsCount] = reason;
        reasonsCount += 1;
    }

    // Update a reason
    function reasonUpdate(uint256 reasonId, string memory reason) external onlyModerator {
        require(!Strings.equal(reasons[reasonId], ""), "REASON_DOESNT_EXISTS");
        reasons[reasonId] = reason;
    }
}
