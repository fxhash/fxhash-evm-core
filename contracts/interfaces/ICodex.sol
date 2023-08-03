// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct CodexData {
    uint256 entryType;
    address author;
    bool locked;
    address issuer;
    bytes[] value;
}

struct CodexInput {
    uint256 inputType;
    bytes value;
    uint256 codexId;
    address issuer;
}

interface ICodex {
    function insertOrUpdateCodex(
        address author,
        CodexInput memory input
    ) external returns (uint256);

    function codexAddEntry(uint256 entryType, address issuer, bytes[] calldata value) external;

    function codexLockEntry(uint256 entryId) external;

    function codexUpdateEntry(uint256 entryId, bool pushEnd, bytes memory value) external;

    function updateIssuerCodexRequest(CodexInput calldata input) external;

    function updateIssuerCodexApprove(address _issuer, uint256 _codexId) external;
}
