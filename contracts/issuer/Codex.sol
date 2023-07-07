// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IModeration.sol";
import "contracts/interfaces/IIssuer.sol";
import "contracts/interfaces/ICodex.sol";
import "contracts/libs/LibIssuer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Codex is ICodex, Ownable {
    uint256 private codexEntriesCount;
    address private moderation;

    mapping(uint256 => LibCodex.CodexData) public codexEntries;
    mapping(uint256 => uint256) public issuerCodexUpdates;

    event CodexInserted(
        uint256 entryType,
        address author,
        bool locked,
        bytes[] value
    );
    event CodexLocked(uint256 entryId);
    event CodexUpdated(uint256 entryId, bool pushEnd, bytes value);
    event CodexReplaced(address author, LibCodex.CodexInput input);
    event UpdateIssuerCodexRequested(
        address issuer,
        uint256 codexId,
        LibCodex.CodexInput input
    );
    event UpdateIssuerCodexApproved(address issuer, uint256 _codexId);

    constructor(address _admin, address _moderation) {
        moderation = _moderation;
        codexEntriesCount = 0;
        transferOwnership(_admin);
    }

    function setModeration(address _moderation) external onlyOwner {
        moderation = _moderation;
    }

    function insertOrUpdateCodex(
        address author,
        LibCodex.CodexInput memory input
    ) public returns (uint256) {
        uint256 codexIdValue = 0;
        if (input.codexId > 0) {
            LibCodex.CodexData storage codexEntry = codexEntries[input.codexId];
            require(codexEntry.author == msg.sender, "403");
            require(codexEntry.locked, "CDX_NOT_LOCK");
            codexIdValue = input.codexId;
            emit CodexReplaced(author, input);
        } else {
            require(input.issuer == msg.sender, "Caller not issuer");
            bytes[] memory valueBytes = new bytes[](1);
            valueBytes[0] = input.value;
            codexInsert(
                input.inputType,
                author,
                true,
                input.issuer,
                valueBytes
            );
            codexIdValue = codexEntriesCount - 1;
        }
        return codexIdValue;
    }

    function codexAddEntry(
        uint256 entryType,
        address issuer,
        bytes[] calldata value
    ) external {
        codexInsert(entryType, msg.sender, true, issuer, value);
    }

    function codexLockEntry(uint256 entryId) external {
        LibCodex.CodexData storage entry = codexEntries[entryId];
        require(entry.author == msg.sender, "403");
        require(!entry.locked, "CDX_LOCK");
        require(entry.value.length > 0, "CDX_EMP");
        entry.locked = true;
        emit CodexLocked(entryId);
    }

    function codexUpdateEntry(
        uint256 entryId,
        bool pushEnd,
        bytes memory value
    ) external {
        LibCodex.CodexData storage entry = codexEntries[entryId];
        require(entry.author == msg.sender, "403");
        require(!entry.locked, "CDX_LOCK");
        if (pushEnd) {
            entry.value.push(value);
        } else {
            bytes[] memory valueBytes = new bytes[](1);
            valueBytes[0] = value;
            entry.value = valueBytes;
        }
        emit CodexUpdated(entryId, pushEnd, value);
    }

    function updateIssuerCodexRequest(
        LibCodex.CodexInput calldata input
    ) external {
        require(input.issuer != address(0), "NO_ISSUER");
        require(IIssuer(input.issuer).owner() == msg.sender, "403");
        uint256 codexId = insertOrUpdateCodex(msg.sender, input);
        require(issuerCodexUpdates[input.codexId] != codexId, "SAME_CDX_ID");
        issuerCodexUpdates[input.codexId] = codexId;
        emit UpdateIssuerCodexRequested(input.issuer, input.codexId, input);
    }

    function updateIssuerCodexApprove(
        address _issuer,
        uint256 _codexId
    ) external {
        require(_issuer != address(0), "NO_ISSUER");
        uint256 issuerCodexId = issuerCodexUpdates[_codexId];
        require(issuerCodexId > 0, "NO_REQ");
        require(issuerCodexId == _codexId, "WRG_CDX_ID");
        require(IModeration(moderation).isAuthorized(msg.sender, 701), "403");
        delete issuerCodexUpdates[issuerCodexId];
        IIssuer(_issuer).setCodex(_codexId);
        emit UpdateIssuerCodexApproved(_issuer, _codexId);
    }

    function codexInsert(
        uint256 entryType,
        address author,
        bool locked,
        address issuer,
        bytes[] memory value
    ) private {
        codexEntries[codexEntriesCount] = LibCodex.CodexData(
            entryType,
            author,
            locked,
            issuer,
            value
        );
        codexEntriesCount++;
        emit CodexInserted(entryType, author, locked, value);
    }
}
