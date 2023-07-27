// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BaseModeration} from "contracts/moderation/BaseModeration.sol";
import {ModerationTeam} from "contracts/moderation/ModerationTeam.sol";
import {IModerationIssuer, IssuerModInfo} from "contracts/interfaces/IModerationIssuer.sol";

contract ModerationIssuer is BaseModeration, IModerationIssuer {
    mapping(address => IssuerModInfo) public issuers;
    mapping(bytes32 => uint256) public reports;

    constructor(address payable _moderation) BaseModeration(_moderation) {}

    function moderate(address _issuer, uint128 _state, uint128 _reason) external onlyModerator {
        if (bytes(reasons[_reason]).length == 0) revert ReasonDoesNotExist();
        issuers[_issuer] = IssuerModInfo(_state, _reason);

        emit IssuerModerated(_issuer, _state, _reason);
    }

    function report(address _issuer, uint128 _reason) external onlyModerator {
        if (bytes(reasons[_reason]).length == 0) revert ReasonDoesNotExist();
        reports[getHashedKey(msg.sender, _issuer)] = _reason;

        emit IssuerReported(msg.sender, _issuer, _reason);
    }

    function isModerator(address _account) public view override returns (bool) {
        return ModerationTeam(moderation).isAuthorized(_account, VERIFIED);
    }

    function getHashedKey(address _reporter, address _reason) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_reporter, _reason));
    }
}
