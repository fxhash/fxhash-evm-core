// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IFxRandomizer
/// @notice Generates and reveals randomizer seeds
interface IFxRandomizer {
    /// @param issuer Address of Issuer contract
    /// @param tokenId ID of the token
    struct TokenKey {
        address issuer;
        uint256 tokenId;
    }

    /// @param chainSeed Hash of the chain seed
    /// @param serialId ID of the serial
    /// @param revealed Hash of reveal
    struct Seed {
        bytes32 chainSeed;
        uint256 serialId;
        bytes32 revealed;
    }

    /// @param seed Hash of randomizer seed
    /// @param salt Hash of randomizer salt
    struct Commitment {
        bytes32 seed;
        bytes32 salt;
    }

    /// @notice Thrown when seed is already revealed
    error AlreadySeeded();
    /// @notice Thrown when chain seed has not been set
    error NoReq();
    /// @notice Thrown when oracle seed does not match the commitment seed
    error OutOfRange();

    /// @notice Emitted when the randomizer is generated
    event RandomizerGenerate(uint256 _tokenId, Seed _seed);
    /// @notice Emitted when the randomizer is revealed
    event RandomizerReveal(uint256 _tokenId, bytes32 _seed);

    /// @notice Sets commitment values
    /// @param _seed Hash of randomizer seed
    /// @param _salt Hash of randomizer salt
    function commit(bytes32 _seed, bytes32 _salt) external;

    /// @notice Generates and stores randomizer seed
    /// @param _tokenId ID of the token
    function generate(uint256 _tokenId) external;

    /// @notice Batch reveals list of token keys
    /// @param _tokenList List of token keys
    /// @param _seed Hash of commitment seed
    function reveal(TokenKey[] memory _tokenList, bytes32 _seed) external;

    /// @notice Generates token key of Issuer contract and token ID
    /// @param _issuer Address of Issuer contract
    /// @param _tokenId ID of the token
    /// @return hash of token key
    function getTokenKey(address _issuer, uint256 _tokenId) external pure returns (bytes32);
}
