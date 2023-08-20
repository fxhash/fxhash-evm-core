// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {BitMaps, BitMap} from "openzeppelin/contracts/utils/structs/BitMaps.sol";

contract MintPass {
    using ECDSA for bytes32;
    using BitMaps for BitMap;

    address internal constant FXHASH_AUTHORITY;
    mapping(address => BitMap) public redeemedBitMaps;

    error AlreadyClaimed();
    error InvalidSig();

    function isClaimed(address _token, uint256 _index) public view returns (bool) {
        return reeemedBitMaps[_token].get(_index);
    }

    function _claimMintPass(
        address _token,
        uint256 _index,
        bytes calldata _mintCode,
        bytes calldata _sig
    ) internal {
        if (isClaimed(_token, _index)) revert AlreadyClaimed();
        bytes32 hash = keccak256(abi.encodePacked(_token, msg.sender, _index, _mintCode));
        if (hash.toEthSignedMessageHash().recover(_sig) != FXHASH_AUTHORITY) revert InvalidSig();
        redeemedBitMaps[_token].set(_index);
    }
}
