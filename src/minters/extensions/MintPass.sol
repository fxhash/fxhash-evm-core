// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "openzeppelin/contracts/utils/cryptography/EIP712.sol";

import {CLAIM_TYPEHASH} from "src/utils/Constants.sol";

/**
 * @title MintPass
 * @author fx(hash)
 * @notice Extension for claiming tokens through mint passes
 */
abstract contract MintPass is EIP712 {
    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;

    /*//////////////////////////////////////////////////////////////////////////
                                    ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when a mint pass has already been claimed
     */
    error PassAlreadyClaimed();

    /**
     * @notice Error thrown when the signature of mint pass claimer is invalid
     */
    error InvalidSignature();

    /*//////////////////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes EIP-712
     */
    constructor() EIP712("MINT_PASS", "1") {}

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Generates the typed data hash for a mint pass claim
     * @param _index Index of the mint pass
     * @param _claimer Address of mint pass
     * @return Digest of typed data hash claimer
     */
    function generateTypedDataHash(uint256 _index, address _claimer) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(CLAIM_TYPEHASH, _index, _claimer));
        return _hashTypedDataV4(structHash);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Validates a mint pass claim
     * @param _token Address of the token contract
     * @param _reserveId ID of the reserve
     * @param _index Index of the mint pass
     * @param _signature Signature of the mint pass claimer
     * @param _bitmap Bitmap used for checking if index is already claimed
     */
    function _claimMintPass(
        address _token,
        uint256 _reserveId,
        uint256 _index,
        bytes calldata _signature,
        BitMaps.BitMap storage _bitmap
    ) internal {
        if (_bitmap.get(_index)) revert PassAlreadyClaimed();
        bytes32 hash = generateTypedDataHash(_index, msg.sender);
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(_signature, (uint8, bytes32, bytes32));
        address signer = ECDSA.recover(hash, v, r, s);
        if (!_isSigningAuthority(signer, _token, _reserveId)) revert InvalidSignature();
        _bitmap.set(_index);
    }

    /**
     * @dev Checks if signer has signing authority
     * @param _signer Address of the signer
     * @param _token Address of the token contract
     * @param _reserveId ID of the reserve
     */
    function _isSigningAuthority(
        address _signer,
        address _token,
        uint256 _reserveId
    ) internal view virtual returns (bool);
}
