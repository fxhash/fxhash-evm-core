// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {EIP712} from "openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract MintPass is EIP712 {
    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;

    address internal FXHASH_AUTHORITY;
    mapping(address => BitMaps.BitMap) internal redeemedBitMaps;

    bytes32 internal constant _CLAIM_TYPEHASH =
        keccak256("Claim(uint256 index, address user, bytes mintCode)");

    error AlreadyClaimed();
    error InvalidSig();

    constructor() EIP712("FXHASH_AUTHORITY", "1") {}

    function isClaimed(address _token, uint256 _index) public view returns (bool) {
        return redeemedBitMaps[_token].get(_index);
    }

    function _claimMintPass(
        address _token,
        uint256 _index,
        address _user,
        bytes calldata _mintCode,
        bytes calldata _sig
    ) internal {
        if (isClaimed(_token, _index)) revert AlreadyClaimed();
        bytes32 hash = _genTypedDataHash(_index, _user, _mintCode);
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(_sig, (uint8, bytes32, bytes32));
        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != FXHASH_AUTHORITY) revert InvalidSig();
        redeemedBitMaps[_token].set(_index);
    }

    function _genTypedDataHash(uint256 _index, address _user, bytes calldata _mintCode)
        internal
        view
        returns (bytes32)
    {
        bytes32 structHash = keccak256(abi.encode(_CLAIM_TYPEHASH, _index, _user, _mintCode));
        return _hashTypedDataV4(structHash);
    }
}
