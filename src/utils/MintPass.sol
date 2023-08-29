// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {EIP712} from "openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import {CLAIM_TYPEHASH} from "src/utils/Constants.sol";

abstract contract MintPass is EIP712 {
    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;

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
    constructor() EIP712("MINT_PASS", "1") {}

    /**
     * @dev Internal function to claim a mint pass.
     * @param _index The index of the mint pass.
     * @param _mintCode The mint code which can have additional data for the mint.
     * @param _signature The signature of the mint pass claim.
     */
    function _claimMintPass(
        BitMaps.BitMap storage _bitmap,
        uint256 _index,
        bytes calldata _mintCode,
        bytes calldata _signature
    ) internal {
        if (_isClaimed(_bitmap, _index)) revert AlreadyClaimed();
        bytes32 hash = _genTypedDataHash(_index, msg.sender, _mintCode);
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(_signature, (uint8, bytes32, bytes32));
        address signer = ECDSA.recover(hash, v, r, s);
        if (!_isSigningAuthority(signer)) revert InvalidSig();
        _bitmap.set(_index);
    }

    function _isSigningAuthority(address _signer) internal view virtual returns (bool);

    /**
     * @dev Checks if a token at a specific index has been claimed.
     * @param _index The index of the mint pass.
     * @return A boolean indicating whether the token has been claimed or not.
     */
    function _isClaimed(BitMaps.BitMap storage _bitmap, uint256 _index)
        internal
        view
        returns (bool)
    {
        return _bitmap.get(_index);
    }

    /**
     * @dev Internal function to generate the typed data hash.
     * @param _index The index of the mint pass.
     * @param _user The address of the user claiming the mint pass.
     * @param _mintCode The mint code which can have additional data for the mint.
     * @return The typed data hash digest.
     */
    function _genTypedDataHash(uint256 _index, address _user, bytes calldata _mintCode)
        internal
        view
        returns (bytes32)
    {
        bytes32 structHash = keccak256(abi.encode(CLAIM_TYPEHASH, _index, _user, _mintCode));
        return _hashTypedDataV4(structHash);
    }
}
