// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/moderation/ModerationTeam.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract BaseModeration is Ownable {
    uint256 internal reasonsCount;
    address internal moderation;
    mapping(uint256 => string) public reasons;

    constructor(address _admin, address _moderation) {
        reasonsCount = 0;
        moderation = _moderation;
        transferOwnership(_admin);
    }

    modifier onlyModerator() {
        require(isModerator(msg.senderr), "NOT_MOD");
        _;
    }

    // Get the address of the moderation team contract
    function getModerationTeamAddress() internal view returns (address payable) {
        return payable(moderation);
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

    function setModeration(address _moderation) external onlyOwner {
        moderation = _moderation;
    }
}
