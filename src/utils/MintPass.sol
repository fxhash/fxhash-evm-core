// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";

contract MintPass {
    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;

    address internal FXHASH_AUTHORITY;

    /**
     * @dev Thrown when a mint pass has already been claimed.
     */
    error AlreadyClaimed();

    /**
     * @dev Thrown when the signature of the mint pass claim is invalid.
     */
    error InvalidSig();

    /**
     * @dev Initializes the contract.
     */
    constructor(address _signer) {
        FXHASH_AUTHORITY = _signer;
    }

    function _isClaimed(BitMaps.BitMap storage _bitmap, uint256 _index)
        internal
        view
        returns (bool)
    {
        return _bitmap.get(_index);
    }

    /*
     * @dev Internal function to claim a mint pass.
     * @param _bitmap The bitmap struct in stroage to write the claim to.
     * @param _index The index of the mint pass.
     * @param _user The address of the user claiming the mint pass.
     * @param _mintCode The mint code which can have additional data for the mint.
     * @param _signature The signature of the mint pass claim.
     */
    function _claimMintPass(
        BitMaps.BitMap storage _bitmap,
        uint256 _index,
        bytes calldata _mintCode,
        bytes calldata _sig
    ) internal {
        if (_isClaimed(_bitmap, _index)) revert AlreadyClaimed();
        bytes32 hash = keccak256(abi.encodePacked(address(this), msg.sender, _index, _mintCode));
        if (hash.toEthSignedMessageHash().recover(_sig) != FXHASH_AUTHORITY) revert InvalidSig();
        _bitmap.set(_index);
    }
}
