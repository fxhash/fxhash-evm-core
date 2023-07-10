// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "contracts/libs/LibModeration.sol";
import "contracts/abstract/BaseModeration.sol";
import "contracts/libs/LibModeration.sol";
import "contracts/interfaces/IModerationIssuer.sol";

contract ModerationIssuer is BaseModeration, IModerationIssuer {
    mapping(address => LibModeration.ModerationState) public issuers;
    mapping(bytes32 => uint256) public reports;

    event IssuerModerated(address issuer, uint256 state, uint256 reason);
    event IssuerReported(address reporter, address issuer, uint256 reason);

    constructor(address _admin, address _moderation) BaseModeration(_admin, _moderation) {}

    function moderateIssuer(
        address issuerContract,
        uint256 state,
        uint256 reason
    ) external onlyModerator {
        require(!Strings.equal(reasons[reason], ""), "REASON_DOESNT_EXISTS");
        issuers[issuerContract] = LibModeration.ModerationState(state, reason);
        emit IssuerModerated(issuerContract, state, reason);
    }

    function report(address issuerContract, uint256 reason) external onlyModerator {
        require(!Strings.equal(reasons[reason], ""), "REASON_DOESNT_EXISTS");
        reports[getHashedKey(msg.sender, issuerContract)] = reason;
        emit IssuerReported(msg.sender, issuerContract, reason);
    }

    function issuerState(address issuerContract) external view returns (uint256) {
        LibModeration.ModerationState memory moderationState = issuers[issuerContract];
        if (moderationState.state == 0 && moderationState.reason == 0) {
            return 0;
        } else {
            return moderationState.state;
        }
    }

    function getHashedKey(address reporter, address issuer) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(reporter, issuer));
    }

    function isModerator(address user) public view override returns (bool) {
        return ModerationTeam(getModerationTeamAddress()).isAuthorized(user, 10);
    }
}
