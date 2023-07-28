// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/libs/LibCodex.sol";

/**
 * @title ICodex
 * @author fxhash
 * @notice The codex stores the code entries made by authors and provides an
 * abstraction to the different ways supported to store the code of a project
 * (let it be onchain or offchain). Issuers are referencing a codex entry as the
 * source for the code powering the project.
 */
interface ICodex {
    /**
     * Insert a new codex entry.
     * @param author the author of the codex entry
     * @param input data describing the insertion into the codex
     * 
     * TODO: It's not sure that we need a mechanism to "update" the codex, 
     * because unlike tezos we are not using the codex to store the code but
     * scripty, as such we are not uploading the code directly though the codex.
     */
    function insertOrUpdateCodex(
        address author,
        LibCodex.CodexInput memory input
    ) external returns (uint256);

    /**
     * Adds an entry into the codex, by specifying its type, and the data
     * associated with it.
     * @param entryType the type of entry, int identified (0=IPFS, 1=scripty)
     * @param issuer the address of the issuer adding a codex entry
     * @param value the value to be inserted into the entry
     */
    function codexAddEntry(uint256 entryType, address issuer, bytes[] calldata value) external;

    /**
     * Locks a codex entry once fully inserted.
     * @param entryId the identifier of the entry
     * 
     * TODO: Same as updateEntry, we may not need to lock it because we're not
     * using the multipart insertion anymore, since it's now managed by scripty.
     */
    function codexLockEntry(uint256 entryId) external;

    /**
     * TODO: not needed, see above
     */
    function codexUpdateEntry(uint256 entryId, bool pushEnd, bytes memory value) external;

    /**
     * Author(s) of a project can request for the code of their project to be
     * updated, by doing so they should provide the ID to a new codex entry they
     * want to associate to their project.
     * @param input data describing the codex update request
     * 
     * TODO: this should be moved to the issuer, we are updating the codex 
     * pointer of an issuer, not directly a codex entry. codex entries are 
     * immutable once locked.
     */
    function updateIssuerCodexRequest(LibCodex.CodexInput calldata input) external;

    /**
     * Moderators can approve a request to update the code, in such a case the
     * pointer to the codex will be updated at the issuer level.
     * @param _issuer the address of the issuer
     * @param _codexId the ID of the request to approve
     */
    function updateIssuerCodexApprove(address _issuer, uint256 _codexId) external;
}
