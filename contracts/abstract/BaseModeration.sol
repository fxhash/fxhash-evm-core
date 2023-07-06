// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/abstract/admin/AuthorizedCaller.sol";
import "contracts/moderation/ModerationTeam.sol";

abstract contract BaseModeration is AuthorizedCaller {
    uint256 internal reasonsCount;
    address internal moderation;
    mapping(uint256 => string) public reasons;

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        reasonsCount = 0;
    }

    modifier onlyModerator() {
        require(isModerator(_msgSender()), "NOT_MOD");
        _;
    }

    // Get the address of the moderation team contract
    function getModerationTeamAddress()
        internal
        view
        returns (address payable)
    {
        return payable(moderation);
    }

    // Check if an address is a user moderator on the moderation team contract
    function isModerator(address user) public view virtual returns (bool);

    function reasonAdd(string memory reason) external onlyModerator {
        reasons[reasonsCount] = reason;
        reasonsCount += 1;
    }

    // Update a reason
    function reasonUpdate(
        uint256 reasonId,
        string memory reason
    ) external onlyModerator {
        require(!Strings.equal(reasons[reasonId], ""), "REASON_DOESNT_EXISTS");
        reasons[reasonId] = reason;
    }

    function setModeration(address _moderation) external onlyAdmin {
        moderation = _moderation;
    }
}
