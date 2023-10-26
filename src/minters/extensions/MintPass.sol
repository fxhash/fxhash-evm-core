// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BitMaps} from "openzeppelin/contracts/utils/structs/BitMaps.sol";
import {EIP712} from "openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {SignatureChecker} from "openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {CLAIM_TYPEHASH} from "src/utils/Constants.sol";

/**
 * @title MintPass
 * @author fx(hash)
 * @notice Extension for claiming tokens through mint passes
 */
abstract contract MintPass is EIP712 {
    using SignatureChecker for address;
    using BitMaps for BitMaps.BitMap;

    /*//////////////////////////////////////////////////////////////////////////
                                    EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when mint pass is claimed
     * @param _token Address of the token
     * @param _reserveId ID of the reserve
     * @param _claimer Address of the mint pass claimer
     * @param _index Index of purchase info inside the BitMap
     */
    event PassClaimed(address indexed _token, uint256 indexed _reserveId, address indexed _claimer, uint256 _index);

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
     * @param _token address of token for the reserve
     * @param _reserveId Id of the reserve to mint the token from
     * @param _index Index of the mint pass
     * @param _claimer Address of mint pass claimer
     * @return Digest of typed data hash claimer
     */
    function generateTypedDataHash(
        address _token,
        uint256 _reserveId,
        uint256 _index,
        address _claimer
    ) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(CLAIM_TYPEHASH, _token, _reserveId, _index, _claimer));
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
        bytes32 hash = generateTypedDataHash(_token, _reserveId, _index, msg.sender);
        address signer = _signingAuthority(_token, _reserveId);
        if (!signer.isValidSignatureNow(hash, _signature)) revert InvalidSignature();
        _bitmap.set(_index);

        emit PassClaimed(_token, _reserveId, msg.sender, _index);
    }

    /**
     * @dev Returns the signing authority
     * @param _token Address of the token contract
     * @param _reserveId ID of the reserve
     */
    function _signingAuthority(address _token, uint256 _reserveId) internal view virtual returns (address);
}
