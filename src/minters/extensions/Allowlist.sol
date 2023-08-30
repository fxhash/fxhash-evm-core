// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MerkleProof} from "openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";

/**
 * @title Allowlist
 * @dev A contract that implements a merkle tree allowlist.
 */
abstract contract Allowlist {
    using BitMaps for BitMaps.BitMap;

    /**
     * @dev Error thrown when an index in a merkle tree has already been claimed
     */
    error AlreadyClaimed();

    /**
     * @dev Error thrown when the proof provided for an index is invalid.
     */
    error InvalidProof();

    /**
     * @dev Claims a merkle tree slot.
     * @param _bitmap The bitmap to check if the index is already claimed.
     * @param _token The address of the token.
     * @param _index The index in the merkle tree.
     * @param _price The price associated with the claim.
     * @param proof The merkle proof.
     */
    function _claimMerkleTreeSlot(
        BitMaps.BitMap storage _bitmap,
        address _token,
        uint256 _index,
        uint256 _price,
        bytes32[] calldata proof
    ) internal {
        if (_isClaimed(_bitmap, _index)) revert AlreadyClaimed();

        bytes32 root = _getTokenMerkleRoot(_token);

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_index, _price, msg.sender))));
        if (!MerkleProof.verify(proof, root, leaf)) revert InvalidProof();
        _bitmap.set(_index);
    }

    /**
     * @dev Retrieves the merkle root of a token.
     * @param _token The address of the token.
     * @return The merkle root of the token.
     */
    function _getTokenMerkleRoot(address _token) internal view virtual returns (bytes32);

    /**
     * @dev Checks if an index in the merkle tree has previusly been claimed
     * @param _index The index in the merkle tree.
     * @return A boolean indicating it has been claimed or not
     */
    function _isClaimed(BitMaps.BitMap storage _bitmap, uint256 _index)
        internal
        view
        returns (bool)
    {
        return _bitmap.get(_index);
    }
}
