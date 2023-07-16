// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title IRandomizer
/// @notice Generates and reveals randomizer seeds
interface IRandomizer {
    struct TokenKey {
        address issuer;
        uint256 tokenId;
    }

    struct Seed {
        bytes32 chainSeed;
        uint256 serialId;
        bytes32 revealed;
    }

    struct Commitment {
        bytes32 seed;
        bytes32 salt;
    }

    error AlreadySeeded();
    error NoReq();
    error OOR();

    event RandomizerGenerate(uint256 tokenId, Seed seed);
    event RandomizerReveal(uint256 tokenId, bytes32 seed);

    function commit(bytes32 _seed, bytes32 _salt) external;

    function generate(uint256 _tokenId) external;

    function reveal(TokenKey[] memory _tokenList, bytes32 _seed) external;

    function getTokenKey(address _issuer, uint256 _tokenId) external pure returns (bytes32);
}
