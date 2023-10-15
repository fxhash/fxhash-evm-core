// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title Allowlist
 * @author fx(hash)
 * @notice Extension for claiming tokens through merkle trees
 */
abstract contract Allowlist {
    using BitMaps for BitMaps.BitMap;

    /**
     * @notice Error thrown when the merkle proof of index is invalid
     */
    error InvalidProof();

    /**
     * @notice Error thrown when index in merkle tree has already been claimed
     */
    error SlotAlreadyClaimed();

    /**
     * @notice Claims a merkle tree slot
     * @param _token Address of the token contract
     * @param _index Index in the merkle tree
     * @param _proof Merkle proof used for validating claim
     * @param _bitmap Bitmap used for checking if index is already claimed
     */
    function _claimSlot(
        address _token,
        uint256 _reserveId,
        uint256 _index,
        bytes32[] memory _proof,
        BitMaps.BitMap storage _bitmap
    ) internal {
        if (_bitmap.get(_index)) revert SlotAlreadyClaimed();
        bytes32 root = _getMerkleRoot(_token, _reserveId);
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_index, msg.sender))));
        if (!MerkleProof.verify(_proof, root, leaf)) revert InvalidProof();
        _bitmap.set(_index);
    }

    /**
     * @dev Gets the merkle root of a token reserve
     */
    function _getMerkleRoot(address _token, uint256 _reserveId) internal view virtual returns (bytes32);
}
