// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAllowlist {
    mapping(address => bytes32) public merkleRoots;
    mapping(address => mapping(uint256 => uint256)) public redeemedBitMaps;

    error AlreadyClaimed();
    error InvalidProof();

    function isClaimed(address _token, uint256 _index) public view returns (bool) {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        uint256 claimedWord = redeemedBitMaps[_token][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setMerkleRoot(address _token, bytes32 _root) internal {
        merkleRoots[_token] = _root;
    }

    function _claimMerkleTreeSlot(
        address _token,
        uint256 _index,
        address _account,
        bytes32[] calldata proof
    ) internal {
        if (isClaimed(_token, _index)) revert AlreadyClaimed();
        bytes32 root = merkleRoots[_token];

        // Verify the merkle proof.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_index, _account))));
        if (!MerkleProof.verify(proof, root, leaf)) revert InvalidProof();

        _setClaimed(_token, _index);
    }

    function _setClaimed(address _token, uint256 _index) private {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        redeemedBitMaps[_token][claimedWordIndex] =
            redeemedBitMaps[_token][claimedWordIndex] |
            (1 << claimedBitIndex);
    }
}
