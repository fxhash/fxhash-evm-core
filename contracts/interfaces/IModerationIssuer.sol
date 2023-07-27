// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct IssuerModInfo {
    uint128 state;
    uint128 reason;
}

interface IModerationIssuer {
    event IssuerModerated(address _issuer, uint128 _state, uint128 _reason);
    event IssuerReported(address _reporter, address _issuer, uint128 _reason);

    function moderate(address _issuer, uint128 _state, uint128 _reason) external;

    function report(address _issuer, uint128 _reason) external;

    function issuers(address) external view returns (uint128, uint128);

    function getHashedKey(address _reporter, address _reason) external pure returns (bytes32);
}
