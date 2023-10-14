// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title Allowlist
 * @notice Extension that allows token claiming through merkle trees
 */
abstract contract Allowlist {
    using BitMaps for BitMaps.BitMap;

    /// @notice Error thrown when an index in a merkle tree has already been claimed
    error SlotAlreadyClaimed();

    /// @notice Error thrown when the proof provided for an index is invalid
    error InvalidProof();

    /**
     * @dev Claims a merkle tree slot
     * @param _bitmap The bitmap to check if the index is already claimed
     * @param _token The address of the token contract
     * @param _index The index in the merkle tree
     * @param _proof The merkle proof
     */
    function _claimSlot(
        BitMaps.BitMap storage _bitmap,
        address _token,
        uint256 _reserveId,
        uint256 _index,
        bytes32[] memory _proof
    ) internal {
        if (_bitmap.get(_index)) revert SlotAlreadyClaimed();
        bytes32 root = _getMerkleRoot(_token, _reserveId);
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_index, msg.sender))));
        if (!MerkleProof.verify(_proof, root, leaf)) revert InvalidProof();
        _bitmap.set(_index);
    }

    /**
     * @dev Retrieves the merkle root of a token
     * @param _token The address of the token contract
     * @param _reserveId The reserveId of the token to get the merkle root for
     * @return The merkle root of the token
     */
    function _getMerkleRoot(address _token, uint256 _reserveId) internal view virtual returns (bytes32);
}
