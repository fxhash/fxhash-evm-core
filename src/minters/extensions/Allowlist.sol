// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MerkleProof} from "openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IDelegateCash} from "src/interfaces/IDelegateCash.sol";

contract Allowlist {
    address public constant delegateRegistry = 0x00000000000076A84feF008CDAbe6409d2FE638B;
    mapping(address => bytes32) public merkleRoots;
    mapping(address => mapping(uint256 => uint256)) public redeemedBitMaps;

    error AlreadyClaimed();
    error InvalidProof();
    error InvalidDelegate();

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
        uint256 _price,
        address _vault,
        bytes32[] calldata proof
    ) internal {
        if (isClaimed(_token, _index)) revert AlreadyClaimed();

        address requester = msg.sender;
        if (_vault != msg.sender) {
            bool isDelegate;
            isDelegate = IDelegateCash(delegateRegistry).checkDelegateForAll(requester, _vault);

            if (!isDelegate) revert InvalidDelegate();
            requester = _vault;
        }

        bytes32 root = merkleRoots[_token];

        // Verify the merkle proof.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_index, _price, requester))));
        if (!MerkleProof.verify(proof, root, leaf)) revert InvalidProof();

        _setClaimed(_token, _index);
    }

    function _setClaimed(address _token, uint256 _index) private {
        uint256 claimedWordIndex = _index / 256;
        uint256 claimedBitIndex = _index % 256;
        redeemedBitMaps[_token][claimedWordIndex] =
            redeemedBitMaps[_token][claimedWordIndex] | (1 << claimedBitIndex);
    }
}
