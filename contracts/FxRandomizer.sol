// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AuthorizedCaller} from "contracts/admin/AuthorizedCaller.sol";
import {IFxRandomizer} from "contracts/interfaces/IFxRandomizer.sol";

/// @title FxRandomizer
/// @notice See documentation in {IFxRandomizer}
contract FxRandomizer is AuthorizedCaller, IFxRandomizer {
    /// @dev Commitment hashes of seed and salt values
    IRandomizer.Commitment private commitment;
    /// @dev Current counter of requested seeds
    uint256 private countRequested;
    /// @dev Current counter of revealed seeds
    uint256 private countRevealed;
    /// @dev Mapping of token key to randomizer seed struct
    mapping(bytes32 => IRandomizer.Seed) private seeds;

    /// @dev Initializes commitment values and sets up user roles
    constructor(bytes32 _seed, bytes32 _salt) {
        commitment.seed = _seed;
        commitment.salt = _salt;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(AUTHORIZED_CALLER, msg.sender);
    }

    /// @inheritdoc IFxRandomizer
    function generate(uint256 _tokenId) external {
        bytes32 hashedKey = getTokenKey(msg.sender, _tokenId);
        IRandomizer.Seed storage storedSeed = seeds[hashedKey];
        if (storedSeed.revealed != bytes32(0)) revert AlreadySeeded();

        storedSeed.chainSeed = keccak256(abi.encode(block.timestamp, hashedKey));
        storedSeed.serialId = ++countRequested;

        emit RandomizerGenerate(_tokenId, storedSeed);
    }

    /// @inheritdoc IFxRandomizer
    function reveal(
        TokenKey[] memory _tokenList,
        bytes32 _seed
    ) external onlyRole(AUTHORIZED_CALLER) {
        uint256 expectedSerialId = setTokenSeed(_tokenList[0], _seed);
        bytes32 oracleSeed = iterateOracleSeed(_seed);
        uint256 length = _tokenList.length;
        unchecked {
            for (uint256 i = 1; i < length; ++i) {
                expectedSerialId--;
                uint256 serialId = setTokenSeed(_tokenList[i], oracleSeed);
                if (expectedSerialId != serialId) revert OutOfRange();
                oracleSeed = iterateOracleSeed(oracleSeed);

                emit RandomizerReveal(_tokenList[i].tokenId, oracleSeed);
            }
        }

        if (countRevealed + 1 != expectedSerialId) revert OutOfRange();
        countRevealed += length;

        if (oracleSeed != commitment.seed) revert OutOfRange();
        commitment.seed = _seed;
    }

    /// @inheritdoc IFxRandomizer
    function commit(bytes32 _seed, bytes32 _salt) external onlyRole(AUTHORIZED_CALLER) {
        commitment.seed = _seed;
        commitment.salt = _salt;
    }

    /// @inheritdoc IFxRandomizer
    function getTokenKey(address _issuer, uint256 _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_issuer, _tokenId));
    }

    /// @dev Sets the token seed and returns the serial ID
    function setTokenSeed(
        IRandomizer.TokenKey memory _tokenKey,
        bytes32 _oracleSeed
    ) private returns (uint256) {
        Seed storage seed = seeds[getTokenKey(_tokenKey.issuer, _tokenKey.tokenId)];
        if (seed.chainSeed == bytes32(0)) revert NoReq();
        seed.revealed = keccak256(abi.encode(_oracleSeed, seed.chainSeed));
        return seed.serialId;
    }

    /// @dev Generates hash of committment salt and oracle seed
    function iterateOracleSeed(bytes32 _oracleSeed) private view returns (bytes32) {
        return keccak256(abi.encode(commitment.salt, _oracleSeed));
    }
}
