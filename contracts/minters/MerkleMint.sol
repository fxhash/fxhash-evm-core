// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IMinter} from "contracts/interfaces/IMinter.sol";
import {Minted, Reserve} from "contracts/minters/Minted.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleMint is IMinter {
    mapping(address => bytes32) public merkleRoots;
    mapping(address => mapping(uint256 => uint256)) public redeemedBitMaps;

    error AlreadyClaimed();
    error NotStarted();
    error Over();
    error InvalidProof();
    error InsufficientSlots();

    /// should integrate delegate cash

    function setMintDetails(Reserve calldata _reserve, bytes calldata) external {}

    function mint(
        address _token,
        uint256 _index,
        address _account,
        bytes32[] calldata proof,
        address _to
    ) external {
        bytes32 root = merkleRoots[_token];
        if (isClaimed(_token, _index)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_index, _account))));
        if (!MerkleProof.verify(proof, root, leaf)) revert InvalidProof();

        _setClaimed(_token, _index);
        // Mark it claimed and override send the token.

        Minted(_token).mint(1, _to);
    }

    function isClaimed(address _token, uint256 _index) public view returns (bool) {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        uint256 claimedWord = redeemedBitMaps[_token][claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(address _token, uint256 _index) private {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        redeemedBitMaps[_token][claimedWordIndex] =
            redeemedBitMaps[_token][claimedWordIndex] |
            (1 << claimedBitIndex);
    }
}
