// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {BaseModeration} from "contracts/admin/moderation/BaseModeration.sol";
import {IModerationIssuer, IssuerModInfo} from "contracts/interfaces/IModerationIssuer.sol";
import {ModerationTeam} from "contracts/admin/moderation/ModerationTeam.sol";
import {TOKEN_AUTH} from "contracts/utils/Constants.sol";

contract ModerationIssuer is BaseModeration, IModerationIssuer {
    mapping(address => IssuerModInfo) public issuers;
    mapping(bytes32 => uint256) public reports;

    constructor(address _moderation) BaseModeration(_moderation) {}

    function moderate(address _issuer, uint128 _state, uint128 _reasonId) external onlyModerator {
        if (bytes(reasons[_reasonId]).length == 0) revert InvalidReason();
        issuers[_issuer] = IssuerModInfo(_state, _reasonId);

        emit IssuerModerated(_issuer, _state, _reasonId);
    }

    function report(address _issuer, uint128 _reasonId) external onlyModerator {
        if (bytes(reasons[_reasonId]).length == 0) revert InvalidReason();
        reports[getReporterKey(msg.sender, _issuer)] = _reasonId;

        emit IssuerReported(msg.sender, _issuer, _reasonId);
    }

    function isModerator(address _account) public view override returns (bool) {
        return ModerationTeam(moderation).isAuthorized(_account, TOKEN_AUTH);
    }

    function getReporterKey(address _reporter, address _issuer) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_reporter, _issuer));
    }
}
