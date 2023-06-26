// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IModeration.sol";
import "contracts/interfaces/IIssuer.sol";
import "contracts/interfaces/ICodex.sol";
import "contracts/libs/LibIssuer.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";

contract Codex is ICodex, AuthorizedCaller {
    struct CodexData {
        uint256 entryType;
        address author;
        bool locked;
        bytes[] value;
    }

    struct CodexInput {
        uint256 inputType;
        bytes value;
        uint256 codexId;
    }

    uint256 private codexEntriesCount;
    IIssuer private issuer;
    IModeration private moderation;

    mapping(uint256 => CodexData) public codexEntries;
    mapping(uint256 => uint256) public issuerCodexUpdates;

    constructor(address _issuer, address _moderation, address _admin) {
        issuer = IIssuer(_issuer);
        moderation = IModeration(_moderation);
        codexEntriesCount = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function codexEntryIdFromInput(
        address author,
        LibCodex.CodexInput memory input
    ) public onlyAuthorizedCaller returns (uint256) {
        uint256 codexIdValue = 0;
        if (input.codexId > 0) {
            require(
                codexEntries[input.codexId].author != address(0),
                "CDX_EMPTY"
            );
            require(codexEntries[input.codexId].locked, "CDX_NOT_LOCK");
            codexIdValue = input.codexId;
        } else {
            require(input.inputType > 0, "CDX_EMP");
            bytes[] memory valueBytes = new bytes[](1);
            valueBytes[0] = input.value;
            codexInsert(input.inputType, author, true, valueBytes);
            codexIdValue = codexEntriesCount - 1;
        }
        return codexIdValue;
    }

    function codexAddEntry(
        uint256 entryType,
        bytes[] memory value
    ) external onlyAuthorizedCaller {
        codexInsert(entryType, msg.sender, true, value);
    }

    function codexLockEntry(uint256 entryId) external onlyAuthorizedCaller {
        CodexData storage entry = codexEntries[entryId];
        require(entry.author == msg.sender, "403");
        require(!entry.locked, "CDX_LOCK");
        require(entry.value.length > 0, "CDX_EMP");
        entry.locked = true;
    }

    function codexUpdateEntry(
        uint256 entryId,
        bool pushEnd,
        bytes memory value
    ) external onlyAuthorizedCaller {
        CodexData storage entry = codexEntries[entryId];
        require(entry.author == msg.sender, "403");
        require(!entry.locked, "CDX_LOCK");
        if (pushEnd) {
            entry.value.push(value);
        } else {
            bytes[] memory valueBytes = new bytes[](1);
            valueBytes[0] = value;
            entry.value = valueBytes;
        }
    }

    function updateIssuerCodexRequest(
        uint256 _issuerId,
        LibCodex.CodexInput calldata input
    ) external onlyAuthorizedCaller {
        require(_issuerId > 0, "NO_ISSUER");
        LibIssuer.IssuerData memory _issuer = issuer.getIssuer(
            _issuerId
        );
        require(_issuer.info.author == msg.sender, "403");
        uint256 codexId = codexEntryIdFromInput(msg.sender, input);
        require(issuerCodexUpdates[_issuerId] != codexId, "SAME_CDX_ID");
        issuerCodexUpdates[_issuerId] = codexId;
    }

    function updateIssuerCodexApprove(
        uint256 _issuerId,
        uint256 _codexId
    ) external onlyAuthorizedCaller {
        uint256 issuerId = issuerCodexUpdates[_issuerId];
        require(issuerId > 0, "NO_REQ");
        require(issuerId == _codexId, "WRG_CDX_ID");
        require(moderation.isAuthorized(msg.sender, 701), "403");
        issuer.setCodex(issuerId, _codexId);
        delete issuerCodexUpdates[issuerId];
    }

    function codexInsert(
        uint256 entryType,
        address author,
        bool locked,
        bytes[] memory value
    ) private {
        codexEntries[codexEntriesCount] = CodexData(
            entryType,
            author,
            locked,
            value
        );
        codexEntriesCount++;
    }
}
