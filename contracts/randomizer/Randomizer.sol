// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {AuthorizedCaller} from "contracts/admin/AuthorizedCaller.sol";
import {IRandomizer} from "contracts/interfaces/IRandomizer.sol";

/// @title Randomizer
/// @notice See documentation in {IRandomizer}
contract Randomizer is AuthorizedCaller, IRandomizer {
    IRandomizer.Commitment private commitment;
    uint256 private countRequested;
    uint256 private countRevealed;
    mapping(bytes32 => IRandomizer.Seed) private seeds;

    constructor(bytes32 _seed, bytes32 _salt) {
        commitment.seed = _seed;
        commitment.salt = _salt;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(AUTHORIZED_CALLER, msg.sender);
    }

    function generate(uint256 _tokenId) external {
        bytes32 hashedKey = getTokenKey(msg.sender, _tokenId);
        IRandomizer.Seed storage storedSeed = seeds[hashedKey];
        if (storedSeed.revealed != bytes32(0)) revert AlreadySeeded();

        bytes memory base = abi.encode(block.timestamp, hashedKey);
        storedSeed.chainSeed = keccak256(base);
        storedSeed.serialId = ++countRequested;

        emit RandomizerGenerate(_tokenId, storedSeed);
    }

    function reveal(
        TokenKey[] memory _tokenList,
        bytes32 _seed
    ) external onlyRole(AUTHORIZED_CALLER) {
        uint256 expectedSerialId = setTokenSeedAndReturnSerial(_tokenList[0], _seed);
        bytes32 oracleSeed = iterateOracleSeed(_seed);
        uint256 length = _tokenList.length;
        for (uint256 i = 1; i < length; ++i) {
            expectedSerialId--;
            uint256 serialId = setTokenSeedAndReturnSerial(_tokenList[i], oracleSeed);
            if (expectedSerialId != serialId) revert OOR();
            oracleSeed = iterateOracleSeed(oracleSeed);

            emit RandomizerReveal(_tokenList[i].tokenId, oracleSeed);
        }

        if (countRevealed + 1 != expectedSerialId) revert OOR();
        countRevealed += length;

        if (oracleSeed != commitment.seed) revert OOR();
        commitment.seed = _seed;
    }

    function commit(bytes32 _seed, bytes32 _salt) external onlyRole(AUTHORIZED_CALLER) {
        commitment.seed = _seed;
        commitment.salt = _salt;
    }

    function getTokenKey(address _issuer, uint256 _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_issuer, _tokenId));
    }

    function setTokenSeedAndReturnSerial(
        IRandomizer.TokenKey memory _tokenKey,
        bytes32 _oracleSeed
    ) private returns (uint256) {
        Seed storage seed = seeds[getTokenKey(_tokenKey.issuer, _tokenKey.tokenId)];
        if (seed.chainSeed == bytes32(0)) revert NoReq();
        seed.revealed = keccak256(abi.encode(_oracleSeed, seed.chainSeed));
        return seed.serialId;
    }

    function iterateOracleSeed(bytes32 _oracleSeed) private view returns (bytes32) {
        return keccak256(abi.encode(commitment.salt, _oracleSeed));
    }
}
