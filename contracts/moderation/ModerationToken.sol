// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "contracts/libs/LibModeration.sol";
import "contracts/abstract/admin/FxHashAdminVerify.sol";
import "contracts/abstract/BaseModeration.sol";
import "contracts/libs/LibModeration.sol";
import "contracts/interfaces/IModerationToken.sol";
import "hardhat/console.sol";

contract ModerationToken is BaseModeration, IModerationToken {
    mapping(uint256 => LibModeration.ModerationState) public tokens;
    mapping(bytes32 => uint256) public reports;

    constructor(address _admin) {
        reasonsCount = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(FXHASH_ADMIN, _admin);
    }

    function moderateToken(
        uint256 tokenId,
        uint256 state,
        uint256 reason
    ) external onlyModerator {
        require(!Strings.equal(reasons[reason], ""), "REASON_DOESNT_EXISTS");
        tokens[tokenId] = LibModeration.ModerationState(state, reason);
    }

    function report(uint256 tokenId, uint256 reason) external onlyModerator {
        require(!Strings.equal(reasons[reason], ""), "REASON_DOESNT_EXISTS");
        reports[getReportKey(tokenId, _msgSender())] = reason;
    }

    function tokenState(uint256 tokenId) external view returns (uint256) {
        LibModeration.ModerationState memory moderationState = tokens[tokenId];
        if (moderationState.state == 0 && moderationState.reason == 0) {
            return 0;
        } else {
            return moderationState.state;
        }
    }

    function getReportKey(
        uint256 tokenId,
        address reporter
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(tokenId, reporter));
    }

    function isModerator(address user) public view override returns (bool) {
        return
            ModerationTeam(getModerationTeamAddress()).isAuthorized(user, 10);
    }
}
