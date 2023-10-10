// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "openzeppelin/contracts/utils/cryptography/EIP712.sol";

import {CLAIM_TYPEHASH} from "src/utils/Constants.sol";

/**
 * @title MintPass
 * @notice Extension for claiming mint pass tokens
 */
abstract contract MintPass is EIP712 {
    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;

    /// @dev Error thrown when a mint pass has already been claimed
    error PassAlreadyClaimed();

    /// @dev Error thrown when the signature of the mint pass claim is invalid
    error InvalidSig();

    /// @dev Initializes the EIP712 data for contract
    constructor() EIP712("MINT_PASS", "1") {}

    /**
     * @dev Generate the typed data hash for a mint pass claim
     * @param _index The index of the mint pass
     * @param _user The address of the user claiming the mint pass
     * @return The typed data hash digest
     */
    function generateTypedDataHash(uint256 _index, address _user) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(CLAIM_TYPEHASH, _index, _user));
        return _hashTypedDataV4(structHash);
    }

    /**
     * @dev Validates a mint pass claim
     * @param _index The index of the mint pass
     * @param _signature The signature of the mint pass claim
     */
    function _claimMintPass(
        BitMaps.BitMap storage _bitmap,
        address _token,
        uint256 _reserveId,
        uint256 _index,
        bytes calldata _signature
    ) internal {
        if (_bitmap.get(_index)) revert PassAlreadyClaimed();
        bytes32 hash = generateTypedDataHash(_index, msg.sender);
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(_signature, (uint8, bytes32, bytes32));
        address signer = ECDSA.recover(hash, v, r, s);
        if (!_isSigningAuthority(signer, _token, _reserveId)) revert InvalidSig();
        _bitmap.set(_index);
    }

    function _isSigningAuthority(
        address _signer,
        address _token,
        uint256 _reserveId
    ) internal view virtual returns (bool);
}
