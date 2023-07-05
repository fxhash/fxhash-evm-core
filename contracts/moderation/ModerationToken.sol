// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "contracts/libs/LibModeration.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";
import "contracts/abstract/BaseModeration.sol";
import "contracts/libs/LibModeration.sol";
import "contracts/interfaces/IModerationToken.sol";

contract ModerationToken is BaseModeration, IModerationToken {
    mapping(uint256 => LibModeration.ModerationState) public tokens;
    mapping(bytes32 => uint256) public reports;

    event TokenModerated(uint256 tokenId, uint256 state, uint256 reason);
    event TokenReported(uint256 tokenId, uint256 reason);

    constructor(address _admin) BaseModeration(_admin) {}

    function moderateToken(
        uint256 tokenId,
        uint256 state,
        uint256 reason
    ) external onlyModerator {
        require(!Strings.equal(reasons[reason], ""), "REASON_DOESNT_EXISTS");
        tokens[tokenId] = LibModeration.ModerationState(state, reason);
        emit TokenModerated(tokenId, state, reason);
    }

    function report(uint256 tokenId, uint256 reason) external onlyModerator {
        require(!Strings.equal(reasons[reason], ""), "REASON_DOESNT_EXISTS");
        reports[getReportKey(tokenId, _msgSender())] = reason;
        emit TokenReported(tokenId, reason);
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
